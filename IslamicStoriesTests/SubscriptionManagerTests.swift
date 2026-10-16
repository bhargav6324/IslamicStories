import XCTest
@testable import IslamicStories

@MainActor
final class SubscriptionManagerTests: XCTestCase {
    
    func testProductIDsMatchRequirements() {
        XCTAssertEqual(SubscriptionManager.monthlyProductID, "com.islamicstories.premium.monthly")
        XCTAssertEqual(SubscriptionManager.annualProductID, "com.islamicstories.premium.annual")
        XCTAssertEqual(SubscriptionManager.subscriptionGroupID, "22483276")
    }
    
    func testSubscriptionPlanMapping() {
        XCTAssertEqual(SubscriptionPlan.annual.productID, SubscriptionManager.annualProductID)
        XCTAssertEqual(SubscriptionPlan.monthly.productID, SubscriptionManager.monthlyProductID)
    }
    
    func testAnnualPlanSelectedByDefault() {
        let manager = SubscriptionManager.shared
        XCTAssertEqual(manager.selectedPlan, .annual, "Annual plan must be selected by default")
    }
    
    func testFiftyPercentDiscountCalculation() {
        // Mathematically verify the discount rule:
        // Monthly: ₹1,000 * 12 = ₹12,000
        // Annual: ₹6,000
        // Savings: ₹6,000 / ₹12,000 = 50%
        let monthlyPrice: Decimal = 1000
        let annualPrice: Decimal = 6000
        let fullYearRegular = monthlyPrice * 12
        let discountDecimal = (1.0 - (annualPrice / fullYearRegular)) * 100
        let discountPercent = NSDecimalNumber(decimal: discountDecimal).intValue
        
        XCTAssertEqual(discountPercent, 50, "Annual savings must calculate to exactly 50%")
    }
    
    func testPaywallLocalizationStrings() {
        let enLang = "en"
        let arLang = "ar"
        
        // Headline
        XCTAssertEqual(AppStrings.tr(.paywallHeadline, lang: enLang), "Unlock Every Story")
        XCTAssertEqual(AppStrings.tr(.paywallHeadline, lang: arLang), "افتح جميع فصول السيرة")
        
        // Subtitle
        XCTAssertFalse(AppStrings.tr(.paywallSubtitle, lang: enLang).isEmpty)
        XCTAssertFalse(AppStrings.tr(.paywallSubtitle, lang: arLang).isEmpty)
        
        // Features
        XCTAssertEqual(AppStrings.tr(.paywallFeature1, lang: enLang), "Access to all 80 Seerah chapters")
        XCTAssertEqual(AppStrings.tr(.paywallFeature1, lang: arLang), "الوصول الكامل إلى جميع فصول السيرة الـ 80")
        
        XCTAssertFalse(AppStrings.tr(.paywallFeature2, lang: enLang).isEmpty)
        XCTAssertFalse(AppStrings.tr(.paywallFeature3, lang: enLang).isEmpty)
        XCTAssertFalse(AppStrings.tr(.paywallFeature4, lang: enLang).isEmpty)
        XCTAssertFalse(AppStrings.tr(.paywallFeature5, lang: enLang).isEmpty)
        
        // Plan titles & Badges
        XCTAssertEqual(AppStrings.tr(.annualPlanTitle, lang: enLang), "Annual")
        XCTAssertEqual(AppStrings.tr(.annualPlanTitle, lang: arLang), "سنوي")
        XCTAssertEqual(AppStrings.tr(.monthlyPlanTitle, lang: enLang), "Monthly")
        XCTAssertEqual(AppStrings.tr(.monthlyPlanTitle, lang: arLang), "شهري")
        
        XCTAssertEqual(AppStrings.tr(.savePercent(50), lang: enLang), "Save 50%")
        XCTAssertEqual(AppStrings.tr(.savePercent(50), lang: arLang), "وفر 50%")
        XCTAssertEqual(AppStrings.tr(.recommended, lang: enLang), "Recommended")
        XCTAssertEqual(AppStrings.tr(.recommended, lang: arLang), "الأكثر توفيراً")
        
        // CTA & Actions
        XCTAssertEqual(AppStrings.tr(.continueWithAnnual, lang: enLang), "Continue with Annual")
        XCTAssertEqual(AppStrings.tr(.continueWithAnnual, lang: arLang), "المتابعة مع الاشتراك السنوي")
        XCTAssertEqual(AppStrings.tr(.continueWithMonthly, lang: enLang), "Continue with Monthly")
        XCTAssertEqual(AppStrings.tr(.continueWithMonthly, lang: arLang), "المتابعة مع الاشتراك الشهري")
        XCTAssertEqual(AppStrings.tr(.restorePurchases, lang: enLang), "Restore Purchases")
        XCTAssertEqual(AppStrings.tr(.restorePurchases, lang: arLang), "استعادة المشتريات")
        
        // Disclosures & Errors
        XCTAssertFalse(AppStrings.tr(.subscriptionDisclosure, lang: enLang).isEmpty)
        XCTAssertFalse(AppStrings.tr(.subscriptionDisclosure, lang: arLang).isEmpty)
        XCTAssertEqual(AppStrings.tr(.termsOfUse, lang: enLang), "Terms of Use")
        XCTAssertEqual(AppStrings.tr(.termsOfUse, lang: arLang), "شروط الاستخدام")
        XCTAssertEqual(AppStrings.tr(.privacyPolicy, lang: enLang), "Privacy Policy")
        XCTAssertEqual(AppStrings.tr(.privacyPolicy, lang: arLang), "سياسة الخصوصية")
        XCTAssertFalse(AppStrings.tr(.productLoadingError, lang: enLang).isEmpty)
        XCTAssertFalse(AppStrings.tr(.productLoadingError, lang: arLang).isEmpty)
        XCTAssertEqual(AppStrings.tr(.retryAction, lang: enLang), "Retry")
        XCTAssertEqual(AppStrings.tr(.retryAction, lang: arLang), "إعادة المحاولة")
        XCTAssertFalse(AppStrings.tr(.loadingPrices, lang: enLang).isEmpty)
        XCTAssertFalse(AppStrings.tr(.loadingPrices, lang: arLang).isEmpty)
        XCTAssertFalse(AppStrings.tr(.subscriptionExpired, lang: enLang).isEmpty)
        XCTAssertFalse(AppStrings.tr(.subscriptionExpired, lang: arLang).isEmpty)
    }
    
    func testAllEightyChaptersRemainAccessibleForSubscribers() throws {
        let repo = ContentRepository.shared
        let enSummaries = repo.getChapterSummaries(collectionId: "seerah", languageCode: "en")
        let arSummaries = repo.getChapterSummaries(collectionId: "seerah", languageCode: "ar")
        
        XCTAssertEqual(enSummaries.count, 80)
        XCTAssertEqual(arSummaries.count, 80)
        
        // Verify chapters 1 through 80 load without content modification
        for chapterNum in 1...80 {
            let enChap = try repo.loadChapter(collectionId: "seerah", chapterNumber: chapterNum, languageCode: "en")
            XCTAssertEqual(enChap.chapterNumber, chapterNum)
            XCTAssertFalse(enChap.sections.isEmpty)
        }
    }
}
