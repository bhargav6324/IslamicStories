import SwiftUI

public enum AppColors {
    // MARK: - Core Palette
    
    /// Warm ivory / parchment background
    public static let parchment = Color(light: Color(hex: 0xFBF8F2), dark: Color(hex: 0x141311))
    
    /// Deep charcoal text
    public static let charcoal = Color(light: Color(hex: 0x24221E), dark: Color(hex: 0xF0ECE3))
    
    /// Secondary muted text
    public static let secondaryText = Color(light: Color(hex: 0x6E685F), dark: Color(hex: 0xA8A297))
    
    /// Muted antique gold accent
    public static let antiqueGold = Color(light: Color(hex: 0xC8A951), dark: Color(hex: 0xD8BC68))
    
    /// Deep emerald green accent
    public static let emeraldGreen = Color(light: Color(hex: 0x1E4738), dark: Color(hex: 0x2D6B54))
    
    /// Bright emerald for highlights
    public static let lightEmerald = Color(light: Color(hex: 0x2A5D4B), dark: Color(hex: 0x3D886D))
    
    /// Warm off-white card background
    public static let cardBackground = Color(light: Color(hex: 0xF4EFE4), dark: Color(hex: 0x1E1C19))
    
    /// Secondary card background for nested controls
    public static let secondaryCardBackground = Color(light: Color(hex: 0xEDE6D8), dark: Color(hex: 0x272421))
    
    /// Border & divider tone
    public static let divider = Color(light: Color(hex: 0xE2DAC9), dark: Color(hex: 0x2F2C27))
    
    /// Subtle gold border
    public static let goldBorder = Color(light: Color(hex: 0xE0CD96).opacity(0.4), dark: Color(hex: 0xC8A951).opacity(0.3))
}

// MARK: - Color Hex Initializer & Dynamic Color Helper
extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    init(light: Color, dark: Color) {
        #if canImport(UIKit)
        self.init(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
        #else
        self = light
        #endif
    }
}
