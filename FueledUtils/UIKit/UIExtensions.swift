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

import Foundation
import UIKit

extension CGSize {
	///
	/// Scale the recipient to the given size, according to the specified content mode.
	///
	/// This methods is best use in combination of `UIImage.resized`, to make sure that the image
	/// is scaled properly for your needs.
	///
	/// - Parameters:
	///   - size: The size to scale the receiver to.
	///   - contentMode: The content mode to use when scaling the receiver.
	///     If `contentMode` is `.scaleAspectFill`, the method will try to maximize the lowest dimension of the receiver
	///     to the lowest dimension of `size`.
	///     If `contentMode` is `.scaleAspectFit`, the method will try to maximize the highest dimension of the receiver
	///     to the lowest dimension of `size`.
	///     If the `contentMode` is `redraw` or `scaleToFill` (the default), `size` is returned.
	///     In all other cases, the receiver is returned and `size` is ignored.
	/// - Returns: The scaled size as specified by the parameters.
	///
	public func scaled(to size: CGSize, contentMode: UIView.ContentMode = .scaleToFill) -> CGSize {
		switch contentMode {
		case .redraw,
				 .scaleToFill:
			return size
		case .scaleAspectFill:
			let aspectRatio = self.width / self.height
			if self.width < self.height {
				return CGSize(width: size.width, height: size.width / aspectRatio)
			} else {
				return CGSize(width: size.width * aspectRatio, height: size.height)
			}
		case .scaleAspectFit:
			let aspectRatio = self.width / self.height
			if self.width < self.height {
				return CGSize(width: size.width, height: size.width / aspectRatio)
			} else {
				return CGSize(width: size.width * aspectRatio, height: size.height)
			}
		default:
			return self
		}
	}
}

extension UIColor {
	///
	/// Initialize a color using a 32-bits integr that represents a color, and an optional alpha component.
	/// Only the right-most 24-bits are used, the left-most 8 bits are ignored.
	///
	/// It is recommended to always include the leading zeros when using a literal color, so as to prevent confusion.
	/// ```swift
	/// UIColor(hex: 0x0000FF) // blue color
	/// ```
	/// rather than:
	/// ```swift
	/// UIColor(hex: 0xFF) // blue color
	/// ```
	///
	/// ## Examples
	/// ```swift
	/// UIColor(hex: 0xFF0000) // red color
	/// UIColor(hex: 0x00FF00) // green color
	/// UIColor(hex: 0x0000FF) // blue color
	/// ```
	///
	/// - Parameters:
	///   - hex: The hexadecimal value to use when initializing the color. The left-most 8 bits are ignored.
	///   - alpha: The alpha value to use when initializing the color. Defaults to `1`
	///
	public convenience init(hex: UInt32, alpha: CGFloat = 1) {
		func byteColor(_ x: UInt32) -> CGFloat {
			return CGFloat(x & 0xFF) / 255
		}
		let red = byteColor(hex >> 16)
		let green = byteColor(hex >> 8)
		let blue = byteColor(hex)
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}

	///
	/// Initialize a color using a hexadecimal string (case insensitive), with an optional `#` or `0x` prefix.
	///
	/// ## Examples
	/// ```swift
	/// UIColor(hexString: "FF0000") // red color
	/// UIColor(hexString: "#00ff00") // green color
	/// UIColor(hexString: "0x0000FF") // blue color
	/// UIColor(hexString: "0x0000FG") // nil
	/// UIColor(hexString: "FF000") // nil
	/// UIColor(hexString: "#FF000") // nil
	/// UIColor(hexString: "0xFF000") // nil
	/// ```
	///
	/// - Parameters:
	///   - hexString: The hexadecimal string to use when initializing the color. The string may start with `0x` and `#` and then must contain exactly 6 characters.
	///     Any invalid characters will result in the initializer failed.
	///   - alpha: The alpha value to use when initializing the color. Defaults to `1`
	///
	public convenience init?(hexString: String, alpha: CGFloat = 1) {
		let regex = try! NSRegularExpression(pattern: "\\A(?:0x|#)?([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])\\Z", options: [.caseInsensitive])
		guard let match = regex.firstMatch(in: hexString, options: [], range: hexString.nsRange), match.numberOfRanges == 4 else {
			return nil
		}
		let redString = (hexString as NSString).substring(with: match.range(at: 1))
		let greenString = (hexString as NSString).substring(with: match.range(at: 2))
		let blueString = (hexString as NSString).substring(with: match.range(at: 3))
		guard let red = Int(redString, radix: 16), let green = Int(greenString, radix: 16), let blue = Int(blueString, radix: 16) else {
			return nil
		}
		self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: alpha)
	}
}

