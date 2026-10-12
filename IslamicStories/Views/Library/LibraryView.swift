import SwiftUI

public struct LibraryView: View {
    @State private var languageManager = LanguageManager.shared
    @State private var navigateToSeerah: Bool = false
    
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
                            Text(AppStrings.tr(.libraryTitle, lang: languageManager.selectedLanguage))
                                .font(AppTypography.largeTitle(isArabic: isArabic))
                                .foregroundColor(AppColors.charcoal)
                                .lineSpacing(isArabic ? 4 : 2)
                            
                            Text(AppStrings.tr(.librarySubtitle, lang: languageManager.selectedLanguage))
                                .font(AppTypography.subheadline(isArabic: isArabic))
                                .foregroundColor(AppColors.secondaryText)
                                .lineSpacing(AppTypography.recommendedLineSpacing(isArabic: isArabic))
                        }
                        .padding(.horizontal, AppSpacing.large)
                        .padding(.top, AppSpacing.medium)
                        
                        // Collections List
                        let collections = ContentRepository.shared.getAvailableCollections(languageCode: languageManager.selectedLanguage)
                        
                        ForEach(collections) { collection in
                            if collection.id == "seerah" {
                                Button(action: {
                                    navigateToSeerah = true
                                }) {
                                    CollectionCard(
                                        collection: collection,
                                        isArabic: isArabic,
                                        onExplore: {
                                            navigateToSeerah = true
                                        }
                                    )
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, AppSpacing.large)
                            } else {
                                CollectionCard(
                                    collection: collection,
                                    isArabic: isArabic
                                )
                                .padding(.horizontal, AppSpacing.large)
                            }
                        }
                    }
                    .padding(.bottom, AppSpacing.medium)
                }
                .safeAreaPadding(.bottom, 72)
            }
            .navigationDestination(isPresented: $navigateToSeerah) {
                SeerahCollectionView()
            }
        }
    }
}
