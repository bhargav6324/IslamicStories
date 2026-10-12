import Foundation
import AVFoundation
import SwiftUI

/// Playback state for speech narration reflecting the synthesizer's real-time condition.
public enum PlaybackState: String, Sendable {
    case idle
    case playing
    case paused
    case finished
}

@Observable
public final class SpeechNarrationService: NSObject, AVSpeechSynthesizerDelegate {
    public static let shared = SpeechNarrationService()
    
    // Persistent single synthesizer instance
    private let synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    // Playback state
    public private(set) var playbackState: PlaybackState = .idle
    public var isPlaying: Bool {
        playbackState == .playing
    }
    public var isPaused: Bool {
        playbackState == .paused
    }
    
    public var currentChapterId: String? = nil
    public var currentSectionIndex: Int = 0
    public var totalSectionsCount: Int = 0
    public var playbackRateMultiplier: Float = 1.0 // 0.75x, 1.0x, 1.25x, 1.5x
    
    // Text sections queue
    private var queuedTexts: [String] = []
    private var currentLanguageCode: String = "en"
    
    // Track the active utterance to prevent stale didCancel callbacks from overwriting playback state
    private var activeUtterance: AVSpeechUtterance? = nil
    
    public override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // MARK: - Audio Session Configuration
    
    private var isAudioSessionConfigured: Bool = false
    
    private func configureAudioSession() {
        guard !isAudioSessionConfigured else { return }
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .spokenAudio, options: [.duckOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
            isAudioSessionConfigured = true
        } catch {
            // Audio session configuration failure is non-fatal on simulator
        }
    }
    
    // MARK: - Voice Resolution
    
    public func resolvedVoice(for languageCode: String) -> AVSpeechSynthesisVoice? {
        let isArabic = languageCode.hasPrefix("ar")
        let targetBCP47 = isArabic ? "ar-SA" : "en-US"
        
        // 1. Try preferred locale
        if let preferredVoice = AVSpeechSynthesisVoice(language: targetBCP47) {
            return preferredVoice
        }
        
        // 2. Search available voices for matching language prefix
        let prefix = isArabic ? "ar" : "en"
        let fallback = AVSpeechSynthesisVoice.speechVoices().first { voice in
            voice.language.lowercased().hasPrefix(prefix)
        }
        
        // 3. System default fallback
        return fallback ?? AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
    }
    
    public var availableVoices: [AVSpeechSynthesisVoice] {
        return AVSpeechSynthesisVoice.speechVoices()
    }
    
    // MARK: - Content Preparation
    
    /// Prepares chapter sections for narration before playback begins.
    /// Retains existing position and state if the same chapter and language are already loaded.
    public func prepareChapter(_ chapter: StoryChapter) {
        if currentChapterId == chapter.id && currentLanguageCode == chapter.languageCode && !queuedTexts.isEmpty {
            return
        }
        
        let wasPlaying = (playbackState == .playing)
        
        // Stop current speech safely
        activeUtterance = nil
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        self.currentChapterId = chapter.id
        self.currentLanguageCode = chapter.languageCode
        
        let readableTexts = chapter.sections.compactMap { section -> String? in
            let trimmed = section.text.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        
        self.queuedTexts = readableTexts
        self.totalSectionsCount = readableTexts.count
        self.currentSectionIndex = 0
        self.playbackState = .idle
        
        if wasPlaying && !readableTexts.isEmpty {
            speakCurrentSection()
        }
    }
    
    // MARK: - Playback Controls
    
    public func startNarration(
        chapter: StoryChapter,
        startSectionIndex: Int = 0
    ) {
        prepareChapter(chapter)
        self.currentSectionIndex = max(0, min(startSectionIndex, max(0, queuedTexts.count - 1)))
        play()
    }
    
    public func play() {
        guard !queuedTexts.isEmpty else { return }
        if currentSectionIndex >= queuedTexts.count {
            currentSectionIndex = 0
        }
        speakCurrentSection()
    }
    
    public func togglePlayPause() {
        switch playbackState {
        case .playing:
            pause()
        case .paused:
            resume()
        case .idle:
            play()
        case .finished:
            currentSectionIndex = 0
            play()
        }
    }
    
    public func pause() {
        guard playbackState == .playing else { return }
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
        }
        playbackState = .paused
    }
    
