import SwiftUI
import AVFoundation

public struct SettingsView: View {
    @State private var languageManager = LanguageManager.shared
    @AppStorage("readerFontSizeDelta") private var fontSizeDelta: Double = 0.0
    @AppStorage("readerTheme") private var selectedThemeRaw: String = ReadingTheme.parchment.rawValue
    
    @State private var narrationService = SpeechNarrationService.shared
    @State private var subscriptionManager = SubscriptionManager.shared
    @State private var showingAboutSheet: Bool = false
    @State private var showingSourcesSheet: Bool = false
    @State private var showingTermsSheet: Bool = false
    @State private var showingPrivacySheet: Bool = false
    @State private var showingManageSubscriptions: Bool = false
    
    public init() {}
    
    private var isArabic: Bool {
        languageManager.isArabic
    }
    
    public var body: some View {
        ZStack {
            AppColors.parchment
                .ignoresSafeArea()
            
            List {
                // Section 1: Language
                Section(header: Text(AppStrings.tr(.languageHeader, lang: languageManager.selectedLanguage)).foregroundColor(AppColors.antiqueGold)) {
                    Button(action: {
                        languageManager.setLanguage("en")
                    }) {
                        HStack {
                            Text("English")
                                .foregroundColor(AppColors.charcoal)
                            Spacer()
                            if languageManager.selectedLanguage == "en" {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.emeraldGreen)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    
                    Button(action: {
                        languageManager.setLanguage("ar")
                    }) {
                        HStack {
                            Text("العربية")
                                .foregroundColor(AppColors.charcoal)
                            Spacer()
                            if languageManager.selectedLanguage == "ar" {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.emeraldGreen)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                }
                .listRowBackground(AppColors.cardBackground)
                
                // Section: Subscription
                Section(header: Text(AppStrings.tr(.subscriptionHeader, lang: languageManager.selectedLanguage)).foregroundColor(AppColors.antiqueGold)) {
                    HStack {
                        Text(AppStrings.tr(.activePlanLabel, lang: languageManager.selectedLanguage))
                            .foregroundColor(AppColors.charcoal)
                        Spacer()
                        Text(subscriptionManager.activePlanTitle(isArabic: isArabic) ?? AppStrings.tr(.subscriptionStatusActive, lang: languageManager.selectedLanguage))
                            .font(AppTypography.footnote())
                            .foregroundColor(AppColors.emeraldGreen)
                            .fontWeight(.semibold)
                    }
                    
                    if let dateFormatted = subscriptionManager.renewalOrExpirationDescription(locale: languageManager.locale) {
                        HStack {
                            Text(AppStrings.tr(.subscriptionStatusLabel, lang: languageManager.selectedLanguage))
                                .foregroundColor(AppColors.charcoal)
                            Spacer()
                            Text(AppStrings.tr(.renewsOnDate(dateFormatted), lang: languageManager.selectedLanguage))
                                .font(AppTypography.caption())
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    
                    Button(action: {
                        showingManageSubscriptions = true
                    }) {
                        HStack {
                            Label(AppStrings.tr(.manageSubscription, lang: languageManager.selectedLanguage), systemImage: "creditcard")
                                .foregroundColor(AppColors.charcoal)
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                .listRowBackground(AppColors.cardBackground)
                
                // Section 2: Reading Experience
                Section(header: Text(AppStrings.tr(.readingHeader, lang: languageManager.selectedLanguage)).foregroundColor(AppColors.antiqueGold)) {
                    // Font Size Delta
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        HStack {
                            Text(AppStrings.tr(.defaultFontSize, lang: languageManager.selectedLanguage))
                                .foregroundColor(AppColors.charcoal)
                            Spacer()
                            Text(fontLabel)
                                .font(AppTypography.caption())
                                .foregroundColor(AppColors.secondaryText)
                        }
                        
                        Slider(value: $fontSizeDelta, in: -4...8, step: 2)
                            .tint(AppColors.emeraldGreen)
                    }
                    .padding(.vertical, 4)
                    
                    // Reader Theme
                    Picker(AppStrings.tr(.readingTheme, lang: languageManager.selectedLanguage), selection: $selectedThemeRaw) {
                        ForEach(ReadingTheme.allCases) { theme in
                            Text(themeTitle(theme)).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppColors.charcoal)
                }
                .listRowBackground(AppColors.cardBackground)
                
                // Section 3: Audio Narration
                Section(header: Text(AppStrings.tr(.audioHeader, lang: languageManager.selectedLanguage)).foregroundColor(AppColors.antiqueGold)) {
                    HStack {
                        Text(AppStrings.tr(.narrationSpeed, lang: languageManager.selectedLanguage))
                            .foregroundColor(AppColors.charcoal)
                        Spacer()
                        Picker("", selection: $narrationService.playbackRateMultiplier) {
                            Text("0.75x").tag(Float(0.75))
                            Text("1.0x").tag(Float(1.0))
                            Text("1.25x").tag(Float(1.25))
                            Text("1.5x").tag(Float(1.5))
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 180)
                    }
                    
                    HStack {
                        Text(AppStrings.tr(.synthesizedVoice, lang: languageManager.selectedLanguage))
                            .foregroundColor(AppColors.charcoal)
                        Spacer()
                        Text(activeVoiceName)
                            .font(AppTypography.footnote())
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                .listRowBackground(AppColors.cardBackground)
                
                // Section 4: About & References
                Section(header: Text(AppStrings.tr(.aboutHeader, lang: languageManager.selectedLanguage)).foregroundColor(AppColors.antiqueGold)) {
                    Button(action: {
                        showingAboutSheet = true
                    }) {
                        HStack {
                            Label(AppStrings.tr(.aboutApp, lang: languageManager.selectedLanguage), systemImage: "info.circle")
                                .foregroundColor(AppColors.charcoal)
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    
                    Button(action: {
                        showingSourcesSheet = true
                    }) {
                        HStack {
                            Label(AppStrings.tr(.historicalSources, lang: languageManager.selectedLanguage), systemImage: "books.vertical")
                                .foregroundColor(AppColors.charcoal)
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    
                    Button(action: {
                        showingTermsSheet = true
                    }) {
                        HStack {
                            Label(AppStrings.tr(.termsOfUse, lang: languageManager.selectedLanguage), systemImage: "doc.text")
                                .foregroundColor(AppColors.charcoal)
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    
                    Button(action: {
                        showingPrivacySheet = true
                    }) {
                        HStack {
                            Label(AppStrings.tr(.privacyPolicy, lang: languageManager.selectedLanguage), systemImage: "hand.raised")
                                .foregroundColor(AppColors.charcoal)
                            Spacer()
                            Image(systemName: "chevron.forward")
                                .font(.system(size: 13))
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                    
                    HStack {
                        Label(AppStrings.tr(.offlineCapability, lang: languageManager.selectedLanguage), systemImage: "wifi.slash")
                            .foregroundColor(AppColors.charcoal)
                        Spacer()
                        Text(AppStrings.tr(.fullyOffline, lang: languageManager.selectedLanguage))
                            .font(AppTypography.caption())
                            .foregroundColor(AppColors.emeraldGreen)
                            .fontWeight(.semibold)
                    }
                }
                .listRowBackground(AppColors.cardBackground)
                
                // Footer
                Section {
                    VStack(spacing: AppSpacing.xs) {
                        IslamicPatternView(size: 24, strokeColor: AppColors.antiqueGold, opacity: 0.7)
                        
                        Text(isArabic ? "تطبيق السيرة والتاريخ الإسلامي" : "Islamic Storytelling")
                            .font(.system(size: 13, weight: .semibold, design: isArabic ? .default : .serif))
                            .foregroundColor(AppColors.charcoal)
                        
                        Text(isArabic ? "الإصدار 1.0.0 · صمم بكل إتقان ومحبة" : "Version 1.0.0 · Crafted with care & reverence")
                            .font(.system(size: 11))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.sm)
                }
                .listRowBackground(Color.clear)
            }
            .id(languageManager.selectedLanguage)
            .scrollContentBackground(.hidden)
            .safeAreaPadding(.bottom, 72)
        }
        .navigationTitle(AppStrings.tr(.settingsTitle, lang: languageManager.selectedLanguage))
        .manageSubscriptionsSheet(isPresented: $showingManageSubscriptions)
        .sheet(isPresented: $showingAboutSheet) {
            AboutModalView(isArabic: isArabic)
        }
        .sheet(isPresented: $showingSourcesSheet) {
            SourcesModalView(isArabic: isArabic)
        }
        .sheet(isPresented: $showingTermsSheet) {
            LegalNoticeModalView(noticeType: .terms, isArabic: isArabic)
        }
        .sheet(isPresented: $showingPrivacySheet) {
            LegalNoticeModalView(noticeType: .privacy, isArabic: isArabic)
        }
    }
    
    private var fontLabel: String {
        switch fontSizeDelta {
        case ..<(-2): return isArabic ? "صغير جداً" : "Extra Small"
        case -2..<0: return isArabic ? "صغير" : "Small"
        case 0: return isArabic ? "قياسي" : "Standard"
        case 0...2: return isArabic ? "متوسط" : "Medium"
        default: return isArabic ? "كبير" : "Large"
        }
    }
    
    private func themeTitle(_ theme: ReadingTheme) -> String {
        switch theme {
        case .parchment: return isArabic ? "مخطوطة عتيقة" : "Warm Parchment"
        case .classicWhite: return isArabic ? "أبيض ناصع" : "Classic White"
        case .night: return isArabic ? "ليلي عميق" : "Night Obsidian"
        }
    }
    
    private var activeVoiceName: String {
        let voice = narrationService.resolvedVoice(for: languageManager.selectedLanguage)
        return voice?.name ?? (isArabic ? "صوت النظام العربي" : "System Voice")
    }
}

// MARK: - About Modal View
private struct AboutModalView: View {
    let isArabic: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.parchment
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        IslamicPatternView(size: 40, strokeColor: AppColors.antiqueGold)
                            .frame(maxWidth: .infinity)
                            .padding(.top, AppSpacing.md)
                        
                        Text(isArabic ? "رؤية التطبيق" : "Our Vision")
                            .font(AppTypography.title2(isArabic: isArabic))
                            .foregroundColor(AppColors.charcoal)
                        
                        Text(isArabic
                             ? "صُمم هذا التطبيق ليقدم تجربة قراءة فاخرة وهادئة لسيرة النبي محمد ﷺ والتاريخ الإسلامي العريق، بالجمع بين عراقة التراث وتصميم أبل العصري المميز."
                             : "This application offers a tranquil, Apple Books-grade reading experience dedicated to the life of Prophet Muhammad ﷺ and Islamic historical heritage. We honor this timeless history through dignified typography, atmospheric fine art, and respectful offline narration.")
                            .font(AppTypography.readerBody(sizeDelta: -2, isArabic: isArabic))
                            .foregroundColor(AppColors.secondaryText)
                            .lineSpacing(6)
                        
                        IslamicDivider()
                        
                        Text(isArabic ? "احترام القداسة والتصوير" : "Artistic Integrity")
                            .font(AppTypography.title3(isArabic: isArabic))
                            .foregroundColor(AppColors.charcoal)
                        
                        Text(isArabic
                             ? "يلتزم التطبيق التزاماً تاماً بعدم تجسيد أو تصوير شخص النبي ﷺ أو أي من الأنبياء والصحابة الكرام. وتقتصر الرسومات على المشاهد الطبيعية والمعالم التاريخية والآثار المعمارية العريقة."
                             : "In strict accordance with traditional Islamic principles, this application never depicts Prophet Muhammad ﷺ, prophets, or sacred personalities. All artwork is strictly atmospheric landscapes, ancient topography, and architectural heritage.")
                            .font(AppTypography.caption(isArabic: isArabic))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle(isArabic ? "عن التطبيق" : "About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isArabic ? "إغلاق" : "Close") { dismiss() }
                        .foregroundColor(AppColors.emeraldGreen)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Sources Modal View
private struct SourcesModalView: View {
    let isArabic: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.parchment
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        Text(isArabic ? "المصادر التاريخية المعتمدة" : "Authoritative Sources")
                            .font(AppTypography.title2(isArabic: isArabic))
                            .foregroundColor(AppColors.charcoal)
                        
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            sourceRow(title: isArabic ? "السيرة النبوية" : "Al-Sirah al-Nabawiyyah", author: isArabic ? "ابن هشام" : "Ibn Hisham")
                            sourceRow(title: isArabic ? "الرحيق المختوم" : "The Sealed Nectar", author: isArabic ? "صفي الرحمن المباركفوري" : "Safiur Rahman al-Mubarakpuri")
                            sourceRow(title: isArabic ? "البداية والنهاية" : "Al-Bidayah wa an-Nihayah", author: isArabic ? "ابن كثير الدمشقي" : "Ibn Kathir")
                            sourceRow(title: isArabic ? "سيرة النبي ﷺ من المصادر المبكرة" : "Muhammad: His Life Based on the Earliest Sources", author: isArabic ? "مارتن لينغز" : "Martin Lings")
                        }
                    }
                    .padding(AppSpacing.lg)
                }
            }
            .navigationTitle(isArabic ? "المصادر والمراجع" : "Sources")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isArabic ? "إغلاق" : "Close") { dismiss() }
                        .foregroundColor(AppColors.emeraldGreen)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func sourceRow(title: String, author: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.charcoal)
            Text(author)
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
        .overlay(RoundedRectangle(cornerRadius: AppCornerRadius.sm).stroke(AppColors.divider, lineWidth: 1))
    }
}
