@testable import FueledSwiftConcurrency
import Testing

@Suite("AsyncStream Single Tests")
struct AsyncStreamSingleTests {
	@Test("Single value is emitted correctly")
	func singleValueTest() async {
		let stream = AsyncStream<Int>.single(value: 42)

		var receivedValues: [Int] = []
		for await value in stream {
			receivedValues.append(value)
		}

		#expect(receivedValues.count == 1)
		#expect(receivedValues.first == 42)
	}

	@Test("Stream finishes after single value")
	func streamFinishesTest() async {
		let stream = AsyncStream<String>.single(value: "test")

		var iterator = stream.makeAsyncIterator()
		let firstValue = await iterator.next()
		let secondValue = await iterator.next()

		#expect(firstValue == "test")
		#expect(secondValue == nil)
	}
}