extension UILabel {
	///
	/// Add the monospaced number font descriptor to the current `font`.
	///
	public func useMonospacedNumbers() {
		let fontDescriptor = self.font.fontDescriptor
		let newFontDescriptor = fontDescriptor.addingAttributes([
			UIFontDescriptor.AttributeName.featureSettings: [
				[
					UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
					UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector,
				],
			],
		])
		self.font = UIFont(descriptor: newFontDescriptor, size: self.font.pointSize)
	}

	///
	/// Allows to set the text and optionally animate the change.
	///
	/// - Parameters:
	///   - string: The text to set
	///   - animated: Whether to animate the change or not. If `false`, the method call is equivalent to using the setter `text`
	///
	public func setText(_ string: String?, animated: Bool) {
		if !animated {
			self.text = string
			return
		}
		UIView.transition(with: self, duration: 0.35, options: .transitionCrossDissolve, animations: {
			self.text = string
		}, completion: nil)
	}

	///
	/// Allows to set an attributed text and optionally animate the change.
	///
	/// - Parameters:
	///   - attributedString: The attributed string to set
	///   - animated: Whether to animate the change or not. If `false`, the method call is equivalent to using the setter `attributedText`
	///
	public func setAttributedText(_ attributedString: NSAttributedString, animated: Bool) {
		if !animated {
			self.attributedText = attributedString
			return
		}
		UIView.transition(with: self, duration: 0.35, options: .transitionCrossDissolve, animations: {
			self.attributedText = attributedString
		}, completion: nil)
	}
}

extension UIActivityIndicatorView {
	///
	/// **Unavailable**: Please use `animating` instead.
	///
	/// Refer to the documentation for `animating` for more info.
	///
	@available(*, unavailable, renamed: "animating")
	public var fueled_animating: Bool {
		get {
			return self.animating
		}
		set {
			self.animating = newValue
		}
	}

	///
	/// Get/Set the animating state of the `UIActivityIndicatorView`.
	///
	public var animating: Bool {
		get {
			return self.isAnimating
		}
		set {
			if newValue {
				self.startAnimating()
			} else {
				self.stopAnimating()
			}
		}
	}
}

extension UITextField {
	///
	/// Allows to set the placeholder color by setting the `attributedPlaceholder`.
	///
	/// - Warning: The getter must not be used or the code will crash at runtime.
	///
	@IBInspectable public var placeholderColor: UIColor? {
		get {
			fatalError("Getter for UITextField.placeholderColor is not implemented")
		}
		set {
			if let color = newValue, let placeholder = self.placeholder {
				attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [
					NSAttributedString.Key.foregroundColor: color,
				])
			}
		}
	}
}

