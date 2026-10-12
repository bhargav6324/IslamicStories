import SwiftUI
import SwiftData

public struct SeerahCollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var languageManager = LanguageManager.shared
    
    @State private var chapters: [StoryChapter] = []
    @State private var progressStore: ReadingProgressStore? = nil
    @State private var selectedChapterForReading: StoryChapter? = nil
    
    private var isArabic: Bool {
        languageManager.isArabic
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AppColors.parchment
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    
                    // Top Hero Banner
                    ZStack(alignment: .bottomLeading) {
                        Image("SeerahCover")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    colors: [Color.clear, Color.black.opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            Text(isArabic ? "مجموعة السيرة" : "THE SEERAH")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppColors.antiqueGold)
                                .tracking(1.2)
                            
                            Text(isArabic ? "سيرة الحبيب المصطفى ﷺ" : "The Life of Prophet Muhammad ﷺ")
                                .font(AppTypography.largeTitle(isArabic: isArabic))
                                .foregroundColor(.white)
                            
                            Text(isArabic
                                 ? "رحلة مباركة عبر تفاصيل سيرة خير خلق الله، من العهد المكي وبشائر الفجر إلى الرسالة الخالدة."
                                 : "Journey through the life of the Prophet, from the world before his birth to the legacy that continues to inspire millions.")
                                .font(AppTypography.footnote(isArabic: isArabic))
                                .foregroundColor(Color.white.opacity(0.85))
                                .lineLimit(3)
                        }
                        .padding(AppSpacing.lg)
                    }
                    
                    // Stats Summary Bar
                    HStack(spacing: AppSpacing.md) {
                        StatItem(
                            icon: "book.closed.fill",
                            value: "\(chapters.count)",
                            label: isArabic ? "فصل متاح" : "Chapter"
                        )
                        
                        Divider()
                            .frame(height: 30)
                        
                        StatItem(
                            icon: "clock.fill",
                            value: "\(totalReadingMinutes)",
                            label: isArabic ? "دقائق قراءة" : "Min Read"
                        )
                        
                        Divider()
                            .frame(height: 30)
                        
                        StatItem(
                            icon: "chart.line.uptrend.xyaxis",
                            value: "\(completedCount)/\(max(1, chapters.count))",
                            label: isArabic ? "مكتمل" : "Completed"
                        )
                    }
                    .padding(AppSpacing.md)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.md)
                            .stroke(AppColors.goldBorder, lineWidth: 1)
                    )
                    .padding(.horizontal, AppSpacing.lg)
                    
                    // Chapters List Section
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        HStack {
                            Text(isArabic ? "الفصول التاريخية" : "Historical Chapters")
                                .font(AppTypography.title2(isArabic: isArabic))
                                .foregroundColor(AppColors.charcoal)
                            
                            Spacer()
                            
                            Text(isArabic ? "بالترتيب الزمني" : "Chronological Order")
                                .font(AppTypography.caption(isArabic: isArabic))
                                .foregroundColor(AppColors.secondaryText)
                        }
                        .padding(.horizontal, AppSpacing.lg)
                        
                        if chapters.isEmpty {
                            VStack(spacing: AppSpacing.sm) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 28))
                                    .foregroundColor(AppColors.antiqueGold)
                                Text(isArabic ? "جاري تحميل محتوى السيرة..." : "Loading Seerah content...")
                                    .font(AppTypography.subheadline(isArabic: isArabic))
                                    .foregroundColor(AppColors.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppSpacing.xl)
                        } else {
                            ForEach(chapters) { chapter in
                                let progress = progressStore?.getProgress(for: chapter.id)
                                Button(action: {
                                    selectedChapterForReading = chapter
                                }) {
                                    ChapterCard(
                                        chapter: chapter,
                                        progress: progress?.scrollRatio ?? 0.0,
                                        isCompleted: progress?.isCompleted ?? false,
                                        isBookmarked: progress?.isBookmarked ?? false,
                                        isArabic: isArabic,
                                        onBookmarkTapped: {
                                            progressStore?.toggleBookmark(chapterId: chapter.id, collectionId: chapter.collectionId)
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, AppSpacing.large)
                            }
                        }
                    }
                    .padding(.bottom, AppSpacing.medium)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedChapterForReading) { chapter in
            ChapterReaderView(collectionId: chapter.collectionId, chapterNumber: chapter.chapterNumber)
        }
        .onAppear {
            self.progressStore = ReadingProgressStore(modelContext: modelContext)
            loadChapters()
        }
        .onChange(of: languageManager.selectedLanguage) { _, _ in
            loadChapters()
        }
    }
    
    private var totalReadingMinutes: Int {
        chapters.reduce(0) { $0 + $1.estimatedReadingMinutes }
    }
    
    private var completedCount: Int {
        guard let store = progressStore else { return 0 }
        return chapters.filter { store.getProgress(for: $0.id)?.isCompleted == true }.count
    }
    
    private func loadChapters() {
        self.chapters = ContentRepository.shared.getChapterSummaries(collectionId: "seerah", languageCode: languageManager.selectedLanguage)
    }
}

private struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.antiqueGold)
            
            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AppColors.charcoal)
                
                Text(label)
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
