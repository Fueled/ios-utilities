/// A concurrency-safe asynchronous cache for storing key-value pairs.
///
/// `AsyncCache` provides thread-safe caching with support for async value providers.
/// Values are computed lazily on first access and cached for subsequent retrievals.
///
/// Example usage:
/// ```swift
/// let cache = AsyncCache<String, Data>()
/// let data = try await cache.getOrAdd(key: "user-123") { key in
///     try await fetchUserData(id: key)
/// }
/// ```
public actor AsyncCache<Key: Sendable & Hashable, Value: Sendable> {
	private var cachedValues: [Key: Value] = [:]

	/// Creates an empty cache.
	public init() {
	}

	/// Retrieves a value from the cache if available, or computes and caches it using the provided async provider.
	///
	/// - Parameters:
	///   - key: The key to look up or associate with a new value.
	///   - provider: An asynchronous closure that computes the value if not already cached.
	/// - Returns: The cached or newly computed value.
	/// - Throws: Rethrows any error thrown by the `provider` closure.
	public func getOrAdd(
		key: Key,
		provider: @escaping @Sendable (Key) async throws -> Value
	) async throws -> Value {
		if let cachedValue = cachedValues[key] {
			return cachedValue
		}

		let value = try await provider(key)
		cachedValues[key] = value
		return value
	}

	/// Removes all cached key-value pairs.
	public func clear() {
		cachedValues.removeAll()
	}

	/// Removes a specific key-value pair from the cache.
	///
	/// - Parameter key: The key to remove.
	/// - Returns: The removed value, or `nil` if the key was not present.
	@discardableResult
	public func remove(key: Key) -> Value? {
		cachedValues.removeValue(forKey: key)
	}

	/// Returns the number of cached items.
	public var count: Int {
		cachedValues.count
	}
}
