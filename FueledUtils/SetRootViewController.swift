import Foundation
import UIKit

public extension UIApplicationDelegate {
	/// Switches root view controller avoiding common problems of unintended animations.
	public func setRootViewController(_ viewController: UIViewController, setWindow: (UIWindow) -> Void, completion: @escaping () -> Void = {}) {
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
				completion: { _ in
					completion()
				}
			)
		} else {
			let window = UIWindow(frame: UIScreen.main.bounds)
			setWindow(window)
			window.rootViewController = viewController
			window.makeKeyAndVisible()
			completion()
		}
	}
}
