//
//  Quiz.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 31/05/2025.
//


import SwiftUI

struct Quiz: Decodable {
    let id: String
    let date: Date
    let title: String
    let questions: [Question]
}
