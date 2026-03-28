import XCTest
@testable import SaturdayQuiz

final class ScoreFormatterTests: XCTestCase {
    // formatScore
    func testFormatScoreZero() { XCTAssertEqual(ScoreFormatter.formatScore(0), "0") }
    func testFormatScoreWholeNumber() { XCTAssertEqual(ScoreFormatter.formatScore(5), "5") }
    func testFormatScoreHalf() { XCTAssertEqual(ScoreFormatter.formatScore(5.5), "5½") }
    func testFormatScoreHalfPoint() { XCTAssertEqual(ScoreFormatter.formatScore(0.5), "0½") }

    // qrPayload
    func testQrPayloadStartsWithWhatsApp() {
        let payload = ScoreFormatter.qrPayload(score: 3, scores: [.full, .none, .full])
        XCTAssertTrue(payload.hasPrefix("whatsapp://send?text="))
    }
    func testQrPayloadContainsScore() {
        let payload = ScoreFormatter.qrPayload(score: 3, scores: [.full, .none, .full])
        // The payload is percent-encoded, so check the decoded version
        let decoded = payload.removingPercentEncoding ?? payload
        XCTAssertTrue(decoded.contains("3"))
    }
}
