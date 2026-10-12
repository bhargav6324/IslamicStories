import SwiftUI
import SwiftData

public struct BookmarksView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var languageManager = LanguageManager.shared
    
    @Query(
        filter: #Predicate<ReadingProgress> { progress in
            progress.isBookmarked == true
        },
        sort: \ReadingProgress.lastReadDate,
        order: .reverse
    ) private var bookmarkedRecords: [ReadingProgress]
    
    @State private var selectedChapterForReading: (collectionId: String, chapterNumber: Int)? = nil
    
    private var isArabic: Bool {
        languageManager.isArabic
    }
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ZStack {
                AppColors.parchment
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.large) {
                        
                        // Header
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text(AppStrings.tr(.bookmarksTitle, lang: languageManager.selectedLanguage))
                                .font(AppTypography.largeTitle(isArabic: isArabic))
                                .foregroundColor(AppColors.charcoal)
                                .lineSpacing(isArabic ? 4 : 2)
                            
                            Text(AppStrings.tr(.bookmarksSubtitle, lang: languageManager.selectedLanguage))
                                .font(AppTypography.subheadline(isArabic: isArabic))
                                .foregroundColor(AppColors.secondaryText)
                                .lineSpacing(AppTypography.recommendedLineSpacing(isArabic: isArabic))
                        }
                        .padding(.horizontal, AppSpacing.large)
                        .padding(.top, AppSpacing.medium)
                        
                        if bookmarkedRecords.isEmpty {
                            // Empty State
                            VStack(spacing: AppSpacing.standard) {
                                ZStack {
                                    Circle()
                                        .fill(AppColors.antiqueGold.opacity(0.12))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "bookmark")
                                        .font(.system(size: 36))
                                        .foregroundColor(AppColors.antiqueGold)
                                }
                                .padding(.top, AppSpacing.xxl)
                                
                                Text(AppStrings.tr(.noBookmarksTitle, lang: languageManager.selectedLanguage))
                                    .font(AppTypography.title3(isArabic: isArabic))
                                    .foregroundColor(AppColors.charcoal)
                                
                                Text(AppStrings.tr(.noBookmarksDescription, lang: languageManager.selectedLanguage))
                                    .font(AppTypography.subheadline(isArabic: isArabic))
                                    .foregroundColor(AppColors.secondaryText)
                                    .lineSpacing(AppTypography.recommendedLineSpacing(isArabic: isArabic))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, AppSpacing.extraLarge)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, AppSpacing.large)
                        } else {
                            // List of Bookmarked Chapters
                            VStack(spacing: AppSpacing.standard) {
                                ForEach(bookmarkedRecords) { record in
                                    if let chapter = try? ContentRepository.shared.loadChapter(
                                        collectionId: record.collectionId,
                                        chapterNumber: 1,
                                        languageCode: languageManager.selectedLanguage
                                    ) {
                                        Button(action: {
                                            selectedChapterForReading = (collectionId: chapter.collectionId, chapterNumber: chapter.chapterNumber)
                                        }) {
                                            ChapterCard(
                                                chapter: chapter,
                                                progress: record.scrollRatio,
                                                isCompleted: record.isCompleted,
                                                isBookmarked: true,
                                                isArabic: isArabic,
                                                onBookmarkTapped: {
                                                    toggleBookmark(for: record)
                                                }
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.horizontal, AppSpacing.large)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, AppSpacing.medium)
                }
                .safeAreaPadding(.bottom, 72)
            }
            .navigationDestination(isPresented: Binding(
                get: { selectedChapterForReading != nil },
                set: { if !$0 { selectedChapterForReading = nil } }
            )) {
                if let target = selectedChapterForReading {
                    ChapterReaderView(collectionId: target.collectionId, chapterNumber: target.chapterNumber)
                }
            }
        }
    }
    
    private func toggleBookmark(for record: ReadingProgress) {
        record.isBookmarked.toggle()
        try? modelContext.save()
    }
}
