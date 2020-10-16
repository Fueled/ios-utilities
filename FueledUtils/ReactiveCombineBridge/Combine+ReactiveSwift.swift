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

extension Publisher {
	public var producer: SignalProducer<Output, Failure> {
		SignalProducer { observer, lifetime in
			lifetime += self.sink(
				receiveCompletion: { completion in
					switch completion {
					case .finished:
						observer.sendCompleted()
					case .failure(let error):
						observer.send(error: error)
					}
				},
				receiveValue: { value in
					observer.send(value: value)
				}
			)
		}
	}
}

extension Lifetime {
	@discardableResult
	public static func += <Cancellable: Combine.Cancellable>(lhs: Lifetime, rhs: Cancellable?) -> Disposable? {
		rhs.flatMap { lhs.observeEnded($0.cancel) }
	}
}

extension Disposable {
	public var cancellable: some Cancellable {
		DisposableCancellable(self)
	}
}

private struct DisposableCancellable<Disposable: ReactiveSwift.Disposable>: Cancellable {
	private let disposable: Disposable

	init(_ disposable: Disposable) {
		self.disposable = disposable
	}

	func cancel() {
		self.disposable.dispose()
	}
}
