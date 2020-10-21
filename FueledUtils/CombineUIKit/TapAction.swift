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

///
/// `TapAction` wraps a `ActionProtocol` for use by any `ControlProtocol`.
final class TapAction<Control: ControlProtocol>: NSObject {
	@objc static var selector: Selector {
		#selector(userDidTapControl(_:))
	}

	@Published private(set) var isExecuting: Bool
	@Published private(set) var isEnabled: Bool

	private var inputTransform: ((Control) -> Any)!
	private var cancellables = Set<AnyCancellable>()
	private let action: AnyAction

	convenience init<Action: ActionProtocol>(_ action: Action) where Action.Input == Void {
		self.init(action, input: ())
	}

	#if true
	// Doing what's in the `else` branch below segfaults (more explanation below),
	// so we use another method to do it... (Swift 5.3/Xcode 12.0 (12A7209))
	convenience init<Action: ActionProtocol>(_ action: Action, input: Action.Input) {
		self.init(action: action)
		self.initializeInput(input)
	}

	convenience init<Action: ActionProtocol>(_ action: Action, inputTransform: @escaping (Control) -> Action.Input) {
		self.init(action: action)
		self.initializeInputTransform(inputTransform)
	}

	private init<Action: ActionProtocol>(action: Action) {
		self.isEnabled = action.isEnabled
		self.isExecuting = action.isExecuting
		self.action = AnyAction(action)
		super.init()
		self.initializePublishers()
	}

	private func initializeInput<Input>(_ input: Input) {
		self.initializeInputTransform { _ in input }
	}

	private func initializeInputTransform<Input>(_ inputTransform: @escaping (Control) -> Input) {
		self.inputTransform = { inputTransform($0) }
	}

	private func initializePublishers() {
		self.action.isEnabledPublisher.assign(to: \.isEnabled, withoutRetaining: self)
			.store(in: &self.cancellables)
		self.action.isExecutingPublisher.assign(to: \.isExecuting, withoutRetaining: self)
			.store(in: &self.cancellables)
	}
	#else
	// FIXME: (Stéphane) To be retested for the next version of Swift (after 5.3)
	// NOTE: The code is kept as it's how it be.

	// The issues here seems to be related to the closure, Swift doesn't seem to like passing them around directly
	// from one initializer to another, hence the workaround above.
	// It doesn't like initializer the publishers directly within the initializer, so we also have to create
	// a method that does it for us.
	// (I have a hunch it might be tied to the number of associated types in the `ActionProtocol` protocol)
	convenience init<Action: ActionProtocol>(_ action: Action, input: Action.Input) {
		self.init(action) { _ in input }
	}

	init<Action: ActionProtocol>(_ action: Action, inputTransform: @escaping (Control) -> Action.Input) {
		self.isEnabled = action.isEnabled
		self.isExecuting = action.isExecuting
		self.inputTransform = { inputTransform($0) }
		self.action = AnyAction(action)
		super.init()
		self.action.isEnabledPublisher.assign(to: \.isEnabled, withoutRetaining: self)
			.store(in: &self.cancellables)
		self.action.isExecutingPublisher.assign(to: \.isExecuting, withoutRetaining: self)
			.store(in: &self.cancellables)
	}
	#endif

	@objc private func userDidTapControl(_ button: Any) {
		self.action.apply(self.inputTransform(button as! Control)).sink()
			.store(in: &self.cancellables)
	}
}
