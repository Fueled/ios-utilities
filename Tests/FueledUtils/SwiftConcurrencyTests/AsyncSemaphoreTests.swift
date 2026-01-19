import ConcurrencyExtras
import Foundation
@testable import FueledSwiftConcurrency
import Testing

@Suite("AsyncSemaphore Tests")
// swiftlint:disable type_body_length
struct AsyncSemaphoreTests {
	@Test("Signal without suspended tasks")
	func signalWithoutSuspendedTasks() {
		// Check DispatchSemaphore behavior
		do {
			let sem = DispatchSemaphore(value: 0)
			#expect(sem.signal() == 0)
		}
		do {
			let sem = DispatchSemaphore(value: 1)
			#expect(sem.signal() == 0)
		}
		do {
			let sem = DispatchSemaphore(value: 2)
			#expect(sem.signal() == 0)
		}

		// Test that AsyncSemaphore behaves identically
		do {
			let sem = AsyncSemaphore(value: 0)
			let woken = sem.signal()
			#expect(!woken)
		}
		do {
			let sem = AsyncSemaphore(value: 1)
			let woken = sem.signal()
			#expect(!woken)
		}
		do {
			let sem = AsyncSemaphore(value: 2)
			let woken = sem.signal()
			#expect(!woken)
		}
	}

	@Test("Signal returns whether it resumes a suspended task")
	func signalReturnsWhetherItResumesASuspendedTask() async throws {
		let delay: UInt64 = 500_000_000

		// Check DispatchSemaphore behavior
		do {
			// Given a thread waiting for the semaphore
			let sem = DispatchSemaphore(value: 0)
			Thread { sem.wait() }.start()
			try await Task.sleep(nanoseconds: delay)

			// First signal wakes the waiting thread
			#expect(sem.signal() != 0)
			// Second signal does not wake any thread
			#expect(sem.signal() == 0)
		}

		// Test that AsyncSemaphore behaves identically
		do {
			// Given a task suspended on the semaphore
			let sem = AsyncSemaphore(value: 0)
			Task { await sem.wait() }
			try await Task.sleep(nanoseconds: delay)

			// First signal resumes the suspended task
			#expect(sem.signal())
			// Second signal does not resume any task
			#expect(!sem.signal())
		}
	}

	@Test("Wait suspends on zero semaphore until signal")
	func waitSuspendsOnZeroSemaphoreUntilSignal() async throws {
		// Test that AsyncSemaphore behaves correctly
		// Given a zero semaphore
		let sem = AsyncSemaphore(value: 0)

		// Create a task that will wait on the semaphore
		let completed = LockIsolated(false)
		let task = Task {
			await sem.wait()
			completed.setValue(true)
		}

		// Give task time to start and suspend
		try await Task.sleep(nanoseconds: 500_000_000)

		// Task should be suspended, not completed
		#expect(!completed.value)

		// Signal the semaphore
		sem.signal()

		// Give task time to resume and complete
		try await Task.sleep(nanoseconds: 500_000_000)

		// Task should now be completed
		#expect(completed.value)

		// Clean up
		task.cancel()
	}

	@Test("Cancellation while suspended throws CancellationError")
	func cancellationWhileSuspendedThrowsCancellationError() async throws {
		let sem = AsyncSemaphore(value: 0)
		let errorType = LockIsolated<Any.Type?>(nil)
		let taskCompleted = LockIsolated(false)

		let task = Task {
			do {
				try await sem.waitUnlessCancelled()
				#expect(Bool(false), "Expected CancellationError")
			} catch let error as CancellationError {
				errorType.setValue(type(of: error))
			} catch {
				#expect(Bool(false), "Unexpected error: \(error)")
			}
			taskCompleted.setValue(true)
		}

		try await Task.sleep(nanoseconds: 100_000_000)
		task.cancel()

		// Give task time to handle cancellation
		try await Task.sleep(nanoseconds: 500_000_000)

		#expect(taskCompleted.value)
		#expect(errorType.value == CancellationError.self)
	}

	@Test("Cancellation before suspension throws CancellationError")
	func cancellationBeforeSuspensionThrowsCancellationError() async throws {
		let sem = AsyncSemaphore(value: 0)
		let errorType = LockIsolated<Any.Type?>(nil)
		let taskCompleted = LockIsolated(false)

		let task = Task {
			// Uncancellable delay
			await withUnsafeContinuation { continuation in
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					continuation.resume()
				}
			}

			do {
				try await sem.waitUnlessCancelled()
				#expect(Bool(false), "Expected CancellationError")
			} catch let error as CancellationError {
				errorType.setValue(type(of: error))
			} catch {
				#expect(Bool(false), "Unexpected error: \(error)")
			}
			taskCompleted.setValue(true)
		}