extension UIView {
	///
	/// Adds the given subview into the receiver, and adds constraint so that its top, bottom, left and right's edges are bounds to its superview's edges.
	///
	public func addAndFitSubview(_ view: UIView) {
		view.translatesAutoresizingMaskIntoConstraints = false
		view.frame = self.bounds
		self.addSubview(view)
		let views = ["view": view]
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views))
	}

	///
	/// Take a snapshot of the view and returns a `UIImage`.
	///
	/// - Parameters:
	///   - afterScreenUpdates: Please refer to the documentation for `afterScreenUpdates` in `UIView.drawHierarchy(in:, afterScreenUpdates:)` for more info.
	/// - Returns: The image if it could be generated. If it couldn't, for example if the `UIView`'s width or height is 0, a crash will happen at runtime.
	///
	/// - Note: The returns is an implicitely unwrapped optional for backward-compatibility purpose, and will be made an optional in a future release (as well as not crash)
	///
	public func snapshotImage(afterScreenUpdates: Bool = true) -> UIImage! {
		return UIImage.draw(size: self.bounds.size) { _ in
			self.drawHierarchy(in: self.bounds, afterScreenUpdates: afterScreenUpdates)
		}
	}

	///
	/// Renders the view's layer and its sublayers and returns a `UIImage`. In contrast with `snapshotImage(afterScreenUpdates:)` which works only for visible onscreen content
	/// it works even in cases when the view's `draw(_:)` method hasn't been called yet at the moment of calling the method.
	///
	/// - Parameters:
	///   - opaque: Please refer to the parameters documentation for `UIGraphicsBeginImageContextWithOptions` for more info.
	///   - scale: Please refer to the parameters documentation for `UIGraphicsBeginImageContextWithOptions` for more info.
	/// - Returns: The image if it could be generated. If it couldn't, for example if the `UIView`'s width or height is 0, a crash will happen at runtime.
	///
	/// - Note: The returns is an implicitely unwrapped optional for backward-compatibility purpose, and will be made an optional in a future release (as well as not crash)
	///
	public func renderToImage(opaque: Bool = false, scale: CGFloat = 0.0) -> UIImage {
		return UIImage.draw(size: self.bounds.size, opaque: opaque, scale: scale) { context in
			self.layer.render(in: context)
		}
	}

	///
	/// Apply a shadow with the parameters that can be specified in the Sketch application.
	/// This methods internally updates the following properties of the backing `CALayer` (`self.layer`):
	/// - `CALayer.shadowColor`
	/// - `CALayer.shadowOpacity`
	/// - `CALayer.shadowOffset`
	/// - `CALayer.shadowRadius`
	/// - `CALayer.shadowPath`
	///
	/// When using this method, it is recommended **not** to modify any of these properties to avoid unexpected results.
	///
	/// - Parameters:
	///   - color: The color of the shadow, as specified in Sketch (usually without the alpha component, specified afterwards)
	///   - alpha: The alpha (opacity) of the shadow, as specified in Sketch
	///   - xAxis: The X direction of the shadow, as specified in Sketch
	///   - yAxis: The y direction of the shadow, as specified in Sketch
	///   - blur: The blur offset of the shadow, as specified in Sketch
	///   - spread: The spread of the shadow, as specified in Sketch.
	///   - path: The path the shadow should use. If `nil`, it defaults to a rectangle of the size of the bounds of the receiver
	///
	/// - Note: It is safe to call this method multiple times without calling `removeSketchShadow` between each calls.
	///
	public func applySketchShadow(
		color: UIColor = .black,
		alpha: Float = 0.5,
		xAxis: CGFloat = 0.0,
		yAxis: CGFloat = 2.0,
		blur: CGFloat = 4.0,
		spread: CGFloat = 0.0,
		path: CGPath? = nil)
	{
		self.layer.shadowColor = color.cgColor
		self.layer.shadowOpacity = alpha
		self.layer.shadowOffset = CGSize(width: xAxis, height: yAxis)
		self.layer.shadowRadius = blur / 2.0

		if path == nil || spread == 0.0 {
			self.layer.shadowPath = nil
		} else {
			let scaleFactor = (self.bounds.size.width + spread * 2.0) / self.bounds.size.width
			let path = (path.map { UIBezierPath(cgPath: $0) } ?? UIBezierPath(rect: self.bounds))
			path.apply(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
			self.layer.shadowPath = path.cgPath
		}
	}

	///
	/// Remove a shadow as set by `applySketchShadow`
	/// This method will reset any shadows sets on the backing layer, _even it wasn't applied by `applySketchShadow`
	///
	public func removeSketchShadow() {
		self.layer.shadowColor = nil
		self.layer.shadowOpacity = 0.0
		self.layer.shadowOffset = .zero
		self.layer.shadowRadius = 0.0
		self.layer.shadowPath = nil
	}
}

