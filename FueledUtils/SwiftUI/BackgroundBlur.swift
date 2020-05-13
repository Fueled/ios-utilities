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

public struct BlurView: UIViewRepresentable {
	public let style: UIBlurEffect.Style

	public func makeUIView(context: Context) -> UIVisualEffectView {
		UIVisualEffectView(effect: UIBlurEffect(style: self.style))
	}

	public func updateUIView(_ visualEffectView: UIVisualEffectView, context: Context) {
		visualEffectView.effect = UIBlurEffect(style: self.style)
	}
}

extension View {
	public func backgroundBlur(style: UIBlurEffect.Style, color: Color? = nil) -> some View {
		ZStack {
			color
			BlurView(style: style)
			self
				.eraseToAnyView()
		}
	}
}
