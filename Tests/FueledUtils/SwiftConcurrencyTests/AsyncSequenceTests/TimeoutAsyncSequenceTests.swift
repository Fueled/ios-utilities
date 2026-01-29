import FueledSwiftConcurrency
import Testing

struct TimeoutError: Error {}

@Suite("TimeoutAsyncSequence Tests")
struct TimeoutAsyncSequenceTests {
	@Test("Stream emits values until timeout")
	func streamEmitsUntilTimeout() async throws {
		let sequence1 = AsyncStream<Int> { continuation in
			Task {
				try? await Task.sleep(for: .milliseconds(100))
				continuation.yield(1)
				try? await Task.sleep(for: .milliseconds(500))
				continuation.yield(2)
				continuation.finish()
			}
		}

		let sut = sequence1.timeout(for: .milliseconds(200), clock: .continuous, alwaysFinishAfterTimeout: true)

		var receivedValues: [Int] = []
		for try await value in sut {
			receivedValues.append(value)
		}

		#expect(receivedValues == [1])
	}

	@Test("Stream emits after timeout when receive value from main stream")
	func streamEmitsAfterTimeout() async throws {
		let sequence1 = AsyncStream<Int> { continuation in
			Task {
				try? await Task.sleep(for: .milliseconds(100))
				continuation.yield(1)
				try? await Task.sleep(for: .milliseconds(500))
				continuation.yield(2)
				continuation.finish()
			}
		}

		let sut = sequence1.timeout(for: .milliseconds(200), clock: .continuous, alwaysFinishAfterTimeout: false)

		var receivedValues: [Int] = []
		for try await value in sut {
			receivedValues.append(value)
		}

		#expect(receivedValues == [1, 2])
	}

	@Test("Stream throw error after timeout")
	func streamThrowAfterTimeout() async throws {
		let sequence1 = AsyncStream<Int> { continuation in
			Task {
				try? await Task.sleep(for: .milliseconds(100))
				continuation.yield(1)
				try? await Task.sleep(for: .milliseconds(500))
				continuation.yield(2)
				continuation.finish()
			}
		}

		let sut = sequence1.timeout(
			for: .milliseconds(200),
			clock: .continuous,
			throwing: TimeoutError(),
			alwaysFinishAfterTimeout: true
		)

		var receivedValues: [Int] = []

		await #expect(throws: TimeoutError.self) {
			for try await value in sut {
				receivedValues.append(value)
			}
		}
	}

	@Test("Stream not throwing error after timeout")
	func streamNotThrowAfterTimeout() async throws {
		let sequence1 = AsyncStream<Int> { continuation in
			Task {
				try? await Task.sleep(for: .milliseconds(100))
				continuation.yield(1)
				try? await Task.sleep(for: .milliseconds(500))
				continuation.yield(2)
				continuation.finish()
			}
		}

		let sut = sequence1.timeout(
			for: .milliseconds(200),
			clock: .continuous,
			throwing: TimeoutError(),
			alwaysFinishAfterTimeout: false
		)

		var receivedValues: [Int] = []
		for try await value in sut {
			receivedValues.append(value)
		}

		#expect(receivedValues == [1, 2])
	}

	@Test("Stream handles empty source correctly")
	func streamHandlesEmptySource() async throws {
		var valueReceived = false
		let stream = AsyncStream<Int> { continuation in
			continuation.finish()
		}

		for try await _ in stream.timeout(for: .seconds(0.1), clock: .continuous) {
			valueReceived = true
		}

		#expect(valueReceived == false)
	}
}
