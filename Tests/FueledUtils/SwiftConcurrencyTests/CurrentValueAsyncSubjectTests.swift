import ConcurrencyExtras
@testable import FueledSwiftConcurrency
import Testing

@Suite("CurrentValueAsyncSubject Tests")
struct CurrentValueAsyncSubjectTests {
	@Test("Initial value is set correctly")
	func initialValueTest() {
		let subject = CurrentValueAsyncSubject(42)
		#expect(subject.value == 42)
	}

	@Test("Send updates current value")
	func sendUpdatesValueTest() async {
		let subject = CurrentValueAsyncSubject(0)
		subject.send(99)

		try? await Task.sleep(for: .milliseconds(50))
		#expect(subject.value == 99)
	}

	@Test("Multiple subscribers receive updates")
	func multipleSubscribersTest() async throws {
		let subject = CurrentValueAsyncSubject(0)
		let receivedValues1 = LockIsolated<[Int]>([])
		let receivedValues2 = LockIsolated<[Int]>([])

		let task1 = Task {
			for await value in subject.values() {
				receivedValues1.withValue {
					$0.append(value)
				}
			}
		}

		let task2 = Task {
			for await value in subject.values() {
				receivedValues2.withValue {
					$0.append(value)
				}
			}
		}

		try await Task.sleep(for: .milliseconds(50))

		// Send some values
		subject.send(1)
		subject.send(2)
		subject.send(3)

		try await Task.sleep(for: .milliseconds(100))

		task1.cancel()
		task2.cancel()

		#expect(receivedValues1.value.count == 4)
		#expect(receivedValues2.value.count == 4)
		#expect(receivedValues1.value == [0, 1, 2, 3])
		#expect(receivedValues2.value == [0, 1, 2, 3])
	}

	@Test("Subscribers receive initial value immediately")
	func immediateInitialValueTest() async throws {
		let subject = CurrentValueAsyncSubject(42)
		let received = LockIsolated<Int?>(nil)

		let task = Task {
			for await value in subject.values() {
				received.setValue(value)
				break
			}
		}

		try await Task.sleep(for: .milliseconds(100))
		task.cancel()

		#expect(received.value == 42)
	}

	@Test("Finish terminates all subscriptions")
	func finishTerminatesTest() async throws {
		let subject = CurrentValueAsyncSubject(0)
		let receivedValues = LockIsolated<[Int]>([])

		let task = Task {
			for await value in subject.values() {
				receivedValues.withValue {
					$0.append(value)
				}
			}
		}

		try await Task.sleep(for: .milliseconds(50))
		subject.send(1)
		try await Task.sleep(for: .milliseconds(50))

		subject.finishContinuations()
		try await Task.sleep(for: .milliseconds(50))

		subject.send(2) // This should not be received
		try await Task.sleep(for: .milliseconds(50))

		task.cancel()

		#expect(receivedValues.value == [0, 1])
	}
}
