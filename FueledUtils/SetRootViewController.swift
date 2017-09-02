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
