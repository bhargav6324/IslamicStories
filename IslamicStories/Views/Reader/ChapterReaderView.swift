import SwiftUI
import SwiftData

public struct ChapterReaderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("readerFontSizeDelta") private var fontSizeDelta: Double = 0.0
    @AppStorage("readerTheme") private var selectedThemeRaw: String = ReadingTheme.parchment.rawValue
    
    @State private var languageManager = LanguageManager.shared
    
    public let collectionId: String
    public let chapterNumber: Int
    
    @State private var showingSettingsSheet: Bool = false
    @State private var isBookmarked: Bool = false
    @State private var readingProgressRatio: Double = 0.0
    @State private var isCompleted: Bool = false
    @State private var showAudioBar: Bool = true
    
    @State private var progressStore: ReadingProgressStore? = nil
    @State private var narrationService = SpeechNarrationService.shared
    @State private var currentChapter: StoryChapter? = nil
    
    public init(collectionId: String = "seerah", chapterNumber: Int = 1) {
        self.collectionId = collectionId
        self.chapterNumber = chapterNumber
    }
    
    public init(chapter: StoryChapter) {
        self.collectionId = chapter.collectionId
        self.chapterNumber = chapter.chapterNumber
        self._currentChapter = State(initialValue: chapter)
    }
    
    private var isArabic: Bool {
        languageManager.isArabic
    }
    
    private var currentTheme: ReadingTheme {
        ReadingTheme(rawValue: selectedThemeRaw) ?? .parchment
    }
    
    public var body: some View {
        Group {
            if let chapter = currentChapter {
                // Scrollable Reading Content
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: AppSpacing.lg) {
                            
                            // 1. Chapter Header Banner Image
                            ZStack(alignment: .bottomLeading) {
                                Image(chapter.coverImageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 240)
                                    .clipped()
                                    .overlay(
                                        LinearGradient(
                                            colors: [Color.clear, currentTheme.backgroundColor.opacity(0.85)],
                                            startPoint: .center,
                                            endPoint: .bottom
                                        )
                                    )
                                
                                // Chapter badge & reading time
                                HStack {
                                    Text(AppStrings.tr(.chapterNumber(chapter.chapterNumber), lang: languageManager.selectedLanguage))
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(AppColors.emeraldGreen)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(AppColors.antiqueGold.opacity(0.7), lineWidth: 1))
                                    
                                    Spacer()
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "clock")
                                        Text(AppStrings.tr(.minRead(chapter.estimatedReadingMinutes), lang: languageManager.selectedLanguage))
                                    }
                                    .font(AppTypography.caption(isArabic: isArabic))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.black.opacity(0.6))
                                    .clipShape(Capsule())
                                }
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.bottom, AppSpacing.md)
                            }
                            
                            // 2. Titles & Decorative Divider
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text(chapter.title)
                                    .font(AppTypography.largeTitle(isArabic: isArabic))
                                    .foregroundColor(currentTheme.textColor)
                                
                                Text(chapter.subtitle)
                                    .font(AppTypography.title3(isArabic: isArabic))
                                    .foregroundColor(AppColors.antiqueGold)
                                
                                IslamicDivider()
                                    .padding(.vertical, AppSpacing.xs)
                            }
                            .padding(.horizontal, AppSpacing.lg)
                            
                            // 3. Story Sections Loop
                            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                                ForEach(Array(chapter.sections.enumerated()), id: \.element.id) { index, section in
                                    SectionView(
                                        section: section,
                                        index: index,
                                        fontSizeDelta: fontSizeDelta,
                                        theme: currentTheme,
                                        isArabic: isArabic
                                    )
                                    .id(section.id)
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                            
                            // 4. Completion & Progress Action Card
                            VStack(spacing: AppSpacing.md) {
                                IslamicDivider(title: isArabic ? "خاتمة الفصل" : "Chapter Conclusion")
                                
                                if isCompleted {
                                    HStack(spacing: AppSpacing.sm) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppColors.emeraldGreen)
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(AppStrings.tr(.chapterCompletedHeadline, lang: languageManager.selectedLanguage))
                                                .font(AppTypography.headline(isArabic: isArabic))
                                                .foregroundColor(currentTheme.textColor)
                                            
                                            Text(AppStrings.tr(.chapterCompletedNote, lang: languageManager.selectedLanguage))
                                                .font(AppTypography.caption(isArabic: isArabic))
                                                .foregroundColor(AppColors.secondaryText)
                                        }
                                    }
                                    .padding(AppSpacing.md)
                                    .frame(maxWidth: .infinity)
                                    .background(currentTheme.cardColor)
                                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.lg))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                                            .stroke(AppColors.emeraldGreen.opacity(0.4), lineWidth: 1)
                                    )
                                } else {
                                    Button(action: {
                                        markChapterCompleted()
                                    }) {
                                        HStack(spacing: AppSpacing.sm) {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text(AppStrings.tr(.markCompleted, lang: languageManager.selectedLanguage))
                                        }
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, AppSpacing.lg)
                                        .padding(.vertical, 14)
                                        .background(AppColors.emeraldGreen)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(AppColors.antiqueGold.opacity(0.6), lineWidth: 1))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.md)
                            
                            // 5. Source References Section
                            if !chapter.references.isEmpty {
                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "books.vertical.fill")
                                            .foregroundColor(AppColors.antiqueGold)
                                        Text(AppStrings.tr(.sourcesTitle, lang: languageManager.selectedLanguage))
                                            .font(AppTypography.headline(isArabic: isArabic))
                                            .foregroundColor(currentTheme.textColor)
                                    }
                                    
                                    ForEach(chapter.references) { ref in
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(ref.title)
                                                .font(.system(size: 14, weight: .semibold, design: isArabic ? .default : .serif))
                                                .foregroundColor(AppColors.charcoal)
                                            
                                            Text("\(ref.author) · \(ref.source)")
                                                .font(.system(size: 12))
                                                .foregroundColor(AppColors.secondaryText)
                                            
                                            if let notes = ref.notes {
                                                Text(notes)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(AppColors.secondaryText.opacity(0.8))
                                                    .italic()
                                            }
                                        }
                                        .padding(AppSpacing.sm)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(currentTheme.cardColor)
                                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                                .stroke(AppColors.divider, lineWidth: 0.8)
                                        )
                                    }
                                }
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.bottom, AppSpacing.md)
                            }
                        }
                    }
                }
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    if showAudioBar {
                        AudioPlayerBar(
                            narrationService: narrationService,
                            isArabic: isArabic,
                            onClose: {
                                withAnimation(.spring(duration: 0.35)) {
                                    showAudioBar = false
                                }
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            } else {
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 32))
                        .foregroundColor(AppColors.antiqueGold)
                    Text(isArabic ? "المحتوى غير متاح بهذه اللغة" : "Content unavailable in this language")
                        .font(AppTypography.headline(isArabic: isArabic))
                        .foregroundColor(AppColors.charcoal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(currentTheme.backgroundColor.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(currentTheme.backgroundColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(currentTheme.textColor)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: AppSpacing.sm) {
                    // Audio Narration Toggle
                    Button(action: {
                        withAnimation(.spring(duration: 0.35)) {
                            showAudioBar.toggle()
                        }
                    }) {
                        Image(systemName: showAudioBar ? "headphones.circle.fill" : "headphones")
                            .font(.system(size: 17))
                            .foregroundColor(showAudioBar ? AppColors.emeraldGreen : currentTheme.textColor)
                    }
                    
                    // Bookmark Toggle
                    Button(action: {
                        toggleBookmark()
                    }) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 16))
                            .foregroundColor(isBookmarked ? AppColors.antiqueGold : currentTheme.textColor)
                    }
                    
                    // Reader Appearance Settings
                    Button(action: {
                        showingSettingsSheet = true
                    }) {
                        Image(systemName: "textformat.size")
                            .font(.system(size: 16))
                            .foregroundColor(currentTheme.textColor)
                    }
                }
            }
        }
        .sheet(isPresented: $showingSettingsSheet) {
            ReaderSettingsView(isArabic: isArabic)
        }
        .onAppear {
            TabBarManager.shared.setHidden(true)
            if let currentChapter = currentChapter {
                narrationService.prepareChapter(currentChapter)
            }
            loadActiveChapter()
        }
        .onChange(of: languageManager.selectedLanguage) { _, newLang in
            loadActiveChapter(for: newLang)
        }
        .onDisappear {
            TabBarManager.shared.setHidden(false)
            // Stop narration when leaving reader screen
            narrationService.stop()
        }
    }
    
    private func loadActiveChapter(for languageCode: String? = nil) {
        let lang = languageCode ?? languageManager.selectedLanguage
        if let loaded = try? ContentRepository.shared.loadChapter(
            collectionId: collectionId,
            chapterNumber: chapterNumber,
            languageCode: lang
        ) {
            self.currentChapter = loaded
            
            let store = ReadingProgressStore(modelContext: modelContext)
            self.progressStore = store
            if let saved = store.getProgress(for: loaded.id) {
                self.isBookmarked = saved.isBookmarked
                self.isCompleted = saved.isCompleted
                self.readingProgressRatio = saved.scrollRatio
            }
            store.updateProgress(chapterId: loaded.id, collectionId: loaded.collectionId, scrollRatio: 0.1)
            
            // Prepare speech narration with newly loaded chapter
            narrationService.prepareChapter(loaded)
        }
    }
    
    private func toggleBookmark() {
        guard let store = progressStore, let chapter = currentChapter else { return }
        isBookmarked = store.toggleBookmark(chapterId: chapter.id, collectionId: chapter.collectionId)
    }
    
    private func markChapterCompleted() {
        guard let store = progressStore, let chapter = currentChapter else { return }
        withAnimation {
            isCompleted = true
            readingProgressRatio = 1.0
        }
        store.updateProgress(
            chapterId: chapter.id,
            collectionId: chapter.collectionId,
            scrollRatio: 1.0,
            isCompleted: true
        )
    }
}

