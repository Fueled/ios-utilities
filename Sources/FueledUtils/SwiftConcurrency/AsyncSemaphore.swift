import Foundation

/// An async-compatible counting semaphore that controls access to a resource across multiple execution contexts.
///
/// Use `AsyncSemaphore` when you need to limit concurrent access to a shared resource in async/await code.
/// Unlike `DispatchSemaphore`, this semaphore suspends tasks without blocking the underlying thread.
///
/// Example usage:
/// ```swift
/// let semaphore = AsyncSemaphore(value: 3)  // Allow 3 concurrent accesses
///
/// await semaphore.wait()
/// defer { semaphore.signal() }
/// // Access shared resource
/// ```
///
/// ## Topics
///
/// ### Creating a Semaphore
///
/// - ``init(value:)``
///
/// ### Signaling the Semaphore
///
/// - ``signal()``
///
/// ### Waiting for the Semaphore
///
/// - ``wait()``
/// - ``waitUnlessCancelled()``
public final class AsyncSemaphore: @unchecked Sendable {
	private class Suspension: @unchecked Sendable {
		enum State {
			case pending
			case suspendedUnlessCancelled(UnsafeContinuation<Void, Error>)
			case suspended(UnsafeContinuation<Void, Never>)
			case cancelled
		}

		var state: State

		init(state: State) {
			self.state = state
		}
	}

	private var value: Int
	private var suspensions: [Suspension] = []
	private let _lock = NSRecursiveLock()

	/// Creates a semaphore with the specified initial value.
	///
	/// - Parameter value: The starting value for the semaphore. Must be greater than or equal to zero.
	/// - Precondition: `value` must be >= 0.
	public init(value: Int) {
		precondition(value >= 0, "AsyncSemaphore requires a value equal or greater than zero")
		self.value = value
	}

	deinit {
		precondition(suspensions.isEmpty, "AsyncSemaphore is deallocated while some task(s) are suspended waiting for a signal.")
	}

	private func lock() { _lock.lock() }
	private func unlock() { _lock.unlock() }

	/// Waits for, or decrements, the semaphore.
	///
	/// Decrements the semaphore count. If the resulting value is less than zero,
	/// this method suspends the current task until ``signal()`` is called.
	/// This suspension does not block the underlying thread.
	public func wait() async {
		lock()

		value -= 1
		if value >= 0 {
			unlock()
			return
		}

		await withUnsafeContinuation { continuation in
			let suspension = Suspension(state: .suspended(continuation))
			suspensions.insert(suspension, at: 0)
			unlock()
		}
	}

	/// Waits for, or decrements, the semaphore with cancellation support.
	///
	/// Decrements the semaphore count. If the resulting value is less than zero,
	/// this method suspends the current task until ``signal()`` is called.
	///
	/// - Throws: `CancellationError` if the task is cancelled before a signal is received.
	public func waitUnlessCancelled() async throws {
		lock()

		value -= 1
		if value >= 0 {
			defer { unlock() }

			do {
				try Task.checkCancellation()
			} catch {
				value += 1
				throw error
			}

			return
		}

		let suspension = Suspension(state: .pending)

		try await withTaskCancellationHandler {
			try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<Void, Error>) in
				if case .cancelled = suspension.state {
					unlock()
					continuation.resume(throwing: CancellationError())
				} else {
					suspension.state = .suspendedUnlessCancelled(continuation)
					suspensions.insert(suspension, at: 0)
					unlock()
				}
			}
		} onCancel: {
			lock()

			value += 1
			if let index = suspensions.firstIndex(where: { $0 === suspension }) {
				suspensions.remove(at: index)
			}

			if case let .suspendedUnlessCancelled(continuation) = suspension.state {
				unlock()
				continuation.resume(throwing: CancellationError())
			} else {
				suspension.state = .cancelled
				unlock()
			}
		}
	}

	/// Signals (increments) the semaphore.
	///
	/// Increments the semaphore count. If there are tasks suspended in ``wait()``
	/// or ``waitUnlessCancelled()``, one of them will be resumed.
	///
	/// - Returns: `true` if a suspended task was resumed, `false` otherwise.
	@discardableResult
	public func signal() -> Bool {
		lock()

		value += 1

		switch suspensions.popLast()?.state {
		case let .suspendedUnlessCancelled(continuation):
			unlock()
			continuation.resume()
			return true
		case let .suspended(continuation):
			unlock()
			continuation.resume()
			return true
		default:
			unlock()
			return false
		}
	}
}
