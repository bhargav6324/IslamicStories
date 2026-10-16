import Foundation
import StoreKit
import Observation

/// Available subscription duration options.
public enum SubscriptionPlan: String, CaseIterable, Identifiable {
    case annual
    case monthly
    
    public var id: String { rawValue }
    
    public var productID: String {
        switch self {
        case .annual:
            return SubscriptionManager.annualProductID
        case .monthly:
            return SubscriptionManager.monthlyProductID
        }
    }
}

/// Lifecycle states of the hard subscription paywall and entitlement status.
public enum SubscriptionState: Equatable {
    /// App launch check verifying StoreKit entitlements.
    case loading
    /// Verified active subscription entitlement exists.
    case subscribed
    /// No active subscription. Hard paywall must be displayed.
    case notSubscribed
    /// Purchase is pending external authorization (e.g., Ask to Buy).
    case purchasePending
    /// Recoverable error with descriptive message.
    case error(String)
}

/// Centralized, production-ready StoreKit 2 entitlement coordinator.
@Observable
@MainActor
public final class SubscriptionManager {
    public static let shared = SubscriptionManager()
    
    // MARK: - App Store Connect Product & Group Identifiers
    
    public static let monthlyProductID = "com.islamicstories.premium.monthly"
    public static let annualProductID = "com.islamicstories.premium.annual"
    public static let subscriptionGroupID = "22483276"
    
    // MARK: - Observable State
    
    public private(set) var state: SubscriptionState = .loading
    public private(set) var monthlyProduct: Product? = nil
    public private(set) var annualProduct: Product? = nil
    public var selectedPlan: SubscriptionPlan = .annual
    
    public private(set) var isPurchasing: Bool = false
    public private(set) var isRestoring: Bool = false
    public private(set) var isLoadingProducts: Bool = false
    public private(set) var productLoadingFailed: Bool = false
    
    public private(set) var activeTransaction: StoreKit.Transaction? = nil
    public private(set) var activeSubscriptionStatus: Product.SubscriptionInfo.Status? = nil
    
    public var lastErrorMessage: String? = nil
    public var restoreAlertMessage: String? = nil
    
    // MARK: - Initialization
    
    private init() {
        // Start listening to background transaction updates (renewals, revocations, family sharing)
        startTransactionUpdatesListener()
        
        // Initial setup & entitlement verification
        Task {
            await loadProducts()
            await checkEntitlements()
        }
    }
    
    // MARK: - Transaction Updates Observer
    
    private func startTransactionUpdatesListener() {
        Task.detached(priority: .background) { [weak self] in
            for await result in StoreKit.Transaction.updates {
                guard let self = self else { return }
                await self.handleIncomingTransactionUpdate(result)
            }
        }
    }
    
    private func handleIncomingTransactionUpdate(_ result: VerificationResult<StoreKit.Transaction>) async {
        switch result {
        case .verified(let transaction):
            // Check if transaction belongs to our subscription products
            guard transaction.productID == Self.monthlyProductID || transaction.productID == Self.annualProductID else {
                return
            }
            
            // Finish transaction with StoreKit
            await transaction.finish()
            
            // Re-verify full entitlement state on the main actor
            await checkEntitlements()
            
        case .unverified(_, let error):
            // Do not grant access for unverified transactions
            #if DEBUG
            print("[StoreKit] Unverified transaction update: \(error.localizedDescription)")
            #endif
        }
    }
    
    // MARK: - Product Loading
    
    /// Queries real StoreKit 2 products from Apple's servers using official identifiers.
    public func loadProducts() async {
        isLoadingProducts = true
        productLoadingFailed = false
        lastErrorMessage = nil
        defer { isLoadingProducts = false }
        
        do {
            let productIDs = [Self.monthlyProductID, Self.annualProductID]
            let loaded = try await Product.products(for: productIDs)
            
            for product in loaded {
                if product.id == Self.monthlyProductID {
                    self.monthlyProduct = product
                } else if product.id == Self.annualProductID {
                    self.annualProduct = product
                }
            }
            
            if self.monthlyProduct == nil || self.annualProduct == nil {
                self.productLoadingFailed = true
                #if DEBUG
                print("[StoreKit] Incomplete products loaded from Apple. Loaded count: \(loaded.count)")
                #endif
            } else {
                self.productLoadingFailed = false
            }
        } catch {
            self.productLoadingFailed = true
            self.lastErrorMessage = AppStrings.tr(.productLoadingError)
            #if DEBUG
            print("[StoreKit] Failed to load products from Apple: \(error.localizedDescription)")
            #endif
        }
    }
    
