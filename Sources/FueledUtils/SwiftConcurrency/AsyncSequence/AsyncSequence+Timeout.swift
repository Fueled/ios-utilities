import AsyncAlgorithms

public extension AsyncSequence where Self: Sendable, Element: Sendable {
	/// Creates a sequence that times out after the specified interval.
	///
	/// - Parameters:
	///   - interval: The duration to wait before timing out.
	///   - clock: The clock to use for timing.
	///   - tolerance: Optional tolerance for the timer.
	///   - throwing: Optional error to throw on timeout. If `nil`, the sequence finishes normally.
	///   - alwaysFinishAfterTimeout: If `true`, always finishes after timeout. If `false`,
	///     only finishes if no value has been received yet. Defaults to `true`.
	/// - Returns: A `TimeoutAsyncSequence` that applies the timeout behavior.
	func timeout<C: Clock>(
		for interval: C.Instant.Duration,
		clock: C,
		tolerance: C.Instant.Duration? = nil,
		throwing: (any Error)? = nil,
		alwaysFinishAfterTimeout: Bool = true
	) -> TimeoutAsyncSequence<Self, C> {
		TimeoutAsyncSequence(
			base: self,
			for: interval,
			clock: clock,
			tolerance: tolerance,
			throwing: throwing,
			alwaysFinishAfterTimeout: alwaysFinishAfterTimeout
		)
	}
}

/// An async sequence that applies a timeout to another sequence.
///
/// If no element is received within the specified interval, the sequence
/// either finishes or throws an error based on configuration.
public struct TimeoutAsyncSequence<Base, C: Clock>: AsyncSequence where Base: AsyncSequence, Base.Element: Sendable, Base: Sendable {
	public typealias Element = Base.Element

	let base: Base
	let interval: C.Instant.Duration
	let tolerance: C.Instant.Duration?
	let clock: C
	let alwaysFinishAfterTimeout: Bool
	let throwing: (any Error)?

	init(
		base: Base,
		for interval: C.Instant.Duration,
		clock: C,
		tolerance: C.Instant.Duration? = nil,
		throwing: (any Error)? = nil,
		alwaysFinishAfterTimeout: Bool
	) {
		self.base = base
		self.interval = interval
		self.tolerance = tolerance
		self.clock = clock
		self.throwing = throwing
		self.alwaysFinishAfterTimeout = alwaysFinishAfterTimeout
	}

	public func makeAsyncIterator() -> TimeoutAsyncIterator {
		TimeoutAsyncIterator(sequence: self)
	}

	/// The iterator for `TimeoutAsyncSequence`.
	public struct TimeoutAsyncIterator: AsyncIteratorProtocol {
		private enum Event<Element: Sendable> {
			case element(Element)
			case timeout
		}

		private let alwaysFinishAfterTimeout: Bool
		private let throwing: (any Error)?
		private var isValueReceived = false
		private var mergedIterator: AsyncMerge2Sequence<AsyncMapSequence<Base, Event<Base.Element>>, AsyncStream<Event<Element>>>.AsyncIterator

		init(sequence: TimeoutAsyncSequence) {
			throwing = sequence.throwing
			alwaysFinishAfterTimeout = sequence.alwaysFinishAfterTimeout
			let timerSequence = AsyncStream<Event<Element>> { continuation in
				Task { [clock = sequence.clock, interval = sequence.interval, tolerance = sequence.tolerance] in
					try? await clock.sleep(for: interval, tolerance: tolerance)
					continuation.yield(.timeout)
					continuation.finish()
				}
			}
			let elements = sequence.base.map { Event<Element>.element($0) }
			let mergedSequence = merge(elements, timerSequence)
			mergedIterator = mergedSequence.makeAsyncIterator()
		}

		/// Advances to the next element, or returns `nil` if the sequence finishes or times out.
		public mutating func next() async throws -> Element? {
			switch try await mergedIterator.next() {
			case let .element(value):
				isValueReceived = true
				return value
			case .timeout:
				if alwaysFinishAfterTimeout || !isValueReceived {
					if let throwing {
						throw throwing
					} else {
						return nil
					}
				} else {
					return try await next()
				}
			case .none:
				return nil
			}
		}
	}
}
