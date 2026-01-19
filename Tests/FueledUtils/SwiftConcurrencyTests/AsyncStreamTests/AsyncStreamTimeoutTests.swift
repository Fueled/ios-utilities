import ConcurrencyExtras
@testable import FueledSwiftConcurrency
import Testing

@Suite("AsyncStream Timeout Tests")
struct AsyncStreamTimeoutTests {
	@Test("Stream emits values until timeout")
	func streamEmitsUntilTimeout() async throws {
		let streamTuple = AsyncStream.makeStream(of: Int.self)
		let receivedValues = LockIsolated([Int]())

		let timeoutStream = streamTuple
			.stream
			.eraseToBufferedStream()

		Task {
			for i in 0...10 {
				streamTuple.continuation.yield(i)
				try await Task.sleep(for: .milliseconds(100))
			}
		}

		for try await value in timeoutStream.timeout(after: 0.3) {
			receivedValues.withValue {
				$0.append(value)
			}
		}

		#expect([3, 4].contains(receivedValues.value.count))
		#expect([[0, 1, 2], [0, 1, 2, 3]].contains(receivedValues.value))
	}

	@Test("Stream finishes immediately on timeout")
	func streamFinishesOnTimeout() async throws {
		let valueReceived = LockIsolated(false)

		let streamTuple = AsyncStream.makeStream(of: Void.self)

		try await withThrowingTaskGroup(of: Void.self) { group in
			group.addTask(priority: .low) {
				try await Task.sleep(for: .milliseconds(200))
				streamTuple.continuation.yield()
			}

			group.addTask(priority: .high) {
				for try await _ in streamTuple.stream.timeout(after: 0.1) {
					valueReceived.withValue {
						$0 = true
					}
				}
			}

			try await group.next()
			group.cancelAll()
		}

		#expect(valueReceived.value == false)
	}

	@Test("Stream handles empty source correctly")
	func streamHandlesEmptySource() async throws {
		var valueReceived = false
		let stream = AsyncStream<Int> { continuation in
			continuation.finish()
		}

		for try await _ in stream.timeout(after: 0.1) {
			valueReceived = true
		}

		#expect(valueReceived == false)
	}
}
