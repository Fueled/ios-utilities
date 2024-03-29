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

///
/// Used to retrieve the frame of a view through a preference key.
/// `TagType` is used to uniquely identify the view using the preference key.
///
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct FramePreferenceKey<TagType>: PreferenceKey {
	public static var defaultValue: CGRect {
		.zero
	}

	public static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
		value = nextValue()
	}
}
