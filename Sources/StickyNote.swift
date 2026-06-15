import Foundation
import CoreGraphics

struct StickyNote: Codable, Identifiable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var position: CGPoint
    var size: CGSize
    var colorHex: String
    var opacity: Double
    var fontSize: CGFloat
    var isPinned: Bool
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        title: String = "",
        content: String = "",
        position: CGPoint = CGPoint(x: 200, y: 200),
        size: CGSize = CGSize(width: 280, height: 260),
        colorHex: String = "#FEF08A",
        opacity: Double = 0.92,
        fontSize: CGFloat = 14,
        isPinned: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.position = position
        self.size = size
        self.colorHex = colorHex
        self.opacity = opacity
        self.fontSize = fontSize
        self.isPinned = isPinned
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
