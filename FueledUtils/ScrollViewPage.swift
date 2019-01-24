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
import UIKit

extension UIScrollView {
	///
	/// **Deprecated**: Please use `currentPage` instead.
	///
	/// Refer to the documentation for `currentPage` for more info.
	///
	@available(*, deprecated, renamed: "currentPage")
	public var lsd_currentPage: Int {
		return self.currentPage
	}

	///
	/// **Deprecated**: Please use `numberOfPages` instead.
	///
	/// Refer to the documentation for `numberOfPages` for more info.
	///
	@available(*, deprecated, renamed: "numberOfPages")
	public var lsd_numberOfPages: Int {
		return self.numberOfPages
	}

	///
	/// **Deprecated**: Please use `setCurrentPage(_:, animated:)` instead.
	///
	/// Refer to the documentation for `setCurrentPage(_:, animated:)` for more info.
	///
	@available(*, deprecated, renamed: "setCurrentPage(_:animated:)")
	public func lsd_setCurrentPage(_ page: Int, animated: Bool) {
		self.setCurrentPage(page, animated: animated)
	}

	///
	/// Gets/Sets (without animation) the current page of the scroll view, assuming a paginated scroll view of width `self.bounds.size.width`, with no left or right content insets.
	///
	/// To set the current page with an animation, use `setCurrentPage(_ page:, animated:)`
	///
	/// - Returns: Returns the current page (0-based)
	///
	public var currentPage: Int {
		get {
			let page = Int((self.bounds.size.width / self.contentOffset.x).rounded())
			return min(max(0, page), self.numberOfPages - 1)
		}
		set {
			self.setCurrentPage(newValue, animated: false)
		}
	}

	///
	/// Gets the total number of pages of the scroll view, assuming a paginated scroll view of width `self.bounds.size.width`, with no left or right content insets.
	///
	/// - Returns: Returns the number of pages.
	///
	public var numberOfPages: Int {
		return Int((self.bounds.size.width / self.contentSize.width).rounded(.up))
	}

	///
	/// Sets the current page of the scroll view, assuming a paginated scroll view of width `self.bounds.size.width`, with no left or right content insets.
	///
	/// - Parameters:
	///   - page: The page to set to.
	///   - animated: Whether to animate the change or not.
	///
	public func setCurrentPage(_ page: Int, animated: Bool) {
		let offset = CGPoint(x: self.bounds.size.width * CGFloat(page), y: 0)
		self.setContentOffset(offset, animated: animated)
	}
}
