import Foundation

/// A thread-safe subject that holds a current value and broadcasts changes to subscribers.
///
/// `CurrentValueAsyncSubject` is similar to Combine's `CurrentValueSubject` but designed
/// for async/await usage. It always has a current value that subscribers receive immediately
/// upon subscription, followed by any subsequent updates.
///
/// Example usage:
/// ```swift
/// let subject = CurrentValueAsyncSubject<Int>(0)
///
/// // Read current value synchronously
/// print(subject.value)  // 0
///
/// // Subscribe to receive updates
/// Task {
///     for await value in subject.values() {
///         print("Received: \(value)")
///     }
/// }
///
/// // Send new values
/// subject.send(42)
/// ```
public final class CurrentValueAsyncSubject<T: Sendable>: @unchecked Sendable {
	private let queue: DispatchQueue
	private var _value: T
	private var continuations: [UUID: AsyncStream<T>.Continuation] = [:]

	/// Creates a subject with the specified initial value.
	///
	/// - Parameters:
	///   - initialValue: The initial value held by the subject.
	///   - queueLabel: Optional custom label for the internal dispatch queue.
	///     If `nil`, uses the default label `"com.fueled.current-value-async-subject"`.
	public init(_ initialValue: T, queueLabel: String? = nil) {
		_value = initialValue
		queue = DispatchQueue(label: queueLabel ?? "com.fueled.current-value-async-subject")
	}

	/// The current value held by the subject.
	///
	/// Reading this property is thread-safe and returns the most recently sent value.
	public var value: T {
		queue.sync {
			_value
		}
	}

	/// Sends a new value to the subject.
	///
	/// The new value becomes the current value and is delivered to all active subscribers.
	///
	/// - Parameter newValue: The value to send.
	public func send(_ newValue: T) {
		queue.async { [weak self] in
			guard let self else {
				return
			}
			_value = newValue
			for (_, continuation) in continuations {
				continuation.yield(newValue)
			}
		}
	}

	/// Creates an async stream that emits the current value immediately, then all subsequent values.
	///
	/// - Returns: An `AsyncStream` that starts with the current value and continues with future updates.
	public func values() -> AsyncStream<T> {
		let id = UUID()

		return AsyncStream { continuation in
			queue.async { [weak self] in
				guard let self else {
					return
				}
				continuation.yield(_value)
				continuations[id] = continuation

				continuation.onTermination = { @Sendable _ in
					self.queue.async {
						self.continuations.removeValue(forKey: id)
					}
				}
			}
		}
	}

	/// Finishes all active subscriber streams.
	///
	/// After calling this method, all active subscribers complete their iteration.
	/// New subscribers created via ``values()`` will still receive the current value.
	public func finishContinuations() {
		queue.sync {
			for (_, continuation) in continuations {
				continuation.finish()
			}
			continuations.removeAll()
		}
	}
}
