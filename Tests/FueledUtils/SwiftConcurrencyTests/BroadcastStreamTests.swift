import ConcurrencyExtras
import Foundation
@testable import FueledSwiftConcurrency
import Testing

@Suite("BroadcastStream Tests")
struct BroadcastStreamTests {
	@Test("Single listener receives emitted value")
	func emitValueToSingleListener() async throws {
		let broadcast = BroadcastStream<Int>()
		let expectedValue = 42

		let task = Task {
			let stream = broadcast.stream(emitLastValue: true)
			for await value in stream {
				#expect(value == expectedValue)
				break
			}
		}

		broadcast.emit(value: expectedValue)
		await task.value
	}

	@Test("Multiple listeners receive same emitted value")
	func emitValueToMultipleListeners() async throws {
		let broadcast = BroadcastStream<Int>()
		let expectedValue = 42
		let listenerCount = 3
		let counter = LockIsolated(0)

		let tasks = (0..<listenerCount).map { _ in
			Task {
				let stream = broadcast.stream(emitLastValue: true)
				for await value in stream {
					#expect(value == expectedValue)
					counter.setValue(counter.value + 1)
					break
				}
			}
		}

		broadcast.emit(value: expectedValue)

		await withTaskGroup(of: Void.self) { group in
			for task in tasks {
				group.addTask {
					await task.value
				}
			}
			await group.waitForAll()
		}

		#expect(counter.value == listenerCount)
	}

	@Test("New listener receives last emitted value")
	func newListenerReceivesLastEmittedValue() async throws {
		let broadcast = BroadcastStream<Int>()
		let expectedValue = 42

		broadcast.emit(value: expectedValue)

		let task = Task {
			let stream = broadcast.stream(emitLastValue: true)
			for await value in stream {
				#expect(value == expectedValue)
				break
			}
		}

		await task.value
	}

	@Test("New listener shouldn't receive last emitted value if not enabled by the stream")
	func newListenerShouldNowReceiveLastEmittedValue() async throws {
		let broadcast = BroadcastStream<Int>()
		let expectedValue = 42

		broadcast.emit(value: expectedValue)

		let task = Task {
			let stream = broadcast.stream(emitLastValue: false)
			for await _ in stream {
				Issue.record("Shouldn't receive value!")
			}
		}

		try await Task.sleep(for: .seconds(0.1))
		task.cancel()
	}

	@Test("Multiple emissions are received in order")
	func multipleEmissions() async throws {
		let broadcast = BroadcastStream<Int>()
		let values = [1, 2, 3, 4, 5]
		let receivedValues = LockIsolated<[Int]>([])

		let task = Task {
			let stream = broadcast.stream()
			for await value in stream {
				receivedValues.withValue {
					$0.append( value)
				}
				if receivedValues.count == values.count {
					break
				}
			}
		}

		for value in values {
			try? await Task.sleep(for: .milliseconds(100))
			broadcast.emit(value: value)
		}

		await task.value
		#expect(receivedValues.value == values)
	}

	@Test("Listeners are cleaned up after cancellation")
	func testListenerCleanupOnCancellation() async throws {
		let broadcast = BroadcastStream<Int>()

		let task = Task {
			let stream = broadcast.stream()
			for await _ in stream {
				break
			}
		}

		task.cancel()
		try? await Task.sleep(for: .milliseconds(100))

		// Access the private property for testing
		let mirror = Mirror(reflecting: broadcast)
		if let continuations = mirror.children.first(where: { $0.label == "continuations" })?.value as? [UUID: AsyncStream<Int>.Continuation] {
			#expect(continuations.isEmpty)
		}
	}
}
