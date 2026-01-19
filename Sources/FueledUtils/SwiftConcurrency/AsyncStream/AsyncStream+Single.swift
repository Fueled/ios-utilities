public extension AsyncStream {
	/// Creates an `AsyncStream` that emits a single value and then completes.
	///
	/// Use this when you need to wrap a single value as an async stream.
	///
	/// - Parameter value: The value to emit.
	/// - Returns: An `AsyncStream` that emits the value once and finishes.
	static func single<T: Sendable>(value: T) -> AsyncStream<T> {
		AsyncStream<T> { continuation in
			continuation.yield(value)
			continuation.finish()
		}
	}
}
