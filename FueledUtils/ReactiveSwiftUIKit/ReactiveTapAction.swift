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
import ReactiveSwift
import Foundation
#if canImport(FueledUtilsUIKit)
import FueledUtilsUIKit
import FueledUtilsReactiveSwift
#endif

///
/// `ReactiveTapAction` wraps a `ReactiveActionProtocol` for use by any `ButtonProtocol`
/// This is a mirror of `CococaAction` in `ReactiveCocoa`, allowing to use a
/// `ButtonProtocol` and assigin
///
public final class ReactiveTapAction<Control: ControlProtocol>: NSObject {
	@objc static var selector: Selector {
		#selector(userDidTapControl(_:))
	}

	public let isExecuting: Property<Bool>
	public let isEnabled: Property<Bool>

	private let executeClosure: (Control) -> Void

	public convenience init<Action: ReactiveActionProtocol>(_ action: Action) where Action.Input == Void {
		self.init(action, input: ())
	}

	public convenience init<Action: ReactiveActionProtocol>(_ action: Action, input: Action.Input) {
		self.init(action) { _ in input }
	}

	public init<Action: ReactiveActionProtocol>(_ action: Action, inputTransform: @escaping (Control) -> Action.Input) {
		self.executeClosure = {
			action.apply(inputTransform($0)).start()
		}

		self.isEnabled = Property(
			initial: action.isEnabled.value,
			then: action.isEnabled.producer.observe(on: UIScheduler())
		)
		self.isExecuting = Property(
			initial: action.isExecuting.value,
			then: action.isExecuting.producer.observe(on: UIScheduler())
		)
	}

	@objc private func userDidTapControl(_ button: Any) {
		self.executeClosure(button as! Control)
	}
}
#endif
