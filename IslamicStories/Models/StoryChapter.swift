import Foundation

public struct StoryChapter: Identifiable, Codable, Hashable {
    public let id: String
    public let collectionId: String
    public let chapterNumber: Int
    public let languageCode: String
    public let title: String
    public let subtitle: String
    public let summary: String
    public let estimatedReadingMinutes: Int
    public let coverImageName: String
    public let isPremium: Bool?
    public let sections: [StorySection]
    public let references: [StoryReference]
    
    public init(
        id: String,
        collectionId: String,
        chapterNumber: Int,
        languageCode: String,
        title: String,
        subtitle: String,
        summary: String,
        estimatedReadingMinutes: Int,
        coverImageName: String,
        isPremium: Bool? = false,
        sections: [StorySection],
        references: [StoryReference]
    ) {
        self.id = id
        self.collectionId = collectionId
        self.chapterNumber = chapterNumber
        self.languageCode = languageCode
        self.title = title
        self.subtitle = subtitle
        self.summary = summary
        self.estimatedReadingMinutes = estimatedReadingMinutes
        self.coverImageName = coverImageName
        self.isPremium = isPremium
        self.sections = sections
        self.references = references
    }
}
