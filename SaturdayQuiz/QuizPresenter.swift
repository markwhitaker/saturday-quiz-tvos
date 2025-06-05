//
//  QuizPresenter.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 31/05/2025.
//


import SwiftUI

enum QuizScene {
    case loading
    case ready(Date)
    case question(Int, QuestionType, String)
    case answersTitle
    case questionAnswer(Int, QuestionType, String, String)
    case results
}

enum ScoreState: Double {
    case empty = 0.0
    case half = 0.5
    case full = 1.0
}

class QuizPresenter : ObservableObject {
    private var quiz: Quiz? = nil
//    @Published var scores: [ScoreState] = []
    @Published var scenes: [QuizScene] = [.loading]
    @Published var sceneIndex = 0
    
    var currentScene: QuizScene {
        return scenes[sceneIndex]
    }
    
    func onViewReady() {
        guard let url = URL(string: "https://eaton-bitrot.koyeb.app/api/quiz") else { return }
        debugPrint("Requesting quiz data from \(url)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    debugPrint("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    debugPrint("No data received")
                    return
                }
                
                do {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.dateDecodingStrategy = .iso8601
                    
                    let decodedQuiz = try jsonDecoder.decode(Quiz.self, from: data)
                    
                    self.quiz = decodedQuiz
                    self.buildScenes()
                    self.next()
                } catch {
                    debugPrint("Failed to decode quiz: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    private func buildScenes() {
        if (self.quiz == nil) {
            return
        }

        self.scenes.append(.ready(self.quiz!.date))
        for question in quiz!.questions {
            self.scenes.append(.question(question.number, question.type, question.question))
        }
        self.scenes.append(.answersTitle)
        for question in quiz!.questions {
            self.scenes.append(.question(question.number, question.type, question.question))
            self.scenes.append(.questionAnswer(question.number, question.type, question.question, question.answer))
        }
        self.scenes.append(.results)
    }

    func next() {
        if (self.sceneIndex < self.scenes.count - 1) {
            sceneIndex += 1
        }
    }
    
    func previous() {
        if (self.sceneIndex > 0) {
            sceneIndex -= 1
        }
    }
}
