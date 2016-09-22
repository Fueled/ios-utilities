import Foundation
import UIKit

public extension UIApplicationDelegate {
	public func setRootViewController(_ viewController: UIViewController, setWindow: (UIWindow) -> Void) {
		if let optionalWindow = self.window, let window = optionalWindow {
			UIView.transition(
				with: window,
				duration: 0.33,
				options: .transitionCrossDissolve,
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
			let window = UIWindow(frame: UIScreen.main.bounds)
			setWindow(window)
			window.rootViewController = viewController
			window.makeKeyAndVisible()
		}
	}
}
