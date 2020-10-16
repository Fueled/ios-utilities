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

import FueledUtils
import ReactiveSwift

///
/// A type-erased Action that allows to store any `ReactiveActionProtocol`
/// (loosing any type information at the same time)
///
final class AnyAction: ReactiveActionProtocol {
	private let applyClosure: (Input) -> SignalProducer<Any, Error>
	private let deinitToken: Lifetime.Token

	init<Action: ReactiveActionProtocol>(_ action: Action) {
		self.isEnabled = action.isEnabled
		self.isExecuting = action.isExecuting
		self.applyClosure = { action.apply($0 as! Action.Input).map { $0 }.mapError { $0 } }
		self.events = action.events.map { $0.map { $0 }.mapError { $0 } }
		self.values = action.values.map { $0 }
		self.errors = action.errors.map { $0 }
		(self.lifetime, self.deinitToken) = Lifetime.make()
	}

	let isEnabled: Property<Bool>
	let isExecuting: Property<Bool>

	let events: Signal<Signal<Any, Error>.Event, Never>
	let values: Signal<Any, Never>
	let errors: Signal<Error, Never>

	let lifetime: Lifetime

	func apply(_ input: Any) -> SignalProducer<Any, Error> {
		self.applyClosure(input)
	}
}
