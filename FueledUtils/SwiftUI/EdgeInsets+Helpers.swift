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

import SwiftUI

extension EdgeInsets {
	public static var zero: EdgeInsets {
		EdgeInsets(top: 0.0, leading: 0.0, bottom: 0.0, trailing: 0.0)
	}

	public init(_ length: CGFloat) {
		self.init(top: length, leading: length, bottom: length, trailing: length)
	}

	public init(_ edges: Edge.Set, _ length: CGFloat) {
		self.init(
			top: edges.contains(.top) ? length : 0.0,
			leading: edges.contains(.leading) ? length : 0.0,
			bottom: edges.contains(.bottom) ? length : 0.0,
			trailing: edges.contains(.trailing) ? length : 0.0
		)
	}
}
