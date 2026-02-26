// Standalone test runner — no XCTest or Xcode required.
// Run with: swift run RunTests
//
// Uses ANSI colors: ✓ green for pass, ✗ red for fail.

import Foundation
import PaymentRecoverySDK

// MARK: - Minimal test harness

private var passed = 0
private var failed = 0

private func test(_ name: String, _ body: () throws -> Void) {
    do {
        try body()
        print("  \u{001B}[32m✓\u{001B}[0m \(name)")
        passed += 1
    } catch {
        print("  \u{001B}[31m✗\u{001B}[0m \(name) — \(error)")
        failed += 1
    }
}

private struct Failure: Error, CustomStringConvertible {
    let description: String
}

private func expect<T: Equatable>(_ actual: T, equals expected: T, _ msg: String = "") throws {
    guard actual == expected else {
        throw Failure(description: "expected \(expected), got \(actual)\(msg.isEmpty ? "" : " — \(msg)")")
    }
}

// MARK: - DeclineClassifier Tests

let classifier = DeclineClassifier()

print("\nDeclineClassifier")

test("success → showSuccess") {
    let r = PaymentResult(status: .success, declineCode: nil, attemptCount: 1)
    try expect(classifier.classify(result: r), equals: .showSuccess)
}

test("processorTimeout attempt 1 → retry") {
    let r = PaymentResult(status: .softDecline, declineCode: .processorTimeout, attemptCount: 1)
    try expect(classifier.classify(result: r), equals: .retry)
}

test("processorTimeout at retryLimit → error") {
    let r = PaymentResult(status: .softDecline, declineCode: .processorTimeout, attemptCount: DeclineClassifier.retryLimit)
    try expect(classifier.classify(result: r), equals: .showError(message: "processor_unavailable"))
}

test("issuerUnavailable attempt 1 → retry") {
    let r = PaymentResult(status: .softDecline, declineCode: .issuerUnavailable, attemptCount: 1)
    try expect(classifier.classify(result: r), equals: .retry)
}

test("issuerUnavailable at retryLimit → error") {
    let r = PaymentResult(status: .softDecline, declineCode: .issuerUnavailable, attemptCount: DeclineClassifier.retryLimit)
    try expect(classifier.classify(result: r), equals: .showError(message: "issuer_unavailable"))
}

test("suspectedFraud attempt 1 → retry") {
    let r = PaymentResult(status: .softDecline, declineCode: .suspectedFraud, attemptCount: 1)
    try expect(classifier.classify(result: r), equals: .retry)
}

test("suspectedFraud attempt 2 → challenge3DS (escalation)") {
    let r = PaymentResult(status: .softDecline, declineCode: .suspectedFraud, attemptCount: 2)
    try expect(classifier.classify(result: r), equals: .challenge3DS)
}

test("authenticationRequired → challenge3DS (direct)") {
    let r = PaymentResult(status: .softDecline, declineCode: .authenticationRequired, attemptCount: 1)
    try expect(classifier.classify(result: r), equals: .challenge3DS)
}

test("insufficientFunds → showError(insufficient_funds)") {
    let r = PaymentResult(status: .hardDecline, declineCode: .insufficientFunds, attemptCount: 1)
    try expect(classifier.classify(result: r), equals: .showError(message: "insufficient_funds"))
}

test("cardBlocked → showError(card_blocked)") {
    let r = PaymentResult(status: .hardDecline, declineCode: .cardBlocked, attemptCount: 1)
    try expect(classifier.classify(result: r), equals: .showError(message: "card_blocked"))
}

// MARK: - Summary

let total = passed + failed
print("\n\(total) tests: \u{001B}[32m\(passed) passed\u{001B}[0m\(failed > 0 ? ", \u{001B}[31m\(failed) failed\u{001B}[0m" : "")\n")
exit(failed > 0 ? 1 : 0)
