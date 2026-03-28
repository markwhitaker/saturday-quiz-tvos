import XCTest
@testable import SaturdayQuiz

final class ScoreStateTests: XCTestCase {
    func testNoneBecomesFullOnNext() { XCTAssertEqual(ScoreState.none.next(), .full) }
    func testFullBecomesHalfOnNext() { XCTAssertEqual(ScoreState.full.next(), .half) }
    func testHalfBecomesNoneOnNext() { XCTAssertEqual(ScoreState.half.next(), .none) }
}
