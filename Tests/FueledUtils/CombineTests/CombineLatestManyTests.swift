// Copyright © 2024 Fueled Digital Media, LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@testable import FueledUtilsCombine

import Combine
import Foundation
import Testing

@Suite("Combine Latest Many")
struct CombineLatestManyTests {
	private var cancellables = [AnyCancellable]()

	@Test("With zero elements it should complete with an empty array and no errors")
	mutating func withZeroElements() {
		var completionCount = 0
		var valueCount = 0
		let publishers: [AnyPublisher<Void, Never>] = []
		Publishers.CombineLatestMany(publishers).sink(
			receiveCompletion: { completion in
				let isFinished: Bool
				switch completion {
				case .failure:
					isFinished = false
				case .finished:
					isFinished = true
				}
				#expect(isFinished == true)
				completionCount += 1
			},
			receiveValue: { values in
				#expect(values.count == .zero)
				valueCount += 1
			}
		)
		.store(in: &self.cancellables)

		#expect(completionCount == 1)
		#expect(valueCount == 1)
	}

	@Test("With two elements should match the native CombineLatest behavior")
	mutating func withTwoElements() async {
		var completionCount = 0
		var valueCount = 0
		var nativeValues: [Int] = []
		var manyValues: [Int] = []

		func publisher(_ value: Int) -> AnyPublisher<Int, Never> {
			Just(value)
				.delay(for: 0.1, scheduler: DispatchQueue.main)
				.eraseToAnyPublisher()
		}

		Publishers.CombineLatest(
			publisher(1).append(publisher(3)),
			publisher(2)
		)
		.sink(
			receiveCompletion: { completion in
				let isFinished: Bool
				switch completion {
				case .failure:
					isFinished = false
				case .finished:
					isFinished = true
				}
				#expect(isFinished == true)
				completionCount += 1
			},
			receiveValue: { value1, value2 in
				nativeValues = [value1, value2]
				valueCount += 1
			}
		)
		.store(in: &self.cancellables)

		Publishers.CombineLatestMany(
			[
				publisher(1).append(publisher(3)).eraseToAnyPublisher(),
				publisher(2).eraseToAnyPublisher()
			]
		)
		.sink(
			receiveCompletion: { completion in
				let isFinished: Bool
				switch completion {
				case .failure:
					isFinished = false
				case .finished:
					isFinished = true
				}
				#expect(isFinished == true)
				completionCount += 1
			},
			receiveValue: { values in
				manyValues = values
				valueCount += 1
			}
		)
		.store(in: &self.cancellables)

		try? await Task.sleep(for: .seconds(0.3))

		#expect(completionCount == 2)
		#expect(valueCount == 4)

		#expect(nativeValues == [3, 2])
		#expect(manyValues == [3, 2])
	}

	@Test("With two publishers should correctly interrupt the publishers when interrupted")
	mutating func withTwoPublishers() async {
		var subscriptionCount = 0
		var cancelCount = 0
		var nativeValueCount = 0
		var nativeValues: [Int] = []
		var manyValueCount = 0
		var manyValues: [Int] = []

		func publisher(_ value: Int) -> AnyPublisher<Int, Never> {
			Just(1)
				.delay(for: 0.1, scheduler: DispatchQueue.main)
				.handleEvents(
					receiveSubscription: { _ in
						subscriptionCount += 1
					},
					receiveCancel: {
						cancelCount += 1
					}
				)
				.eraseToAnyPublisher()
		}

		var cancellable = Publishers.CombineLatest(
			publisher(1),
			publisher(2)
		)
			.handleEvents(
				receiveCancel: {
					cancelCount += 1
				}
			)
			.sink(
				receiveValue: { value1, value2 in
					nativeValues = [value1, value2]
					nativeValueCount += 1
				}
			)

		cancellable = Publishers.CombineLatestMany(
			[
				publisher(1),
				publisher(2)
			]
		)
		.handleEvents(
			receiveCancel: {
				cancelCount += 1
			}
		)
		.sink(
			receiveValue: { values in
				manyValues = values
				manyValueCount += 1
			}
		)

		cancellable.cancel()

		#expect(subscriptionCount == 4)
		#expect(cancelCount == 6)

		#expect(nativeValueCount == 0)
		#expect(nativeValues.count == 0)

		#expect(manyValueCount == 0)
		#expect(manyValues.count == 0)
	}
}
