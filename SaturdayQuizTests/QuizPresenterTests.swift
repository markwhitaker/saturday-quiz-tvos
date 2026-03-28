import XCTest
@testable import SaturdayQuiz

final class QuizPresenterTests: XCTestCase {

    var mockService: MockQuizService!
    var testDefaults: UserDefaults!
    var presenter: QuizPresenter!

    override func setUp() {
        super.setUp()
        mockService = MockQuizService()
        testDefaults = UserDefaults(suiteName: UUID().uuidString)!
        presenter = QuizPresenter(service: mockService, userDefaults: testDefaults)
    }

    override func tearDown() {
        testDefaults.removePersistentDomain(forName: testDefaults.description)
        super.tearDown()
    }

    // Helper to build a fake Quiz with N questions
    func makeQuiz(questionCount: Int = 3, date: Date = Date(timeIntervalSince1970: 0)) -> Quiz {
        let questions = (1...questionCount).map { i in
            Question(number: i, question: "Q\(i)", answer: "A\(i)", type: .normal, whatLinks: [])
        }
        return Quiz(id: "test", date: date, title: "Test Quiz", questions: questions)
    }

    // MARK: - Scene building tests

    // New quiz (no stored scores): quizPicker → ready → Q×N → answersTitle → (Q+QA)×N → results → shareResults
    func testNewQuizBuildsFullSceneSequence() {
        mockService.quizResult = .success(makeQuiz(questionCount: 2))
        presenter.onViewReady()

        // Expected: quizPicker, ready, q1, q2, answersTitle, q1, qa1, q2, qa2, results, shareResults = 11 scenes
        XCTAssertEqual(presenter.scenes.count, 11)
        XCTAssertEqual(presenter.sceneIndex, 1)

        if case .quizPicker = presenter.scenes[0] {} else { XCTFail("scenes[0] should be quizPicker") }
        if case .ready = presenter.scenes[1] {} else { XCTFail("scenes[1] should be ready") }
        if case .question = presenter.scenes[2] {} else { XCTFail("scenes[2] should be question") }
        if case .question = presenter.scenes[3] {} else { XCTFail("scenes[3] should be question") }
        if case .answersTitle = presenter.scenes[4] {} else { XCTFail("scenes[4] should be answersTitle") }
        if case .question = presenter.scenes[5] {} else { XCTFail("scenes[5] should be question") }
        if case .questionAnswer = presenter.scenes[6] {} else { XCTFail("scenes[6] should be questionAnswer") }
        if case .question = presenter.scenes[7] {} else { XCTFail("scenes[7] should be question") }
        if case .questionAnswer = presenter.scenes[8] {} else { XCTFail("scenes[8] should be questionAnswer") }
        if case .results = presenter.scenes[9] {} else { XCTFail("scenes[9] should be results") }
        if case .shareResults = presenter.scenes[10] {} else { XCTFail("scenes[10] should be shareResults") }
    }

    // Returning quiz (scores stored): quizPicker → ready → (Q+QA)×N → results → shareResults (no question-only section)
    func testQuizWithStoredScoresSkipsQuestionSection() {
        let quiz = makeQuiz(questionCount: 2, date: Date(timeIntervalSince1970: 0))
        // Store scores for this quiz
        let scoresKey = "quiz_scores_1970-01-01"
        let encoded = try! JSONEncoder().encode([ScoreState.full, ScoreState.half])
        testDefaults.set(encoded, forKey: scoresKey)

        mockService.quizResult = .success(quiz)
        presenter.onViewReady()

        // Expected: quizPicker, ready, q1, qa1, q2, qa2, results, shareResults = 8 scenes (no answersTitle, no question-only)
        XCTAssertEqual(presenter.scenes.count, 8)
        XCTAssertEqual(presenter.scores, [.full, .half])
    }

    // MARK: - Navigation tests

    func testNextIncrementsSceneIndex() {
        mockService.quizResult = .success(makeQuiz())
        presenter.onViewReady()
        let initial = presenter.sceneIndex
        presenter.next()
        XCTAssertEqual(presenter.sceneIndex, initial + 1)
    }

    func testPreviousDecrementsSceneIndex() {
        mockService.quizResult = .success(makeQuiz())
        presenter.onViewReady()
        presenter.next() // move to index 2
        let before = presenter.sceneIndex
        presenter.previous()
        XCTAssertEqual(presenter.sceneIndex, before - 1)
    }

