//
//  Combine+Operators.swift
//  RPMHelpers
//
//  Created by Stéphane Copin on 2/11/20.
//  Copyright © 2020 Fueled. All rights reserved.
//

import Combine

// swiftlint:disable generic_type_name

precedencegroup BindingPrecedence {
	associativity: right

	higherThan: AssignmentPrecedence
}

infix operator <~: BindingPrecedence

precedencegroup AccessPrecedence {
	associativity: right

	higherThan: BindingPrecedence
}

infix operator ~: AccessPrecedence

precedencegroup InsertCancellablePrecedence {
	associativity: left

	lowerThan: AssignmentPrecedence
}

infix operator >>>: InsertCancellablePrecedence

public struct ObjectKeyPathReference<Root, Value> {
	public let object: Root
	public let keyPath: ReferenceWritableKeyPath<Root, Value>
}

public func ~ <Object, Value>(lhs: Object, rhs: ReferenceWritableKeyPath<Object, Value>) -> ObjectKeyPathReference<Object, Value> {
	ObjectKeyPathReference(object: lhs, keyPath: rhs)
}

public func <~ <Object: AnyObject, Value, Publisher: Combine.Publisher>(
	lhs: ObjectKeyPathReference<Object, Value>,
	rhs: Publisher
) -> AnyCancellable where Publisher.Output == Value, Publisher.Failure == Never {
	rhs.assign(to: lhs.keyPath, withoutRetaining: lhs.object)
}

public func <~ <ObservingObject: ObservableObject, ObservedObject: ObservableObject>(
	lhs: ObservingObject,
	rhs: ObservedObject
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher {
	lhs.link(to: rhs)
}

public func <~ <ObservingObject: ObservableObject, ObservedObjectCollection: Collection>(
	lhs: ObservingObject,
	rhs: ObservedObjectCollection
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher, ObservedObjectCollection.Element: ObservableObject {
	lhs.link(to: rhs)
}

public func <~ <ObservingObject: ObservableObject, Publisher: Combine.Publisher>(
	lhs: ObservingObject,
	rhs: Publisher
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher, Publisher.Output: ObservableObject {
	lhs.link(to: rhs)
}

public func <~ <ObservingObject: ObservableObject, Publisher: Combine.Publisher>(
	lhs: ObservingObject,
	rhs: Publisher
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher, Publisher.Output: OptionalProtocol, Publisher.Output.Wrapped: ObservableObject {
	lhs.link(to: rhs)
}

public func <~ <ObservingObject: ObservableObject, Publisher: Combine.Publisher>(
	lhs: ObservingObject,
	rhs: Publisher
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher, Publisher.Output: Collection, Publisher.Output.Element: ObservableObject {
	lhs.link(to: rhs)
}

public func <~ <ObservingObject: ObservableObject, ObservedObject: ObservableObject>(
	lhs: ObservingObject,
	rhs: ReferenceWritableKeyPath<ObservingObject, ObservedObject>
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher {
	lhs.link(to: lhs[keyPath: rhs])
}

public func <~ <ObservingObject: ObservableObject, ObservedObjectCollection: Collection>(
	lhs: ObservingObject,
	rhs: ReferenceWritableKeyPath<ObservingObject, ObservedObjectCollection>
) where ObservingObject.ObjectWillChangePublisher == ObservableObjectPublisher, ObservedObjectCollection.Element: ObservableObject {
	lhs.link(to: lhs[keyPath: rhs])
}

public func >>> <CancellableCollection: RangeReplaceableCollection>(lhs: AnyCancellable, rhs: inout CancellableCollection) where CancellableCollection.Element == AnyCancellable {
	lhs.store(in: &rhs)
}

public func >>> (lhs: AnyCancellable, rhs: inout Set<AnyCancellable>) {
	lhs.store(in: &rhs)
}
