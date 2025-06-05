//
//  QuizQuestion.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 31/05/2025.
//


import SwiftUI

struct Question: Decodable {
    let number: Int
    let question: String
    let answer: String
    let type: QuestionType
    let whatLinks: [String]
}
