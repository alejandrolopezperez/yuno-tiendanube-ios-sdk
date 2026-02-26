import XCTest
@testable import PaymentRecoverySDK

final class DeclineClassifierTests: XCTestCase {

    let classifier = DeclineClassifier()

    // MARK: - 1. Success

    func testSuccess_returnsShowSuccess() {
        let result = PaymentResult(status: .success, declineCode: nil, attemptCount: 1)
        XCTAssertEqual(classifier.classify(result: result), .showSuccess)
    }

    // MARK: - 2. Retry paths

    func testProcessorTimeout_firstAttempt_returnsRetry() {
        let result = PaymentResult(status: .softDecline, declineCode: .processorTimeout, attemptCount: 1)
        XCTAssertEqual(classifier.classify(result: result), .retry)
    }

    func testProcessorTimeout_atRetryLimit_returnsError() {
        let result = PaymentResult(
            status: .softDecline,
            declineCode: .processorTimeout,
            attemptCount: DeclineClassifier.retryLimit
        )
        XCTAssertEqual(classifier.classify(result: result), .showError(message: "processor_unavailable"))
    }

    func testIssuerUnavailable_firstAttempt_returnsRetry() {
        let result = PaymentResult(status: .softDecline, declineCode: .issuerUnavailable, attemptCount: 1)
        XCTAssertEqual(classifier.classify(result: result), .retry)
    }

    func testIssuerUnavailable_atRetryLimit_returnsError() {
        let result = PaymentResult(
            status: .softDecline,
            declineCode: .issuerUnavailable,
            attemptCount: DeclineClassifier.retryLimit
        )
        XCTAssertEqual(classifier.classify(result: result), .showError(message: "issuer_unavailable"))
    }

    // MARK: - 3. Suspected fraud escalation

    func testSuspectedFraud_firstAttempt_returnsRetry() {
        let result = PaymentResult(status: .softDecline, declineCode: .suspectedFraud, attemptCount: 1)
        XCTAssertEqual(classifier.classify(result: result), .retry)
    }

    func testSuspectedFraud_secondAttempt_escalatesTo3DS() {
        let result = PaymentResult(status: .softDecline, declineCode: .suspectedFraud, attemptCount: 2)
        XCTAssertEqual(classifier.classify(result: result), .challenge3DS)
    }

    // MARK: - 4. Direct 3DS

    func testAuthenticationRequired_alwaysChallenge3DS() {
        let result = PaymentResult(status: .softDecline, declineCode: .authenticationRequired, attemptCount: 1)
        XCTAssertEqual(classifier.classify(result: result), .challenge3DS)
    }

    // MARK: - 5. Hard declines

    func testInsufficientFunds_isHardDecline() {
        let result = PaymentResult(status: .hardDecline, declineCode: .insufficientFunds, attemptCount: 1)
        XCTAssertEqual(classifier.classify(result: result), .showError(message: "insufficient_funds"))
    }

    func testCardBlocked_isHardDecline() {
        let result = PaymentResult(status: .hardDecline, declineCode: .cardBlocked, attemptCount: 1)
        XCTAssertEqual(classifier.classify(result: result), .showError(message: "card_blocked"))
    }
}
