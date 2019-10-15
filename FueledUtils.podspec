Pod::Spec.new do |s|
	s.name = 'FueledUtils'
	s.version = '2.0.2'
	s.summary = 'A collection of utilities used at Fueled'
	s.description = 'This is a collection of classes, extensions, methods and functions used within Fueled projects that aims at decomplexifying tasks that should be easy.'
	s.swift_version = '5'

	s.homepage = 'https://github.com/Fueled/ios-utilities'
	s.license = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
	s.author = { 'Vadim-Yelagin' => 'vadim.yelagin@gmail.com', 'stephanecopin' => 'stephane@fueled.com', 'leontiy' => 'leonty@fueled.com', 'bastienFalcou' => 'bastien@fueled.com', 'heymansmile' => 'ivan@fueled.com', 'thib4ult' => 'thibault@fueled.com', 'notbenoit' => 'benoit@fueled.com' }
	s.source = { :git => 'https://github.com/Fueled/ios-utilities.git', :tag => s.version.to_s }
	s.documentation_url = 'https://cdn.rawgit.com/Fueled/ios-utilities/master/docs/index.html'

	s.ios.deployment_target = '8.0'
	s.osx.deployment_target = '10.9'
	s.watchos.deployment_target = '2.0'
	s.tvos.deployment_target = '9.0'

	s.source_files = 'FueledUtils/**/*.swift'
	s.osx.exclude_files = ['FueledUtils/FueledUtils.h', 'FueledUtils/ButtonWithTitleAdjustment.swift', 'FueledUtils/DecoratingTextFieldDelegate.swift', 'FueledUtils/DimmingButton.swift', 'FueledUtils/HairlineView.swift', 'FueledUtils/HairlineView.swift', 'FueledUtils/KeyboardInsetHelper.swift', 'FueledUtils/LabelWithTitleAdjustment.swift', 'FueledUtils/ReactiveCocoaExtensions.swift', 'FueledUtils/ScrollViewPage.swift', 'FueledUtils/SetRootViewController.swift', 'FueledUtils/SignalingAlert.swift', 'FueledUtils/UIExtensions.swift', 'FueledUtils/GradientView.swift']
	s.ios.exclude_files = ['FueledUtils/FueledUtils.h']
	s.watchos.exclude_files = ['FueledUtils/FueledUtils.h', 'FueledUtils/ButtonWithTitleAdjustment.swift', 'FueledUtils/DecoratingTextFieldDelegate.swift', 'FueledUtils/DimmingButton.swift', 'FueledUtils/HairlineView.swift', 'FueledUtils/HairlineView.swift', 'FueledUtils/KeyboardInsetHelper.swift', 'FueledUtils/LabelWithTitleAdjustment.swift', 'FueledUtils/ReactiveCocoaExtensions.swift', 'FueledUtils/ScrollViewPage.swift', 'FueledUtils/SetRootViewController.swift', 'FueledUtils/SignalingAlert.swift', 'FueledUtils/UIExtensions.swift', 'FueledUtils/GradientView.swift']
	s.tvos.exclude_files = ['FueledUtils/FueledUtils.h', 'FueledUtils/KeyboardInsetHelper.swift']

	s.dependency 'ReactiveSwift', '~> 6.0'
	s.dependency 'ReactiveCocoa', '~> 10.0'
end
