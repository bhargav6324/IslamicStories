import SwiftUI
import SwiftData

public struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var languageManager = LanguageManager.shared
    
    @State private var navigateToSeerah: Bool = false
    @State private var activeChapterForReading: (collectionId: String, chapterNumber: Int)? = nil
    
    @State private var recentProgress: ReadingProgress? = nil
    @State private var recentChapter: StoryChapter? = nil
    
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
                        
                        // 1. Top Greeting Header
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            HStack(spacing: AppSpacing.small) {
                                IslamicPatternView(size: 18, strokeColor: AppColors.antiqueGold, opacity: 0.95)
                                Text(AppStrings.tr(.greeting, lang: languageManager.selectedLanguage))
                                    .font(.system(size: isArabic ? 14 : 13, weight: .semibold))
                                    .foregroundColor(AppColors.antiqueGold)
                            }
                            
                            Text(AppStrings.tr(.homeHeadline, lang: languageManager.selectedLanguage))
                                .font(AppTypography.largeTitle(isArabic: isArabic))
                                .foregroundColor(AppColors.charcoal)
                                .lineSpacing(isArabic ? 4 : 2)
                                .padding(.vertical, 2)
                            
                            Text(AppStrings.tr(.homeSubheadline, lang: languageManager.selectedLanguage))
                                .font(AppTypography.subheadline(isArabic: isArabic))
                                .foregroundColor(AppColors.secondaryText)
                                .lineSpacing(AppTypography.recommendedLineSpacing(isArabic: isArabic))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, AppSpacing.large)
                        .padding(.top, AppSpacing.medium)
                        
                        // 2. Continue Reading Section (only shown if reading progress exists)
                        if let recentChapter = recentChapter, let recentProgress = recentProgress {
                            VStack(alignment: .leading, spacing: AppSpacing.small) {
                                HStack {
                                    Text(AppStrings.tr(.continueReading, lang: languageManager.selectedLanguage))
                                        .font(AppTypography.headline(isArabic: isArabic))
                                        .foregroundColor(AppColors.charcoal)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(recentProgress.scrollRatio * 100))%")
                                        .font(AppTypography.caption())
                                        .foregroundColor(AppColors.antiqueGold)
                                        .fontWeight(.bold)
                                }
                                
                                Button(action: {
                                    activeChapterForReading = (collectionId: recentChapter.collectionId, chapterNumber: recentChapter.chapterNumber)
                                }) {
                                    HStack(spacing: AppSpacing.standard) {
                                        Image(recentChapter.coverImageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 72, height: 72)
                                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                                    .stroke(AppColors.goldBorder, lineWidth: 1)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: AppSpacing.extraSmall) {
                                            Text(recentChapter.title)
                                                .font(AppTypography.headline(isArabic: isArabic))
                                                .foregroundColor(AppColors.charcoal)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                            
                                            Text(recentChapter.subtitle)
                                                .font(AppTypography.footnote(isArabic: isArabic))
                                                .foregroundColor(AppColors.secondaryText)
                                                .lineLimit(1)
                                            
                                            ReadingProgressBar(progress: recentProgress.scrollRatio, height: 4)
                                                .padding(.top, 2)
                                        }
                                        
                                        Spacer(minLength: AppSpacing.extraSmall)
                                        
                                        Image(systemName: "chevron.forward.circle.fill")
                                            .font(.system(size: 26))
                                            .foregroundColor(AppColors.emeraldGreen)
                                    }
                                    .padding(AppSpacing.standard)
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
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, AppSpacing.large)
                        }
                        
                        // 3. Featured Collection Card (The Seerah)
                        VStack(alignment: .leading, spacing: AppSpacing.small) {
                            Text(AppStrings.tr(.featuredBadge, lang: languageManager.selectedLanguage))
                                .font(AppTypography.caption(isArabic: isArabic))
                                .foregroundColor(AppColors.antiqueGold)
                                .fontWeight(.bold)
                                .tracking(1.0)
                                .padding(.horizontal, AppSpacing.large)
                            
                            let seerahCollection = ContentRepository.shared
                                .getAvailableCollections(languageCode: languageManager.selectedLanguage)
                                .first { $0.id == "seerah" }
                            
                            if let seerahCollection = seerahCollection {
                                Button(action: {
                                    navigateToSeerah = true
                                }) {
                                    CollectionCard(
                                        collection: seerahCollection,
                                        isArabic: isArabic,
                                        onExplore: {
                                            navigateToSeerah = true
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, AppSpacing.large)
                            }
                        }
                        
                        // 4. Discover Section (Future collections marked Coming Soon)
                        VStack(alignment: .leading, spacing: AppSpacing.standard) {
                            HStack {
                                Text(AppStrings.tr(.discoverMore, lang: languageManager.selectedLanguage))
                                    .font(AppTypography.title3(isArabic: isArabic))
                                    .foregroundColor(AppColors.charcoal)
                                
                                Spacer()
                            }
                            .padding(.horizontal, AppSpacing.large)
                            
                            let otherCollections = ContentRepository.shared
                                .getAvailableCollections(languageCode: languageManager.selectedLanguage)
                                .filter { $0.id != "seerah" }
                            
                            ForEach(otherCollections) { collection in
                                CollectionCard(
                                    collection: collection,
                                    isArabic: isArabic
                                )
                                .padding(.horizontal, AppSpacing.large)
                            }
                        }
                        .padding(.bottom, AppSpacing.medium)
                    }
                }
                .safeAreaPadding(.bottom, 72)
            }
            .navigationDestination(isPresented: $navigateToSeerah) {
                SeerahCollectionView()
            }
            .navigationDestination(isPresented: Binding(
                get: { activeChapterForReading != nil },
                set: { if !$0 { activeChapterForReading = nil } }
            )) {
                if let target = activeChapterForReading {
                    ChapterReaderView(collectionId: target.collectionId, chapterNumber: target.chapterNumber)
                }
            }
            .onAppear {
                refreshReadingState()
            }
            .onChange(of: languageManager.selectedLanguage) { _, _ in
                refreshReadingState()
            }
        }
    }
    
    private func refreshReadingState() {
        let store = ReadingProgressStore(modelContext: modelContext)
        if let recent = store.fetchRecentProgress() {
            self.recentProgress = recent
            self.recentChapter = try? ContentRepository.shared.loadChapter(
                collectionId: recent.collectionId,
                chapterNumber: 1,
                languageCode: languageManager.selectedLanguage
            )
        } else {
            self.recentProgress = nil
            self.recentChapter = nil
        }
    }
}
