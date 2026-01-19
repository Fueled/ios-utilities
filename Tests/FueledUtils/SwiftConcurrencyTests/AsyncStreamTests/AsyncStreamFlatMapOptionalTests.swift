@testable import FueledSwiftConcurrency
import Testing

@Suite("AsyncStream FlatMapOptional Tests")
struct AsyncStreamFlatMapOptionalTests {
	@Test("Transforms values through streams")
	func transformsValuesTest() async {
		let originalStream = AsyncStream<Int> { continuation in
			continuation.yield(1)
			continuation.yield(2)
			continuation.finish()
		}

		let transformedStream = originalStream.flatMapOptional { value -> AsyncStream<String>? in
			AsyncStream<String> { continuation in
				continuation.yield("\(value) transformed")
				continuation.finish()
			}
		}

		var receivedValues: [String?] = []
		for await value in transformedStream {
			receivedValues.append(value)
		}

		#expect(receivedValues.count == 2)
		#expect(receivedValues[0] == "1 transformed")
		#expect(receivedValues[1] == "2 transformed")
	}

	@Test("Handles nil streams correctly")
	func handlesNilStreamsTest() async {
		let originalStream = AsyncStream<Int> { continuation in
			continuation.yield(1)
			continuation.yield(2)
			continuation.yield(3)
			continuation.finish()
		}

		let transformedStream = originalStream.flatMapOptional { value -> AsyncStream<String>? in
			if value.isMultiple(of: 2) {
				return AsyncStream<String> { continuation in
					continuation.yield("Even: \(value)")
					continuation.finish()
				}
			} else {
				return nil
			}
		}

		var receivedValues: [String?] = []
		for await value in transformedStream {
			receivedValues.append(value)
		}

		#expect(receivedValues.count == 3)
		#expect(receivedValues[0] == nil)
		#expect(receivedValues[1] == "Even: 2")
		#expect(receivedValues[2] == nil)
	}

	@Test("Propagates upstream termination")
	func propagatesTerminationTest() async {
		let originalStream = AsyncStream<Int> { continuation in
			continuation.yield(1)
			continuation.finish()
		}

		let transformedStream = originalStream.flatMapOptional { value -> AsyncStream<String>? in
			AsyncStream<String> { continuation in
				continuation.yield("\(value) transformed")
				continuation.yield("additional value")
				continuation.finish()
			}
		}

		var receivedValues: [String?] = []
		for await value in transformedStream {
			receivedValues.append(value)
		}

		#expect(receivedValues.count == 2)
		#expect(receivedValues[0] == "1 transformed")
		#expect(receivedValues[1] == "additional value")
	}

	@Test("Handles empty source stream")
	func handlesEmptySourceTest() async {
		let emptyStream = AsyncStream<Int> { continuation in
			continuation.finish()
		}

		let transformedStream = emptyStream.flatMapOptional { value -> AsyncStream<String>? in
			AsyncStream<String> { continuation in
				continuation.yield("\(value) transformed")
				continuation.finish()
			}
		}

		var receivedValues: [String?] = []
		for await value in transformedStream {
			receivedValues.append(value)
		}

		#expect(receivedValues.isEmpty)
	}

	@Test("Multiple values from inner streams are propagated")
	func multipleInnerValuesTest() async {
		let originalStream = AsyncStream<Int> { continuation in
			continuation.yield(1)
			continuation.yield(2)
			continuation.finish()
		}

		let transformedStream = originalStream.flatMapOptional { value -> AsyncStream<String>? in
			AsyncStream<String> { continuation in
				for i in 1...value {
					continuation.yield("\(value).\(i)")
				}
				continuation.finish()
			}
		}

		var receivedValues: [String?] = []
		for await value in transformedStream {
			receivedValues.append(value)
		}

		#expect(receivedValues.count == 3)
		#expect(receivedValues[0] == "1.1")
		#expect(receivedValues[1] == "2.1")
		#expect(receivedValues[2] == "2.2")
	}
}