    // MARK: - Entitlement Verification
    
    /// Verifies current entitlements using Apple's cryptographic StoreKit 2 verification.
    /// Operates offline using StoreKit's locally cached signed receipts.
    public func checkEntitlements() async {
        var foundValidSubscription = false
        var newestTransaction: StoreKit.Transaction? = nil
        
        for await result in StoreKit.Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                // Ensure product ID matches our subscription products
                guard transaction.productID == Self.monthlyProductID || transaction.productID == Self.annualProductID else {
                    continue
                }
                
                // Ensure transaction has not been revoked or refunded
                guard transaction.revocationDate == nil else {
                    continue
                }
                
                // An active subscription remains active until the paid entitlement actually ends,
                // even if auto-renewal has been canceled.
                if let expiration = transaction.expirationDate {
                    if expiration > Date() {
                        foundValidSubscription = true
                        if newestTransaction == nil || expiration > (newestTransaction?.expirationDate ?? .distantPast) {
                            newestTransaction = transaction
                        }
                    }
                } else {
                    // Non-expiring entitlement
                    foundValidSubscription = true
                    newestTransaction = transaction
                }
                
            case .unverified(_, let error):
                #if DEBUG
                print("[StoreKit] Unverified entitlement skipped: \(error.localizedDescription)")
                #endif
                continue
            }
        }
        
        // Also check Product.SubscriptionInfo.Status if products are loaded to honor billing grace period
        if let annualProduct = annualProduct, let statusList = try? await annualProduct.subscription?.status {
            for status in statusList {
                if status.state == .subscribed || status.state == .inGracePeriod {
                    foundValidSubscription = true
                    self.activeSubscriptionStatus = status
                    break
                }
            }
        }
        if !foundValidSubscription, let monthlyProduct = monthlyProduct, let statusList = try? await monthlyProduct.subscription?.status {
            for status in statusList {
                if status.state == .subscribed || status.state == .inGracePeriod {
                    foundValidSubscription = true
                    self.activeSubscriptionStatus = status
                    break
                }
            }
        }
        
        self.activeTransaction = newestTransaction
        
        if foundValidSubscription {
            self.state = .subscribed
            self.lastErrorMessage = nil
        } else {
            self.state = .notSubscribed
        }
    }
    
    // MARK: - Purchase Flow
    
    /// Starts a purchase for the selected plan via Apple's official purchase sheet.
    /// Returns true if successfully verified.
    @discardableResult
    public func purchase(plan: SubscriptionPlan) async -> Bool {
        guard !isPurchasing else { return false }
        
        let productToPurchase = (plan == .annual) ? annualProduct : monthlyProduct
        guard let product = productToPurchase else {
            // Products might still be loading, attempt to load first
            await loadProducts()
            let retryProduct = (plan == .annual) ? annualProduct : monthlyProduct
            guard let retryProduct = retryProduct else {
                let msg = AppStrings.tr(.productLoadingError)
                self.lastErrorMessage = msg
                return false
            }
            return await executePurchase(product: retryProduct)
        }
        
        return await executePurchase(product: product)
    }
    
    private func executePurchase(product: Product) async -> Bool {
        isPurchasing = true
        lastErrorMessage = nil
        
        defer {
            isPurchasing = false
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    // Finish the transaction with Apple
                    await transaction.finish()
                    
                    // Verify revocation & expiration
                    if transaction.revocationDate == nil {
                        self.activeTransaction = transaction
                        self.state = .subscribed
                        self.lastErrorMessage = nil
                        return true
                    } else {
                        self.state = .notSubscribed
                        self.lastErrorMessage = AppStrings.tr(.purchaseError)
                        return false
                    }
                    
                case .unverified(_, let error):
                    self.state = .notSubscribed
                    self.lastErrorMessage = AppStrings.tr(.unverifiedTransaction)
                    #if DEBUG
                    print("[StoreKit] Purchase transaction unverified: \(error.localizedDescription)")
                    #endif
                    return false
                }
                
            case .userCancelled:
                // User dismissed purchase sheet without buying.
                // Stay on paywall calmly, do not display an alarming error.
                if self.state != .subscribed {
                    self.state = .notSubscribed
                }
                return false
                
            case .pending:
                // Purchase requires external authorization (e.g. Ask to Buy)
                self.state = .purchasePending
                self.lastErrorMessage = AppStrings.tr(.purchasePending)
                return false
                
            @unknown default:
                self.state = .notSubscribed
                return false
            }
        } catch {
            self.state = .notSubscribed
            self.lastErrorMessage = AppStrings.tr(.purchaseError)
            return false
        }
    }
    
    // MARK: - Restore Purchases
    
    /// Restores prior purchases by explicitly syncing with the App Store.
    /// Only called in response to user interaction.
    public func restorePurchases() async {
        guard !isRestoring else { return }
        isRestoring = true
        restoreAlertMessage = nil
        
        do {
            try await AppStore.sync()
            await checkEntitlements()
            
            if self.state == .subscribed {
                self.restoreAlertMessage = AppStrings.tr(.restoreSuccess)
            } else {
                self.restoreAlertMessage = AppStrings.tr(.restoreNotFound)
            }
        } catch {
            #if DEBUG
            print("[StoreKit] Restore failed: \(error.localizedDescription)")
            #endif
            self.restoreAlertMessage = AppStrings.tr(.restoreNotFound)
        }
        
        isRestoring = false
    }
    
    // MARK: - Pricing & Discount Helpers
    
    /// Calculates the verified annual discount percentage compared to 12 months of the monthly price.
    /// Returns an integer (e.g., 50) ONLY if confirmed by actual StoreKit product pricing.
    /// Returns nil if monthly or annual product is missing, or if prices do not confirm a discount.
    public var annualSavingsPercentage: Int? {
        guard let annual = annualProduct, let monthly = monthlyProduct else {
            return nil
        }
        
        let annualPrice = annual.price
        let monthlyPrice = monthly.price
        
        guard monthlyPrice > 0 else { return nil }
        
        let regularFullYear = monthlyPrice * 12
        guard annualPrice < regularFullYear else { return nil }
        
        let discountDecimal = (1.0 - (annualPrice / regularFullYear)) * 100
        let percentage = NSDecimalNumber(decimal: discountDecimal).doubleValue.rounded()
        return Int(percentage)
    }
    
    /// Localized monthly equivalent price for the annual plan (e.g. "₹500.00" or "$5.83").
    public var annualMonthlyEquivalentFormatted: String? {
        guard let annual = annualProduct else { return nil }
        let perMonthDecimal = annual.price / 12
        return perMonthDecimal.formatted(annual.priceFormatStyle)
    }
    
    /// Real display price for the annual plan directly from StoreKit (e.g. "₹6,000.00"), or nil if not loaded.
    public var annualPriceDisplay: String? {
        annualProduct?.displayPrice
    }
    
    /// Real display price for the monthly plan directly from StoreKit (e.g. "₹1,000.00"), or nil if not loaded.
    public var monthlyPriceDisplay: String? {
        monthlyProduct?.displayPrice
    }
    
    /// Real display name from StoreKit (e.g. "IslamicStories Premium Annual"), or localized fallback.
    public func annualDisplayName(isArabic: Bool) -> String {
        if let name = annualProduct?.displayName, !name.isEmpty {
            return name
        }
        return isArabic ? "الاشتراك السنوي" : "Annual Plan"
    }
    
    /// Real display name from StoreKit (e.g. "IslamicStories Premium Monthly"), or localized fallback.
    public func monthlyDisplayName(isArabic: Bool) -> String {
        if let name = monthlyProduct?.displayName, !name.isEmpty {
            return name
        }
        return isArabic ? "الاشتراك الشهري" : "Monthly Plan"
    }
    
    // MARK: - Subscription Metadata for Settings
    
    public func activePlanTitle(isArabic: Bool) -> String? {
        guard let transaction = activeTransaction else { return nil }
        if transaction.productID == Self.annualProductID {
            return isArabic ? "الاشتراك السنوي" : "Annual Plan"
        } else if transaction.productID == Self.monthlyProductID {
            return isArabic ? "الاشتراك الشهري" : "Monthly Plan"
        }
        return isArabic ? "اشتراك نشط" : "Active Subscription"
    }
    
    public var renewalOrExpirationDate: Date? {
        activeTransaction?.expirationDate
    }
    
    public func renewalOrExpirationDescription(locale: Locale) -> String? {
        guard let date = renewalOrExpirationDate else { return nil }
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
