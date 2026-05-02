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

    private let service: QuizServiceProtocol
    private let userDefaults: UserDefaults
    private let scoresKeyPrefix = "quiz_scores_"

    init(service: QuizServiceProtocol = QuizService(), userDefaults: UserDefaults = .standard) {
        self.service = service
        self.userDefaults = userDefaults
    }

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
        service.fetchCurrentQuiz { result in
            switch result {
            case .success(let quiz):
                self.quiz = quiz
                let scoresStored = self.initializeScores()
                self.buildScenes(skipToAnswers: scoresStored)
            case .failure(let error):
                debugPrint("Network error fetching quiz: \(error.localizedDescription)")
            }
        }
    }

    private func fetchQuizMetadata() {
        service.fetchQuizMetadata { result in
            switch result {
            case .success(let metadata):
                self.quizMetadata = metadata
            case .failure(let error):
                debugPrint("Network error fetching quiz metadata: \(error.localizedDescription)")
            }
        }
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
            // Go back to the Ready screen (skip date picker at index 0)
            buildScenes(skipToAnswers: true)
            sceneIndex = 1
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

        service.fetchQuiz(for: dateString) { result in
            switch result {
            case .success(let quiz):
                self.quiz = quiz
                let scoresStored = self.initializeScores()
                self.buildScenes(skipToAnswers: scoresStored)
            case .failure(let error):
                debugPrint("Network error loading quiz for date \(dateString): \(error.localizedDescription)")
            }
        }
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
