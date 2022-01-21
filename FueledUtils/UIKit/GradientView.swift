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

#if canImport(UIKit)
import UIKit

///
/// An easy to use wrapper around `CGGradient` for drawing linear gradients.
///
/// For examples and testing its usage, you can use the `FueledUtils` playground file provided with the workspace.
///
public final class GradientView: UIView {
	///
	/// Defines the colors of a given type.
	///
	public enum Definition {
		///
		/// Defines a simple gradient, that has a start color and an end color
		///
		case simple(startColor: UIColor, endColor: UIColor)
		///
		/// Defines a custom gradient, that has as many colors and location point as wanted.
		/// It should at least contain 2 elements.
		/// When used in `GradientView`, it ensures that it is the case, and will report a
		/// crash at runtime if the array has less than 2 elements.
		///
		case custom([(color: UIColor, location: CGFloat)])

		///
		/// Get the start color of the receiver.
		/// If the current value is `.simple`, returns `startColor`.
		/// If the current value is `.custom`, returns the first color of the array. If the array is empty, this will crash at runtime.
		///
		public var startColor: UIColor {
			switch self {
			case .simple(let startColor, _):
				return startColor
			case .custom(let colors):
				return colors.first!.color
			}
		}

		///
		/// Get the end color of the receiver.
		/// If the current value is `.simple`, returns `endColor`.
		/// If the current value is `.custom`, returns the last color of the array. If the array is empty, this will crash at runtime.
		///
		public var endColor: UIColor {
			switch self {
			case .simple(_, let endColor):
				return endColor
			case .custom(let colors):
				return colors.last!.color
			}
		}

		fileprivate var gradientInfo: [(color: UIColor, location: CGFloat)] {
			switch self {
			case .simple(let startColor, let endColor):
				return [
					(startColor, 0.0),
					(endColor, 1.0),
				]
			case .custom(let colors):
				return colors
			}
		}
	}

	///
	/// Defines the different type of supported gradients.
	///
	public enum GradientType {
		///
		/// Defines a linear gradient type, along the specified direction.
		/// When used with `GradientView`, `direction` is scaled to the bounds of the view.
		///
		/// ## Examples
		/// - `.linear(direction: CGPoint(x: 0.0, y: 1.0)`: Define a gradient going from the left edge to the right edge.
		/// - `.linear(direction: CGPoint(x: 1.0, y: 1.0)`: Define a gradient going from the top-left corner to the bottom-right corner.
		/// - `.linear(direction: CGPoint(x: -1.0, y: -1.0)`: Define a gradient going from the bottom-right corner to the top-left corner.
		/// - `.linear(direction: CGPoint(x: -1.0, y: 0.0)`: Define a gradient going from the bottom edge to the top edge.
		/// - `.linear(direction: CGPoint(x: 0.0, y: 0.5)`: Define a gradient going from the top edge to the middle, extending the last color until the bottom edge.
		///
		/// - Note: If `direction` is `.zero`, only the `endColor` of the `Definition` will be drawn. See `GradientView.Definition.endColor` for more info
		/// about what this property refers to.
		///
		case linear(direction: CGPoint)
		///
		/// Defines a radial gradient type, starting at the specified center with the given initial radius, and expanding/reducing to the specified center and final radius.
		/// When used with `GradientView`, `startCenter` and `endCenter` is scaled to the bounds of the view. `startRadius` and `endRadius` are not scaled.
		///
		/// ## Examples
		/// - `.radial(startCenter: CGPoint(x: 0.5, y: 0.5), startRadius: 10.0, endCenter: CGPoint(x: 0.5, y: 0.5), endRadius: 200.0)`: Define a radial gradient that starts
		///   in the center of the view with an initial radius of 10, and expands to a radius of 200 without changing its center.
		/// - `.radial(startCenter: CGPoint(x: 0.0, y: 0.5), startRadius: 200.0, endCenter: CGPoint(x: 1.0, y: 0.5), endRadius: 10.0)`: Define a radial gradient that starts
		///   in the left edge of the view centered vertically with an initial radius of 200, and reduce to a radius of 50 to the right-most edge centered vertically.
		///
		/// - Note: When using different centers for a radial gradient, the resulting gradient might be unexpected.
		///
		case radial(startCenter: CGPoint, startRadius: CGFloat, endCenter: CGPoint, endRadius: CGFloat)
	}

	///
	/// Get/Set the type of the gradient. Please refer to `GradientType` for more info.
	///
	public var type: GradientType = .linear(direction: .verticalDirection) {
		didSet {
			self.setNeedsDisplay()
		}
	}

