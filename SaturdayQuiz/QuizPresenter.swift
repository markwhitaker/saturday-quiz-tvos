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
    case results(Double)
}

enum ScoreState: Double, CaseIterable, Codable {
    case none = 0.0
    case half = 0.5
    case full = 1.0

    func next() -> ScoreState {
        switch self {
        case .none:
            return .full
        case .full:
            return .half
        case .half:
            return .none
        }
    }
}

class QuizPresenter : ObservableObject {
    private var quiz: Quiz? = nil
    @Published var scores: [ScoreState] = []
    @Published var scenes: [QuizScene] = [.loading]
    @Published var sceneIndex = 0
    
    private let userDefaults = UserDefaults.standard
    private let scoresKeyPrefix = "quiz_scores_"
    private let scoresKeyDateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var currentScene: QuizScene {
        return scenes[sceneIndex]
    }
    
    var totalScore: Double {
        return scores.map(\.rawValue).reduce(0, +)
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
                    let scoresStored = self.initializeScores()
                    self.buildScenes(skipToAnswers: scoresStored)
                } catch {
                    debugPrint("Failed to decode quiz: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    private func buildScenes(skipToAnswers: Bool) {
        if (self.quiz == nil) {
            return
        }
        
        self.scenes.append(.ready(self.quiz!.date))
        
        if (!skipToAnswers) {
            for question in quiz!.questions {
                self.scenes.append(.question(question.number, question.type, question.question))
            }
        }

        self.scenes.append(.answersTitle)

        for question in quiz!.questions {
            self.scenes.append(.question(question.number, question.type, question.question))
            self.scenes.append(.questionAnswer(question.number, question.type, question.question, question.answer))
        }

        self.scenes.append(.results(totalScore))
        
        self.scenes.remove(at: 0)
    }
    
    private func initializeScores() -> Bool {
        guard let quiz = self.quiz else { return false }
        
        // Create a key based on the quiz date
        let scoresKey = getScoreStorageKey(date: quiz.date)

        // Try to load existing scores for this quiz date
        if let savedScoresData = userDefaults.data(forKey: scoresKey),
           let savedScores = try? JSONDecoder().decode([ScoreState].self, from: savedScoresData),
           savedScores.count == quiz.questions.count {
            // Use saved scores if they exist and match the question count
            self.scores = savedScores
            return true
        } else {
            // Initialize with default scores if no saved scores or count mismatch
            clearStoredScores()
            self.scores = Array(repeating: .none, count: quiz.questions.count)
            return false
        }
    }
    
    private func saveScores() {
        guard let quiz = self.quiz else { return }
        
        // Create the same key used for loading
        let scoresKey = getScoreStorageKey(date: quiz.date)
        
        // Save scores to UserDefaults
        if let encodedScores = try? JSONEncoder().encode(scores) {
            userDefaults.set(encodedScores, forKey: scoresKey)
        }
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
    
    func cycleScore(for questionNumber: Int) {
        let index = questionNumber - 1
        if index >= 0 && index < scores.count {
            scores[index] = scores[index].next()
            saveScores() // Save immediately when score changes
        }
    }
    
    private func getScoreStorageKey(date: Date) -> String {
        return scoresKeyPrefix + scoresKeyDateFormatter.string(from: date)
    }
    
    private func clearStoredScores() {
        let quizScoreKeys = userDefaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(scoresKeyPrefix) }
        for key in quizScoreKeys {
            userDefaults.removeObject(forKey: key)
        }
    }
}
