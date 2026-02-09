import SwiftUI

extension Color {
    // MARK: - Hex Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        self.init(
            red: Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8) & 0xFF) / 255,
            blue: Double(int & 0xFF) / 255
        )
    }
    
    // MARK: - Backgrounds
    static let appBackground = Color(hex: "DDC59F")

    // MARK: - Borders
    static let borderBrown = Color(hex: "7D3B22")
    static let buttonborder = Color(hex: "FFF7E0")

    // MARK: - Text
    static let primaryText = Color.black
    static let placeholderText = Color.black.opacity(0.4)

    // MARK: - Fields
    static let fieldBackground = Color.white
}
