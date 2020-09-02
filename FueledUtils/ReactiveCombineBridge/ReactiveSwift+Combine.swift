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
import ReactiveSwift

// From https://github.com/ReactiveCocoa/ReactiveSwift/pull/776/files#diff-d8195adf8a5f3283e072483fd9699c90
extension SignalProducerConvertible {
	public func eraseToAnyPublisher() -> AnyPublisher<Value, Error> {
		self.publisher.eraseToAnyPublisher()
	}

	public var publisher: Publishers.SignalProducerPublisher<Value, Error> {
		Publishers.SignalProducerPublisher(self.producer)
	}
}

extension Publishers {
	public struct SignalProducerPublisher<Output, Failure: Swift.Error>: Publisher {
		public let base: SignalProducer<Output, Failure>

		public init(_ base: SignalProducer<Output, Failure>) {
			self.base = base
		}

		public func receive<Subscriber: Combine.Subscriber>(subscriber: Subscriber) where Subscriber.Input == Output, Subscriber.Failure == Failure {
			let subscription = SignalProducerSubscription(subscriber: subscriber, base: base)
			subscription.bootstrap()
		}
	}
}

private final class SignalProducerSubscription<Subscriber: Combine.Subscriber>: Combine.Subscription {
	typealias Output = Subscriber.Input
	typealias Failure = Subscriber.Failure

	let subscriber: Subscriber
	let base: SignalProducer<Output, Failure>
	private let state: ReactiveSwift.Atomic<State>

	init(subscriber: Subscriber, base: SignalProducer<Output, Failure>) {
		self.subscriber = subscriber
		self.base = base
		self.state = ReactiveSwift.Atomic(State())
	}

	func bootstrap() {
		subscriber.receive(subscription: self)
	}

	func request(_ incoming: Subscribers.Demand) {
		let response: DemandResponse = state.modify { state in
			guard state.hasCancelled == false else {
				return .noAction
			}

			guard state.hasStarted else {
				state.hasStarted = true
				state.requested = incoming
				return .startUpstream
			}

			state.requested = state.requested + incoming
			let unsatified = state.requested - state.satisfied

			if let max = unsatified.max {
				let dequeueCount = Swift.min(state.buffer.count, max)
				state.satisfied += dequeueCount

				defer { state.buffer.removeFirst(dequeueCount) }
				return .satisfyDemand(Array(state.buffer.prefix(dequeueCount)))
			} else {
				defer { state.buffer = [] }
				return .satisfyDemand(state.buffer)
			}
		}

		switch response {
		case let .satisfyDemand(output):
			var demand: Subscribers.Demand = .none

			for output in output {
				demand += subscriber.receive(output)
			}

			if demand != .none {
				request(demand)
			}

		case .startUpstream:
			let disposable = base.start { [weak self] event in
				guard let self = self else { return }

				switch event {
				case let .value(output):
					let (shouldSendImmediately, isDemandUnlimited): (Bool, Bool) = self.state.modify { state in
						guard state.hasCancelled == false else { return (false, false) }

						let unsatified = state.requested - state.satisfied

						if let count = unsatified.max, count >= 1 {
							assert(state.buffer.count == 0)
							state.satisfied += 1
							return (true, false)
						} else if unsatified == .unlimited {
							assert(state.buffer.isEmpty)
							return (true, true)
						} else {
							assert(state.requested == state.satisfied)
							state.buffer.append(output)
							return (false, false)
						}
					}

					if shouldSendImmediately {
						let demand = self.subscriber.receive(output)

						if isDemandUnlimited == false && demand != .none {
							self.request(demand)
						}
					}

				case .completed, .interrupted:
					self.cancel()
					self.subscriber.receive(completion: .finished)

				case let .failed(error):
					self.cancel()
					self.subscriber.receive(completion: .failure(error))
				}
			}

			let shouldDispose: Bool = state.modify { state in
				guard state.hasCancelled == false else { return true }
				state.producerSubscription = disposable
				return false
			}

			if shouldDispose {
				disposable.dispose()
			}

		case .noAction:
			break
		}
	}

	func cancel() {
		let disposable = state.modify { $0.cancel() }
		disposable?.dispose()
	}

	struct State {
		var requested: Subscribers.Demand = .none
		var satisfied: Subscribers.Demand = .none

		var buffer: [Output] = []

		var producerSubscription: Disposable?
		var hasStarted = false
		var hasCancelled = false

		init() {
			producerSubscription = nil
			hasStarted = false
			hasCancelled = false
		}

		mutating func cancel() -> Disposable? {
			hasCancelled = true
			defer { producerSubscription = nil }
			return producerSubscription
		}
	}

	enum DemandResponse {
		case startUpstream
		case satisfyDemand([Output])
		case noAction
	}
}


extension Cancellable {
	var disposable: some Disposable {
		CancellableDisposable(self)
	}
}

private final class CancellableDisposable<Cancellable: Combine.Cancellable>: Disposable {
	private let cancellable: Cancellable
	private(set) var isDisposed: Bool = false

	init(_ cancellable: Cancellable) {
		self.cancellable = cancellable
	}

	func dispose() {
		self.cancellable.cancel()
		self.isDisposed = true
	}
}
