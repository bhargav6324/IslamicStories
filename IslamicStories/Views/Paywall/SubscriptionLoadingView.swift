import SwiftUI

/// Clean, elegant loading view displayed while verifying existing StoreKit 2 entitlements.
/// Prevents paywall flash for returning active subscribers.
public struct SubscriptionLoadingView: View {
    @State private var languageManager = LanguageManager.shared
    
    private var isArabic: Bool {
        languageManager.isArabic
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppColors.parchment
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.lg) {
                // Ambient glow behind the emblem
                ZStack {
                    Circle()
                        .fill(AppColors.antiqueGold.opacity(0.12))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                    
                    IslamicPatternView(size: 60, strokeColor: AppColors.antiqueGold, lineWidth: 1.5, opacity: 0.9)
                }
                
                VStack(spacing: AppSpacing.xs) {
                    Text(isArabic ? "سيرة النبي محمد ﷺ" : "Islamic Stories")
                        .font(AppTypography.title2(isArabic: isArabic))
                        .foregroundColor(AppColors.charcoal)
                    
                    Text(AppStrings.tr(.subscriptionChecking, lang: languageManager.selectedLanguage))
                        .font(AppTypography.footnote(isArabic: isArabic))
                        .foregroundColor(AppColors.secondaryText)
                }
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.emeraldGreen))
                    .scaleEffect(1.1)
                    .padding(.top, AppSpacing.sm)
            }
        }
    }
}
