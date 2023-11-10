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

@testable import FueledUtilsCombine

import Combine
import Foundation
import Quick
import Nimble

class CoalescingActionSpec: QuickSpec {
	override func spec() {
		describe("CoalescingAction") {
			describe("apply.dispose()") {
				it("should dispose of all created signal producers") {
					var subscriptionCounter = 0
					var cancelledCounter = 0
					let coalescingAction = CoalescingAction {
						Just(2.0)
							.delay(for: 1.0, scheduler: DispatchQueue.main)
							.handleEvents(
								receiveSubscription: { _ in
									subscriptionCounter += 1
								},
								receiveCancel: {
									cancelledCounter += 1
								}
							)
					}

					expect(subscriptionCounter) == 0

					let publishersCount = 5
					let cancellables = (0..<publishersCount).map { _ in coalescingAction.apply(()).sink() }

					expect(subscriptionCounter) == 1

					cancellables[0].cancel()

					expect(cancelledCounter) == 0

					cancellables[1..<publishersCount].forEach { $0.cancel() }

					expect(cancelledCounter).toEventually(equal(1))
				}
			}
		}
	}
}
