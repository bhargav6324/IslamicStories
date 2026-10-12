import SwiftUI
import Observation

@Observable
public final class LanguageManager {
    public static let shared = LanguageManager()
    
    public private(set) var selectedLanguage: String {
        didSet {
            UserDefaults.standard.set(selectedLanguage, forKey: "selectedLanguage")
        }
    }
    
    public init() {
        let saved = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        self.selectedLanguage = saved
    }
    
    public var isArabic: Bool {
        selectedLanguage.hasPrefix("ar")
    }
    
    public var layoutDirection: LayoutDirection {
        isArabic ? .rightToLeft : .leftToRight
    }
    
    public var locale: Locale {
        Locale(identifier: isArabic ? "ar" : "en")
    }
    
    public func setLanguage(_ code: String) {
        guard code != selectedLanguage else { return }
        // Stop any ongoing speech synthesis immediately
        SpeechNarrationService.shared.stop()
        self.selectedLanguage = code
    }
}
