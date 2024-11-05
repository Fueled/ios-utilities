// Copyright © 2024 Fueled Digital Media, LLC
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
import Testing

@Suite("AnyCurrentValuePluisher Initialization")
struct AnyCurrentValuePublisherTests {
	@Test("Should initialize with a stored value")
	func withAStoredValue() {
		let publisher = AnyCurrentValuePublisher<Int, Never>(1)
		#expect(publisher.value == 1)
	}

	@Test("Should initialize with a nested CurrentValueSubject")
	func withNestedCurrentValueSubject() {
		let subject = CurrentValueSubject<Int, Never>(2)
		let publisher = AnyCurrentValuePublisher(subject)
		#expect(publisher.value == 2)
	}
}
