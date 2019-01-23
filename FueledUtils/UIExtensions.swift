/*
Copyright © 2019 Fueled Digital Media, LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
import Foundation
import UIKit

public extension UIColor {
	public convenience init(hex: UInt32, alpha: CGFloat = 1) {
		func byteColor(_ x: UInt32) -> CGFloat {
			return CGFloat(x & 0xFF) / 255
		}
		let red = byteColor(hex >> 16)
		let green = byteColor(hex >> 8)
		let blue = byteColor(hex)
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}

	public convenience init?(hexString: String, alpha: CGFloat = 1) {
		let regex = try! NSRegularExpression(pattern: "\\A#?([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])([0-9a-f][0-9a-f])\\Z", options: [.caseInsensitive])
		guard let match = regex.firstMatch(in: hexString, options: [], range: hexString.nsRange) , match.numberOfRanges == 4 else {
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

public extension UILabel {
	///
	/// Add the monospaced number font descriptor to the current `font`.
	///
	public func useMonospacedNumbers() {
		let fontDescriptor = self.font.fontDescriptor
		let newFontDescriptor = fontDescriptor.addingAttributes([
			UIFontDescriptor.AttributeName.featureSettings: [[
				UIFontDescriptor.FeatureKey.featureIdentifier: kNumberSpacingType,
				UIFontDescriptor.FeatureKey.typeIdentifier: kMonospacedNumbersSelector
			]]
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

public extension UIActivityIndicatorView {
	@available(*, deprecated, renamed: "animating")
	public var fueled_animating: Bool {
		get {
			return self.animating
		}
		set {
			self.animating = newValue
		}
	}

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

public extension UITextField {
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
					NSAttributedString.Key.foregroundColor: color
				])
			}
		}
	}
}

public extension UIView {
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
}

public extension UITableView {
	///
	/// Deselect given rows, optionally with an animation.
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
	/// **Deprecated**: Please use `deselectAllRows(animated:)` instead.
	///
	/// Refer to the documentation for `deselectAllRows(animated:)` for more info.
	///
	@available(*, deprecated, renamed: "deselectAllRows(animated:)")
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

public extension UICollectionView {
	///
	/// Deselect given items, optionally with an animation.
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
	/// **Deprecated**: Please use `deselectAllItems(animated:)` instead.
	///
	/// Refer to the documentation for `deselectAllItems(animated:)` for more info.
	///
	@available(*, deprecated, renamed: "deselectAllItems(animated:)")
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

public extension UIImage {
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
	/// **Deprecated**: Please use `withAlpha(_:)` instead.
	///
	/// Refer to the documentation for `withAlpha(_:)` for more info.
	///
	@available(*, deprecated, renamed: "withAlpha(_:)")
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
	/// **Deprecated**: Please use `withTint(_:)` instead.
	///
	/// Refer to the documentation for `withTint(_:)` for more info.
	///
	@available(*, deprecated, renamed: "withTint(_:)")
	public func imageTintedWithColor(_ color: UIColor) -> UIImage {
		return self.withTint(color)
	}

	///
	/// Apply the given tint to the image. The rendering mode is kept the same.
	/// The resulting image will be made resizable whether it was originally or not,
	/// with `capInsets` set as the cap insets, and `resizingMode` as its resizing mode.
	///
	/// - Parameters:
	///   - color: The color to apply to the receiver.
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
	/// **Deprecated**: Please use `ofColor(_:)` instead.
	///
	/// Refer to the documentation for `ofColor(_:)` for more info.
	///
	@available(*, deprecated, renamed: "ofColor(_:)")
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

	public static func roundedRectStretchableImage(
		borderColor: UIColor,
		backgroundColor: UIColor = .clear,
		lineWidth: CGFloat,
		radius: CGFloat,
		scale: CGFloat = UIScreen.main.scale)
		-> UIImage
	{
		let stretchableAreaSize: CGFloat = 1
		let canvasSize = CGSize(width: radius * 2 + stretchableAreaSize, height: radius * 2 + stretchableAreaSize)
		let roundedRectSize = CGSize(width: canvasSize.width - lineWidth, height: canvasSize.height - lineWidth)

		let image = UIImage.draw(size: canvasSize, scale: scale) { _ in
			backgroundColor.setFill()
			borderColor.setStroke()

			let bezierPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: lineWidth / 2, y: lineWidth / 2), size: roundedRectSize), cornerRadius: radius)
			bezierPath.lineWidth = lineWidth
			bezierPath.fill()
			bezierPath.stroke()
		}

		let capInset = radius + 0.5 * lineWidth
		return image.resizableImage(withCapInsets: .init(top: capInset, left: capInset, bottom: capInset, right: capInset), resizingMode: .stretch)
	}
}
