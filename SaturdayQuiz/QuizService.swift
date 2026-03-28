//
//  QuizService.swift
//  SaturdayQuiz
//
//  Created by Mark Whitaker on 28/03/2026.
//

import Foundation

protocol QuizServiceProtocol {
    func fetchCurrentQuiz(completion: @escaping (Result<Quiz, Error>) -> Void)
    func fetchQuizMetadata(completion: @escaping (Result<[QuizMetadata], Error>) -> Void)
    func fetchQuiz(for dateString: String, completion: @escaping (Result<Quiz, Error>) -> Void)
}

class QuizService: QuizServiceProtocol {

    private func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    func fetchCurrentQuiz(completion: @escaping (Result<Quiz, Error>) -> Void) {
        guard let url = URL(string: "https://eaton-bitrot.koyeb.app/api/quiz") else { return }

        debugPrint("Requesting quiz data from \(url)")
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(URLError(.zeroByteResource)))
                    return
                }

                do {
                    let quiz = try self.makeDecoder().decode(Quiz.self, from: data)
                    completion(.success(quiz))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchQuizMetadata(completion: @escaping (Result<[QuizMetadata], Error>) -> Void) {
        guard let url = URL(string: "https://eaton-bitrot.koyeb.app/api/quiz-metadata") else { return }

        debugPrint("Requesting quiz metadata from \(url)")
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(URLError(.zeroByteResource)))
                    return
                }

                do {
                    let metadata = try self.makeDecoder().decode([QuizMetadata].self, from: data)
                    completion(.success(metadata))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    func fetchQuiz(for dateString: String, completion: @escaping (Result<Quiz, Error>) -> Void) {
        guard let url = URL(string: "https://eaton-bitrot.koyeb.app/api/quiz/\(dateString)") else { return }

        debugPrint("Loading quiz for date \(dateString)")
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(URLError(.zeroByteResource)))
                    return
                }

                do {
                    let quiz = try self.makeDecoder().decode(Quiz.self, from: data)
                    completion(.success(quiz))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}
