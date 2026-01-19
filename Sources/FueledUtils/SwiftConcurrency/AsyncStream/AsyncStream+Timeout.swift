import AsyncAlgorithms
import ConcurrencyExtras
import Foundation

public extension AsyncSequence where Element: Sendable {
	/// Creates a stream that completes after the specified duration.
	///
	/// - Parameter duration: The time interval in seconds after which the stream finishes.
	/// - Returns: An `AsyncStream` that emits elements until the timeout expires.
	func timeout(after duration: TimeInterval) -> AsyncStream<Element> {
		let sequence = UncheckedSendable(self).eraseToStream()
		return sequence.timeout(after: duration)
	}
}

private enum TimeoutEvent<Element: Sendable>: Sendable {
	case value(Element)
	case timeout
}

public extension AsyncStream where Element: Sendable {
	/// Creates a stream that completes after the specified duration.
	///
	/// Uses `AsyncTimerSequence` from Swift Async Algorithms to create a timeout.
	/// When the duration elapses, the stream finishes and stops emitting values.
	///
	/// Example usage:
	/// ```swift
	/// let stream = AsyncStream<Int> { ... }
	/// for await value in stream.timeout(after: 5.0) {
	///     print(value)
	/// }
	/// // Stream finishes after 5 seconds
	/// ```
	///
	/// - Parameter duration: The time interval in seconds after which the stream finishes.
	/// - Returns: An `AsyncStream` that emits elements until the timeout expires.
	func timeout(after duration: TimeInterval) -> AsyncStream<Element> {
		AsyncStream { continuation in
			let timer = AsyncTimerSequence(interval: .seconds(duration), clock: .continuous)
			let merged = merge(
				map { TimeoutEvent.value($0) },
				timer.map { _ in TimeoutEvent<Element>.timeout }
			)
			Task {
				for await event in merged {
					switch event {
					case .value(let value):
						continuation.yield(value)
					case .timeout:
						continuation.finish()
						return
					}
				}

				continuation.finish()
			}
		}
	}
}
