import SwiftUI
import SwiftData

@main
struct IslamicStoriesApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @State private var languageManager = LanguageManager.shared
    
    // Shared SwiftData model container
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ReadingProgress.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if !hasCompletedOnboarding {
                    OnboardingContainerView()
                } else {
                    MainTabView()
                }
            }
            .environment(\.layoutDirection, languageManager.layoutDirection)
            .environment(\.locale, languageManager.locale)
            .transaction { transaction in
                transaction.animation = nil
            }
            .tint(AppColors.emeraldGreen)
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Onboarding Navigation Container
struct OnboardingContainerView: View {
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            WelcomeView(navigationPath: $navigationPath)
                .navigationDestination(for: String.self) { destination in
                    if destination == "language_selection" {
                        LanguageSelectionView()
                    }
                }
        }
    }
}

// MARK: - Main Tab View
struct MainTabView: View {
    @Bindable private var tabBarManager = TabBarManager.shared
    
    var body: some View {
        ZStack {
            HomeView()
                .opacity(tabBarManager.selectedTab == .home ? 1 : 0)
                .allowsHitTesting(tabBarManager.selectedTab == .home)
            
            LibraryView()
                .opacity(tabBarManager.selectedTab == .library ? 1 : 0)
                .allowsHitTesting(tabBarManager.selectedTab == .library)
            
            BookmarksView()
                .opacity(tabBarManager.selectedTab == .bookmarks ? 1 : 0)
                .allowsHitTesting(tabBarManager.selectedTab == .bookmarks)
            
            NavigationStack {
                SettingsView()
            }
            .opacity(tabBarManager.selectedTab == .settings ? 1 : 0)
            .allowsHitTesting(tabBarManager.selectedTab == .settings)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            if !tabBarManager.isHidden {
                FloatingBottomNavBar(selectedTab: $tabBarManager.selectedTab)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: tabBarManager.isHidden)
    }
}
