import SwiftUI

public enum ReadingTheme: String, CaseIterable, Identifiable {
    case parchment = "Parchment"
    case classicWhite = "Classic"
    case night = "Obsidian"
    
    public var id: String { rawValue }
    
    public var backgroundColor: Color {
        switch self {
        case .parchment: return Color(hex: 0xFBF8F2)
        case .classicWhite: return Color(hex: 0xFFFFFF)
        case .night: return Color(hex: 0x151515)
        }
    }
    
    public var textColor: Color {
        switch self {
        case .parchment: return Color(hex: 0x24221E)
        case .classicWhite: return Color(hex: 0x111111)
        case .night: return Color(hex: 0xE6E2DA)
        }
    }
    
    public var cardColor: Color {
        switch self {
        case .parchment: return Color(hex: 0xF4EFE4)
        case .classicWhite: return Color(hex: 0xF8F9FA)
        case .night: return Color(hex: 0x202020)
        }
    }
}

public struct ReaderSettingsView: View {
    @AppStorage("readerFontSizeDelta") private var fontSizeDelta: Double = 0.0
    @AppStorage("readerTheme") private var selectedThemeRaw: String = ReadingTheme.parchment.rawValue
    @Environment(\.dismiss) private var dismiss
    
    public let isArabic: Bool
    
    public init(isArabic: Bool = false) {
        self.isArabic = isArabic
    }
    
    private var currentTheme: ReadingTheme {
        ReadingTheme(rawValue: selectedThemeRaw) ?? .parchment
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                // Font Size Section
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(AppStrings.tr(.textSize, lang: LanguageManager.shared.selectedLanguage))
                        .font(AppTypography.headline(isArabic: isArabic))
                        .foregroundColor(AppColors.charcoal)
                    
                    HStack(spacing: AppSpacing.lg) {
                        Button(action: {
                            if fontSizeDelta > -4 {
                                fontSizeDelta -= 2
                            }
                        }) {
                            Image(systemName: "textformat.size.smaller")
                                .font(.system(size: 18))
                                .frame(width: 44, height: 44)
                                .background(AppColors.secondaryCardBackground)
                                .clipShape(Circle())
                        }
                        .disabled(fontSizeDelta <= -4)
                        
                        Slider(value: $fontSizeDelta, in: -4...8, step: 2)
                            .tint(AppColors.emeraldGreen)
                        
                        Button(action: {
                            if fontSizeDelta < 8 {
                                fontSizeDelta += 2
                            }
                        }) {
                            Image(systemName: "textformat.size.larger")
                                .font(.system(size: 22))
                                .frame(width: 44, height: 44)
                                .background(AppColors.secondaryCardBackground)
                                .clipShape(Circle())
                        }
                        .disabled(fontSizeDelta >= 8)
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                }
                
                // Reading Theme Section
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(AppStrings.tr(.readingTheme, lang: LanguageManager.shared.selectedLanguage))
                        .font(AppTypography.headline(isArabic: isArabic))
                        .foregroundColor(AppColors.charcoal)
                    
                    HStack(spacing: AppSpacing.md) {
                        ForEach(ReadingTheme.allCases) { theme in
                            ThemeButton(
                                theme: theme,
                                isSelected: currentTheme == theme,
                                isArabic: isArabic,
                                onSelect: {
                                    selectedThemeRaw = theme.rawValue
                                }
                            )
                        }
                    }
                }
                
                Spacer()
            }
            .padding(AppSpacing.lg)
            .background(AppColors.parchment)
            .navigationTitle(AppStrings.tr(.readingOptions, lang: LanguageManager.shared.selectedLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(AppStrings.tr(.done, lang: LanguageManager.shared.selectedLanguage)) {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppColors.emeraldGreen)
                }
            }
        }
        .presentationDetents([.height(300)])
    }
}

private struct ThemeButton: View {
    let theme: ReadingTheme
    let isSelected: Bool
    let isArabic: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .fill(theme.backgroundColor)
                        .frame(height: 54)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                .stroke(isSelected ? AppColors.antiqueGold : AppColors.divider, lineWidth: isSelected ? 2 : 1)
                        )
                    
                    Text("Aa")
                        .font(.system(size: 18, weight: .semibold, design: .serif))
                        .foregroundColor(theme.textColor)
                }
                
                Text(themeTitle)
                    .font(AppTypography.caption(isArabic: isArabic))
                    .foregroundColor(isSelected ? AppColors.charcoal : AppColors.secondaryText)
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
    
    private var themeTitle: String {
        switch theme {
        case .parchment: return isArabic ? "مخطوطة" : "Parchment"
        case .classicWhite: return isArabic ? "أبيض" : "Classic"
        case .night: return isArabic ? "ليلي" : "Obsidian"
        }
    }
}
