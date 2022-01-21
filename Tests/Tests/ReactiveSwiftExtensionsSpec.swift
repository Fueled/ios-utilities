// Copyright © 2020 Fueled Digital Media, LLC
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

import Quick
import Nimble
#if canImport(FueledUtilsReactiveSwift)
import FueledUtilsReactiveSwift
#elseif canImport(FueledUtils)
import FueledUtils
#endif
import Foundation
import ReactiveSwift

class ReactiveSwiftExtensionsSpec: QuickSpec {
	override func spec() {
		describe("Signal") {
			describe("minimum") {
				it("should send any values after the minimum time specified") {
					let (signal, observer) = Signal<Void, Never>.pipe()
					let waitScheduler = QueueScheduler(qos: .utility, name: "Observe", targeting: nil)
					var valuesReceived = 0
					signal.minimum(interval: 0.1, on: waitScheduler).observeValues {
						valuesReceived += 1
					}

					observer.send(value: ())

					expect(valuesReceived) == 0

					expect(valuesReceived).toEventually(equal(1), timeout: .seconds(1))

					observer.send(value: ())

					expect(valuesReceived) == 2
				}
				it("should send any errors after the minimum time specified") {
					let (signal, observer) = Signal<Never, NSError>.pipe()
					let waitScheduler = QueueScheduler(qos: .utility, name: "Observe", targeting: nil)
					var errorsReceived = 0
					signal.minimum(interval: 0.1, on: waitScheduler).observeFailed { _ in
						errorsReceived += 1
					}

					observer.send(error: NSError(domain: "", code: 0, userInfo: nil))

					expect(errorsReceived) == 0

					expect(errorsReceived).toEventually(equal(1), timeout: .seconds(1))
				}
				it("should send any values instantly and receive an interrupted event if interrupted before the minimum interval is met") {
					let (signal, observer) = Signal<Void, Never>.pipe()
					let waitScheduler = QueueScheduler(qos: .utility, name: "Observe", targeting: nil)
					var valuesReceived = 0
					var interruptedReceived = 0
					signal.minimum(interval: 0.1, on: waitScheduler).observe { event in
						switch event {
						case .value:
							valuesReceived += 1
						case .interrupted:
							interruptedReceived += 1
						default:
							break
						}
					}

					observer.send(value: ())
					observer.send(value: ())

					expect(valuesReceived) == 0
					expect(interruptedReceived) == 0

					observer.sendInterrupted()

					expect(valuesReceived) == 2
					expect(interruptedReceived) == 1
				}
			}
		}
	}
}
