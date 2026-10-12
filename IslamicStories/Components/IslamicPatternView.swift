import SwiftUI

/// A subtle, mathematically constructed 8-pointed Islamic geometric star motif
/// to provide peaceful, authentic decorative accents inspired by classical architecture.
public struct IslamicPatternView: View {
    public var size: CGFloat = 40
    public var strokeColor: Color = AppColors.antiqueGold
    public var lineWidth: CGFloat = 1.0
    public var opacity: Double = 0.5
    
    public init(
        size: CGFloat = 40,
        strokeColor: Color = AppColors.antiqueGold,
        lineWidth: CGFloat = 1.0,
        opacity: Double = 0.5
    ) {
        self.size = size
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.opacity = opacity
    }
    
    public var body: some View {
        ZStack {
            // First square
            RoundedRectangle(cornerRadius: size * 0.08)
                .stroke(strokeColor.opacity(opacity), lineWidth: lineWidth)
                .frame(width: size, height: size)
            
            // Second square rotated 45 degrees to form 8-point star (Khatam)
            RoundedRectangle(cornerRadius: size * 0.08)
                .stroke(strokeColor.opacity(opacity), lineWidth: lineWidth)
                .frame(width: size, height: size)
                .rotationEffect(.degrees(45))
            
            // Inner subtle concentric circle
            Circle()
                .stroke(strokeColor.opacity(opacity * 0.7), lineWidth: lineWidth * 0.8)
                .frame(width: size * 0.55, height: size * 0.55)
            
            // Central jewel dot
            Circle()
                .fill(strokeColor.opacity(opacity * 0.9))
                .frame(width: size * 0.12, height: size * 0.12)
        }
    }
}

/// A delicate horizontal divider with an Islamic star motif at the center
public struct IslamicDivider: View {
    public var title: String? = nil
    
    public init(title: String? = nil) {
        self.title = title
    }
    
    public var body: some View {
        HStack(spacing: AppSpacing.md) {
            line
            
            IslamicPatternView(size: 20, strokeColor: AppColors.antiqueGold, opacity: 0.7)
            
            if let title = title {
                Text(title)
                    .font(AppTypography.caption())
                    .foregroundColor(AppColors.secondaryText)
                
                IslamicPatternView(size: 20, strokeColor: AppColors.antiqueGold, opacity: 0.7)
            }
            
            line
        }
        .padding(.vertical, AppSpacing.sm)
    }
    
    private var line: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [AppColors.antiqueGold.opacity(0.1), AppColors.antiqueGold.opacity(0.4), AppColors.antiqueGold.opacity(0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
}
