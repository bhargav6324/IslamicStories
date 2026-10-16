import SwiftUI
import StoreKit

/// Hard Subscription Paywall powered by StoreKit 2.
/// Fully gates the application until an active, verified auto-renewable subscription entitlement is present.
public struct PaywallView: View {
    @Bindable private var subscriptionManager = SubscriptionManager.shared
    @State private var languageManager = LanguageManager.shared
    
    @State private var showingTermsSheet: Bool = false
    @State private var showingPrivacySheet: Bool = false
    @State private var showingRestoreAlert: Bool = false
    @State private var showingErrorAlert: Bool = false
    
    private var isArabic: Bool {
        languageManager.isArabic
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            AppColors.parchment
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.lg) {
                    
                    // Top Bar: Language toggle
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                languageManager.setLanguage(isArabic ? "en" : "ar")
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "globe")
                                    .font(.system(size: 13))
                                Text(isArabic ? "English" : "العربية")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(AppColors.antiqueGold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppColors.cardBackground)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(AppColors.goldBorder, lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.top, AppSpacing.sm)
                    
                    // Header: Logo emblem & Titles
                    VStack(spacing: AppSpacing.sm) {
                        ZStack {
                            Circle()
                                .fill(AppColors.antiqueGold.opacity(0.12))
                                .frame(width: 80, height: 80)
                                .blur(radius: 8)
                            
                            IslamicPatternView(size: 46, strokeColor: AppColors.antiqueGold, lineWidth: 1.5, opacity: 0.95)
                        }
                        .padding(.bottom, 2)
                        
                        Text(AppStrings.tr(.paywallHeadline, lang: languageManager.selectedLanguage))
                            .font(AppTypography.largeTitle(isArabic: isArabic))
                            .foregroundColor(AppColors.charcoal)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.md)
                        
                        Text(AppStrings.tr(.paywallSubtitle, lang: languageManager.selectedLanguage))
                            .font(AppTypography.subheadline(isArabic: isArabic))
                            .foregroundColor(AppColors.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(AppTypography.recommendedLineSpacing(isArabic: isArabic))
                            .padding(.horizontal, AppSpacing.lg)
                    }
                    
