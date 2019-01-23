/*
Copyright © 2019 Fueled Digital Media, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import Foundation
import ReactiveSwift
import Result

public enum LoadingState<Error: Swift.Error> {
	case `default`
	case loading
	case failed(error: Error)
	public var error: Error? {
		if case .failed(let error) = self {
			return error
		} else {
			return nil
		}
	}
	public var loading: Bool {
		if case .loading = self {
			return true
		} else {
			return false
		}
	}
}

public extension Action {
	public func loadingState() -> SignalProducer<LoadingState<Error>, NoError> {
		let loading = self.isExecuting.producer
			.filter { $0 }
			.map { _ in LoadingState<Error>.loading }
		let eventStates = SignalProducer(self.events).map {
			(event: Signal<Output, Error>.Event) -> LoadingState<Error> in
			switch event {
			case .failed(let error):
				return LoadingState<Error>.failed(error: error)
			default:
				return LoadingState<Error>.default
			}
		}
		return SignalProducer.merge(loading, eventStates)
	}
}
