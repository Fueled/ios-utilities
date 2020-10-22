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
import FueledUtils
import ReactiveSwift
import Combine

class SinkForLifetimeSpec: QuickSpec {
	override func spec() {
		describe("sinkForLifeTimeOf()") {
			it("should cancel itself automatically when the object becomes out of scope") {
				var object: NSObject!
				var valueCount = 0
				var cancelCount = 0
				do {
					object = NSObject()
					Timer.publish(every: 0.42, on: .current, in: .common)
						.autoconnect()
						.handleEvents(
							receiveCancel: {
								cancelCount += 1
							}
						)
						.sinkForLifetimeOf(object) { _ in
							valueCount += 1
						}
				}

				DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
					object = nil
				}

				expect(valueCount).toEventually(equal(2))
				expect(cancelCount).toEventually(equal(1), timeout: 2.0)
			}
		}
	}
}
