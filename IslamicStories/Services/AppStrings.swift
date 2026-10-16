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
        
        // Subscription & Hard Paywall
        case paywallHeadline
        case paywallSubtitle
        case paywallFeature1
        case paywallFeature2
        case paywallFeature3
        case paywallFeature4
        case paywallFeature5
        case annualPlanTitle
        case monthlyPlanTitle
        case savePercent(Int)
        case recommended
        case perYear
        case perMonth
        case approxMonthlyRate(String)
        case continueWithAnnual
        case continueWithMonthly
        case continueAction
        case subscriptionDisclosure
        case restorePurchases
        case termsOfUse
        case privacyPolicy
        case subscriptionChecking
        case purchasingInProgress
        case restoringInProgress
        case restoreSuccess
        case restoreNotFound
        case purchaseCancelled
        case purchasePending
        case purchaseError
        case unverifiedTransaction
        case manageSubscription
        case subscriptionHeader
        case activePlanLabel
        case subscriptionStatusLabel
        case subscriptionStatusActive
        case renewsOnDate(String)
        case expiresOnDate(String)
        case productLoadingError
        case retryAction
        case loadingPrices
        case subscriptionExpired

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
            
            // Subscription & Hard Paywall (English)
            case .paywallHeadline: return "Unlock Every Story"
            case .paywallSubtitle: return "Explore the complete Seerah of Prophet Muhammad ﷺ through immersive storytelling."
            case .paywallFeature1: return "Access to all 80 Seerah chapters"
            case .paywallFeature2: return "Complete English and Arabic stories"
            case .paywallFeature3: return "Immersive audio narration"
            case .paywallFeature4: return "Bookmarks and reading progress"
            case .paywallFeature5: return "Full offline reading support"
            case .annualPlanTitle: return "Annual"
            case .monthlyPlanTitle: return "Monthly"
            case .savePercent(let p): return "Save \(p)%"
            case .recommended: return "Recommended"
            case .perYear: return "/ year"
            case .perMonth: return "/ month"
            case .approxMonthlyRate(let r): return "Approximately \(r)/month"
            case .continueWithAnnual: return "Continue with Annual"
            case .continueWithMonthly: return "Continue with Monthly"
            case .continueAction: return "Continue"
            case .subscriptionDisclosure: return "Payment will be charged to your Apple Account. Your subscription automatically renews unless canceled at least 24 hours before the end of the current billing cycle. You can manage or cancel your subscription anytime in your Apple Account settings."
            case .restorePurchases: return "Restore Purchases"
            case .termsOfUse: return "Terms of Use"
            case .privacyPolicy: return "Privacy Policy"
            case .subscriptionChecking: return "Verifying subscription status..."
            case .purchasingInProgress: return "Contacting App Store..."
            case .restoringInProgress: return "Restoring purchases from Apple..."
            case .restoreSuccess: return "Your subscription has been successfully restored."
            case .restoreNotFound: return "No active subscription found for this Apple Account."
            case .purchaseCancelled: return "Purchase was cancelled."
            case .purchasePending: return "Purchase is pending approval. Your access will activate once approved."
            case .purchaseError: return "Unable to complete purchase. Please try again."
            case .unverifiedTransaction: return "Transaction could not be verified by Apple."
            case .manageSubscription: return "Manage Subscription"
            case .subscriptionHeader: return "Subscription"
            case .activePlanLabel: return "Active Plan"
            case .subscriptionStatusLabel: return "Status"
            case .subscriptionStatusActive: return "Active Subscriber"
            case .renewsOnDate(let d): return "Renews on \(d)"
            case .expiresOnDate(let d): return "Expires on \(d)"
            case .productLoadingError: return "Unable to load subscription plans from the App Store. Please check your connection and tap Retry."
            case .retryAction: return "Retry"
            case .loadingPrices: return "Loading prices from Apple..."
            case .subscriptionExpired: return "Your subscription has expired. Please choose a plan below to continue."
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
            
            // Subscription & Hard Paywall (Arabic)
            case .paywallHeadline: return "افتح جميع فصول السيرة"
            case .paywallSubtitle: return "استكشف سيرة النبي محمد ﷺ الكاملة من خلال سرد تاريخي وأدبي غامر."
            case .paywallFeature1: return "الوصول الكامل إلى جميع فصول السيرة الـ 80"
            case .paywallFeature2: return "قصص وسير متكاملة باللغتين العربية والإنجليزية"
            case .paywallFeature3: return "قراءة صوتية ناطقة لجميع الفقرات"
            case .paywallFeature4: return "حفظ الإشارات المرجعية ومتابعة التقدم"
            case .paywallFeature5: return "إمكانية القراءة دون اتصال بالإنترنت"
            case .annualPlanTitle: return "سنوي"
            case .monthlyPlanTitle: return "شهري"
            case .savePercent(let p): return "وفر \(p)%"
            case .recommended: return "الأكثر توفيراً"
            case .perYear: return "/ سنوياً"
            case .perMonth: return "/ شهرياً"
            case .approxMonthlyRate(let r): return "\(r) شهرياً تقريباً"
            case .continueWithAnnual: return "المتابعة مع الاشتراك السنوي"
            case .continueWithMonthly: return "المتابعة مع الاشتراك الشهري"
            case .continueAction: return "المتابعة"
            case .subscriptionDisclosure: return "سيتم خصم الدفع من حساب Apple الخاص بك. يتجدد اشتراكك تلقائياً ما لم يتم إلغاؤه قبل 24 ساعة على الأقل من نهاية الفترة الحالية. يمكنك إدارة أو إلغاء اشتراكك في أي وقت من إعدادات حساب Apple الخاص بك."
            case .restorePurchases: return "استعادة المشتريات"
            case .termsOfUse: return "شروط الاستخدام"
            case .privacyPolicy: return "سياسة الخصوصية"
            case .subscriptionChecking: return "جاري التحقق من حالة الاشتراك..."
            case .purchasingInProgress: return "جاري الاتصال بمتجر App Store..."
            case .restoringInProgress: return "جاري استعادة المشتريات من Apple..."
            case .restoreSuccess: return "تم استعادة اشتراكك بنجاح."
            case .restoreNotFound: return "لم يتم العثور على اشتراك نشط لهذا الحساب."
            case .purchaseCancelled: return "تم إلغاء عملية الشراء."
            case .purchasePending: return "تم تعليق الشراء بانتظار الموافقة. سيتفعل وصولك فور اعتماد العملية."
            case .purchaseError: return "تعذر إتمام عملية الشراء. يرجى المحاولة مرة أخرى."
            case .unverifiedTransaction: return "تعذر التحقق من صحة العملية لدى Apple."
            case .manageSubscription: return "إدارة الاشتراك"
            case .subscriptionHeader: return "الاشتراك"
            case .activePlanLabel: return "الخطة الحالية"
            case .subscriptionStatusLabel: return "الحالة"
            case .subscriptionStatusActive: return "مشترك نشط"
            case .renewsOnDate(let d): return "يتجدد في \(d)"
            case .expiresOnDate(let d): return "ينتهي في \(d)"
            case .productLoadingError: return "تعذر تحميل خطط الاشتراك من App Store. يرجى التحقق من اتصالك والمحاولة مجدداً."
            case .retryAction: return "إعادة المحاولة"
            case .loadingPrices: return "جاري تحميل الأسعار من Apple..."
            case .subscriptionExpired: return "انتهت فترة اشتراكك. يرجى اختيار خطة أدناه للمتابعة."
            }
        }
    }
}
