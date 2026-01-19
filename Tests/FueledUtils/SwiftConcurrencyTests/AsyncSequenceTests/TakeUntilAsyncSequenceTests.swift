import ConcurrencyExtras
import Foundation
import Testing

@Suite("TakeUntilAsyncSequence Tests")
struct TakeUntilAsyncSequenceTests {
	@Test("TakeUntil stops emitting after condition is met")
	func takeUntilStopsAfterCondition() async throws {
		let sequence = AsyncStream<Int> { continuation in
			continuation.yield(1)
			continuation.yield(2)
			continuation.yield(3)
			continuation.yield(4)
			continuation.finish()
		}

		let condition: @Sendable (Int) -> Bool = { $0 == 3 }
		let takeUntilSequence = sequence.takeUntil(condition)

		var receivedValues: [Int] = []
		for try await value in takeUntilSequence {
			receivedValues.append(value)
		}

		#expect(receivedValues == [1, 2, 3])
	}

	@Test("TakeUntil handles empty sequence")
	func takeUntilHandlesEmptySequence() async throws {
		let sequence = AsyncStream<Int> { continuation in
			continuation.finish()
		}

		let condition: @Sendable (Int) -> Bool = { $0 == 3 }
		let takeUntilSequence = sequence.takeUntil(condition)

		var receivedValues: [Int] = []
		for try await value in takeUntilSequence {
			receivedValues.append(value)
		}

		#expect(receivedValues.isEmpty)
	}

	@Test("TakeUntil handles condition never being met")
	func takeUntilHandlesConditionNeverMet() async throws {
		let sequence = AsyncStream<Int> { continuation in
			continuation.yield(1)
			continuation.yield(2)
			continuation.yield(3)
			continuation.finish()
		}

		let condition: @Sendable (Int) -> Bool = { $0 == 5 }
		let takeUntilSequence = sequence.takeUntil(condition)

		var receivedValues: [Int] = []
		for try await value in takeUntilSequence {
			receivedValues.append(value)
		}

		#expect(receivedValues == [1, 2, 3])
	}
}