    public func resume() {
        guard playbackState == .paused || playbackState == .idle else { return }
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            playbackState = .playing
        } else {
            speakCurrentSection()
        }
    }
    
    public func stop() {
        activeUtterance = nil
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        playbackState = .idle
        currentSectionIndex = 0
    }
    
    public func restartChapter(chapter: StoryChapter) {
        prepareChapter(chapter)
        currentSectionIndex = 0
        play()
    }
    
    public func updateLanguageAndContent(newChapter: StoryChapter) {
        prepareChapter(newChapter)
    }
    
    public func nextSection() {
        guard totalSectionsCount > 0, currentSectionIndex + 1 < queuedTexts.count else {
            return
        }
        
        let wasPlaying = (playbackState == .playing)
        
        // Invalidate active utterance before stopping so didCancel does not overwrite state
        self.activeUtterance = nil
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        currentSectionIndex += 1
        
        if wasPlaying {
            speakCurrentSection()
        } else {
            // Preserve paused or idle state
            if playbackState == .playing {
                playbackState = .paused
            }
        }
    }
    
    public func previousSection() {
        guard totalSectionsCount > 0, currentSectionIndex > 0 else {
            return
        }
        
        let wasPlaying = (playbackState == .playing)
        
        // Invalidate active utterance before stopping so didCancel does not overwrite state
        self.activeUtterance = nil
        if synthesizer.isSpeaking || synthesizer.isPaused {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        currentSectionIndex -= 1
        
        if wasPlaying {
            speakCurrentSection()
        } else {
            // Preserve paused or idle state
            if playbackState == .playing {
                playbackState = .paused
            }
        }
    }
    
    public func cyclePlaybackSpeed() {
        let speeds: [Float] = [0.75, 1.0, 1.25, 1.5]
        if let currentIndex = speeds.firstIndex(of: playbackRateMultiplier) {
            let nextIndex = (currentIndex + 1) % speeds.count
            playbackRateMultiplier = speeds[nextIndex]
        } else {
            playbackRateMultiplier = 1.0
        }
        
        if playbackState == .playing {
            speakCurrentSection()
        }
    }
    
    // MARK: - Private Speech Invocation
    
    private func speakCurrentSection() {
        guard currentSectionIndex >= 0 && currentSectionIndex < queuedTexts.count else {
            playbackState = .finished
            return
        }
        
        // Stop any currently speaking utterance and detach activeUtterance
        if synthesizer.isSpeaking || synthesizer.isPaused {
            activeUtterance = nil
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let text = queuedTexts[currentSectionIndex]
        let utterance = AVSpeechUtterance(string: text)
        
        if let voice = resolvedVoice(for: currentLanguageCode) {
            utterance.voice = voice
        }
        
        let baseRate = AVSpeechUtteranceDefaultSpeechRate
        let adjustedRate = baseRate * playbackRateMultiplier
        utterance.rate = min(AVSpeechUtteranceMaximumSpeechRate, max(AVSpeechUtteranceMinimumSpeechRate, adjustedRate))
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        utterance.preUtteranceDelay = 0.05
        utterance.postUtteranceDelay = 0.1
        
        self.activeUtterance = utterance
        self.playbackState = .playing
        
        configureAudioSession()
        synthesizer.speak(utterance)
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            guard utterance == self.activeUtterance else { return }
            self.playbackState = .playing
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in
            guard utterance == self.activeUtterance else { return }
            self.playbackState = .paused
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in
            guard utterance == self.activeUtterance else { return }
            self.playbackState = .playing
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            guard utterance == self.activeUtterance else { return }
            self.activeUtterance = nil
            if self.currentSectionIndex + 1 < self.queuedTexts.count {
                self.currentSectionIndex += 1
                self.speakCurrentSection()
            } else {
                self.playbackState = .finished
            }
        }
    }
    
    public func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            guard utterance == self.activeUtterance else { return }
            self.activeUtterance = nil
            self.playbackState = .idle
        }
    }
}
