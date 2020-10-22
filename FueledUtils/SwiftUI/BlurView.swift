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
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit) && !os(watchOS)
@available(iOS 13.0, tvOS 13.0, *)
public struct BlurView: UIViewRepresentable {
	public let style: UIBlurEffect.Style

	public init(style: UIBlurEffect.Style) {
		self.style = style
	}

	public func makeUIView(context: Context) -> UIVisualEffectView {
		UIVisualEffectView(effect: UIBlurEffect(style: self.style))
	}

	public func updateUIView(_ visualEffectView: UIVisualEffectView, context: Context) {
		visualEffectView.effect = UIBlurEffect(style: self.style)
	}
}
#elseif canImport(AppKit)
@available(macOS 10.15, *)
public struct BlurView: NSViewRepresentable {
	public let material: NSVisualEffectView.Material
	public let blendingMode: NSVisualEffectView.BlendingMode
	public let state: NSVisualEffectView.State
	public let maskImage: NSImage?
	public let isEmphasized: Bool

	public init(
		material: NSVisualEffectView.Material = .appearanceBased,
		blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
		state: NSVisualEffectView.State = .followsWindowActiveState,
		maskImage: NSImage? = nil,
		isEmphasized: Bool = false
	) {
		self.material = material
		self.blendingMode = blendingMode
		self.state = state
		self.maskImage = maskImage
		self.isEmphasized = isEmphasized
	}

	public func makeNSView(context: Context) -> NSVisualEffectView {
		NSVisualEffectView()
	}

	public func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
		visualEffectView.material = self.material
		visualEffectView.blendingMode = self.blendingMode
		visualEffectView.state = self.state
		visualEffectView.maskImage = self.maskImage
		visualEffectView.isEmphasized = self.isEmphasized
	}
}

#endif
