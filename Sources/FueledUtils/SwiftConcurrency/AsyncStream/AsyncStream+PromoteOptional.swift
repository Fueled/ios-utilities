import ConcurrencyExtras

public extension AsyncStream where Element: Sendable {
	/// Wraps each emitted value in an optional, converting `AsyncStream<T>` to `AsyncStream<T?>`.
	///
	/// This is useful when you need to unify streams that may or may not have values
	/// into a common optional type.
	///
	/// - Returns: A new `AsyncStream<Element?>` where every emitted value is wrapped as `Optional<Element>`.
	func promoteOptional() -> AsyncStream<Element?> {
		map {
			Optional($0)
		}
		.eraseToStream()
	}
}
