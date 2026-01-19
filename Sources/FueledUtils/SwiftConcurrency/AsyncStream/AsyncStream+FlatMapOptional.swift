import ConcurrencyExtras

public extension AsyncStream where Element: Sendable {
	/// Transforms each element into an optional stream, flattening the result.
	///
	/// For each element, the transform closure returns either a stream or `nil`.
	/// If `nil` is returned, a single `nil` value is emitted. Otherwise, the returned
	/// stream is flattened with values wrapped as optionals.
	///
	/// - Parameter transform: A closure that takes an element and returns an optional `AsyncStream<T>`.
	/// - Returns: A new `AsyncStream<T?>` containing the flattened results.
	func flatMapOptional<T: Sendable>(_ transform: @Sendable @escaping (Element) -> AsyncStream<T>?) -> AsyncStream<T?> {
		flatMap { value -> AsyncStream<T?> in
			guard let stream = transform(value) else {
				return .single(value: nil)
			}
			return stream.promoteOptional()
		}
		.eraseToStream()
	}
}
