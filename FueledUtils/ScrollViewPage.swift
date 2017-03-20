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
