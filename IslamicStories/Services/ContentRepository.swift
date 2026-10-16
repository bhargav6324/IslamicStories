import Foundation
import SwiftUI

public enum ContentError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String)
    case translationUnavailable(String)
    
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Content file not found at: \(path)"
        case .decodingFailed(let reason):
            return "Failed to parse chapter content: \(reason)"
        case .translationUnavailable(let lang):
            return "Translation is currently unavailable for language code: \(lang)"
        }
    }
}

@Observable
public final class ContentRepository {
    public static let shared = ContentRepository()
    
    // In-memory cache of decoded chapters: Key is "\(chapterId)_\(languageCode)" (e.g. "seerah_001_en")
    private var chapterCache: [String: StoryChapter] = [:]
    
    public init() {
        // Pre-warm local bundled chapters into memory for instantaneous language switching
        prewarmBundledContent()
    }
    
    private func prewarmBundledContent() {
        for lang in ["en", "ar"] {
            for chapNum in 1...40 {
                _ = try? loadChapterFromBundle(collectionId: "seerah", chapterNumber: chapNum, languageCode: lang)
            }
        }
    }
    
    // MARK: - Collections
    
    public func getAvailableCollections(languageCode: String) -> [StoryCollection] {
        let isArabic = languageCode.hasPrefix("ar")
        return [
            StoryCollection(
                id: "seerah",
                title: isArabic ? "السيرة النبوية" : "The Seerah",
                subtitle: isArabic ? "سيرة الحبيب المصطفى ﷺ" : "The Life of Prophet Muhammad ﷺ",
                description: isArabic
                    ? "رحلة إيمانية مباركة عبر تفاصيل سيرة خير خلق الله، من العهد المكي وبشائر الفجر إلى الرسالة الخالدة."
                    : "Journey through the life of the Prophet, from the world before his birth to the legacy that continues to inspire millions.",
                coverImageName: "SeerahCover",
                isComingSoon: false,
                totalChapters: 80
            ),
            StoryCollection(
                id: "prophets",
                title: isArabic ? "قصص الأنبياء" : "Stories of the Prophets",
                subtitle: isArabic ? "من آدم إلى عيسى عليهم السلام" : "From Adam to Jesus (peace be upon them)",
                description: isArabic
                    ? "قصص الصبر واليقين ورسالات التوحيد عبر موكب الأنبياء والمرسلين."
                    : "Stories of steadfast faith, divine revelation, and moral courage across generations of messengers.",
                coverImageName: "AncientMakkah",
                isComingSoon: true,
                totalChapters: 0
            ),
            StoryCollection(
                id: "companions",
                title: isArabic ? "سير الصحابة" : "The Companions",
                subtitle: isArabic ? "رجال ونساء صدقوا ما عاهدوا الله عليه" : "Men & Women Around the Messenger ﷺ",
                description: isArabic
                    ? "معالم البطولة والتضحية في حياة صحابة رسول الله ﷺ الذين شيدوا صرح التاريخ."
                    : "Tales of devotion, sacrifice, and integrity from the remarkable circle of early believers.",
                coverImageName: "DesertCaravan",
                isComingSoon: true,
                totalChapters: 0
            ),
            StoryCollection(
                id: "islamic_history",
                title: isArabic ? "تاريخ الحضارة الإسلامية" : "Islamic History",
                subtitle: isArabic ? "عصور العلم والمعرفة" : "Eras of Knowledge and Civilization",
                description: isArabic
                    ? "صفحات مضيئة من تاريخ الإيمان والعمران والمراكز العلمية الكبرى."
                    : "Exploring the intellectual renaissance, architectural triumphs, and profound cultural exchanges of the classical world.",
                coverImageName: "ArabiaLandscape",
                isComingSoon: true,
                totalChapters: 0
            )
        ]
    }
    
    // MARK: - Chapter Fetching
    
    public func loadChapter(
        collectionId: String,
        chapterNumber: Int,
        languageCode: String
    ) throws -> StoryChapter {
        let normalizedLang = languageCode.hasPrefix("ar") ? "ar" : "en"
        let paddedNumber = String(format: "%03d", chapterNumber)
        let chapterId = "\(collectionId)_\(paddedNumber)"
        let cacheKey = "\(chapterId)_\(normalizedLang)"
        
        // Instant in-memory cache lookup
        if let cached = chapterCache[cacheKey] {
            return cached
        }
        
        return try loadChapterFromBundle(collectionId: collectionId, chapterNumber: chapterNumber, languageCode: normalizedLang)
    }
    
