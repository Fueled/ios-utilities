## Main

##### New Features/Enhancements

- Add `ActionProtocol`
- Add `AnyAction`, allowing to type-erase any actions represented by a `ActionProtocol`
- Add `CoalescingAction` & `OverridingAction`
- Add a `CombineExtensions` & `CombineExtensionsProvider` protocol, replicating the `.reactive` of ReactiveSwift (so as not to pollute too much the global namespace)
- All `NSObject` now can have a `cancellables` object attached to them via `<object>.combineExtensions.cancellables`. It's created lazily, so there's impact if not used.
- Extend `Publisher.handleEvents` to add two new hooks:
	- `receiveTermination`: When either a completion or a cancellation is received
	- `receiveResult`: Takes a `Result`, and called when either values are received or an error is received
- Add `Publisher.promoteOptional()`
- Add `then(receiveResult:)`, which takes a closure with a `Result`, allowing to handle values & error in the same place
- Add `sinkForLifetimeOf(_:)` methods family, allowing to sink on a publisher and link to the lifetime of a given `CombineExtensionsProvider & AnyObject`. The goal of this is to avoid having to write the classic boilerplate code in Combine handling with having to create `cancellables` for every single object (this used the `cancellables` extension mentioned above).
- Add `performDuringLifetimeOf(_:action:)`, allowing to link an action with the lifetime of an object. This act as an equivalent for `makeBindingTarget` from `ReactiveSwift` when calling functions or assigning multiple variables.
- Add `assign(to:forLifetimeOf:)`, allowing to assign the output of the producer to a keyPath, keeping it alive until the specified object is deallocated.
- Add `TapAction` and `<UIControl>.combineExtensions.tapped`, allowing to link an `Action` to a button, without having to do the bindings manually (similar to `UIButton.reactive.pressed` in ReactiveCocoa)
- Add `<UIControl>.publisherForControlEvent(_:)`, to get a publisher that triggers on any control events.
- Add `(UITextField/UITextView).(textValues|continuousTextValues)`, which are equivalent to same thing as for ReactiveCocoa.
  [Stéphane Copin](https://github.com/stephanecopin)
  [#54](https://github.com/Fueled/ios-utilities/pull/54)

- Add an optional `insets` parameter to `addAndFitSubview()`  
- Make `removeArrangedSubviews()`'s `removeFromHierachy` parameter default to `true`  
- Add `tapped` helper to link any `ReactiveActionProtocol` to any `UIControl`  
- Add `AnyIdentifiable` & `AnyAction` for type-erased `Identifiable` & `ReactiveActionProtocol` respectively  
- Add `OverridingAction`, a new `Action` that if executed when already executing, will cancel the previous producer and start a new one  
- Make `OrderedSet` conform to `SetAlgebra`  
  [Stéphane Copin](https://github.com/stephanecopin)
  [#53](https://github.com/Fueled/ios-utilities/pull/53)

##### Bug Fixes

- Fix a bug in `CombineLatestMany` where cancelling the resulting publisher would not cancel the array of publishers themselves.
  [Stéphane Copin](https://github.com/stephanecopin)
  [#55](https://github.com/Fueled/ios-utilities/pull/55)

- Fix a bug in `Action` where a cancellation would be ignored and not set `isExecuting` to `false`
  [Stéphane Copin](https://github.com/stephanecopin)
  [#54](https://github.com/Fueled/ios-utilities/pull/54)

- Fix an internal state corruption issue in `OrderedSet`
  [Stéphane Copin](https://github.com/stephanecopin)
  [#53](https://github.com/Fueled/ios-utilities/pull/53)

##### Breaking changes

- The original `TapAction`, `OverridingAction` and `AnyAction` were all prefixed with `Reactive`.
  [Stéphane Copin](https://github.com/stephanecopin)
  [#54](https://github.com/Fueled/ios-utilities/pull/54)
