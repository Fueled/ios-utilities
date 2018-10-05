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
		guard let match = regex.firstMatch(in: hexString, options: [], range: hexString.fullRange) , match.numberOfRanges == 4 else {
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

	public func setText(_ string: String?, animated: Bool) {
		if !animated {
			self.text = string
			return
		}
		UIView.transition(with: self, duration: 0.35, options: .transitionCrossDissolve, animations: {
			self.text = string
		}, completion: nil)
	}

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
	public var fueled_animating: Bool {
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
	public func addAndFitSubview(_ view: UIView) {
		view.translatesAutoresizingMaskIntoConstraints = false
		view.frame = self.bounds
		self.addSubview(view)
		let views = ["view": view]
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: views))
		self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: views))
	}

	public func snapshotImage(afterScreenUpdates: Bool = true) -> UIImage? {
		return UIImage.draw(size: self.bounds.size) { _ in
			self.drawHierarchy(in: self.bounds, afterScreenUpdates: afterScreenUpdates)
		}
	}
}

public extension UITableView {
	public func deselectAllRows(_ animated: Bool) {
		if let indexPaths = self.indexPathsForSelectedRows {
			for indexPath in indexPaths {
				self.deselectRow(at: indexPath, animated: animated)
			}
		}
	}
}

public extension UICollectionView {
	public func deselectAllItems(_ animated: Bool) {
		if let indexPaths = self.indexPathsForSelectedItems {
			for indexPath in indexPaths {
				self.deselectItem(at: indexPath, animated: animated)
			}
		}
	}
}

public extension UIImage {
	public static func draw(size: CGSize, opaque: Bool = false, scale: CGFloat = 0, graphics: (CGContext) -> Void) -> UIImage {
		var image: UIImage?
		autoreleasepool {
			UIGraphicsBeginImageContextWithOptions(size, opaque, scale)
			graphics(UIGraphicsGetCurrentContext()!)
			image = UIGraphicsGetImageFromCurrentImageContext()
			UIGraphicsEndImageContext()
		}
		return image!
	}

	public func imageWithAlpha(_ alpha: CGFloat) -> UIImage {
		let rect = CGRect(origin: .zero, size: self.size)
		let image = UIImage.draw(size: self.size, opaque: false, scale: self.scale) { _ in
			self.draw(in: rect, blendMode: .normal, alpha: alpha)
		}
		return image.resizableImage(withCapInsets: self.capInsets, resizingMode: self.resizingMode).withRenderingMode(self.renderingMode)
	}

	public func imageTintedWithColor(_ color: UIColor) -> UIImage {
		let image = UIImage.draw(size: self.size, scale: self.scale) { _ in
			color.setFill()
			UIRectFill(CGRect(origin: .zero, size: self.size))
			self.draw(at: .zero, blendMode: .destinationIn, alpha: 1)
		}
		return image.resizableImage(withCapInsets: self.capInsets, resizingMode: self.resizingMode).withRenderingMode(self.renderingMode)
	}

	public func resized(offset: CGPoint = .zero, size: CGSize) -> UIImage? {
		return UIImage.draw(size: size) { _ in
			self.draw(in: CGRect(origin: offset, size: size))
		}
	}

	public static func imageWithColor(_ color: UIColor) -> UIImage {
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
