import Foundation

public enum StorySectionType: String, Codable, CaseIterable {
    case heading
    case paragraph
    case image
    case quote
}

public struct StorySection: Identifiable, Codable, Hashable {
    public let id: String
    public let type: StorySectionType
    public let text: String
    public let imageName: String?
    
    public init(id: String, type: StorySectionType, text: String, imageName: String? = nil) {
        self.id = id
        self.type = type
        self.text = text
        self.imageName = imageName
    }
}
