//
//  QuizPresenter.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 31/05/2025.
//

import SwiftUI

enum QuizScene {
    case loading
    case quizPicker
    case ready(date: Date)
    case question(number: Int, type: QuestionType, question: String)
    case answersTitle
    case questionAnswer(number: Int, type: QuestionType, question: String, answer: String)
    case results
    case shareResults
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
    @Published var quizMetadata: [QuizMetadata] = []
    @Published var pickerSelectedIndex: Int = 0

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
        fetchCurrentQuiz()
        fetchQuizMetadata()
    }

    private func fetchCurrentQuiz() {
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

    private func fetchQuizMetadata() {
        guard let url = URL(string: "https://eaton-bitrot.koyeb.app/api/quiz-metadata") else { return }

        debugPrint("Requesting quiz metadata from \(url)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    debugPrint("Quiz metadata network error: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    debugPrint("No quiz metadata received")
                    return
                }

                do {
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.dateDecodingStrategy = .iso8601
                    self.quizMetadata = try jsonDecoder.decode([QuizMetadata].self, from: data)
                } catch {
                    debugPrint("Failed to decode quiz metadata: \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    private func buildScenes(skipToAnswers: Bool) {
        guard let quiz = self.quiz else { return }

        var localScenes: [QuizScene] = []

        localScenes.append(.quizPicker)
        localScenes.append(.ready(date: quiz.date))

        if (!skipToAnswers) {
            for question in quiz.questions {
                localScenes.append(.question(
                    number: question.number,
                    type: question.type,
                    question: question.question))
            }
            localScenes.append(.answersTitle)
        }

        for question in quiz.questions {
            localScenes.append(.question(
                number: question.number,
                type: question.type,
                question: question.question))
            localScenes.append(.questionAnswer(
                number: question.number,
                type: question.type,
                question: question.question,
                answer: question.answer))
        }

        localScenes.append(.results)

        localScenes.append(.shareResults)

        scenes = localScenes
        sceneIndex = 1
    }

    private func initializeScores() -> Bool {
        guard let quiz = self.quiz else { return false }

        let scoresKey = getScoreStorageKey(date: quiz.date)

        if let savedScoresData = userDefaults.data(forKey: scoresKey),
           let savedScores = try? JSONDecoder().decode([ScoreState].self, from: savedScoresData) {
            scores = savedScores
            return true
        } else {
            pruneStoredScores()
            scores = Array(repeating: .none, count: quiz.questions.count)
            return false
        }
    }

    private func saveScores() {
        guard let quiz = self.quiz else { return }

        let scoresKey = getScoreStorageKey(date: quiz.date)

        if let encodedScores = try? JSONEncoder().encode(scores) {
            userDefaults.set(encodedScores, forKey: scoresKey)
        }
    }

    func next() {
        if (sceneIndex < scenes.count - 1) {
            sceneIndex += 1
        } else {
            exit(0)
        }
    }

    func previous() {
        if (sceneIndex > 0) {
            sceneIndex -= 1
        }
    }

    func cycleScore() {
        if case .questionAnswer(let questionNumber, _, _, _) = currentScene {
            let index = questionNumber - 1
            if index >= 0 && index < scores.count {
                scores[index] = scores[index].next()
                saveScores()
            }
        }
    }

    func pickerUp() {
        if pickerSelectedIndex > 0 {
            pickerSelectedIndex -= 1
        }
    }

    func pickerDown() {
        if pickerSelectedIndex < quizMetadata.count - 1 {
            pickerSelectedIndex += 1
        }
    }

    func selectPickerItem() {
        guard !quizMetadata.isEmpty else { return }
        let selected = quizMetadata[pickerSelectedIndex]
        let dateString = scoresKeyDateFormatter.string(from: selected.date)

        scenes = [.loading]
        sceneIndex = 0

        guard let url = URL(string: "https://eaton-bitrot.koyeb.app/api/quiz/\(dateString)") else { return }

        debugPrint("Loading quiz for date \(dateString)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    debugPrint("Network error loading quiz by date: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    debugPrint("No data received for quiz date \(dateString)")
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
                    debugPrint("Failed to decode quiz for date \(dateString): \(error.localizedDescription)")
                }
            }
        }.resume()
    }

    private func getScoreStorageKey(date: Date) -> String {
        return scoresKeyPrefix + scoresKeyDateFormatter.string(from: date)
    }

    private func pruneStoredScores() {
        let quizScoreKeys = userDefaults.dictionaryRepresentation().keys
            .filter { $0.hasPrefix(scoresKeyPrefix) }
            .sorted(by: >)
        for key in quizScoreKeys.dropFirst(10) {
            userDefaults.removeObject(forKey: key)
        }
    }
}
