//
//  ScoreFormatter.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 22/06/2025.
//

import Foundation

class ScoreFormatter {
    static func formatScore(_ score: Double) -> String {
        var scoreString = "\(Int(score))"
        if (score.rounded(.down) < score) {
            scoreString.append("½")
        }
        return scoreString
    }
}
