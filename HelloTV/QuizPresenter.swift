//
//  QuizPresenter.swift
//  HelloTV
//
//  Created by Mark Whitaker on 31/05/2025.
//


import SwiftUI

class QuizPresenter: ObservableObject {
    @Published var quiz: Quiz?

    func fetchQuiz() {
        guard let url = URL(string: "https://eaton-bitrot.koyeb.app/api/quiz") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Fetch error:", error ?? "Unknown error")
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let decoded = try decoder.decode(Quiz.self, from: data)
                DispatchQueue.main.async {
                    self.quiz = decoded
                }
            } catch {
                print("Decoding error:", error)
            }
        }.resume()
    }
}