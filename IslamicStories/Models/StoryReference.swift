import Foundation

public struct StoryReference: Identifiable, Codable, Hashable {
    public let id: String
    public let title: String
    public let author: String
    public let source: String
    public let notes: String?
    
    public init(id: String, title: String, author: String, source: String, notes: String? = nil) {
        self.id = id
        self.title = title
        self.author = author
        self.source = source
        self.notes = notes
    }
}