                    // Feature Highlights
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        featureRow(icon: "book.pages.fill", text: AppStrings.tr(.paywallFeature1, lang: languageManager.selectedLanguage))
                        featureRow(icon: "text.book.closed.fill", text: AppStrings.tr(.paywallFeature2, lang: languageManager.selectedLanguage))
                        featureRow(icon: "speaker.wave.2.fill", text: AppStrings.tr(.paywallFeature3, lang: languageManager.selectedLanguage))
                        featureRow(icon: "bookmark.fill", text: AppStrings.tr(.paywallFeature4, lang: languageManager.selectedLanguage))
                        featureRow(icon: "wifi.slash", text: AppStrings.tr(.paywallFeature5, lang: languageManager.selectedLanguage))
                    }
                    .padding(AppSpacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                            .stroke(AppColors.goldBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Product Loading Error Banner with Retry (shown if StoreKit products could not be fetched)
                    if subscriptionManager.productLoadingFailed && (subscriptionManager.annualProduct == nil || subscriptionManager.monthlyProduct == nil) {
                        VStack(spacing: AppSpacing.sm) {
                            HStack(alignment: .top, spacing: AppSpacing.xs) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(AppColors.antiqueGold)
                                Text(AppStrings.tr(.productLoadingError, lang: languageManager.selectedLanguage))
                                    .font(AppTypography.caption(isArabic: isArabic))
                                    .foregroundColor(AppColors.charcoal)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            Button(action: {
                                Task {
                                    await subscriptionManager.loadProducts()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "arrow.clockwise")
                                    Text(AppStrings.tr(.retryAction, lang: languageManager.selectedLanguage))
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(AppColors.emeraldGreen)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(AppColors.emeraldGreen.opacity(0.12))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity)
                        .background(AppColors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                .stroke(AppColors.antiqueGold.opacity(0.4), lineWidth: 1)
                        )
                        .padding(.horizontal, AppSpacing.lg)
                    }
                    
                    // Subscription Selection Cards
                    VStack(spacing: AppSpacing.md) {
                        // Annual Subscription Card (Selected by Default)
                        annualCard
                        
                        // Monthly Subscription Card
                        monthlyCard
                    }
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Error message banner if present
                    if let error = subscriptionManager.lastErrorMessage, !subscriptionManager.productLoadingFailed {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red.opacity(0.8))
                            Text(error)
                                .font(AppTypography.caption(isArabic: isArabic))
                                .foregroundColor(AppColors.charcoal)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                    
                    // Primary Purchase Button (Disabled until real StoreKit products are verified loaded)
                    purchaseButton
                        .padding(.horizontal, AppSpacing.lg)
                    
                    // Disclosures Text
                    Text(AppStrings.tr(.subscriptionDisclosure, lang: languageManager.selectedLanguage))
                        .font(AppTypography.caption(isArabic: isArabic))
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, AppSpacing.xl)
                    
                    // Footer: Restore, Terms of Use, Privacy Policy
                    footerView
                        .padding(.bottom, AppSpacing.xl)
                }
            }
        }
        .task {
            if subscriptionManager.annualProduct == nil || subscriptionManager.monthlyProduct == nil {
                await subscriptionManager.loadProducts()
            }
        }
        .sheet(isPresented: $showingTermsSheet) {
            LegalNoticeModalView(noticeType: .terms, isArabic: isArabic)
        }
        .sheet(isPresented: $showingPrivacySheet) {
            LegalNoticeModalView(noticeType: .privacy, isArabic: isArabic)
        }
        .alert(
            isArabic ? "استعادة المشتريات" : "Restore Purchases",
            isPresented: $showingRestoreAlert,
            actions: {
                Button(AppStrings.tr(.done, lang: languageManager.selectedLanguage), role: .cancel) {
                    subscriptionManager.restoreAlertMessage = nil
                }
            },
            message: {
                Text(subscriptionManager.restoreAlertMessage ?? "")
            }
        )
        .onChange(of: subscriptionManager.restoreAlertMessage) { _, newValue in
            if newValue != nil {
                showingRestoreAlert = true
            }
        }
    }
    
    // MARK: - Feature Highlight Row
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(AppColors.antiqueGold)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.charcoal)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    // MARK: - Annual Subscription Card
    
    private var annualCard: some View {
        let isSelected = subscriptionManager.selectedPlan == .annual
        let savings = subscriptionManager.annualSavingsPercentage
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                subscriptionManager.selectedPlan = .annual
            }
        }) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(alignment: .top) {
                    // Selection indicator
                    ZStack {
                        Circle()
                            .stroke(isSelected ? AppColors.emeraldGreen : AppColors.divider, lineWidth: 2)
                            .frame(width: 22, height: 22)
                        
                        if isSelected {
                            Circle()
                                .fill(AppColors.emeraldGreen)
                                .frame(width: 12, height: 12)
                        }
                    }
                    .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: AppSpacing.xs) {
                            Text(subscriptionManager.annualDisplayName(isArabic: isArabic))
                                .font(AppTypography.headline(isArabic: isArabic))
                                .foregroundColor(AppColors.charcoal)
                            
                            // "Recommended" Badge
                            Text(AppStrings.tr(.recommended, lang: languageManager.selectedLanguage))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(AppColors.charcoal)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(AppColors.antiqueGold.opacity(0.35))
                                .clipShape(Capsule())
                            
                            // "Save 50%" Badge (only shown when confirmed by actual StoreKit product pricing)
                            if let savings = savings, savings > 0 {
                                Text(AppStrings.tr(.savePercent(savings), lang: languageManager.selectedLanguage))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(AppColors.emeraldGreen)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        // Approximate monthly rate
                        if let monthlyEquivalent = subscriptionManager.annualMonthlyEquivalentFormatted {
                            Text(AppStrings.tr(.approxMonthlyRate(monthlyEquivalent), lang: languageManager.selectedLanguage))
                                .font(AppTypography.caption(isArabic: isArabic))
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    // Localized annual price directly from StoreKit
                    VStack(alignment: .trailing, spacing: 1) {
                        if let price = subscriptionManager.annualPriceDisplay {
                            Text(price)
                                .font(.system(size: 19, weight: .bold, design: .serif))
                                .foregroundColor(AppColors.charcoal)
                            
                            Text(AppStrings.tr(.perYear, lang: languageManager.selectedLanguage))
                                .font(AppTypography.caption(isArabic: isArabic))
                                .foregroundColor(AppColors.secondaryText)
                        } else if subscriptionManager.isLoadingProducts {
                            ProgressView()
                                .scaleEffect(0.8)
                                .frame(height: 22)
                        } else {
                            Text("—")
                                .font(AppTypography.headline())
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .fill(isSelected ? AppColors.cardBackground : AppColors.cardBackground.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(
                        isSelected ? AppColors.emeraldGreen : AppColors.divider,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .overlay(
                // Subtle gold corner accent when selected
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(isSelected ? AppColors.antiqueGold.opacity(0.4) : Color.clear, lineWidth: 1)
                    .padding(2)
            )
            .shadow(
                color: isSelected ? AppColors.emeraldGreen.opacity(0.12) : Color.clear,
                radius: 8,
                x: 0,
                y: 3
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Monthly Subscription Card
    
    private var monthlyCard: some View {
        let isSelected = subscriptionManager.selectedPlan == .monthly
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                subscriptionManager.selectedPlan = .monthly
            }
        }) {
            HStack(alignment: .center) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppColors.emeraldGreen : AppColors.divider, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    
                    if isSelected {
                        Circle()
                            .fill(AppColors.emeraldGreen)
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text(subscriptionManager.monthlyDisplayName(isArabic: isArabic))
                    .font(AppTypography.headline(isArabic: isArabic))
                    .foregroundColor(AppColors.charcoal)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 1) {
                    if let price = subscriptionManager.monthlyPriceDisplay {
                        Text(price)
                            .font(.system(size: 17, weight: .bold, design: .serif))
                            .foregroundColor(AppColors.charcoal)
                        
                        Text(AppStrings.tr(.perMonth, lang: languageManager.selectedLanguage))
                            .font(AppTypography.caption(isArabic: isArabic))
                            .foregroundColor(AppColors.secondaryText)
                    } else if subscriptionManager.isLoadingProducts {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(height: 20)
                    } else {
                        Text("—")
                            .font(AppTypography.headline())
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .fill(isSelected ? AppColors.cardBackground : AppColors.cardBackground.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(
                        isSelected ? AppColors.emeraldGreen : AppColors.divider,
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(
                color: isSelected ? AppColors.emeraldGreen.opacity(0.12) : Color.clear,
                radius: 8,
                x: 0,
                y: 3
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Primary Purchase CTA Button
    
    private var purchaseButton: some View {
        let hasProducts = subscriptionManager.annualProduct != nil && subscriptionManager.monthlyProduct != nil
        
        return Button(action: {
            Task {
                await subscriptionManager.purchase(plan: subscriptionManager.selectedPlan)
            }
        }) {
            ZStack {
                HStack(spacing: AppSpacing.sm) {
                    Text(ctaButtonTitle)
                        .font(.system(size: 17, weight: .semibold))
                    
                    if hasProducts && !subscriptionManager.isPurchasing {
                        Image(systemName: isArabic ? "arrow.left" : "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .opacity(subscriptionManager.isPurchasing ? 0 : 1)
                
                if subscriptionManager.isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: hasProducts
                        ? [AppColors.emeraldGreen, AppColors.lightEmerald]
                        : [AppColors.secondaryText.opacity(0.5), AppColors.secondaryText.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(hasProducts ? AppColors.antiqueGold.opacity(0.6) : Color.clear, lineWidth: 1)
            )
            .shadow(color: hasProducts ? AppColors.emeraldGreen.opacity(0.3) : Color.clear, radius: 14, x: 0, y: 5)
        }
        .disabled(!hasProducts || subscriptionManager.isPurchasing || subscriptionManager.isRestoring || subscriptionManager.isLoadingProducts)
    }
    
    private var ctaButtonTitle: String {
        if subscriptionManager.isLoadingProducts {
            return AppStrings.tr(.loadingPrices, lang: languageManager.selectedLanguage)
        }
        guard subscriptionManager.annualProduct != nil && subscriptionManager.monthlyProduct != nil else {
            return AppStrings.tr(.continueAction, lang: languageManager.selectedLanguage)
        }
        switch subscriptionManager.selectedPlan {
        case .annual:
            return AppStrings.tr(.continueWithAnnual, lang: languageManager.selectedLanguage)
        case .monthly:
            return AppStrings.tr(.continueWithMonthly, lang: languageManager.selectedLanguage)
        }
    }
    
    // MARK: - Footer (Restore, Terms, Privacy)
    
    private var footerView: some View {
        VStack(spacing: AppSpacing.md) {
            // Restore Purchases Button
            Button(action: {
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }) {
                HStack(spacing: 6) {
                    if subscriptionManager.isRestoring {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.emeraldGreen))
                            .scaleEffect(0.8)
                    }
                    Text(AppStrings.tr(.restorePurchases, lang: languageManager.selectedLanguage))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppColors.charcoal)
                }
                .padding(.vertical, 4)
            }
            .disabled(subscriptionManager.isRestoring || subscriptionManager.isPurchasing)
            
            // Legal links (Terms & Privacy)
            HStack(spacing: AppSpacing.lg) {
                Button(action: {
                    showingTermsSheet = true
                }) {
                    Text(AppStrings.tr(.termsOfUse, lang: languageManager.selectedLanguage))
                        .font(AppTypography.caption(isArabic: isArabic))
                        .foregroundColor(AppColors.secondaryText)
                        .underline()
                }
                
                Text("•")
                    .foregroundColor(AppColors.secondaryText)
                
                Button(action: {
                    showingPrivacySheet = true
                }) {
                    Text(AppStrings.tr(.privacyPolicy, lang: languageManager.selectedLanguage))
                        .font(AppTypography.caption(isArabic: isArabic))
                        .foregroundColor(AppColors.secondaryText)
                        .underline()
                }
            }
        }
    }
}
