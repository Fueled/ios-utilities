import ConcurrencyExtras

/// Converts any `AsyncSequence` into a `BufferedStream` for value storage and replay.
public extension AsyncSequence {
	/// Converts the async sequence into a `BufferedStream`, allowing values to be stored and replayed.
	///
	/// - Returns: A `BufferedStream` that buffers all emitted values for later consumption.
	func eraseToBufferedStream() -> BufferedStream<Element> where Element: Sendable {
		let stream = UncheckedSendable(self).eraseToStream()
		return BufferedStream(stream)
	}
}

/// A buffered async stream that stores emitted values and replays them to new consumers.
///
/// `BufferedStream` maintains an internal buffer of all emitted values. When a consumer
/// starts iterating, they receive all previously buffered values before receiving new ones.
///
/// Example usage:
/// ```swift
/// let buffer = BufferedStream<Int>()
/// buffer.yield(1)
/// buffer.yield(2)
///
/// // New consumer receives 1, 2, then any future values
/// for await value in buffer {
///     print(value)
/// }
/// ```
public final class BufferedStream<T: Sendable>: AsyncSequence, Sendable {
	public typealias AsyncIterator = BufferedStreamIterator<T>
	public typealias Element = T

	private let buffer = LockIsolated<[T]>([])
	private let continuation = LockIsolated<AsyncStream<T>.Continuation?>(nil)
	private let isFinished = LockIsolated(false)

	/// Creates an empty buffered stream.
	public init() {
	}

	fileprivate init(_ stream: AsyncStream<T>) {
		Task {
			for await value in stream {
				yield(value)
			}

			finish()
		}
	}

	private var stream: AsyncStream<T> {
		AsyncStream { continuation in
			self.continuation.withValue {
				$0 = continuation
			}
			for value in buffer.value {
				continuation.yield(value)
			}
			if isFinished.value {
				continuation.finish()
			}
		}
	}

	/// Emits a value into the buffered stream.
	///
	/// The value is stored in the buffer and delivered to any active consumer.
	/// Future consumers will receive this value when they start iterating.
	///
	/// - Parameter value: The value to emit.
	public func yield(_ value: T) {
		if let continuation = continuation.value {
			continuation.yield(value)
		} else {
			buffer.withValue {
				$0.append(value)
			}
		}
	}

	/// Marks the stream as finished, preventing further emissions.
	///
	/// After calling this method, any active consumer will complete iteration
	/// and new consumers will only receive previously buffered values.
	public func finish() {
		isFinished.withValue {
			$0 = true
		}
		continuation.withValue {
			$0?.finish()
		}
	}

	public func makeAsyncIterator() -> BufferedStreamIterator<T> {
		BufferedStreamIterator(stream: stream)
	}
}

/// An async iterator for `BufferedStream`.
public struct BufferedStreamIterator<T: Sendable>: AsyncIteratorProtocol {
	private var streamIterator: AsyncStream<T>.AsyncIterator

	init(stream: AsyncStream<T>) {
		streamIterator = stream.makeAsyncIterator()
	}

	/// Advances to and returns the next element, or `nil` if no more elements exist.
	public mutating func next() async throws -> T? {
		await streamIterator.next()
	}
}
