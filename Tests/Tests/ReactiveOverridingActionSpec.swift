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
import FueledUtils
import Nimble
import ReactiveSwift

class ReactiveOverridingActionSpec: QuickSpec {
	override func spec() {
		describe("ReactiveOverridingAction") {
			describe("apply.start()") {
				it("should cancel the previous work") {
					var startCounter = 0
					var disposeCounter = 0
					var interruptedCounter = 0
					let overridingAction = ReactiveOverridingAction {
						SignalProducer(value: 2.0)
							.observe(on: UIScheduler())
							.delay(1.0, on: QueueScheduler.main)
							.on(
								started: {
									startCounter += 1
								},
								interrupted: {
									interruptedCounter += 1
								},
								disposed: {
									disposeCounter += 1
								}
							)
					}

					expect(startCounter) == 0

					let producersCount = 5
					(0..<producersCount).forEach { _ in
						overridingAction.apply(()).start()
					}

					expect(startCounter) == producersCount
					expect(disposeCounter).toEventually(equal(producersCount - 1), timeout: .milliseconds(10))
					expect(interruptedCounter).toEventually(equal(producersCount - 1), timeout: .milliseconds(10))

					expect(disposeCounter).toEventually(equal(producersCount), timeout: .seconds(2))
					expect(interruptedCounter).toEventually(equal(producersCount - 1), timeout: .seconds(2))
				}
			}
		}
	}
}
