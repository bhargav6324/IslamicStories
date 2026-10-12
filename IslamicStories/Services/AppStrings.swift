import Foundation

public enum AppStrings {
    public static func tr(_ key: Key, lang: String = LanguageManager.shared.selectedLanguage) -> String {
        let isArabic = lang.hasPrefix("ar")
        return isArabic ? key.arabic : key.english
    }
    
    public enum Key {
        // Navigation / Tabs
        case tabHome
        case tabLibrary
        case tabBookmarks
        case tabSettings
        
        // Common
        case done
        case close
        case completed
        case comingSoon
        case active
        case exploreCollection
        case minRead(Int)
        case chaptersAvailable(Int)
        
        // Home
        case greeting
        case homeHeadline
        case homeSubheadline
        case continueReading
        case featuredBadge
        case discoverMore
        
        // Reader
        case chapterNumber(Int)
        case markCompleted
        case chapterCompletedHeadline
        case chapterCompletedNote
        case sourcesTitle
        case audioNarration
        case audioReady
        case audioSection(current: Int, total: Int)
        case readingOptions
        case textSize
        case readingTheme
        
        // Settings
        case settingsTitle
        case languageHeader
        case readingHeader
        case defaultFontSize
        case audioHeader
        case narrationSpeed
        case synthesizedVoice
        case aboutHeader
        case aboutApp
        case historicalSources
        case offlineCapability
        case fullyOffline
        
        // Bookmarks
        case bookmarksTitle
        case bookmarksSubtitle
        case noBookmarksTitle
        case noBookmarksDescription
        
        // Library
        case libraryTitle
        case librarySubtitle
        
        var english: String {
            switch self {
            case .tabHome: return "Home"
            case .tabLibrary: return "Library"
            case .tabBookmarks: return "Bookmarks"
            case .tabSettings: return "Settings"
            case .done: return "Done"
            case .close: return "Close"
            case .completed: return "Completed"
            case .comingSoon: return "COMING SOON"
            case .active: return "ACTIVE"
            case .exploreCollection: return "Explore Collection"
            case .minRead(let m): return "\(m) min read"
            case .chaptersAvailable(let c): return "\(c) Chapter Available"
            case .greeting: return "Assalamu Alaikum"
            case .homeHeadline: return "Explore Islamic History"
            case .homeSubheadline: return "Discover timeless stories of faith, courage, and humanity."
            case .continueReading: return "Continue Reading"
            case .featuredBadge: return "FEATURED COLLECTION"
            case .discoverMore: return "Discover More Collections"
            case .chapterNumber(let n): return "CHAPTER \(n)"
            case .markCompleted: return "Mark as Completed"
            case .chapterCompletedHeadline: return "You have completed this chapter"
            case .chapterCompletedNote: return "May Allah increase you in beneficial knowledge."
            case .sourcesTitle: return "Historical Sources & References"
            case .audioNarration: return "Audio Narration"
            case .audioReady: return "Ready to play"
            case .audioSection(let c, let t): return "Section \(c) of \(t)"
            case .readingOptions: return "Reading Options"
            case .textSize: return "Text Size"
            case .readingTheme: return "Reading Theme"
            case .settingsTitle: return "Settings"
            case .languageHeader: return "Language"
            case .readingHeader: return "Reading Experience"
            case .defaultFontSize: return "Default Font Size"
            case .audioHeader: return "Audio Narration"
            case .narrationSpeed: return "Narration Speed"
            case .synthesizedVoice: return "Synthesized Voice"
            case .aboutHeader: return "About & References"
            case .aboutApp: return "About the App"
            case .historicalSources: return "Historical Sources"
            case .offlineCapability: return "Offline Capability"
            case .fullyOffline: return "Fully Offline"
            case .bookmarksTitle: return "Bookmarks"
            case .bookmarksSubtitle: return "Chapters and saved moments for effortless reflection."
            case .noBookmarksTitle: return "No Bookmarks Yet"
            case .noBookmarksDescription: return "Tap the bookmark icon while reading any chapter to save it here for later."
            case .libraryTitle: return "Library"
            case .librarySubtitle: return "Curated collections and verified historical biographies."
            }
        }
        
        var arabic: String {
            switch self {
            case .tabHome: return "الرئيسية"
            case .tabLibrary: return "المكتبة"
            case .tabBookmarks: return "الإشارات"
            case .tabSettings: return "الإعدادات"
            case .done: return "تم"
            case .close: return "إغلاق"
            case .completed: return "مكتمل"
            case .comingSoon: return "قريباً"
            case .active: return "مفعل"
            case .exploreCollection: return "استكشف المجموعة"
            case .minRead(let m): return "\(m) دقائق قراءة"
            case .chaptersAvailable(let c): return "\(c) فصول متاحة"
            case .greeting: return "السلام عليكم ورحمة الله"
            case .homeHeadline: return "استكشف التاريخ الإسلامي"
            case .homeSubheadline: return "اكتشف روائع القصص الخالدة في الإيمان والشجاعة والقيم الإنسانية السامية."
            case .continueReading: return "متابعة القراءة"
            case .featuredBadge: return "مجموعة مميزة"
            case .discoverMore: return "استكشف المزيد من السلسلة"
            case .chapterNumber(let n): return "الفصل \(n)"
            case .markCompleted: return "تحديد كمكتمل"
            case .chapterCompletedHeadline: return "أتممت قراءة هذا الفصل"
            case .chapterCompletedNote: return "جزاك الله خيراً ونفعك بما علمت."
            case .sourcesTitle: return "المصادر والمراجع التاريخية"
            case .audioNarration: return "قراءة صوتية ناطقة"
            case .audioReady: return "جاهز للقراءة"
            case .audioSection(let c, let t): return "الفقرة \(c) من \(t)"
            case .readingOptions: return "خيارات القراءة"
            case .textSize: return "حجم الخط"
            case .readingTheme: return "نمط القراءة"
            case .settingsTitle: return "الإعدادات"
            case .languageHeader: return "اللغة والتوجيه"
            case .readingHeader: return "تجربة القراءة"
            case .defaultFontSize: return "حجم الخط الافتراضي"
            case .audioHeader: return "القراءة الصوتية"
            case .narrationSpeed: return "سرعة القراءة"
            case .synthesizedVoice: return "صوت القارئ الافتراضي"
            case .aboutHeader: return "حول التطبيق والمراجع"
            case .aboutApp: return "عن التطبيق"
            case .historicalSources: return "المصادر والمراجع المعتمدة"
            case .offlineCapability: return "العمل دون إنترنت"
            case .fullyOffline: return "مفعل بالكامل"
            case .bookmarksTitle: return "الإشارات المرجعية"
            case .bookmarksSubtitle: return "الفصول والمواضع المحفوظة للرجوع إليها لاحقاً."
            case .noBookmarksTitle: return "لا توجد إشارات مرجعية حتى الآن"
            case .noBookmarksDescription: return "أثناء قراءة أي فصل، اضغط على أيقونة الإشارة المرجعية لحفظه هنا."
            case .libraryTitle: return "المكتبة التاريخية"
            case .librarySubtitle: return "مجموعات القصص والسير الموثقة في تاريخ الإسلام."
            }
        }
    }
}