@available(iOS 9.0, *)
extension UIStackView {
	///
	/// Removes all of the current arranged subviews from the `UIStackView`, optionally
	/// allowing to remove them from the `UIStackView`'s subviews as well.
	///
	/// - Parameters:
	///   - removeFromHierachy: If `true`, each views is also removed from the receiver using `removeFromSuperview()`.
	///     If `false`, `removeFromSuperview()` is not called.
	///
	public func removeArrangedSubviews(removeFromHierachy: Bool) {
		let arrangedSubviews = self.arrangedSubviews
		arrangedSubviews.forEach { self.removeArrangedSubview($0, removeFromHierachy: removeFromHierachy) }
	}

	///
	/// Removes the given arranged subview from the `UIStackView`, optionally
	/// allowing to remove it from the `UIStackView`'s subviews as well.
	///
	/// - Parameters:
	///   - view: The arranged subview to remove from the receiver.
	///   - removeFromHierachy: If `true`, the view is also removed from the receiver using `removeFromSuperview()`.
	///     If `false`, `removeFromSuperview()` is not called.
	///
	public func removeArrangedSubview(_ view: UIView, removeFromHierachy: Bool) {
		if removeFromHierachy {
			view.removeFromSuperview()
		} else {
			// `removeArrangedSubview` doesn't call `removeFromSuperview` for the `view`
			self.removeArrangedSubview(view)
		}
	}
}

extension UITableView {
	///
	/// Deselect the given rows, optionally with an animation.
	///
	/// - Parameters:
	///   - indexPaths: The rows to deselect.
	///   - animated: `true` if you want to animate the deselection, and `false` if the change should be immediate.
	///
	public func deselectRows(_ indexPaths: [IndexPath], animated: Bool) {
		for indexPath in indexPaths {
			self.deselectRow(at: indexPath, animated: animated)
		}
	}

	///
	/// **Unavailable**: Please use `deselectAllRows(animated:)` instead.
	///
	/// Refer to the documentation for `deselectAllRows(animated:)` for more info.
	///
	@available(*, unavailable, renamed: "deselectAllRows(animated:)")
	public func deselectAllRows(_ animated: Bool) {
		self.deselectAllRows(animated: animated)
	}

	///
	/// Deselect all currently selected rows, optionally with an animation.
	///
	/// - Parameters:
	///   - animated: `true` if you want to animate the deselection, and `false` if the change should be immediate.
	///
	public func deselectAllRows(animated: Bool) {
		if let indexPaths = self.indexPathsForSelectedRows {
			self.deselectRows(indexPaths, animated: animated)
		}
	}
}

extension UICollectionView {
	///
	/// Deselect the given items, optionally with an animation.
	///
	/// - Parameters:
	///   - indexPaths: The items to deselect.
	///   - animated: `true` if you want to animate the deselection, and `false` if the change should be immediate.
	///
	public func deselectItems(_ indexPaths: [IndexPath], animated: Bool) {
		for indexPath in indexPaths {
			self.deselectItem(at: indexPath, animated: animated)
		}
	}

	///
	/// **Unavailable**: Please use `deselectAllItems(animated:)` instead.
	///
	/// Refer to the documentation for `deselectAllItems(animated:)` for more info.
	///
	@available(*, unavailable, renamed: "deselectAllItems(animated:)")
	public func deselectAllItems(_ animated: Bool) {
		self.deselectAllItems(animated: animated)
	}

	///
	/// Deselect all currently selected rows, optionally with an animation.
	///
	/// - Parameters:
	///   - animated: `true` if you want to animate the deselection, and `false` if the change should be immediate.
	///
	public func deselectAllItems(animated: Bool) {
		if let indexPaths = self.indexPathsForSelectedItems {
			self.deselectItems(indexPaths, animated: animated)
		}
	}
}

extension UIImage {
	///
	/// Create a `CGContext` allowing to do custom drawing, and returns the resulting image as drawn in the context.
	/// - Parameters:
	///   - size: Please refer to the parameters documentation for `UIGraphicsBeginImageContextWithOptions` for more info.
	///   - opaque: Please refer to the parameters documentation for `UIGraphicsBeginImageContextWithOptions` for more info.
	///   - scale: Please refer to the parameters documentation for `UIGraphicsBeginImageContextWithOptions` for more info.
	///   - graphics: The drawing actions to execute.
	///
	public static func draw(size: CGSize, opaque: Bool = false, scale: CGFloat = 0.0, graphics: (CGContext) -> Void) -> UIImage {
		var image: UIImage!
		autoreleasepool {
			UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
			graphics(UIGraphicsGetCurrentContext()!)
			image = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
		}
		return image
	}

