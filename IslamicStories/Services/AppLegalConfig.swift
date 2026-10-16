import Foundation
import SwiftUI

/// Central configuration for legal terms, privacy policies, and subscription compliance URLs.
public enum AppLegalConfig {
    /// Terms of Use (EULA) URL.
    ///
    /// IMPORTANT: Configure with your live production terms URL prior to App Store Connect submission.
    /// Default fallback is Apple's standard Licensed Application End User License Agreement:
    /// https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
    public static var termsOfUseURL: URL? {
        if let custom = configuredTermsURL {
            return custom
        }
        return URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
    }
    
    /// Privacy Policy URL.
    ///
    /// IMPORTANT: Configure with your hosted privacy policy URL prior to App Store Connect submission.
    public static var privacyPolicyURL: URL? {
        configuredPrivacyURL
    }
    
    // MARK: - Internal Configured Overrides
    
    /// Set your organization's custom terms URL here when deployed.
    public static let configuredTermsURL: URL? = nil
    
    /// Set your organization's hosted privacy policy URL here when deployed.
    public static let configuredPrivacyURL: URL? = nil
}

/// Fallback view displaying standard subscription terms & disclosures if external web viewing is unavailable.
public struct LegalNoticeModalView: View {
    public enum NoticeType {
        case terms
        case privacy
    }
    
    public let noticeType: NoticeType
    public let isArabic: Bool
    @Environment(\.dismiss) private var dismiss
    
    public init(noticeType: NoticeType, isArabic: Bool = false) {
        self.noticeType = noticeType
        self.isArabic = isArabic
    }
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.parchment
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        IslamicPatternView(size: 32, strokeColor: AppColors.antiqueGold)
                            .frame(maxWidth: .infinity)
                            .padding(.top, AppSpacing.sm)
                        
                        Text(title)
                            .font(AppTypography.title2(isArabic: isArabic))
                            .foregroundColor(AppColors.charcoal)
                        
                        Text(bodyText)
                            .font(AppTypography.readerBody(sizeDelta: -2, isArabic: isArabic))
                            .foregroundColor(AppColors.secondaryText)
                            .lineSpacing(AppTypography.recommendedLineSpacing(isArabic: isArabic))
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isArabic ? "إغلاق" : "Close") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.emeraldGreen)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private var title: String {
        switch noticeType {
        case .terms:
            return isArabic ? "شروط الاستخدام" : "Terms of Use (EULA)"
        case .privacy:
            return isArabic ? "سياسة الخصوصية" : "Privacy Policy"
        }
    }
    
    private var bodyText: String {
        switch noticeType {
        case .terms:
            if isArabic {
                return """
                شروط استخدام تطبيق السيرة والتاريخ الإسلامي (IslamicStories):
                
                1. الاشتراكات والفوترة:
                - يتم توفير الوصول الكامل لجميع محتويات السيرة النبوية والميزات الصوتية من خلال اشتراك قابل للتجديد تلقائياً (شهري أو سنوي).
                - يتم خصم المبلغ من حساب Apple الخاص بك عند تأكيد عملية الشراء.
                - يتجدد الاشتراك تلقائياً ما لم يتم إيقاف التجديد التلقائي قبل 24 ساعة على الأقل من نهاية الفترة الحالية.
                - يتم خصم رسوم التجديد خلال الـ 24 ساعة السابقة لنهاية الفترة الحالية وفقاً للسعر المحدد للاشتراك.
                
                2. الإلغاء وإدارة الاشتراكات:
                - يمكنك إدارة اشتراكك أو إلغاء التجديد التلقائي في أي وقت عبر إعدادات حساب Apple الخاص بك في جهازك.
                - لا يتم استرداد المبالغ عن الأيام المتبقية في فترة الاشتراك الحالية، ويبقى الوصول متاحاً حتى انتهاء الفترة المدفوعة.
                
                3. حقوق الملكية الفكرية:
                - جميع النصوص والسير والمحتويات الأدبية والتصاميم محمية بموجب حقوق النشر. لا يجوز نسخ أو إعادة توزيع المحتوى تجارياً دون إذن خطي مسبق.
                """
            } else {
                return """
                IslamicStories Terms of Use (EULA):
                
                1. Subscriptions & Billing:
                - Access to all 80 Seerah chapters, historical biographies, and synthesized audio narration requires an active auto-renewable subscription (Monthly or Annual).
                - Payment will be charged to your Apple Account at confirmation of purchase.
                - Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current billing cycle.
                - Your account will be charged for renewal within 24 hours prior to the end of the current period at the rate of the selected plan.
                
                2. Managing & Canceling:
                - You can manage or cancel your subscription at any time by going to your Apple Account Settings on your device.
                - If you cancel, your subscription access continues until the end of the current paid billing period.
                
                3. Content & Intellectual Property:
                - All written biographical stories, curated historical adaptations, translations, and illustrations are the property of IslamicStories. Unauthorized copying, distribution, or commercial exploitation is prohibited.
                """
            }
        case .privacy:
            if isArabic {
                return """
                سياسة الخصوصية لتطبيق IslamicStories:
                
                1. جمع البيانات والخصوصية:
                - نحن نحترم خصوصيتك احتراماً تاماً. لا يقوم تطبيق IslamicStories بجمع أو تخزين أي بيانات شخصية أو معلومات بطاقات ائتمان أو حسابات مصرفية.
                
                2. المشتريات والمدفوعات:
                - تتم جميع المعاملات المالية ومعالجة الاشتراكات بصورة آمنة ومباشرة عبر نظام Apple الرسمي (StoreKit 2).
                
                3. البيانات المحلية:
                - يتم تخزين تفضيلات القراءة، والإشارات المرجعية، وتقدم القراءة محلياً على جهازك فقط عبر تقنية SwiftData ولا يتم إرسالها إلى أي خوادم خارجية.
                """
            } else {
                return """
                IslamicStories Privacy Policy:
                
                1. Data Privacy:
                - We deeply respect your privacy. IslamicStories does not collect, track, or share your personal data, contacts, or browsing history.
                
                2. Payment & Purchases:
                - All financial transactions and subscription entitlements are handled directly, securely, and exclusively by Apple via StoreKit 2. We never have access to your payment credentials or credit card numbers.
                
                3. Local Storage:
                - Your reading progress, bookmarks, and font preferences are stored strictly locally on your device via SwiftData and are never transmitted to external third-party tracking services.
                """
            }
        }
    }
}
