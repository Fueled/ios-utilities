// Copyright © 2020 Fueled Digital Media, LLC
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
import Quick
import Nimble

class CombineLatestManySpec: QuickSpec {
	private var cancellables: [AnyCancellable]!

	override func spec() {
		describe("Publishers.CombineLatestMany") {
			beforeEach {
				self.cancellables = []
			}
			describe("with zero elements") {
				it("should complete instantaneously with an empty array and no errors") {
					var completionCount = 0
					var valueCount = 0
					Publishers.CombineLatestMany<[Just<Void>]>([]).sink(
						receiveCompletion: { completion in
							let isFinished: Bool
							switch completion {
							case .failure:
								isFinished = false
							case .finished:
								isFinished = true
							}
							expect(isFinished) == true
							completionCount += 1
						},
						receiveValue: { values in
							expect(values).to(haveCount(0))
							valueCount += 1
						}
					)
						.store(in: &self.cancellables)

					expect(completionCount) == 1
					expect(valueCount) == 1
				}
			}
			describe("with two elements") {
				it("should match the native CombineLatest behavior") {
					var completionCount = 0
					var valueCount = 0
					var nativeValues: [Int] = []
					var manyValues: [Int] = []

					func publisher(_ value: Int) -> AnyPublisher<Int, Never> {
						Just(value).delay(for: 0.3, scheduler: DispatchQueue.main)
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
								expect(isFinished) == true
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
								expect(isFinished) == true
								completionCount += 1
							},
							receiveValue: { values in
								manyValues = values
								valueCount += 1
							}
						)
						.store(in: &self.cancellables)

					expect(completionCount).toEventually(equal(2))
					expect(valueCount).toEventually(equal(4))

					expect(nativeValues).toEventually(equal([3, 2]))
					expect(manyValues).toEventually(equal([3, 2]))
				}
			}
			describe("with two publishers") {
				it("should correctly interrupt the publishers when interrupted") {
					var subscriptionCount = 0
					var cancelCount = 0
					var nativeValueCount = 0
					var nativeValues: [Int] = []
					var manyValueCount = 0
					var manyValues: [Int] = []

					func publisher(_ value: Int) -> AnyPublisher<Int, Never> {
						Just(1).delay(for: 0.5, scheduler: DispatchQueue.main)
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

					expect(subscriptionCount) == 4
					expect(cancelCount).toEventually(equal(6))

					expect(nativeValueCount).toEventually(equal(0))
					expect(nativeValues).toEventually(haveCount(0))

					expect(manyValueCount).toEventually(equal(0))
					expect(manyValues).toEventually(haveCount(0))
				}
			}
		}
	}
}
