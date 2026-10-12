import Foundation
import SwiftData
import SwiftUI

@Observable
public final class ReadingProgressStore {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func getProgress(for chapterId: String) -> ReadingProgress? {
        var descriptor = FetchDescriptor<ReadingProgress>(
            predicate: #Predicate<ReadingProgress> { progress in
                progress.chapterId == chapterId
            }
        )
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }
    
    public func updateProgress(
        chapterId: String,
        collectionId: String = "seerah",
        lastSectionId: String? = nil,
        scrollRatio: Double = 0.0,
        isCompleted: Bool = false
    ) {
        if let existing = getProgress(for: chapterId) {
            if let sectionId = lastSectionId {
                existing.lastSectionId = sectionId
            }
            if scrollRatio > existing.scrollRatio {
                existing.scrollRatio = min(1.0, scrollRatio)
            }
            if isCompleted {
                existing.isCompleted = true
                existing.scrollRatio = 1.0
            }
            existing.lastReadDate = Date()
        } else {
            let newProgress = ReadingProgress(
                chapterId: chapterId,
                collectionId: collectionId,
                lastSectionId: lastSectionId,
                scrollRatio: scrollRatio,
                isCompleted: isCompleted,
                isBookmarked: false,
                lastReadDate: Date()
            )
            modelContext.insert(newProgress)
        }
        try? modelContext.save()
    }
    
    @discardableResult
    public func toggleBookmark(chapterId: String, collectionId: String = "seerah") -> Bool {
        if let existing = getProgress(for: chapterId) {
            existing.isBookmarked.toggle()
            existing.lastReadDate = Date()
            try? modelContext.save()
            return existing.isBookmarked
        } else {
            let newProgress = ReadingProgress(
                chapterId: chapterId,
                collectionId: collectionId,
                lastSectionId: nil,
                scrollRatio: 0.0,
                isCompleted: false,
                isBookmarked: true,
                lastReadDate: Date()
            )
            modelContext.insert(newProgress)
            try? modelContext.save()
            return true
        }
    }
    
    public func isBookmarked(chapterId: String) -> Bool {
        return getProgress(for: chapterId)?.isBookmarked ?? false
    }
    
    public func fetchRecentProgress() -> ReadingProgress? {
        var descriptor = FetchDescriptor<ReadingProgress>(
            predicate: #Predicate<ReadingProgress> { progress in
                progress.scrollRatio > 0.01 && !progress.isCompleted
            },
            sortBy: [SortDescriptor(\.lastReadDate, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }
    
    public func fetchBookmarkedProgress() -> [ReadingProgress] {
        let descriptor = FetchDescriptor<ReadingProgress>(
            predicate: #Predicate<ReadingProgress> { progress in
                progress.isBookmarked == true
            },
            sortBy: [SortDescriptor(\.lastReadDate, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}
