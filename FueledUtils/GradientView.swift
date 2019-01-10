import UIKit

public final class GradientView: UIView {
	var gradientInfo: [(color: UIColor, location: CGFloat)] = [] {
		didSet {
			self.setNeedsDisplay()
		}
	}

	@IBInspectable var isVertical: Bool = true {
		didSet {
			if self.isVertical != oldValue {
				self.setNeedsDisplay()
			}
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}

	private func commonInit() {
		self.contentMode = .redraw
		// https://stackoverflow.com/a/43898524/3605958
		// The background color must be set to a non-nil value or drawRect(_:) will not render the gradient properly
		self.backgroundColor = UIColor.clear
	}

	override public func draw(_ rect: CGRect) {
		let context = UIGraphicsGetCurrentContext()!
		let colors = self.gradientInfo.map { $0.color.cgColor }
		var locations: [CGFloat] = self.gradientInfo.map { $0.location }
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: &locations)!
		context.drawLinearGradient(
			gradient,
			start: .zero,
			end: CGPoint(
				x: self.isVertical ? 0.0 : self.bounds.size.width,
				y: self.isVertical ? self.bounds.size.height : 0.0
			),
			options: []
		)
	}
}

public final class SimpleGradientView: UIView {
	private lazy var gradientView: GradientView = {
		$0.gradientInfo = [
			(.white, 0.0),
			(.black, 1.0),
		]
		return $0
	}(GradientView())

	@IBInspectable
	public var startColor: UIColor {
		get {
			return UIColor(cgColor: self.gradientView.gradientInfo[0].color.cgColor)
		}
		set {
			self.gradientView.gradientInfo[0].color = newValue
		}
	}

	@IBInspectable
	public var endColor: UIColor {
		get {
			return UIColor(cgColor: self.gradientView.gradientInfo[1].color.cgColor)
		}
		set {
			self.gradientView.gradientInfo[1].color = newValue
		}
	}

	@IBInspectable var isVertical: Bool {
		get {
			return self.gradientView.isVertical
		}
		set {
			self.gradientView.isVertical = newValue
		}
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}

	private func commonInit() {
		self.addAndFitSubview(self.gradientView)
	}
}
