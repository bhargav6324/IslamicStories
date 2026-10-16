import XCTest
@testable import IslamicStories

final class SeerahContentTests: XCTestCase {
    
    let repository = ContentRepository.shared
    
    func testAllChaptersLoadInBothLanguages() throws {
        for chapterNum in 1...80 {
            // Test English
            let enChapter = try repository.loadChapter(
                collectionId: "seerah",
                chapterNumber: chapterNum,
                languageCode: "en"
            )
            XCTAssertEqual(enChapter.chapterNumber, chapterNum)
            XCTAssertEqual(enChapter.languageCode, "en")
            XCTAssertFalse(enChapter.title.isEmpty)
            XCTAssertFalse(enChapter.sections.isEmpty)
            
            // Test Arabic
            let arChapter = try repository.loadChapter(
                collectionId: "seerah",
                chapterNumber: chapterNum,
                languageCode: "ar"
            )
            XCTAssertEqual(arChapter.chapterNumber, chapterNum)
            XCTAssertEqual(arChapter.languageCode, "ar")
            XCTAssertFalse(arChapter.title.isEmpty)
            XCTAssertFalse(arChapter.sections.isEmpty)
            
            // Verify IDs match exactly
            XCTAssertEqual(enChapter.id, arChapter.id)
            XCTAssertEqual(enChapter.sections.count, arChapter.sections.count, "Section counts must match for chapter \(chapterNum)")
            
            for (index, enSec) in enChapter.sections.enumerated() {
                let arSec = arChapter.sections[index]
                XCTAssertEqual(enSec.id, arSec.id, "Section ID mismatch at index \(index) in chapter \(chapterNum)")
                XCTAssertEqual(enSec.type, arSec.type, "Section type mismatch for \(enSec.id)")
                XCTAssertEqual(enSec.imageName, arSec.imageName, "Section imageName mismatch for \(enSec.id)")
                XCTAssertFalse(enSec.text.isEmpty, "English text empty for \(enSec.id)")
                XCTAssertFalse(arSec.text.isEmpty, "Arabic text empty for \(arSec.id)")
            }
            
            // Verify References match
            XCTAssertEqual(enChapter.references.count, arChapter.references.count, "Reference count mismatch for chapter \(chapterNum)")
            for (refIndex, enRef) in enChapter.references.enumerated() {
                let arRef = arChapter.references[refIndex]
                XCTAssertEqual(enRef.id, arRef.id, "Reference ID mismatch at index \(refIndex)")
            }
        }
    }
    
    func testSeerahCollectionSummariesCount() {
        let enSummaries = repository.getChapterSummaries(collectionId: "seerah", languageCode: "en")
        XCTAssertEqual(enSummaries.count, 80, "Expected 80 chapters in English Seerah summaries")
        for (i, chap) in enSummaries.enumerated() {
            XCTAssertEqual(chap.chapterNumber, i + 1)
        }
        
        let arSummaries = repository.getChapterSummaries(collectionId: "seerah", languageCode: "ar")
        XCTAssertEqual(arSummaries.count, 80, "Expected 80 chapters in Arabic Seerah summaries")
        for (i, chap) in arSummaries.enumerated() {
            XCTAssertEqual(chap.chapterNumber, i + 1)
        }
    }
    
    func testWordCountAndHistoricalSubstance() throws {
        for chapterNum in 1...5 {
            let chapter = try repository.loadChapter(
                collectionId: "seerah",
                chapterNumber: chapterNum,
                languageCode: "en"
            )
            
            let totalWords = chapter.sections
                .filter { $0.type == .paragraph || $0.type == .quote }
                .map { $0.text.split(separator: " ").count }
                .reduce(0, +)
            
            print("Chapter \(chapterNum): \(chapter.title) has \(totalWords) English words across \(chapter.sections.count) sections.")
            XCTAssertGreaterThanOrEqual(totalWords, 900, "Chapter \(chapterNum) should have approximately 1000+ words")
        }
    }
}
