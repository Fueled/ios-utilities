import FueledUtils
import PlaygroundSupport
import UIKit

let gradientView = GradientView(frame: CGRect(origin: .zero, size: CGSize(width: 500.0, height: 500.0)))

gradientView.type = .radial(startCenter: CGPoint(x: 0.5, y: 0.5), startRadius: 10.0, endCenter: CGPoint(x: 0.5, y: 0.5), endRadius: 50.0)
gradientView.definition = .custom([(.black, 0.0), (.red, 0.5), (.blue, 1.0)])

let test: [Int] = [2, 3]
let result = test.splitBetween { $0 == 2 && $1 == 3 }
result
