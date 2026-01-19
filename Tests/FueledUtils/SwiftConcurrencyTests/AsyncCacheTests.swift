import ConcurrencyExtras
@testable import FueledSwiftConcurrency
import Testing

private actor CountActor {
	private(set) var count = 0

	func increment() {
		count += 1
	}
}

@Suite("Async Cache Tests")
struct AsyncCacheTests {
	@Test("Retrieves and caches value for a key")
	func retrievesAndCachesValue() async throws {
		let cache = AsyncCache<String, Int>()
		let countActor = CountActor()

		let result1 = try await cache.getOrAdd(key: "test") { key in
			await countActor.increment()
			return key.count
		}

		#expect(result1 == 4)
		#expect(await countActor.count == 1)

		// Second call should return cached value
		let result2 = try await cache.getOrAdd(key: "test") { key in
			await countActor.increment()
			return key.count
		}

		#expect(result2 == 4)
		#expect(await countActor.count == 1)
	}

	@Test("Handles different keys independently")
	func handlesDifferentKeys() async throws {
		let cache = AsyncCache<String, Int>()

		let result1 = try await cache.getOrAdd(key: "test1") { key in
			key.count
		}

		let result2 = try await cache.getOrAdd(key: "test2") { key in
			key.count * 2
		}

		#expect(result1 == 5)
		#expect(result2 == 10)
	}

	@Test("Clears cache correctly")
	func clearsCacheCorrectly() async throws {
		let cache = AsyncCache<String, Int>()

		let countActor = CountActor()
		let result1 = try await cache.getOrAdd(key: "test") { key in
			await countActor.increment()
			return key.count
		}

		#expect(result1 == 4)
		#expect(await countActor.count == 1)

		// Clear the cache
		await cache.clear()

		// Subsequent call should invoke provider again
		let result2 = try await cache.getOrAdd(key: "test") { key in
			await countActor.increment()
			return key.count
		}

		#expect(result2 == 4)
		#expect(await countActor.count == 2)
	}

	@Test("Handles provider throwing error")
	func handlesProviderError() async throws {
		let cache = AsyncCache<String, Int>()

		struct TestError: Error {}

		await #expect(throws: TestError.self) {
			_ = try await cache.getOrAdd(key: "test") { _ in
				throw TestError()
			}
		}
	}
}
