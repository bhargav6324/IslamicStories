import Foundation
import SwiftData

@Model
public final class ReadingProgress {
    @Attribute(.unique) public var chapterId: String
    public var collectionId: String
    public var lastSectionId: String?
    public var scrollRatio: Double
    public var isCompleted: Bool
    public var isBookmarked: Bool
    public var lastReadDate: Date
    
    public init(
        chapterId: String,
        collectionId: String = "seerah",
        lastSectionId: String? = nil,
        scrollRatio: Double = 0.0,
        isCompleted: Bool = false,
        isBookmarked: Bool = false,
        lastReadDate: Date = Date()
    ) {
        self.chapterId = chapterId
        self.collectionId = collectionId
        self.lastSectionId = lastSectionId
        self.scrollRatio = scrollRatio
        self.isCompleted = isCompleted
        self.isBookmarked = isBookmarked
        self.lastReadDate = lastReadDate
    }
}
