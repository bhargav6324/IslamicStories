import SwiftUI

public enum AppSpacing {
    /// 4 pt (Extra small)
    public static let xxs: CGFloat = 4
    public static let extraSmall: CGFloat = 4
    
    /// 8 pt (Small)
    public static let xs: CGFloat = 8
    public static let small: CGFloat = 8
    
    /// 12 pt (Medium)
    public static let sm: CGFloat = 12
    public static let medium: CGFloat = 12
    
    /// 16 pt (Standard)
    public static let md: CGFloat = 16
    public static let standard: CGFloat = 16
    
    /// 20 pt
    public static let normal: CGFloat = 20
    
    /// 24 pt (Large)
    public static let lg: CGFloat = 24
    public static let large: CGFloat = 24
    
    /// 32 pt (Extra large)
    public static let xl: CGFloat = 32
    public static let extraLarge: CGFloat = 32
    
    /// 48 pt
    public static let xxl: CGFloat = 48
    /// 64 pt
    public static let huge: CGFloat = 64
}

public enum AppCornerRadius {
    /// 8 pt
    public static let sm: CGFloat = 8
    /// 12 pt
    public static let md: CGFloat = 12
    /// 18 pt
    public static let lg: CGFloat = 18
    /// 24 pt
    public static let xl: CGFloat = 24
    /// 32 pt
    public static let pill: CGFloat = 999
}

public enum AppShadow {
    public static func subtle() -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        (Color.black.opacity(0.06), 12, 0, 4)
    }
    
    public static func card() -> (color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        (Color.black.opacity(0.08), 16, 0, 6)
    }
}
