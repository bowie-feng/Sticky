import Foundation
import CoreGraphics

struct StickyNote: Codable, Identifiable, Equatable {
    let id: UUID
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
        content: String = "",
        position: CGPoint = CGPoint(x: 200, y: 200),
        size: CGSize = CGSize(width: 260, height: 220),
        colorHex: String = "#FEF08A",
        opacity: Double = 0.92,
        fontSize: CGFloat = 14,
        isPinned: Bool = false
    ) {
        self.id = id
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