// MARK: - Section Rendering Component
private struct SectionView: View {
    let section: StorySection
    let index: Int
    let fontSizeDelta: Double
    let theme: ReadingTheme
    let isArabic: Bool
    
    var body: some View {
        switch section.type {
        case .heading:
            VStack(alignment: .leading, spacing: 6) {
                Text(section.text)
                    .font(AppTypography.title2(isArabic: isArabic))
                    .foregroundColor(theme.textColor)
                
                Rectangle()
                    .fill(AppColors.antiqueGold.opacity(0.6))
                    .frame(width: 40, height: 2)
            }
            .padding(.top, AppSpacing.sm)
            
        case .paragraph:
            Text(section.text)
                .font(AppTypography.readerBody(sizeDelta: CGFloat(fontSizeDelta), isArabic: isArabic))
                .foregroundColor(theme.textColor)
                .lineSpacing(isArabic ? 10 : 8)
                .multilineTextAlignment(.leading)
            
        case .image:
            if let imageName = section.imageName {
                VStack(spacing: AppSpacing.xs) {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 200)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                .stroke(AppColors.goldBorder, lineWidth: 1)
                        )
                        .shadow(color: AppShadow.subtle().color, radius: 8, x: 0, y: 3)
                    
                    if !section.text.isEmpty {
                        Text(section.text)
                            .font(AppTypography.caption(isArabic: isArabic))
                            .foregroundColor(AppColors.secondaryText)
                            .italic()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.sm)
                    }
                }
                .padding(.vertical, AppSpacing.xs)
            }
            
        case .quote:
            HStack(alignment: .top, spacing: AppSpacing.md) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColors.antiqueGold)
                    .frame(width: 4)
                
                Text(section.text)
                    .font(AppTypography.readerQuote(sizeDelta: CGFloat(fontSizeDelta), isArabic: isArabic))
                    .foregroundColor(theme.textColor)
                    .italic(!isArabic)
                    .lineSpacing(isArabic ? 8 : 6)
            }
            .padding(AppSpacing.md)
            .background(theme.cardColor)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .stroke(AppColors.goldBorder.opacity(0.6), lineWidth: 0.8)
            )
            .padding(.vertical, AppSpacing.xs)
        }
    }
}
