import SwiftUI

/// Observable coordinator for floating tab bar state and visibility across screens.
@Observable
public final class TabBarManager {
    public static let shared = TabBarManager()
    
    public var selectedTab: AppTab {
        didSet {
            UserDefaults.standard.set(selectedTab.rawValue, forKey: "appSelectedTab")
        }
    }
    public var isHidden: Bool = false
    
    private init() {
        if let raw = UserDefaults.standard.string(forKey: "appSelectedTab"),
           let tab = AppTab(rawValue: raw) {
            self.selectedTab = tab
        } else {
            self.selectedTab = .home
        }
    }
    
    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }
    
    public func setHidden(_ hidden: Bool) {
        isHidden = hidden
    }
}
