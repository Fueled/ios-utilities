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

///
/// Represents the possible state of an `Action` in Reactive Swift.
///
public enum LoadingState<Error: Swift.Error> {
	///
	/// Represents the state of an action that has received any values, has completed successfully or was interrupted.
	///
	case `default`
	///
	/// Represents the state of an action that is loading
	///
	case loading
	///
	/// Represents the state of an action that has failed, with the `Error` it failed with.
	///
	case failed(error: Error)

	///
	/// If the current state is `.failed`, returns the associated error. If not, returns `nil`
	///
	public var error: Error? {
		if case .failed(let error) = self {
			return error
		} else {
			return nil
		}
	}

	///
	/// If the current state is `.loading`, returns `true`. If not, returns `false`
	///
	public var isLoading: Bool {
		if case .loading = self {
			return true
		} else {
			return false
		}
	}
}

extension ActionProtocol {
	///
	/// Returns a `SignalProducer` whose events corresponds to the current loading state of the action.
	/// Please refer to `LoadingState` for more info.
	///
	public var loadingState: SignalProducer<LoadingState<Error>, Never> {
		let loading = self.isExecuting.producer
			.filter { $0 }
			.map { _ in LoadingState<Error>.loading }
		let eventStates = self.events.map { (event: Signal<Output, Error>.Event) -> LoadingState<Error> in
			switch event {
			case .failed(let error):
				return .failed(error: error)
			default:
				return .default
			}
		}
		return SignalProducer.merge(loading, eventStates)
	}
}
