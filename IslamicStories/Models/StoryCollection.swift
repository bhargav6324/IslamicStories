import Foundation

public struct StoryCollection: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let description: String
    public let coverImageName: String
    public let isComingSoon: Bool
    public let totalChapters: Int
    
    public init(
        id: String,
        title: String,
        subtitle: String,
        description: String,
        coverImageName: String,
        isComingSoon: Bool = false,
        totalChapters: Int = 0
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.coverImageName = coverImageName
        self.isComingSoon = isComingSoon
        self.totalChapters = totalChapters
    }
}
