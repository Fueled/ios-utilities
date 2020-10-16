## Master

##### New Features/Enhancements

- Add an optional `insets` parameter to `addAndFitSubview()`  
  [Stéphane Copin](https://github.com/stephanecopin)
  [#53](https://github.com/Fueled/ios-utilities/pull/53)

- Make `removeArrangedSubviews()`'s `removeFromHierachy` parameter default to `true`  
  [Stéphane Copin](https://github.com/stephanecopin)
  [#53](https://github.com/Fueled/ios-utilities/pull/53)

- Add `tapped` helper to link any `ReactiveActionProtocol` to any `UIControl`  
  [Stéphane Copin](https://github.com/stephanecopin)
  [#53](https://github.com/Fueled/ios-utilities/pull/53)

- Add `AnyIdentifiable` & `AnyAction` for type-erased `Identifiable` & `ReactiveActionProtocol` respectively  
  [Stéphane Copin](https://github.com/stephanecopin)
  [#53](https://github.com/Fueled/ios-utilities/pull/53)

- Add `OverridingAction`, a new `Action` that if executed when already executing, will cancel the previous producer and start a new one  
  [Stéphane Copin](https://github.com/stephanecopin)
  [#53](https://github.com/Fueled/ios-utilities/pull/53)

- Make `OrderedSet` conform to `SetAlgebra`  
  [Stéphane Copin](https://github.com/stephanecopin)
  [#53](https://github.com/Fueled/ios-utilities/pull/53)

##### Bug Fixes

- Fix an internal state corruption issue in `OrderedSet`
  [Stéphane Copin](https://github.com/stephanecopin)
  [#53](https://github.com/Fueled/ios-utilities/pull/53)
