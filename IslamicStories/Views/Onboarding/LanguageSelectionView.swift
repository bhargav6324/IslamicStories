import SwiftUI

public struct LanguageSelectionView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var languageManager = LanguageManager.shared
    @State private var currentSelection: String
    
    public init() {
        let initial = LanguageManager.shared.selectedLanguage
        self._currentSelection = State(initialValue: initial)
    }
    
    private var isArabic: Bool {
        currentSelection.hasPrefix("ar")
    }
    
    public var body: some View {
        ZStack {
            AppColors.parchment
                .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.lg) {
                Spacer().frame(height: AppSpacing.md)
                
                // Top ornament
                IslamicPatternView(size: 38, strokeColor: AppColors.antiqueGold, opacity: 0.7)
                
                // Headlines
                VStack(spacing: AppSpacing.xs) {
                    Text(isArabic ? "اختر لغتك المفضلة" : "Choose Your Language")
                        .font(AppTypography.largeTitle(isArabic: isArabic))
                        .foregroundColor(AppColors.charcoal)
                        .multilineTextAlignment(.center)
                    
                    Text(isArabic
                         ? "اختر لغة القراءة والتصفح. يمكنك تغيير هذا الخيار في أي وقت من الإعدادات."
                         : "Select your preferred reading language. You can change this anytime in Settings.")
                        .font(AppTypography.subheadline(isArabic: isArabic))
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                }
                
                Spacer().frame(height: AppSpacing.md)
                
                // Selectable Cards
                VStack(spacing: AppSpacing.md) {
                    // Card 1: English
                    LanguageCard(
                        title: "English",
                        nativeSubtitle: "English (US / UK)",
                        code: "en",
                        isSelected: currentSelection == "en",
                        onSelect: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentSelection = "en"
                                languageManager.setLanguage("en")
                            }
                        }
                    )
                    
                    // Card 2: Arabic
                    LanguageCard(
                        title: "العربية",
                        nativeSubtitle: "اللغة العربية الفصحى",
                        code: "ar",
                        isSelected: currentSelection == "ar",
                        onSelect: {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                currentSelection = "ar"
                                languageManager.setLanguage("ar")
                            }
                        }
                    )
                }
                .padding(.horizontal, AppSpacing.lg)
                
                Spacer()
                
                // Bottom Button
                Button(action: {
                    languageManager.setLanguage(currentSelection)
                    withAnimation {
                        hasCompletedOnboarding = true
                    }
                }) {
                    HStack(spacing: AppSpacing.sm) {
                        Text(isArabic ? "ابدأ الاستكشاف" : "Begin Exploring")
                            .font(.system(size: 17, weight: .semibold))
                        
                        Image(systemName: "arrow.forward")
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [AppColors.emeraldGreen, AppColors.lightEmerald],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                            .stroke(AppColors.antiqueGold.opacity(0.6), lineWidth: 1)
                    )
                    .shadow(color: AppColors.emeraldGreen.opacity(0.25), radius: 14, x: 0, y: 5)
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.lg)
            }
        }
        .navigationBarBackButtonHidden(false)
    }
}

// MARK: - LanguageCard Component
private struct LanguageCard: View {
    let title: String
    let nativeSubtitle: String
    let code: String
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: AppSpacing.md) {
                // Circular selection check
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppColors.antiqueGold : AppColors.divider, lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    if isSelected {
                        Circle()
                            .fill(AppColors.antiqueGold)
                            .frame(width: 14, height: 14)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 20, weight: isSelected ? .bold : .medium, design: code == "ar" ? .default : .serif))
                        .foregroundColor(isSelected ? AppColors.charcoal : AppColors.charcoal.opacity(0.8))
                    
                    Text(nativeSubtitle)
                        .font(AppTypography.caption())
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                if isSelected {
                    Text(code == "ar" ? "مفعل" : "ACTIVE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppColors.emeraldGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColors.emeraldGreen.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(AppSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .fill(isSelected ? AppColors.cardBackground : AppColors.cardBackground.opacity(0.6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(isSelected ? AppColors.antiqueGold : AppColors.divider, lineWidth: isSelected ? 1.5 : 1)
            )
            .shadow(
                color: isSelected ? AppColors.antiqueGold.opacity(0.12) : Color.clear,
                radius: 10,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(.plain)
    }
}
