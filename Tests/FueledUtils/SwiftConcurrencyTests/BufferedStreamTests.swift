import ConcurrencyExtras
@testable import FueledSwiftConcurrency
import Testing

@Suite("BufferedStream Tests")
struct BufferedStreamTests {
	@Test("Empty buffer initially")
	func emptyBufferInitiallyTest() async throws {
		let stream = BufferedStream<Int>()
		let task = Task {
			var values: [Int] = []
			for try await value in stream {
				values.append(value)
				if values.count == 1 {
					break
				}
			}
			return values
		}

		// No values should be received yet
		try await Task.sleep(for: .milliseconds(50))
		stream.finish()
		let values = try await task.value
		#expect(values.isEmpty)
	}

	@Test("Yield adds values to buffer before iteration")
	func yieldToBufferBeforeIterationTest() async throws {
		let stream = BufferedStream<Int>()

		stream.yield(1)
		stream.yield(2)
		stream.yield(3)

		let receivedValues = LockIsolated<[Int]>([])
		let task = Task {
			for try await value in stream {
				receivedValues.withValue {
					$0.append(value)
				}
				if receivedValues.count == 3 {
					break
				}
			}
		}

		try await Task.sleep(for: .milliseconds(100))
		stream.finish()
		try await task.value

		#expect(receivedValues.count == 3)
		#expect(receivedValues.value == [1, 2, 3])
	}

	@Test("Yield sends values directly to continuation after iteration starts")
	func yieldToContinuationAfterIterationTest() async throws {
		let stream = BufferedStream<Int>()
		let receivedValues = LockIsolated<[Int]>([])

		let task = Task {
			for try await value in stream {
				receivedValues.withValue { $0.append(value) }
				if receivedValues.value.count == 5 {
					break
				}
			}
		}

		try await Task.sleep(for: .milliseconds(50))

		stream.yield(1)
		stream.yield(2)
		stream.yield(3)
		stream.yield(4)
		stream.yield(5)

		try await Task.sleep(for: .milliseconds(100))
		stream.finish()
		try await task.value

		#expect(receivedValues.value.count == 5)
		#expect(receivedValues.value == [1, 2, 3, 4, 5])
	}

	@Test("Finish terminates all subscriptions")
	func finishTerminatesTest() async throws {
		let stream = BufferedStream<Int>()
		let receivedValues = LockIsolated<[Int]>([])

		let task = Task {
			for try await value in stream {
				receivedValues.withValue { $0.append(value) }
			}
		}

		try await Task.sleep(for: .milliseconds(50))

		stream.yield(1)
		stream.yield(2)

		try await Task.sleep(for: .milliseconds(50))

		// Finish should terminate the stream
		stream.finish()

		try await Task.sleep(for: .milliseconds(50))

		// These should not be received
		stream.yield(3)
		stream.yield(4)

		try await Task.sleep(for: .milliseconds(100))
		task.cancel()

		#expect(receivedValues.value.count == 2)
		#expect(receivedValues.value == [1, 2])
	}

	@Test("Can create from an existing AsyncStream")
	func createFromAsyncStreamTest() async throws {
		let originalStream = AsyncStream<Int> { continuation in
			continuation.yield(1)
			continuation.yield(2)
			continuation.yield(3)
			continuation.finish()
		}

		let bufferedStream = originalStream.eraseToBufferedStream()

		var receivedValues: [Int] = []
		for try await value in bufferedStream {
			receivedValues.append(value)
		}

		#expect(receivedValues.count == 3)
		#expect(receivedValues == [1, 2, 3])
	}

	@Test("Iterator returns nil after finish")
	func iteratorReturnsNilAfterFinishTest() async throws {
		let stream = BufferedStream<Int>()

		stream.yield(1)
		stream.finish()

		var iterator = stream.makeAsyncIterator()
		let firstValue = try await iterator.next()
		let secondValue = try await iterator.next()

		#expect(firstValue == 1)
		#expect(secondValue == nil)
	}

	@Test("eraseToBufferedStream preserves values emitted before reading starts")
	func eraseToBufferedStreamRaceConditionTest() async throws {
		// Create an AsyncStream that emits values immediately
		let (originalStream, continuation) = AsyncStream<String>.makeStream()

		// Convert to buffered stream
		let bufferedStream = originalStream.eraseToBufferedStream()

		// Emit values BEFORE anyone starts reading (simulating race condition)
		continuation.yield("fast_value_1")
		continuation.yield("fast_value_2")
		continuation.yield("fast_value_3")

		// Small delay to simulate processing time
		try await Task.sleep(for: .milliseconds(10))

		// Now start reading - should get all values that were emitted earlier
		let receivedValues = LockIsolated<[String]>([])
		let readingTask = Task {
			for try await value in bufferedStream {
				receivedValues.withValue {
					$0.append(value)
				}
				if receivedValues.count >= 5 {
					break
				}
			}
		}

		// Emit more values after reading started
		try await Task.sleep(for: .milliseconds(5))
		continuation.yield("after_reading_1")
		continuation.yield("after_reading_2")

		// Wait for reading to complete
		try await readingTask.value

		// Verify we got ALL values in correct order
		#expect(receivedValues.count == 5)
		#expect(receivedValues.value == [
			"fast_value_1",
			"fast_value_2",
			"fast_value_3",
			"after_reading_1",
			"after_reading_2",
		])
	}
}
