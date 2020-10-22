// Copyright © 2020, Fueled Digital Media, LLC
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

import Combine

extension Publishers {
	public struct CombineLatestMany<PublisherCollection: Swift.Collection>: Publisher where PublisherCollection.Element: Combine.Publisher {
		public typealias Output = [PublisherCollection.Element.Output]

		public typealias Failure = PublisherCollection.Element.Failure

		public let publishers: PublisherCollection

		public init(_ publishers: PublisherCollection) {
			self.publishers = publishers
		}

		public func receive<Subscriber: Combine.Subscriber>(subscriber: Subscriber) where PublisherCollection.Element.Failure == Subscriber.Failure, Subscriber.Input == Output {
			let subscription = CombineLatestManySubscription(subscriber: subscriber, publishers: self.publishers)
			subscription.startReceiving()
		}
	}
}

private final class CombineLatestManySubscription<
	Subscriber: Combine.Subscriber,
	PublisherCollection: Swift.Collection
>: Subscription where
	PublisherCollection.Element: Combine.Publisher,
	PublisherCollection.Element.Failure == Subscriber.Failure,
	Subscriber.Input == [PublisherCollection.Element.Output]
{
	@Atomic private var demandsState = DemandsState()
	private let subscriber: Subscriber
	private let publishers: PublisherCollection

	private struct DemandsState {
		var currentDemand: Subscribers.Demand!
		var pendingValuesBuffer: [Subscriber.Input] = []
		var cancellables: [AnyCancellable] = []

		mutating func cancel() {
			self.currentDemand = .none
			self.pendingValuesBuffer = []
			self.cancellables.forEach { $0.cancel() }
		}
	}

	init(subscriber: Subscriber, publishers: PublisherCollection) {
		self.subscriber = subscriber
		self.publishers = publishers
	}

	func startReceiving() {
		self.subscriber.receive(subscription: self)
	}

	func request(_ demand: Subscribers.Demand) {
		if self.publishers.isEmpty {
			if demand > 0 {
				self.subscriber.receive([])
			}
			self.subscriber.receive(completion: .finished)
			return
		}

		func sendValueIfPossible(_ value: Subscriber.Input, demandsState: inout DemandsState) {
			if demandsState.currentDemand == nil {
				// Cancelled
				return
			}

			if demandsState.currentDemand == 0 {
				demandsState.pendingValuesBuffer.append(value)
				return
			}

			self.subscriber.receive(value)
			demandsState.currentDemand -= 1
		}

		let shouldReturn = self.$demandsState.modify { demandsState -> Bool in
			if let currentDemand = demandsState.currentDemand {
				demandsState.currentDemand += demand
				while let firstValue = demandsState.pendingValuesBuffer.first, demandsState.currentDemand > 0 {
					demandsState.pendingValuesBuffer.removeFirst()
					sendValueIfPossible(firstValue, demandsState: &demandsState)
				}
				return true
			}

			demandsState.currentDemand = demand
			return false
		}

		if shouldReturn {
			return
		}

		let publishers = Array(self.publishers)
		let cancellables = AtomicValue(
			[
				(
					cancellable: AnyCancellable?,
					latestValue: PublisherCollection.Element.Output?,
					hasCompleted: Bool
				),
			](repeating: (nil, nil, false), count: self.publishers.count)
		)
		publishers.enumerated().forEach { index, publisher in
			let cancellable = publisher.sink(
				receiveCompletion: { completion in
					cancellables.modify {
						switch completion {
						case .failure(let error):
							self.subscriber.receive(completion: .failure(error))
							for i in $0.indices {
								$0[i].cancellable = nil
							}
						case .finished:
							$0[index].cancellable = nil
							$0[index].hasCompleted = true
							if $0.allSatisfy({ $0.hasCompleted }) {
								self.subscriber.receive(completion: .finished)
							}
						}
					}
				},
				receiveValue: { value in
					cancellables.modify {
						$0[index].latestValue = value
						let allLatestValues = $0.compactMap { $0.latestValue }
						if allLatestValues.count == publishers.count {
							self.$demandsState.modify {
								sendValueIfPossible(allLatestValues, demandsState: &$0)
							}
						}
					}
				}
			)
			cancellables.modify { cancellables in
				if !cancellables[index].hasCompleted {
					cancellables[index].cancellable = cancellable
				}
				self.$demandsState.modify {
					$0.cancellables = cancellables.compactMap { $0.cancellable }
				}
			}
		}
	}

	func cancel() {
		self.$demandsState.modify { $0.cancel() }
	}
}
