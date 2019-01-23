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

public extension UIScrollView {

	public var lsd_currentPage: Int {
		let bw = self.bounds.size.width
		let cx = self.contentOffset.x
		let page = Int((cx / bw).rounded())
		return min(max(0, page), self.lsd_numberOfPages - 1)
	}

	public var lsd_numberOfPages: Int {
		let bw = self.bounds.size.width
		let cw = self.contentSize.width
		return Int((cw / bw).rounded(.up))
	}

	public func lsd_setCurrentPage(_ page: Int, animated: Bool) {
		let bw = self.bounds.size.width
		let offset = CGPoint(x: bw * CGFloat(page), y: 0)
		self.setContentOffset(offset, animated: animated)
	}

}
