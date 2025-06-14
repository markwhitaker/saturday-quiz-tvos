//
//  Color.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 14/06/2025.
//


import SwiftUI

enum HexColorError: Error {
    case invalidFormat
}

extension Color {
    static func fromHex(_ hex: String) throws -> Color {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)

        if (hex.count == 3) {
            hex = hex.map { String($0) + String($0) }.joined()
        }

        guard hex.count == 6 else {
            throw HexColorError.invalidFormat
        }

        var rgb: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&rgb) else {
            throw HexColorError.invalidFormat
        }

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        return Color(red: r, green: g, blue: b)
    }
}
