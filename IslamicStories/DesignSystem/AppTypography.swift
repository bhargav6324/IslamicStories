import SwiftUI

public enum AppTypography {
    
    // MARK: - Display & Titles
    
    public static func largeTitle(isArabic: Bool = false) -> Font {
        if isArabic {
            return .system(size: 32, weight: .bold, design: .default)
        } else {
            return .system(size: 34, weight: .bold, design: .serif)
        }
    }
    
    public static func title1(isArabic: Bool = false) -> Font {
        if isArabic {
            return .system(size: 26, weight: .bold, design: .default)
        } else {
            return .system(size: 28, weight: .bold, design: .serif)
        }
    }
    
    public static func title2(isArabic: Bool = false) -> Font {
        if isArabic {
            return .system(size: 22, weight: .semibold, design: .default)
        } else {
            return .system(size: 23, weight: .semibold, design: .serif)
        }
    }
    
    public static func title3(isArabic: Bool = false) -> Font {
        if isArabic {
            return .system(size: 19, weight: .semibold, design: .default)
        } else {
            return .system(size: 20, weight: .semibold, design: .serif)
        }
    }
    
    // MARK: - Verse & Special Calligraphy
    
    public static func quranicVerse(size: CGFloat = 28) -> Font {
        // High-legibility system Arabic font with diacritic support
        return .system(size: size, weight: .medium, design: .serif)
    }
    
    // MARK: - Reader Body Typography
    
    public static func readerBody(sizeDelta: CGFloat = 0, isArabic: Bool = false) -> Font {
        let baseSize: CGFloat = isArabic ? 20 : 18
        let finalSize = max(14, baseSize + sizeDelta)
        if isArabic {
            return .system(size: finalSize, weight: .regular, design: .default)
        } else {
            return .system(size: finalSize, weight: .regular, design: .serif)
        }
    }
    
    public static func readerQuote(sizeDelta: CGFloat = 0, isArabic: Bool = false) -> Font {
        let baseSize: CGFloat = isArabic ? 19 : 17
        let finalSize = max(13, baseSize + sizeDelta)
        if isArabic {
            return .system(size: finalSize, weight: .medium, design: .default)
        } else {
            return .system(size: finalSize, weight: .medium, design: .serif)
        }
    }
    
    // MARK: - Standard UI Typography
    
    public static func headline(isArabic: Bool = false) -> Font {
        return .system(size: isArabic ? 18 : 17, weight: .semibold, design: isArabic ? .default : .serif)
    }
    
    public static func subheadline(isArabic: Bool = false) -> Font {
        return .system(size: isArabic ? 16 : 15, weight: .regular, design: .default)
    }
    
    public static func footnote(isArabic: Bool = false) -> Font {
        return .system(size: isArabic ? 14 : 13, weight: .regular, design: .default)
    }
    
    public static func caption(isArabic: Bool = false) -> Font {
        return .system(size: isArabic ? 12.5 : 12, weight: .regular, design: .default)
    }
    
    // MARK: - Recommended Line Spacing
    
    public static func recommendedLineSpacing(isArabic: Bool = false) -> CGFloat {
        return isArabic ? 5.5 : 3.5
    }
}
