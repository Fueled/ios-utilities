import Foundation
import ReactiveCocoa
import Result

public final class Terminal<Value> {

	public let disposable: CompositeDisposable
	public let setter: (Value -> Void)

	public init(disposable: CompositeDisposable, setter: Value -> Void) {
		self.disposable = disposable
		self.setter = setter
	}

	public convenience init<Object: NSObject>(_ object: Object, setter: (Object, Value) -> Void) {
		let disposable = CompositeDisposable()
		object.rac_deallocDisposable.addDisposable(RACDisposable {
			disposable.dispose()
			})
		self.init(disposable: disposable) {
			[weak object] value in
			if let object = object {
				setter(object, value)
			}
		}
	}

}

public func <~ <Value> (terminal: Terminal<Value>?, producer: Signal<Value, NoError>) -> Disposable? {
	guard let terminal = terminal else { return nil }
	let disposable = producer.observeNext(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

public func <~ <Value> (terminal: Terminal<Value>?, producer: SignalProducer<Value, NoError>) -> Disposable? {
	guard let terminal = terminal else { return nil }
	let disposable = producer.startWithNext(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

public func <~ <P: PropertyType> (terminal: Terminal<P.Value>?, property: P) -> Disposable? {
	guard let terminal = terminal else { return nil }
	return terminal <~ property.producer
}

public func <~ <Value> (terminal: Terminal<Value?>?, producer: Signal<Value, NoError>) -> Disposable? {
	guard let terminal = terminal else { return nil }
	let disposable = producer.observeNext(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

public func <~ <Value> (terminal: Terminal<Value?>?, producer: SignalProducer<Value, NoError>) -> Disposable? {
	guard let terminal = terminal else { return nil }
	let disposable = producer.startWithNext(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

public func <~ <P: PropertyType> (terminal: Terminal<P.Value?>?, property: P) -> Disposable? {
	guard let terminal = terminal else { return nil }
	return terminal <~ property.producer
}

public extension UIView {
	public var racHidden: Terminal<Bool> {
		return Terminal(self) { $0.hidden = $1 }
	}

	public var racAlpha: Terminal<CGFloat> {
		return Terminal(self) { $0.alpha = $1 }
	}

	public var racBackgroundColor: Terminal<UIColor> {
		return Terminal(self) { $0.backgroundColor = $1 }
	}

	var racUserInteractionEnabled: Terminal<Bool> {
		return Terminal(self) { $0.userInteractionEnabled = $1 }
	}
}

public extension UILabel {
	public var racText: Terminal<String?> {
		return Terminal(self) { $0.text = $1 }
	}

	public var racTextColor: Terminal<UIColor> {
		return Terminal(self) { $0.textColor = $1 }
	}
}

public extension UIImageView {
	public var racImage: Terminal<UIImage?> {
		return Terminal(self) { $0.image = $1 }
	}
}

public extension UIControl {
	public var racSelected: Terminal<Bool> {
		return Terminal(self) { $0.selected = $1 }
	}
	public var racEnabled: Terminal<Bool> {
		return Terminal(self) { $0.enabled = $1 }
	}
}

public extension UIButton {
	public func racTitleForState(state: UIControlState) -> Terminal<String?> {
		return Terminal(self) { $0.setTitle($1, forState:  state) }
	}
}

public extension UIBarButtonItem {
	public var racEnabled: Terminal<Bool> {
		return Terminal(self) { $0.enabled = $1 }
	}
}

public extension UITextField {
	public var racText: Terminal<String?> {
		return Terminal(self) { $0.text = $1 }
	}
}

public extension UIActivityIndicatorView {
	public var racAnimating: Terminal<Bool> {
		return Terminal(self) { $0.animating = $1 }
	}
}

public extension NSLayoutConstraint {
	public var racActive: Terminal<Bool> {
		return Terminal(self) { $0.active = $1 }
	}
}

public extension UISegmentedControl {
	public var racSelectedSegment: Terminal<Int> {
		return Terminal(self) { $0.selectedSegmentIndex = $1 }
	}
}

public extension UINavigationItem {
	public var racTitle: Terminal<String?> {
		return Terminal(self) { $0.title = $1 }
	}
}

public extension UITableViewCell {
	public var racSelectionStyle: Terminal<UITableViewCellSelectionStyle> {
		return Terminal(self) { $0.selectionStyle = $1 }
	}
}

public extension UITabBarItem {
	public var racBadgeValue: Terminal<String?> {
		return Terminal(self) { $0.badgeValue = $1 }
	}
}

extension UIViewController {
	var racPerformSegue: Terminal<(String, AnyObject?)> {
		return Terminal(self) { $0.performSegueWithIdentifier($1.0, sender: $1.1) }
	}
}
