//
//  Theme.swift
//  Utilities App
//
//  Centralized theme colors with dynamic light/dark support.
//

import SwiftUI

extension Color {
    static let appBackground: Color = Color(UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor.systemBackground
        } else {
            return UIColor(hex: "#FFFFFF")
        }
    })

    static let cardBackground: Color = Color(UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor.secondarySystemBackground
        } else {
            return UIColor.white
        }
    })

    static let fieldBackground: Color = Color(UIColor { trait in
        if trait.userInterfaceStyle == .dark {
            return UIColor.tertiarySystemFill
        } else {
            return UIColor.systemGray6
        }
    })
}

extension UIColor {
    convenience init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 247, 247, 247) // default to #F7F7F7
        }
        self.init(red: CGFloat(r) / 255.0,
                  green: CGFloat(g) / 255.0,
                  blue: CGFloat(b) / 255.0,
                  alpha: CGFloat(a) / 255.0)
    }
}