	///
	/// Get/Set the definition of the gradient. Please refer to `Definition` for more info.
	///
	/// - Warning: If the definition is `.custom`, and the array has less than 2 elements, the code will crash at runtime.
	///
	public var definition: Definition = .simple(startColor: .black, endColor: .white) {
		didSet {
			if case .custom(let info) = self.definition, info.count < 2 {
				fatalError(".custom() must have at least 2 colors to make a gradient")
			}
			self.setNeedsDisplay()
		}
	}

	///
	/// Get/Set the start color of the gradient.
	/// When getting the property, if the gradient is `.custom`, it will return the first color in the array.
	/// When setting this property, if the gradient is `.custom`, it will convert it to a `.simple` using
	/// the last color of the array as the `endColor`.
	///
	@IBInspectable
	public var startColor: UIColor {
		get {
			return self.definition.startColor
		}
		set {
			self.definition = .simple(startColor: newValue, endColor: self.definition.endColor)
		}
	}

	///
	/// Get/Set the end color of the gradient.
	/// When getting the property, if the gradient is `.custom`, it will return the last color in the array.
	/// When setting this property, if the gradient is `.custom`, it will convert it to a `.simple` using
	/// the first color of the array as the `startColor`.
	///
	@IBInspectable
	public var endColor: UIColor {
		get {
			return self.definition.endColor
		}
		set {
			self.definition = .simple(startColor: self.definition.startColor, endColor: newValue)
		}
	}

	///
	/// Get/set the direction of the gradient. Returns `.zero` if the configured gradient is not `.linear`
	/// When setting this property, if the gradient is not `.linear`, it is converted to a `.linear` gradient with the given direction.
	///
	@IBInspectable var direction: CGPoint {
		get {
			if case .linear(let direction) = self.type {
				return direction
			}
			return .zero
		}
		set {
			self.type = .linear(direction: newValue)
		}
	}

	///
	/// Please refer to the documentation for `UIView.init(frame:)`
	///
	override public init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
	}

	///
	/// Please refer to the documentation for `UIView.init(coder:)`
	///
	required public init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}

	private func commonInit() {
		self.contentMode = .redraw
		// https://stackoverflow.com/a/43898524/3605958
		// The background color must be set to a non-nil value or drawRect(_:) will not render the gradient properly
		self.backgroundColor = UIColor.clear
	}

	///
	/// Please refer to the documentation for `UIView.draw(_:)`
	///
	override public func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()!
		let colors = self.definition.gradientInfo.map { $0.color.cgColor }
		var locations = self.definition.gradientInfo.map { $0.location }
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: &locations)!
		switch self.type {
		case .linear(let direction):
			let baseEnd = CGPoint(
				x: self.bounds.size.width * direction.x,
				y: self.bounds.size.height * direction.y
			)
			context.drawLinearGradient(
				gradient,
				start: CGPoint(
					x: baseEnd.x < 0.0 ? -baseEnd.x : 0.0,
					y: baseEnd.y < 0.0 ? -baseEnd.y : 0.0
				),
				end: CGPoint(
					x: baseEnd.x < 0.0 ? 0.0 : baseEnd.x,
					y: baseEnd.y < 0.0 ? 0.0 : baseEnd.y
				),
				options: [
					.drawsBeforeStartLocation,
					.drawsAfterEndLocation,
				]
			)
		case .radial(let startCenter, let startRadius, let endCenter, let endRadius):
			let startCenter = CGPoint(
				x: self.bounds.size.width * startCenter.x,
				y: self.bounds.size.height * startCenter.y
			)
			let endCenter = CGPoint(
				x: self.bounds.size.width * endCenter.x,
				y: self.bounds.size.height * endCenter.y
			)
			context.drawRadialGradient(
				gradient,
				startCenter: startCenter,
				startRadius: startRadius,
				endCenter: endCenter,
				endRadius: endRadius,
				options: [
					.drawsBeforeStartLocation,
					.drawsAfterEndLocation,
				]
			)
		}
	}
}

extension CGPoint {
	///
	/// Defines a vertical top to down direction.
	///
	public static var verticalDirection: CGPoint {
		return CGPoint(x: 0.0, y: 1.0)
	}

	///
	/// Defines a horizontal left to right direction.
	///
	public static var horizontalDirection: CGPoint {
		return CGPoint(x: 1.0, y: 0.0)
	}
}
#endif
