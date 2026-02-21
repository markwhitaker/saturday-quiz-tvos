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

    static func qrPayload(score: Double, scores: [ScoreState]) -> String {
        let scoreStr = formatScore(score)
        let list = formatCorrectList(scores: scores)
        return "\(scoreStr)...\n\n\(list)"
    }

    private static func formatCorrectList(scores: [ScoreState]) -> String {
        let items = scores.enumerated().compactMap { (index, state) -> String? in
            switch state {
            case .full:
                return "\(index + 1)"
            case .half:
                return "\(index + 1) (half)"
            case .none:
                return nil
            }
        }
        return items.joined(separator: ", ")
    }
}
