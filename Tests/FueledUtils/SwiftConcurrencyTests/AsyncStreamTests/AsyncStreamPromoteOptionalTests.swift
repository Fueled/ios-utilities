@testable import FueledSwiftConcurrency
import Testing

@Suite("AsyncStream PromoteOptional Tests")
struct AsyncStreamPromoteOptionalTests {
	@Test("Promotes values to optionals")
	func promotesToOptionalsTest() async {
		let originalStream = AsyncStream<Int> { continuation in
			continuation.yield(1)
			continuation.finish()
		}

		let optionalStream = originalStream.promoteOptional()

		var receivedValue: Int?
		for await value in optionalStream {
			receivedValue = value
		}

		#expect(receivedValue == 1)
	}

	@Test("Empty stream is still empty after promotion")
	func emptyStreamTest() async {
		let emptyStream = AsyncStream<String> { continuation in
			continuation.finish()
		}

		let optionalStream = emptyStream.promoteOptional()

		var receivedValues: [String?] = []
		for await value in optionalStream {
			receivedValues.append(value)
		}

		#expect(receivedValues.isEmpty)
	}

	@Test("Works with already optional values")
	func worksWithOptionalValuesTest() async {
		let originalStream = AsyncStream<Int?> { continuation in
			continuation.yield(1)
			continuation.yield(nil)
			continuation.yield(3)
			continuation.finish()
		}

		let doubleOptionalStream = originalStream.promoteOptional()

		var receivedValues: [Int??] = []
		for await value in doubleOptionalStream {
			receivedValues.append(value)
		}

		#expect(receivedValues.count == 3)
		#expect(receivedValues[0] == 1)
		#expect(receivedValues[1]! == nil)
		#expect(receivedValues[2] == 3)
	}

	@Test("Stream is properly finished after promotion")
	func streamFinishesTest() async {
		let originalStream = AsyncStream<Int> { continuation in
			continuation.yield(42)
			continuation.finish()
		}

		let optionalStream = originalStream.promoteOptional()

		var iterator = optionalStream.makeAsyncIterator()
		let firstValue = await iterator.next()
		let secondValue = await iterator.next()

		#expect(firstValue == 42)
		#expect(secondValue == nil)
	}
}
