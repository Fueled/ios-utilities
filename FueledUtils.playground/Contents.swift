import FueledUtils
import PlaygroundSupport
import UIKit

let gradientView = GradientView(frame: CGRect(origin: .zero, size: CGSize(width: 200.0, height: 200.0)))

gradientView.type = .linear(direction: CGPoint(x: 0.0, y: 0.5))
gradientView.definition = .custom([(.black, 0.0), (.red, 0.5), (.blue, 1.0)])