		task.cancel()

		// Give task time to complete
		try await Task.sleep(nanoseconds: 500_000_000)

		#expect(taskCompleted.value)
		#expect(errorType.value == CancellationError.self)
	}

	@Test("Cancellation while suspended increments the semaphore")
	func cancellationWhileSuspendedIncrementsTheSemaphore() async throws {
		// Given a task cancelled while suspended on a semaphore
		let sem = AsyncSemaphore(value: 0)
		let task = Task {
			try await sem.waitUnlessCancelled()
		}
		try await Task.sleep(nanoseconds: 100_000_000)
		task.cancel()

		// Create a second task that waits on the semaphore
		let completed = LockIsolated(false)
		let task2 = Task {
			await sem.wait()
			completed.setValue(true)
		}

		// Give second task time to start and suspend
		try await Task.sleep(nanoseconds: 500_000_000)

		// Task should be suspended, not completed
		#expect(!completed.value)

		// Signal the semaphore
		sem.signal()

		// Give task time to resume and complete
		try await Task.sleep(nanoseconds: 500_000_000)

		// Task should now be completed
		#expect(completed.value)

		// Clean up
		task2.cancel()
	}

	@Test("Cancellation before suspension increments the semaphore")
	func cancellationBeforeSuspensionIncrementsTheSemaphore() async throws {
		// Given a task cancelled before it waits on a semaphore
		let sem = AsyncSemaphore(value: 0)
		let task = Task {
			// Uncancellable delay
			await withUnsafeContinuation { continuation in
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
					continuation.resume()
				}
			}
			try await sem.waitUnlessCancelled()
		}
		task.cancel()

		// Create a second task that waits on the semaphore
		let completed = LockIsolated(false)
		let task2 = Task {
			await sem.wait()
			completed.setValue(true)
		}

		// Give second task time to start and suspend
		try await Task.sleep(nanoseconds: 500_000_000)

		// Task should be suspended, not completed
		#expect(!completed.value)

		// Signal the semaphore
		sem.signal()

		// Give task time to resume and complete
		try await Task.sleep(nanoseconds: 500_000_000)

		// Task should now be completed
		#expect(completed.value)

		// Clean up
		task2.cancel()
	}

	@Test("Cancellation before suspension increments the semaphore (variant)")
	func cancellationBeforeSuspensionIncrementsTheSemaphoreVariant() async throws {
		// Given a task that waits for a semaphore with value 1 after the
		// task has been cancelled
		let sem = AsyncSemaphore(value: 1)
		let task = Task {
			while !Task.isCancelled {
				await Task.yield()
			}
			try await sem.waitUnlessCancelled()
		}
		task.cancel()
		try? await task.value

		// Create a second task that waits on the semaphore
		let completed = LockIsolated(false)
		let task2 = Task {
			await sem.wait()
			completed.setValue(true)
		}

		// Give second task time to execute
		try await Task.sleep(nanoseconds: 500_000_000)

		// Second task should complete without being suspended
		#expect(completed.value)

		// Clean up
		task2.cancel()
	}

	@Test("Semaphore limits concurrent executions of actor method")
	func semaphoreLimitsConcurrentExecutionsOfActorMethod() async {
		/// An actor that limits the number of concurrent executions of
		/// its `run()` method, and counts the effective number of
		/// concurrent executions for testing purpose.
		actor Runner {
			private let semaphore: AsyncSemaphore
			private var count = 0
			private(set) var effectiveMaxConcurrentRuns = 0

			init(maxConcurrentRuns: Int) {
				semaphore = AsyncSemaphore(value: maxConcurrentRuns)
			}

			func run() async {
				await semaphore.wait()
				defer { semaphore.signal() }

				count += 1
				effectiveMaxConcurrentRuns = max(effectiveMaxConcurrentRuns, count)
				try! await Task.sleep(nanoseconds: 100_000_000)
				count -= 1
			}
		}

		for maxConcurrentRuns in 1...10 {
			let runner = Runner(maxConcurrentRuns: maxConcurrentRuns)

			// Spawn many concurrent tasks
			await withTaskGroup(of: Void.self) { group in
				for _ in 0..<20 {
					group.addTask {
						await runner.run()
					}
				}
			}

			let effectiveMaxConcurrentRuns = await runner.effectiveMaxConcurrentRuns
			#expect(effectiveMaxConcurrentRuns == maxConcurrentRuns)
		}
	}

	@Test("Semaphore limits concurrent executions of async method")
	func semaphoreLimitsConcurrentExecutionsOfAsyncMethod() async {
		/// A class that limits the number of concurrent executions of
		/// its `run()` method, and counts the effective number of
		/// concurrent executions for testing purpose.
		@MainActor
		class Runner {
			private let semaphore: AsyncSemaphore
			private var count = 0
			private(set) var effectiveMaxConcurrentRuns = 0

			init(maxConcurrentRuns: Int) {
				semaphore = AsyncSemaphore(value: maxConcurrentRuns)
			}

			func run() async {
				await semaphore.wait()
				defer { semaphore.signal() }

				count += 1
				effectiveMaxConcurrentRuns = max(effectiveMaxConcurrentRuns, count)
				try! await Task.sleep(nanoseconds: 100_000_000)
				count -= 1
			}
		}

		for maxConcurrentRuns in 1...10 {
			let runner = await Runner(maxConcurrentRuns: maxConcurrentRuns)

			// Spawn many concurrent tasks
			await withTaskGroup(of: Void.self) { group in
				for _ in 0..<20 {
					group.addTask {
						await runner.run()
					}
				}
			}

			let effectiveMaxConcurrentRuns = await runner.effectiveMaxConcurrentRuns
			#expect(effectiveMaxConcurrentRuns == maxConcurrentRuns)
		}
	}

	@Test("Semaphore limits concurrent executions on single thread")
	// swiftlint:disable identifier_name
	func semaphoreLimitsConcurrentExecutionsOnSingleThread() async {
		/// A class that limits the number of concurrent executions of
		/// its `run()` method, and counts the effective number of
		/// concurrent executions for testing purpose.
		@MainActor
		class Runner {
			private let semaphore: AsyncSemaphore
			private var count = 0
			private(set) var effectiveMaxConcurrentRuns = 0

			init(maxConcurrentRuns: Int) {
				semaphore = AsyncSemaphore(value: maxConcurrentRuns)
			}

			func run() async {
				await semaphore.wait()
				defer { semaphore.signal() }

				count += 1
				effectiveMaxConcurrentRuns = max(effectiveMaxConcurrentRuns, count)
				try! await Task.sleep(nanoseconds: 100_000_000)
				count -= 1
			}
		}

		await Task { @MainActor in
			let runner = Runner(maxConcurrentRuns: 3)
			async let x0: Void = runner.run()
			async let x1: Void = runner.run()
			async let x2: Void = runner.run()
			async let x3: Void = runner.run()
			async let x4: Void = runner.run()
			async let x5: Void = runner.run()
			async let x6: Void = runner.run()
			async let x7: Void = runner.run()
			async let x8: Void = runner.run()
			async let x9: Void = runner.run()
			_ = await (x0, x1, x2, x3, x4, x5, x6, x7, x8, x9)
			let effectiveMaxConcurrentRuns = runner.effectiveMaxConcurrentRuns
			#expect(effectiveMaxConcurrentRuns == 3)
		}.value
	}

	@Test("Semaphore limits concurrent executions with cancellation support")
	func semaphoreLimitsConcurrentExecutionsWithCancellationSupport() async {
		/// An actor that limits the number of concurrent executions of
		/// its `run()` method, and counts the effective number of
		/// concurrent executions for testing purpose.
		actor Runner {
			private let semaphore: AsyncSemaphore
			private var count = 0
			private(set) var effectiveMaxConcurrentRuns = 0

			init(maxConcurrentRuns: Int) {
				semaphore = AsyncSemaphore(value: maxConcurrentRuns)
			}

			func run() async throws {
				try await semaphore.waitUnlessCancelled()
				defer { semaphore.signal() }

				count += 1
				effectiveMaxConcurrentRuns = max(effectiveMaxConcurrentRuns, count)
				try! await Task.sleep(nanoseconds: 100_000_000)
				count -= 1
			}
		}

		for maxConcurrentRuns in 1...10 {
			let runner = Runner(maxConcurrentRuns: maxConcurrentRuns)

			// Spawn many concurrent tasks
			await withThrowingTaskGroup(of: Void.self) { group in
				for _ in 0..<20 {
					group.addTask {
						try await runner.run()
					}
				}
			}

			let effectiveMaxConcurrentRuns = await runner.effectiveMaxConcurrentRuns
			#expect(effectiveMaxConcurrentRuns == maxConcurrentRuns)
		}
	}
}
