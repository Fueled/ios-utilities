import Foundation
import UIKit

public extension UIApplicationDelegate {
	public func setRootViewController(viewController: UIViewController, @noescape setWindow: UIWindow -> Void) {
		if let optionalWindow = self.window, window = optionalWindow {
			UIView.transitionWithView(
				window,
				duration: 0.33,
				options: .TransitionCrossDissolve,
				animations: {
					UIView.setAnimationsEnabled(false)
					window.endEditing(true)
					window.rootViewController = viewController
					window.layoutIfNeeded()
					UIView.setAnimationsEnabled(true)
				},
				completion: nil
			)
		} else {
			let window = UIWindow(frame: UIScreen.mainScreen().bounds)
			setWindow(window)
			window.rootViewController = viewController
			window.makeKeyAndVisible()
		}
	}
}
