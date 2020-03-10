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
			if self.publishers.isEmpty {
				_ = subscriber.receive([])
				subscriber.receive(completion: .finished)
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
								subscriber.receive(completion: .failure(error))
								for i in $0.indices {
									$0[i].cancellable = nil
								}
							case .finished:
								$0[index].cancellable = nil
								$0[index].hasCompleted = true
								if $0.allSatisfy({ $0.hasCompleted }) {
									subscriber.receive(completion: .finished)
								}
							}
						}
					},
					receiveValue: { value in
						cancellables.modify {
							$0[index].latestValue = value
							let allLatestValues = $0.compactMap { $0.latestValue }
							if allLatestValues.count == publishers.count {
								_ = subscriber.receive(allLatestValues)
							}
						}
					}
				)
				cancellables.modify {
					if !$0[index].hasCompleted {
						$0[index].cancellable = cancellable
					}
				}
			}
		}
	}
}
