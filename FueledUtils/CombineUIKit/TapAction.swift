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

#if canImport(UIKit) && !os(watchOS)
import Combine

///
/// `TapAction` wraps a `ActionProtocol` for use by any `ControlProtocol`.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
final class TapAction<Control: ControlProtocol>: NSObject {
	@objc static var selector: Selector {
		#selector(userDidTapControl(_:))
	}

	@Published private(set) var isExecuting: Bool = false
	@Published private(set) var isEnabled: Bool = false

	// FIXME: (Stéphane) To be retested for the next version of Swift (after 5.3)
	// Any initializers below create a segfault when compiling with optimizations.
	#if false
	private let inputTransform: ((Control) -> Any)
	private let action: AnyAction
	private var cancellables = Set<AnyCancellable>()

	convenience init<Action: ActionProtocol>(_ action: Action) where Action.Input == Void {
		self.init(action, input: ())
	}

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
		#if false
		self.action.apply(self.inputTransform(button as! Control)).sink()
			.store(in: &self.cancellables)
		#endif
	}
}
#endif