    func testPreviousAtZeroDoesNotGoNegative() {
        presenter.sceneIndex = 0
        presenter.previous()
        XCTAssertEqual(presenter.sceneIndex, 0)
    }

    // MARK: - Score cycling tests

    func testCycleScoreOnQuestionAnswerScene() {
        mockService.quizResult = .success(makeQuiz(questionCount: 3))
        presenter.onViewReady()

        // Navigate to first questionAnswer scene
        // Scene layout for 3 questions: [0]quizPicker [1]ready [2]q1 [3]q2 [4]q3 [5]answersTitle [6]q1 [7]qa1...
        // sceneIndex is 1 (ready). Navigate to index 7 (qa1).
        presenter.sceneIndex = 7  // questionAnswer(number: 1, ...)
        XCTAssertEqual(presenter.scores[0], .none)
        presenter.cycleScore()
        XCTAssertEqual(presenter.scores[0], .full)
        presenter.cycleScore()
        XCTAssertEqual(presenter.scores[0], .half)
        presenter.cycleScore()
        XCTAssertEqual(presenter.scores[0], .none)
    }

    func testCycleScoreOnNonAnswerSceneDoesNothing() {
        mockService.quizResult = .success(makeQuiz(questionCount: 2))
        presenter.onViewReady()
        presenter.sceneIndex = 1 // ready scene
        let scoresBefore = presenter.scores
        presenter.cycleScore()
        XCTAssertEqual(presenter.scores, scoresBefore)
    }

    // MARK: - Score persistence tests

    func testCycleScoreSavesToUserDefaults() {
        let quiz = makeQuiz(questionCount: 1, date: Date(timeIntervalSince1970: 0))
        mockService.quizResult = .success(quiz)
        presenter.onViewReady()

        // Navigate to the questionAnswer scene (index 5 for 1 question: quizPicker,ready,q1,answersTitle,q1,qa1,results,shareResults)
        presenter.sceneIndex = 5
        presenter.cycleScore()

        let key = "quiz_scores_1970-01-01"
        let savedData = testDefaults.data(forKey: key)
        XCTAssertNotNil(savedData)
        let savedScores = try? JSONDecoder().decode([ScoreState].self, from: savedData!)
        XCTAssertEqual(savedScores, [.full])
    }

    // MARK: - Picker navigation tests

    func testPickerDownIncrementsIndex() {
        presenter.quizMetadata = [
            QuizMetadata(id: "1", date: Date(), title: "Q1"),
            QuizMetadata(id: "2", date: Date(), title: "Q2"),
        ]
        presenter.pickerSelectedIndex = 0
        presenter.pickerDown()
        XCTAssertEqual(presenter.pickerSelectedIndex, 1)
    }

    func testPickerDownDoesNotExceedBounds() {
        presenter.quizMetadata = [QuizMetadata(id: "1", date: Date(), title: "Q1")]
        presenter.pickerSelectedIndex = 0
        presenter.pickerDown()
        XCTAssertEqual(presenter.pickerSelectedIndex, 0)
    }

    func testPickerUpDecrementsIndex() {
        presenter.quizMetadata = [
            QuizMetadata(id: "1", date: Date(), title: "Q1"),
            QuizMetadata(id: "2", date: Date(), title: "Q2"),
        ]
        presenter.pickerSelectedIndex = 1
        presenter.pickerUp()
        XCTAssertEqual(presenter.pickerSelectedIndex, 0)
    }

    func testPickerUpDoesNotGoBelowZero() {
        presenter.pickerSelectedIndex = 0
        presenter.pickerUp()
        XCTAssertEqual(presenter.pickerSelectedIndex, 0)
    }

    func testSelectPickerItemWithEmptyMetadataDoesNothing() {
        presenter.quizMetadata = []
        presenter.selectPickerItem() // should not crash
        XCTAssertEqual(presenter.sceneIndex, 0) // unchanged
    }

    func testSelectPickerItemFetchesQuizByDate() {
        let date = Date(timeIntervalSince1970: 0)
        presenter.quizMetadata = [QuizMetadata(id: "1", date: date, title: "Q1")]
        presenter.pickerSelectedIndex = 0
        mockService.quizResult = .success(makeQuiz(date: date))
        presenter.selectPickerItem()
        XCTAssertEqual(mockService.fetchedQuizDateString, "1970-01-01")
    }
}
