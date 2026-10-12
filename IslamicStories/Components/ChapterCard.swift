import SwiftUI

public struct ChapterCard: View {
    public let chapter: StoryChapter
    public let progress: Double // 0.0 to 1.0
    public let isCompleted: Bool
    public let isBookmarked: Bool
    public let isArabic: Bool
    public let onBookmarkTapped: (() -> Void)?
    
    public init(
        chapter: StoryChapter,
        progress: Double = 0.0,
        isCompleted: Bool = false,
        isBookmarked: Bool = false,
        isArabic: Bool = false,
        onBookmarkTapped: (() -> Void)? = nil
    ) {
        self.chapter = chapter
        self.progress = progress
        self.isCompleted = isCompleted
        self.isBookmarked = isBookmarked
        self.isArabic = isArabic
        self.onBookmarkTapped = onBookmarkTapped
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            // Thumbnail image
            ZStack(alignment: .topLeading) {
                Image(chapter.coverImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.md)
                            .stroke(AppColors.goldBorder, lineWidth: 1)
                    )
                
                // Chapter number badge
                Text(isArabic ? "الفصل \(chapter.chapterNumber)" : "CH \(chapter.chapterNumber)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(AppColors.emeraldGreen.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(6)
            }
            
            // Content
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(chapter.title)
                            .font(AppTypography.headline(isArabic: isArabic))
                            .foregroundColor(AppColors.charcoal)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        
                        Text(chapter.subtitle)
                            .font(AppTypography.footnote(isArabic: isArabic))
                            .foregroundColor(AppColors.antiqueGold)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Bookmark indicator/action
                    if let onBookmarkTapped = onBookmarkTapped {
                        Button(action: onBookmarkTapped) {
                            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 15))
                                .foregroundColor(isBookmarked ? AppColors.antiqueGold : AppColors.secondaryText.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Text(chapter.summary)
                    .font(AppTypography.caption(isArabic: isArabic))
                    .foregroundColor(AppColors.secondaryText)
                    .lineSpacing(AppTypography.recommendedLineSpacing(isArabic: isArabic))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                Spacer(minLength: 4)
                
                // Bottom row: Duration, Progress bar, or Completed badge
                HStack(spacing: AppSpacing.sm) {
                    Label(
                        isArabic ? "\(chapter.estimatedReadingMinutes) دقائق" : "\(chapter.estimatedReadingMinutes) min read",
                        systemImage: "clock"
                    )
                    .font(AppTypography.caption(isArabic: isArabic))
                    .foregroundColor(AppColors.secondaryText)
                    
                    Spacer()
                    
                    if isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.emeraldGreen)
                            Text(isArabic ? "مكتمل" : "Completed")
                                .font(AppTypography.caption(isArabic: isArabic))
                                .foregroundColor(AppColors.emeraldGreen)
                        }
                    } else if progress > 0 {
                        HStack(spacing: AppSpacing.xs) {
                            ReadingProgressBar(progress: progress, height: 4)
                                .frame(width: 50)
                            Text("\(Int(progress * 100))%")
                                .font(AppTypography.caption())
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                .stroke(AppColors.goldBorder, lineWidth: 1)
        )
        .shadow(
            color: AppShadow.subtle().color,
            radius: AppShadow.subtle().radius,
            x: AppShadow.subtle().x,
            y: AppShadow.subtle().y
        )
    }
}
