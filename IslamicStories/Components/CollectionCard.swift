import SwiftUI

public struct CollectionCard: View {
    public let collection: StoryCollection
    public let isArabic: Bool
    public var onExplore: (() -> Void)? = nil
    
    public init(
        collection: StoryCollection,
        isArabic: Bool = false,
        onExplore: (() -> Void)? = nil
    ) {
        self.collection = collection
        self.isArabic = isArabic
        self.onExplore = onExplore
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover Image with Gradient Overlay & Badges
            ZStack(alignment: .bottomLeading) {
                Image(collection.coverImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 170)
                    .clipped()
                
                // Dark subtle gradient overlay for text contrast
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.75)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                
                // Badges
                VStack(alignment: .leading, spacing: 4) {
                    if collection.isComingSoon {
                        Text(isArabic ? "قريباً" : "COMING SOON")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.65))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(AppColors.antiqueGold.opacity(0.7), lineWidth: 1))
                    } else {
                        Text(isArabic ? "مجموعة مميزة" : "FEATURED COLLECTION")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppColors.antiqueGold)
                            .tracking(1.0)
                    }
                    
                    Text(collection.title)
                        .font(AppTypography.title2(isArabic: isArabic))
                        .foregroundColor(.white)
                }
                .padding(AppSpacing.md)
            }
            
            // Description & Button section
            VStack(alignment: .leading, spacing: AppSpacing.small) {
                Text(collection.subtitle)
                    .font(AppTypography.subheadline(isArabic: isArabic))
                    .foregroundColor(AppColors.antiqueGold)
                    .fontWeight(.semibold)
                
                Text(collection.description)
                    .font(AppTypography.footnote(isArabic: isArabic))
                    .foregroundColor(AppColors.secondaryText)
                    .lineSpacing(AppTypography.recommendedLineSpacing(isArabic: isArabic))
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(alignment: .center) {
                    if !collection.isComingSoon {
                        HStack(spacing: AppSpacing.extraSmall) {
                            Image(systemName: "book.pages")
                                .font(.system(size: 13))
                            Text(isArabic ? "\(collection.totalChapters) فصول متاحة" : (collection.totalChapters == 1 ? "1 Chapter Available" : "\(collection.totalChapters) Chapters Available"))
                                .font(AppTypography.caption(isArabic: isArabic))
                        }
                        .foregroundColor(AppColors.secondaryText)
                    }
                    
                    Spacer(minLength: AppSpacing.small)
                    
                    if !collection.isComingSoon {
                        HStack(spacing: AppSpacing.extraSmall) {
                            Text(isArabic ? "استكشف المجموعة" : "Explore Collection")
                                .font(.system(size: 13, weight: .semibold))
                            Image(systemName: isArabic ? "arrow.left" : "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                        .foregroundColor(AppColors.emeraldGreen)
                    }
                }
                .padding(.top, AppSpacing.extraSmall)
            }
            .padding(AppSpacing.standard)
            .background(AppColors.cardBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                .stroke(AppColors.goldBorder, lineWidth: 1)
        )
        .shadow(
            color: AppShadow.card().color,
            radius: AppShadow.card().radius,
            x: AppShadow.card().x,
            y: AppShadow.card().y
        )
    }
}
