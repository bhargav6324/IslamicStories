import SwiftUI

public enum AppTab: String, CaseIterable, Identifiable {
    case home = "home"
    case library = "library"
    case bookmarks = "bookmarks"
    case settings = "settings"
    
    public var id: String { rawValue }
    
    public func icon(isSelected: Bool) -> String {
        switch self {
        case .home:
            return isSelected ? "house.fill" : "house"
        case .library:
            return isSelected ? "books.vertical.fill" : "books.vertical"
        case .bookmarks:
            return isSelected ? "bookmark.fill" : "bookmark"
        case .settings:
            return isSelected ? "gearshape.fill" : "gearshape"
        }
    }
    
    public func titleKey() -> AppStrings.Key {
        switch self {
        case .home: return .tabHome
        case .library: return .tabLibrary
        case .bookmarks: return .tabBookmarks
        case .settings: return .tabSettings
        }
    }
}

public typealias NavigationTab = AppTab

public struct FloatingBottomNavBar: View {
    @Binding public var selectedTab: AppTab
    @State private var languageManager = LanguageManager.shared
    
    private var isArabic: Bool {
        languageManager.isArabic
    }
    
    public init(selectedTab: Binding<AppTab>) {
        self._selectedTab = selectedTab
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let isSelected = selectedTab == tab
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        selectedTab = tab
                    }
                }) {
                    VStack(spacing: 3) {
                        Image(systemName: tab.icon(isSelected: isSelected))
                            .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? AppColors.emeraldGreen : AppColors.secondaryText)
                            .frame(height: 22)
                        
                        Text(AppStrings.tr(tab.titleKey(), lang: languageManager.selectedLanguage))
                            .font(.system(size: isArabic ? 11.5 : 10.5, weight: isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? AppColors.emeraldGreen : AppColors.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44) // Accessible touch target >= 44pt
                    .padding(.vertical, 6)
                    .padding(.horizontal, 4)
                    .background(
                        Group {
                            if isSelected {
                                Capsule()
                                    .fill(AppColors.emeraldGreen.opacity(0.12))
                            } else {
                                Color.clear
                            }
                        }
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AppStrings.tr(tab.titleKey(), lang: languageManager.selectedLanguage))
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(AppColors.cardBackground.opacity(0.94))
                .background(
                    Capsule()
                        .fill(Material.ultraThinMaterial)
                )
        )
        .overlay(
            Capsule()
                .stroke(AppColors.goldBorder.opacity(0.6), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 12,
            x: 0,
            y: 4
        )
        .padding(.horizontal, AppSpacing.lg)
        .padding(.bottom, AppSpacing.xs)
    }
}