	///
	/// **Unavailable**: Please use `withAlpha(_:)` instead.
	///
	/// Refer to the documentation for `withAlpha(_:)` for more info.
	///
	@available(*, unavailable, renamed: "withAlpha(_:)")
	public func imageWithAlpha(_ alpha: CGFloat) -> UIImage {
		return self.withAlpha(alpha)
	}

	///
	/// Returns the receiver with the given alpha applied to it. The rendering mode is kept the same.
	/// The resulting image will be made resizable whether it was originally or not,
	/// with `capInsets` set as the cap insets, and `resizingMode` as its resizing mode.
	///
	/// - Parameters:
	///   - alpha: The alpha to apply to the receiver.
	///
	public func withAlpha(_ alpha: CGFloat) -> UIImage {
		let rect = CGRect(origin: .zero, size: self.size)
		let image = UIImage.draw(size: self.size, opaque: false, scale: self.scale) { _ in
			self.draw(in: rect, blendMode: .normal, alpha: alpha)
		}
		return image.resizableImage(withCapInsets: self.capInsets, resizingMode: self.resizingMode).withRenderingMode(self.renderingMode)
	}

	///
	/// **Unavailable**: Please use `withTint(_:)` instead.
	///
	/// Refer to the documentation for `withTint(_:)` for more info.
	///
	@available(*, unavailable, renamed: "withTint(_:)")
	public func imageTintedWithColor(_ color: UIColor) -> UIImage {
		return self.withTint(color)
	}

	///
	/// Apply the given tint to the image. The rendering mode is kept the same.
	/// This method takes the rgb values of each pixels in the image, and replace them with the color
	/// given as parameter. The alpha value of each pixels is kept the same.
	/// The resulting image will be made resizable whether it was originally or not,
	/// with `capInsets` set as the cap insets, and `resizingMode` as its resizing mode.
	///
	/// The behavior of this method is similar to using the `UIImage` with a `.alwaysTemplate` rendering mode
	/// and using a `tintColor` when displaying the `UIImage` in an `UIImageView`.
	///
	/// - SeeAlso: `withColor(_:)`
	///
	/// - Parameters:
	///   - tint: The tint to apply to the receiver.
	///
	public func withTint(_ tint: UIColor) -> UIImage {
		let image = UIImage.draw(size: self.size, scale: self.scale) { _ in
			tint.setFill()
			UIRectFill(CGRect(origin: .zero, size: self.size))
			self.draw(at: .zero, blendMode: .destinationIn, alpha: 1)
		}
		return image.resizableImage(withCapInsets: self.capInsets, resizingMode: self.resizingMode).withRenderingMode(self.renderingMode)
	}

	///
	/// Apply the given color to the image. The rendering mode is kept the same.
	/// This method keeps the brightness of all pixels the same, but updates the saturation and hue
	/// to that of the given color.
	///
	/// In other words, this methods can be used to color grayscale images or tint images without loosing
	/// contrast information.
	///
	/// - SeeAlso: `withTint(_:)`
	///
	/// - Parameters:
	///   - color: The color to apply to the receiver.
	///
	public func withColor(_ color: UIColor) -> UIImage {
		return UIImage.draw(
			size: self.size,
			graphics: { context in
				let rect = CGRect(origin: .zero, size: self.size)
				self.draw(in: rect, blendMode: .color, alpha: 1.0)
				context.setFillColor(color.cgColor)
				context.setBlendMode(.color)
				context.fill(rect)
			}
		).withRenderingMode(self.renderingMode)
	}

	///
	/// Apply the given tint to the image. The rendering mode is kept the same.
	///
	/// - Parameters:
	///   - offset: The offset to apply to the original image in the resulting image.
	///   - contextSize: The size of the context used to resize the image. If not specified, it defaults to `CGSize(width: offset.x + size.width, height: offset.y + size.height)`
	///   - size: The size to resize the image to.
	///
	public func resized(offset: CGPoint = .zero, contextSize: CGSize? = nil, size: CGSize) -> UIImage? {
		let contextSize = contextSize ?? CGSize(width: offset.x + size.width, height: offset.y + size.height)
		return UIImage.draw(size: contextSize) { _ in
			self.draw(in: CGRect(origin: offset, size: size))
		}.withRenderingMode(self.renderingMode)
	}

