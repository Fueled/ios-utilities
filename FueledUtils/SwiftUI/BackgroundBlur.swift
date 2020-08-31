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

extension View {
	#if os(iOS)
	public func backgroundBlur(style: UIBlurEffect.Style, color: Color? = nil) -> some View {
		ZStack {
			color
			BlurView(style: style)
			self
				.eraseToAnyView()
		}
	}
	#else
	public func backgroundBlur(
		material: NSVisualEffectView.Material = .appearanceBased,
		blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
		state: NSVisualEffectView.State = .followsWindowActiveState,
		maskImage: NSImage? = nil,
		isEmphasized: Bool = false,
		color: Color? = nil
	) -> some View {
		ZStack {
			color
			BlurView(
				material: material,
				blendingMode: blendingMode,
				state: state,
				maskImage: maskImage,
				isEmphasized: isEmphasized
			)
			self
				.eraseToAnyView()
		}
	}
	#endif
}