    public func loadChapter(chapterId: String, languageCode: String) throws -> StoryChapter {
        let normalizedLang = languageCode.hasPrefix("ar") ? "ar" : "en"
        let cacheKey = "\(chapterId)_\(normalizedLang)"
        
        if let cached = chapterCache[cacheKey] {
            return cached
        }
        
        // Extract components e.g. "seerah_001"
        let parts = chapterId.split(separator: "_")
        if parts.count >= 2, let number = Int(parts[1]) {
            return try loadChapter(collectionId: String(parts[0]), chapterNumber: number, languageCode: normalizedLang)
        }
        
        throw ContentError.fileNotFound("\(chapterId).json")
    }
    
    private func loadChapterFromBundle(
        collectionId: String,
        chapterNumber: Int,
        languageCode: String
    ) throws -> StoryChapter {
        let normalizedLang = languageCode.hasPrefix("ar") ? "ar" : "en"
        let paddedNumber = String(format: "%03d", chapterNumber)
        let resourceName = "chapter_\(paddedNumber)"
        let chapterId = "\(collectionId)_\(paddedNumber)"
        let cacheKey = "\(chapterId)_\(normalizedLang)"
        
        // 1. Direct bundle search for Resources/Content/{lang}/{collectionId}/{resourceName}.json
        let subpaths = [
            "Content/\(normalizedLang)/\(collectionId)/\(resourceName)",
            "Resources/Content/\(normalizedLang)/\(collectionId)/\(resourceName)",
            "\(normalizedLang)/\(collectionId)/\(resourceName)",
            resourceName
        ]
        
        var fileURL: URL?
        for path in subpaths {
            if let url = Bundle.main.url(forResource: path, withExtension: "json") {
                fileURL = url
                break
            }
        }
        
        if fileURL == nil {
            fileURL = Bundle.main.url(forResource: resourceName, withExtension: "json", subdirectory: "Content/\(normalizedLang)/\(collectionId)")
        }
        
        if fileURL == nil, let bundleResourceURL = Bundle.main.resourceURL {
            let candidatePaths = [
                bundleResourceURL.appendingPathComponent("Content").appendingPathComponent(normalizedLang).appendingPathComponent(collectionId).appendingPathComponent("\(resourceName).json"),
                bundleResourceURL.appendingPathComponent("Resources").appendingPathComponent("Content").appendingPathComponent(normalizedLang).appendingPathComponent(collectionId).appendingPathComponent("\(resourceName).json")
            ]
            for path in candidatePaths {
                if FileManager.default.fileExists(atPath: path.path) {
                    fileURL = path
                    break
                }
            }
        }
        
        // Fallback to English if translation is missing
        if fileURL == nil && normalizedLang != "en" {
            let fallbackKey = "\(chapterId)_en"
            if let cachedEnglish = chapterCache[fallbackKey] {
                return cachedEnglish
            }
            return try loadChapterFromBundle(collectionId: collectionId, chapterNumber: chapterNumber, languageCode: "en")
        }
        
        guard let validURL = fileURL else {
            throw ContentError.fileNotFound("\(normalizedLang)/\(collectionId)/\(resourceName).json")
        }
        
        do {
            let data = try Data(contentsOf: validURL)
            let decoder = JSONDecoder()
            let chapter = try decoder.decode(StoryChapter.self, from: data)
            chapterCache[cacheKey] = chapter
            return chapter
        } catch {
            throw ContentError.decodingFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Chapter Listing
    
    public func getChapterSummaries(
        collectionId: String,
        languageCode: String
    ) -> [StoryChapter] {
        var chapters: [StoryChapter] = []
        for chapterNumber in 1...100 {
            if let chapter = try? loadChapter(collectionId: collectionId, chapterNumber: chapterNumber, languageCode: languageCode) {
                chapters.append(chapter)
            } else {
                break
            }
        }
        return chapters
    }
}
