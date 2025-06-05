//
//  QuizPresenter.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 31/05/2025.
//


import SwiftUI

protocol QuizPresenting {
    func onViewReady(view: QuizViewing)
}

class QuizPresenter: QuizPresenting {
    @Published var quiz: Quiz?

    private var view: QuizViewing?

    func onViewReady(view: QuizViewing) {
        self.view = view

        guard let url = URL(string: "https://eaton-bitrot.koyeb.app/api/quiz") else { return }
        debugPrint("Requesting quiz data from \(url)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                debugPrint("Fetch error:", error ?? "Unknown error")
                return
            }
            do {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.dateDecodingStrategy = .iso8601
                let decodedQuiz = try jsonDecoder.decode(Quiz.self, from: data)
                DispatchQueue.main.async {
                    self.quiz = decodedQuiz
                }
            } catch {
                debugPrint("Decoding error:", error)
            }
        }.resume()
    }
}
