import XCTest
@testable import IslamicStories

final class SpeechNarrationServiceTests: XCTestCase {
    
    var service: SpeechNarrationService!
    var sampleChapter: StoryChapter!
    
    @MainActor
    override func setUp() {
        super.setUp()
        service = SpeechNarrationService.shared
        service.stop()
        
        let sections = [
            StorySection(id: "s1", type: .heading, text: "The Dawn of Light"),
            StorySection(id: "s2", type: .paragraph, text: "In the heart of the Arabian Peninsula, Mecca was a bustling trade hub."),
            StorySection(id: "s3", type: .paragraph, text: "The people preserved ancient traditions of honor and generosity."),
            StorySection(id: "s4", type: .quote, text: "Verily, knowledge is light.")
        ]
        
        sampleChapter = StoryChapter(
            id: "seerah_1_en",
            collectionId: "seerah",
            chapterNumber: 1,
            languageCode: "en",
            title: "The Dawn of Light",
            subtitle: "Pre-Islamic Arabia",
            summary: "A story of dawn.",
            estimatedReadingMinutes: 5,
            coverImageName: "ancient_makkah",
            sections: sections,
            references: []
        )
    }
    
    @MainActor
    func testCheck1_FirstTimePlaybackStartsImmediately() {
        // 1. Prepare chapter (which happens automatically upon chapter load in ChapterReaderView)
        service.prepareChapter(sampleChapter)
        
        XCTAssertEqual(service.totalSectionsCount, 4)
        XCTAssertEqual(service.currentSectionIndex, 0)
        XCTAssertEqual(service.playbackState, .idle)
        
        // 2. User presses Play for the first time
        service.togglePlayPause()
        
        // Must immediately transition to playing
        XCTAssertEqual(service.playbackState, .playing)
        XCTAssertTrue(service.isPlaying)
        XCTAssertFalse(service.isPaused)
    }
    
    @MainActor
    func testCheck2_NextWhilePlayingAdvancesAndStaysPlaying() {
        service.prepareChapter(sampleChapter)
        service.play()
        XCTAssertEqual(service.playbackState, .playing)
        XCTAssertEqual(service.currentSectionIndex, 0)
        
        // While playing, press Next
        service.nextSection()
        
        XCTAssertEqual(service.currentSectionIndex, 1)
        XCTAssertEqual(service.playbackState, .playing)
        XCTAssertTrue(service.isPlaying)
    }
    
    @MainActor
    func testCheck3_PreviousWhilePlayingRewindsAndStaysPlaying() {
        service.prepareChapter(sampleChapter)
        service.play()
        service.nextSection() // Go to section 1
        XCTAssertEqual(service.currentSectionIndex, 1)
        XCTAssertEqual(service.playbackState, .playing)
        
        // While playing, press Previous
        service.previousSection()
        
        XCTAssertEqual(service.currentSectionIndex, 0)
        XCTAssertEqual(service.playbackState, .playing)
        XCTAssertTrue(service.isPlaying)
    }
    
    @MainActor
    func testCheck4_PauseThenNextRemainsPausedUntilPlay() {
        service.prepareChapter(sampleChapter)
        service.play()
        XCTAssertEqual(service.playbackState, .playing)
        
        // Pause narration
        service.pause()
        XCTAssertEqual(service.playbackState, .paused)
        XCTAssertFalse(service.isPlaying)
        XCTAssertTrue(service.isPaused)
        
        // Press Next while paused
        service.nextSection()
        
        // Must remain paused at new section
        XCTAssertEqual(service.currentSectionIndex, 1)
        XCTAssertEqual(service.playbackState, .paused)
        XCTAssertFalse(service.isPlaying)
        
        // User presses Play
        service.togglePlayPause()
        XCTAssertEqual(service.playbackState, .playing)
        XCTAssertTrue(service.isPlaying)
    }
    
    @MainActor
    func testCheck5_CloseAndReopenContinuesFunctioning() {
        service.prepareChapter(sampleChapter)
        service.play()
        
        // Close audio player (invokes stop)
        service.stop()
        XCTAssertEqual(service.playbackState, .idle)
        XCTAssertEqual(service.currentSectionIndex, 0)
        // Content should still be available
        XCTAssertEqual(service.totalSectionsCount, 4)
        
        // Reopen audio player and press Play
        service.togglePlayPause()
        XCTAssertEqual(service.playbackState, .playing)
        XCTAssertTrue(service.isPlaying)
        
        // Next / Previous still function
        service.nextSection()
        XCTAssertEqual(service.currentSectionIndex, 1)
        XCTAssertEqual(service.playbackState, .playing)
    }
}
