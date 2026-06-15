import SwiftUI

// MARK: - Hex String Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b, a: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
            a = 1.0
        case 8:
            a = Double((int >> 24) & 0xFF) / 255.0
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 1; g = 1; b = 0; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    var hexString: String {
        guard let components = NSColor(self).cgColor.components else {
            return "#FEF08A"
        }
        let r: Int, g: Int, b: Int
        if components.count >= 3 {
            r = Int(components[0] * 255.0)
            g = Int(components[1] * 255.0)
            b = Int(components[2] * 255.0)
        } else {
            r = 255; g = 255; b = 0
        }
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - Preset Palette
struct NotePalette {
    static let colors: [(name: String, hex: String)] = [
        ("黄色",  "#FEF08A"),
        ("绿色",  "#BBF7D0"),
        ("蓝色",  "#BFDBFE"),
        ("粉色",  "#FBCFE8"),
        ("紫色",  "#DDD6FE"),
        ("橙色",  "#FED7AA"),
        ("白色",  "#F5F5F5"),
        ("青色",  "#99F6E4"),
    ]

    static let defaultHex = "#FEF08A"
}
