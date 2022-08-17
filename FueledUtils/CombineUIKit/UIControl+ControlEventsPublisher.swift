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

#if canImport(UIKit) && !os(watchOS) && canImport(Combine)
import Combine
import UIKit

private var publisherControlEventsProcessorsHolderKey: UInt8 = 0

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension ControlProtocol {
	public func publisherForControlEvents(_ controlEvents: UIControl.Event) -> AnyPublisher<Self, Never> {
		let passthroughSubject = PassthroughSubject<Any, Never>()
		var cancellable: AnyCancellable! = self.publisherControlEventsProcessorsHolder.addProcessor(
			for: controlEvents,
			in: self,
			passthroughSubject: passthroughSubject
		)
		_ = cancellable
		return passthroughSubject
			.map {
				$0 as! Self
			}
			.handleEvents(
				receiveCancel: {
					cancellable = nil
				}
			)
			.eraseToAnyPublisher()
	}

	private var publisherControlEventsProcessorsHolder: PublisherControlEventsProcessorsHolder {
		get {
			objc_getAssociatedObject(self, &publisherControlEventsProcessorsHolderKey) as? PublisherControlEventsProcessorsHolder ?? {
				let publisherControlEventsProcessorsHolder = PublisherControlEventsProcessorsHolder()
				self.publisherControlEventsProcessorsHolder = publisherControlEventsProcessorsHolder
				return publisherControlEventsProcessorsHolder
			}()
		}
		set {
			objc_setAssociatedObject(self, &publisherControlEventsProcessorsHolderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private final class PublisherControlEventsProcessorsHolder {
	private final class PublisherControlEventsProcessor: NSObject {
		weak var passthroughSubject: PassthroughSubject<Any, Never>!

		init(control: ControlProtocol, controlEvents: UIControl.Event, passthroughSubject: PassthroughSubject<Any, Never>) {
			self.passthroughSubject = passthroughSubject
			super.init()
			control.addTarget(self, action: #selector(PublisherControlEventsProcessor.handleControlEvents(_:)), for: controlEvents)
		}

		@objc func handleControlEvents(_ sender: Any) {
			self.passthroughSubject.send(sender)
		}
	}

	private var processors: [PublisherControlEventsProcessor] = []

	init() {
	}

	func addProcessor(
		for controlEvents: UIControl.Event,
		in control: ControlProtocol,
		passthroughSubject: PassthroughSubject<Any, Never>
	) -> AnyCancellable {
		let processor = PublisherControlEventsProcessor(
			control: control,
			controlEvents: controlEvents,
			passthroughSubject: passthroughSubject
		)
		return AnyCancellable {
			self.processors.removeAll { $0 === processor }
		}
	}
}

#endif
