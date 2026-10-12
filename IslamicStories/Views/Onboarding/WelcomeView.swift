import SwiftUI

public struct WelcomeView: View {
    @Binding var navigationPath: NavigationPath
    @State private var isAnimating: Bool = false
    
    public init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }
    
    public var body: some View {
        ZStack {
            // Warm ivory parchment background
            AppColors.parchment
                .ignoresSafeArea()
            
            // Subtle ambient background illumination
            VStack {
                Circle()
                    .fill(AppColors.antiqueGold.opacity(0.08))
                    .frame(width: 320, height: 320)
                    .blur(radius: 60)
                    .offset(y: -50)
                Spacer()
            }
            .ignoresSafeArea()
            
            VStack(spacing: AppSpacing.lg) {
                Spacer()
                
                // Top geometric Islamic pattern
                VStack(spacing: AppSpacing.sm) {
                    IslamicPatternView(size: 54, strokeColor: AppColors.antiqueGold, lineWidth: 1.5, opacity: 0.85)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.0)
                    
                    Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                        .font(AppTypography.quranicVerse(size: 16))
                        .foregroundColor(AppColors.secondaryText)
                        .opacity(isAnimating ? 0.9 : 0.0)
                }
                
                Spacer().frame(height: AppSpacing.md)
                
                // Centered Quranic Verse from Surah Al-Alaq
                VStack(spacing: AppSpacing.md) {
                    Text("اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ")
                        .font(AppTypography.quranicVerse(size: 32))
                        .foregroundColor(AppColors.charcoal)
                        .multilineTextAlignment(.center)
                        .lineSpacing(12)
                        .padding(.horizontal, AppSpacing.lg)
                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                    
                    Text("Read in the Name of your Lord Who created—")
                        .font(.system(size: 18, weight: .regular, design: .serif))
                        .italic()
                        .foregroundColor(AppColors.antiqueGold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, AppSpacing.lg)
                    
                    Text("Surah Al-Alaq · 96:1")
                        .font(AppTypography.caption())
                        .foregroundColor(AppColors.secondaryText)
                        .tracking(1.5)
                        .textCase(.uppercase)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                
                // Decorative divider
                IslamicDivider()
                    .padding(.horizontal, AppSpacing.xl)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                // Supporting headline
                Text("Discover the stories that shaped history.")
                    .font(AppTypography.title3())
                    .foregroundColor(AppColors.charcoal)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.xl)
                    .opacity(isAnimating ? 1.0 : 0.0)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    navigationPath.append("language_selection")
                }) {
                    HStack(spacing: AppSpacing.sm) {
                        Text("Continue")
                            .font(.system(size: 17, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
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
                    .shadow(color: AppColors.emeraldGreen.opacity(0.3), radius: 16, x: 0, y: 6)
                }
                .padding(.horizontal, AppSpacing.xl)
                .padding(.bottom, AppSpacing.lg)
                .scaleEffect(isAnimating ? 1.0 : 0.95)
                .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
    }
}
