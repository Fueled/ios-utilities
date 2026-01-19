import Foundation

/// A thread-safe broadcast stream that emits values to multiple subscribers.
///
/// `BroadcastStream` allows multiple consumers to subscribe to the same stream of values.
/// When a value is emitted, all active subscribers receive it. New subscribers can optionally
/// receive the last emitted value upon subscription.
///
/// Example usage:
/// ```swift
/// let broadcast = BroadcastStream<String>()
///
/// // Subscribe to receive values
/// Task {
///     for await value in broadcast.stream(emitLastValue: true) {
///         print("Received: \(value)")
///     }
/// }
///
/// // Emit values to all subscribers
/// broadcast.emit(value: "Hello")
/// ```
public final class BroadcastStream<Value: Sendable & Equatable>: @unchecked Sendable {
	private var currentValue: Value?
	private var continuations: [UUID: AsyncStream<Value>.Continuation] = [:]
	private let queue: DispatchQueue

	/// Creates an empty broadcast stream.
	///
	/// - Parameter queueLabel: Optional custom label for the internal dispatch queue.
	///   If `nil`, uses the default label `"com.fueled.broadcast-stream"`.
	public init(queueLabel: String? = nil) {
		queue = DispatchQueue(label: queueLabel ?? "com.fueled.broadcast-stream")
	}

	/// Emits a value to all active subscribers.
	///
	/// - Parameter value: The value to broadcast to all subscribers.
	public func emit(value: Value) {
		queue.sync {
			currentValue = value
			for continuation in continuations.values {
				continuation.yield(value)
			}
		}
	}

	/// Creates a new subscriber stream.
	///
	/// - Parameter emitLastValue: If `true` and a value has been previously emitted,
	///   the subscriber immediately receives that value. Defaults to `false`.
	/// - Returns: An `AsyncStream` that receives all future emitted values.
	public func stream(emitLastValue: Bool = false) -> AsyncStream<Value> {
		let id = UUID()

		return AsyncStream { continuation in
			queue.sync {
				if let currentValue, emitLastValue {
					continuation.yield(currentValue)
				}
				continuations[id] = continuation
			}

			continuation.onTermination = { [weak self] _ in
				self?.queue.sync {
					_ = self?.continuations.removeValue(forKey: id)
				}
			}
		}
	}

	/// Finishes all active subscriber streams.
	public func finish() {
		queue.sync {
			for continuation in continuations.values {
				continuation.finish()
			}
			continuations.removeAll()
		}
	}
}
