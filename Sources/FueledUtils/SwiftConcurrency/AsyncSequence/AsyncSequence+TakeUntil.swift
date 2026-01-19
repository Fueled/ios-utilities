public extension AsyncSequence {
	/// Takes elements from the sequence until a condition is met, including the element that satisfies it.
	///
	/// - Parameter condition: A closure that evaluates each element. Returns `true` to stop taking elements.
	/// - Returns: A `TakeUntilAsyncSequence` that emits elements until the condition is satisfied.
	func takeUntil(_ condition: @escaping @Sendable (Element) -> Bool) -> TakeUntilAsyncSequence<Self> {
		TakeUntilAsyncSequence(self, condition: condition)
	}
}

/// An async sequence that emits elements until a condition is met.
///
/// This sequence stops emitting after the first element that satisfies the condition,
/// including that element in the output.
public struct TakeUntilAsyncSequence<Base: AsyncSequence>: AsyncSequence {
	public typealias Element = Base.Element

	private let base: Base
	private let condition: @Sendable (Element) -> Bool

	/// Creates a take-until sequence.
	///
	/// - Parameters:
	///   - base: The underlying async sequence.
	///   - condition: A closure that determines when to stop. Returns `true` on the last element to emit.
	public init(_ base: Base, condition: @escaping @Sendable (Element) -> Bool) {
		self.base = base
		self.condition = condition
	}

	public func makeAsyncIterator() -> AsyncIterator {
		AsyncIterator(base: base, condition: condition)
	}

	/// The iterator for `TakeUntilAsyncSequence`.
	public struct AsyncIterator: AsyncIteratorProtocol {
		private var baseIterator: Base.AsyncIterator
		private let condition: @Sendable (Element) -> Bool
		private var isFinished = false

		fileprivate init(base: Base, condition: @escaping @Sendable (Element) -> Bool) {
			baseIterator = base.makeAsyncIterator()
			self.condition = condition
		}

		/// Advances to the next element, or returns `nil` if finished or condition is met.
		public mutating func next() async throws -> Element? {
			guard !isFinished else {
				return nil
			}

			guard let value = try await baseIterator.next() else {
				isFinished = true
				return nil
			}

			if condition(value) {
				isFinished = true
				return value
			}

			return value
		}
	}
}