	///
	/// **Unavailable**: Please use `ofColor(_:)` instead.
	///
	/// Refer to the documentation for `ofColor(_:)` for more info.
	///
	@available(*, unavailable, renamed: "ofColor(_:)")
	public static func imageWithColor(_ color: UIColor) -> UIImage {
		return self.ofColor(color)
	}

	///
	/// Create a 1px image with the given color.
	///
	/// - Parameters:
	///   - color: The of the image to create
	///
	public static func ofColor(_ color: UIColor) -> UIImage {
		let size = CGSize(width: 1, height: 1)

		let image = UIImage.draw(size: size, scale: 1) { _ in
			color.setFill()
			UIRectFill(CGRect(origin: .zero, size: size))
		}
		return image
	}

	///
	/// **Unavailable**: Please use `roundedRectStretchableImage(borderColor:, fillColor:, borderWidth:, cornerRadius:, scale:)` instead.
	/// Create an stretchable rectangle with rounded corners image, with the given parameters.
	///
	/// - Parameters:
	///   - borderColor: The border color to use for the rectangle.
	///   - backgroundColor: The color to use to fill the rectangle.
	///   - lineWidth: The width of the border.
	///   - radius: The radius of the corners of the rectangle. `0` means the rectangle will not have rounded corners.
	///   - scale: Please refer to the parameters documentation for `UIGraphicsBeginImageContextWithOptions` for more info.
	/// - Returns: The generated stretchable rectangle with rounded corners, with the given parameters.
	///
	@available(*, unavailable, renamed: "roundedRectStretchableImage(borderColor:borderWidth:fillColor:cornerRadius:scale:)")
	public static func roundedRectStretchableImage(
		borderColor: UIColor,
		backgroundColor: UIColor = .clear,
		lineWidth: CGFloat,
		radius: CGFloat,
		scale: CGFloat = 0.0)
		-> UIImage
	{
		return self.roundedRectStretchableImage(borderColor: borderColor, borderWidth: lineWidth, fillColor: backgroundColor, cornerRadius: radius, scale: scale)
	}

	///
	/// Create an stretchable rectangle with rounded corners image, with the given parameters.
	///
	/// - Parameters:
	///   - borderColor: The border color to use for the rectangle.
	///   - borderWidth: The width of the border.
	///   - fillColor: The color to use to fill the rectangle.
	///   - cornerRadius: The radius of the corners of the rectangle. `0` means the rectangle will not have rounded corners.
	///   - scale: Please refer to the parameters documentation for `UIGraphicsBeginImageContextWithOptions` for more info.
	/// - Returns: The generated stretchable rectangle with rounded corners, with the given parameters.
	///
	public static func roundedRectStretchableImage(
		borderColor: UIColor,
		borderWidth: CGFloat,
		fillColor: UIColor = .clear,
		cornerRadius: CGFloat,
		scale: CGFloat = 0.0)
		-> UIImage
	{
		let stretchableAreaSize: CGFloat = 1
		let canvasSize = CGSize(width: cornerRadius * 2 + stretchableAreaSize, height: cornerRadius * 2 + stretchableAreaSize)
		let roundedRectSize = CGSize(width: canvasSize.width - borderWidth, height: canvasSize.height - borderWidth)

		let image = UIImage.draw(size: canvasSize, scale: scale) { _ in
			fillColor.setFill()
			borderColor.setStroke()

			let bezierPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: borderWidth / 2, y: borderWidth / 2), size: roundedRectSize), cornerRadius: cornerRadius)
			bezierPath.lineWidth = borderWidth
			bezierPath.fill()
			bezierPath.stroke()
		}

		let capInset = cornerRadius + borderWidth / 2
		return image.resizableImage(withCapInsets: .init(top: capInset, left: capInset, bottom: capInset, right: capInset), resizingMode: .stretch)
	}
}
