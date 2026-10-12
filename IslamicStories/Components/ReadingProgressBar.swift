import SwiftUI

public struct ReadingProgressBar: View {
    public var progress: Double // 0.0 to 1.0
    public var height: CGFloat = 4
    public var showPercentage: Bool = false
    
    public init(progress: Double, height: CGFloat = 4, showPercentage: Bool = false) {
        self.progress = max(0.0, min(1.0, progress))
        self.height = height
        self.showPercentage = showPercentage
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(AppColors.divider)
                        .frame(height: height)
                    
                    // Filled Progress
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [AppColors.antiqueGold, AppColors.emeraldGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * CGFloat(progress)), height: height)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: height)
            
            if showPercentage {
                HStack {
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(AppTypography.caption())
                        .foregroundColor(AppColors.secondaryText)
                }
            }
        }
    }
}
