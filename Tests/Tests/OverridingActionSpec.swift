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

#if canImport(Combine)
import Combine
#if canImport(FueledUtilsCombine)
import FueledUtilsCombine
#elseif canImport(FueledUtils)
import FueledUtils
#endif
import Foundation
import Quick
import Nimble

class OverridingActionSpec: QuickSpec {
	private var cancellables: [AnyCancellable]!

	override func spec() {
		describe("OverridingAction") {
			beforeEach {
				self.cancellables = []
			}
			describe("apply.sink()") {
				it("should cancel the previous work") {
					var subscriptionCounter = 0
					var cancelledCounter = 0
					var interruptedCounter = 0
					let coalescingAction = OverridingAction {
						Just(2.0)
							.delay(for: 1.0, scheduler: DispatchQueue.main)
							.handleEvents(
								receiveSubscription: { _ in
									subscriptionCounter += 1
								},
								receiveCancel: {
									cancelledCounter += 1
								},
								receiveTermination: {
									interruptedCounter += 1
								}
							)
					}

					expect(subscriptionCounter) == 0

					let publishersCount = 5
					self.cancellables = (0..<publishersCount).map { _ in coalescingAction.apply(()).sink() }

					expect(subscriptionCounter) == publishersCount
					expect(cancelledCounter) == publishersCount - 1
					expect(interruptedCounter) == publishersCount - 1

					expect(cancelledCounter).toEventually(equal(publishersCount - 1), timeout: .seconds(2))
					expect(cancelledCounter).toEventually(equal(interruptedCounter), timeout: .seconds(2))
				}
			}
		}
	}
}

#endif
