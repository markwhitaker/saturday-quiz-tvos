//
//  QuizMetadata.swift
//  SaturdayQuiz
//

import Foundation

struct QuizMetadata: Decodable, Identifiable {
    let id: String
    let date: Date
    let title: String
}
