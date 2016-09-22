import Foundation
import ReactiveSwift
import Result

public final class Terminal<Value> {

	public let disposable: CompositeDisposable
	public let setter: ((Value) -> Void)

	public init(disposable: CompositeDisposable, setter: @escaping (Value) -> Void) {
		self.disposable = disposable
		self.setter = setter
	}

	public convenience init<Object: NSObject>(_ object: Object, setter: @escaping (Object, Value) -> Void) {
		let disposable = CompositeDisposable()
		object.rac_lifetime.ended.observeCompleted {
			disposable.dispose()
		}
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
	let disposable = producer.observeValues(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

public func <~ <Value> (terminal: Terminal<Value>?, producer: SignalProducer<Value, NoError>) -> Disposable? {
	guard let terminal = terminal else { return nil }
	let disposable = producer.startWithValues(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

public func <~ <P: PropertyProtocol> (terminal: Terminal<P.Value>?, property: P) -> Disposable? {
	guard let terminal = terminal else { return nil }
	return terminal <~ property.producer
}

public func <~ <Value> (terminal: Terminal<Value?>?, producer: Signal<Value, NoError>) -> Disposable? {
	guard let terminal = terminal else { return nil }
	let disposable = producer.observeValues(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

public func <~ <Value> (terminal: Terminal<Value?>?, producer: SignalProducer<Value, NoError>) -> Disposable? {
	guard let terminal = terminal else { return nil }
	let disposable = producer.startWithValues(terminal.setter)
	terminal.disposable += disposable
	return disposable
}

public func <~ <P: PropertyProtocol> (terminal: Terminal<P.Value?>?, property: P) -> Disposable? {
	guard let terminal = terminal else { return nil }
	return terminal <~ property.producer
}

public extension UIView {
	public var racHidden: Terminal<Bool> {
		return Terminal(self) { $0.isHidden = $1 }
	}

	public var racAlpha: Terminal<CGFloat> {
		return Terminal(self) { $0.alpha = $1 }
	}

	public var racBackgroundColor: Terminal<UIColor> {
		return Terminal(self) { $0.backgroundColor = $1 }
	}

	var racUserInteractionEnabled: Terminal<Bool> {
		return Terminal(self) { $0.isUserInteractionEnabled = $1 }
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
		return Terminal(self) { $0.isSelected = $1 }
	}
	public var racEnabled: Terminal<Bool> {
		return Terminal(self) { $0.isEnabled = $1 }
	}
}

public extension UIButton {
	public func racTitleForState(_ state: UIControlState) -> Terminal<String?> {
		return Terminal(self) { $0.setTitle($1, for:  state) }
	}
}

public extension UIBarButtonItem {
	public var racEnabled: Terminal<Bool> {
		return Terminal(self) { $0.isEnabled = $1 }
	}
}

public extension UITextField {
	public var racText: Terminal<String?> {
		return Terminal(self) { $0.text = $1 }
	}
}

public extension UIActivityIndicatorView {
	public var racAnimating: Terminal<Bool> {
		return Terminal(self) { $0.fueled_animating = $1 }
	}
}

public extension NSLayoutConstraint {
	public var racActive: Terminal<Bool> {
		return Terminal(self) { $0.isActive = $1 }
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
		return Terminal(self) { $0.performSegue(withIdentifier: $1.0, sender: $1.1) }
	}
}
