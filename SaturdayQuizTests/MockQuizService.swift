import Foundation
@testable import SaturdayQuiz

final class MockQuizService: QuizServiceProtocol {
    var quizResult: Result<Quiz, Error>?
    var metadataResult: Result<[QuizMetadata], Error>?
    var fetchedQuizDateString: String?
    var quizCompletion: ((Result<Quiz, Error>) -> Void)?

    func fetchCurrentQuiz(completion: @escaping (Result<Quiz, Error>) -> Void) {
        if let result = quizResult { completion(result) }
    }

    func fetchQuizMetadata(completion: @escaping (Result<[QuizMetadata], Error>) -> Void) {
        if let result = metadataResult { completion(result) }
    }

    func fetchQuiz(for dateString: String, completion: @escaping (Result<Quiz, Error>) -> Void) {
        fetchedQuizDateString = dateString
        quizCompletion = completion
        if let result = quizResult { completion(result) }
    }
}
