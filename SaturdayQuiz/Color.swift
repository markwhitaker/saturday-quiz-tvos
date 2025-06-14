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
        var rgb: UInt64 = 0

        guard hex.count == 6 else {
            throw HexColorError.invalidFormat
        }

        guard Scanner(string: hex).scanHexInt64(&rgb) else {
            throw HexColorError.invalidFormat
        }

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        return Color(red: r, green: g, blue: b)
    }
}
