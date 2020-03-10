# frozen_string_literal: true

Pod::Spec.new do |s|
  s.name = 'FueledUtils'
  s.version = '3.0'
  s.summary = 'A collection of utilities used at Fueled'
  s.description = 'This is a collection of classes, extensions, methods and functions used within Fueled projects that aims at decomplexifying tasks that should be easy.'
  s.swift_version = '5'

  s.homepage = 'https://github.com/Fueled/ios-utilities'
  s.license = { type: 'Apache License, Version 2.0', file: 'LICENSE' }
  s.author = { 'Vadim-Yelagin' => 'vadim.yelagin@gmail.com', 'stephanecopin' => 'stephane@fueled.com', 'leontiy' => 'leonty@fueled.com', 'bastienFalcou' => 'bastien@fueled.com', 'heymansmile' => 'ivan@fueled.com', 'thib4ult' => 'thibault@fueled.com', 'notbenoit' => 'benoit@fueled.com' }
  s.source = { git: 'https://github.com/Fueled/ios-utilities.git', tag: s.version.to_s }
  s.documentation_url = 'https://cdn.rawgit.com/Fueled/ios-utilities/master/docs/index.html'

  s.subspec 'Core' do |s|
    s.source_files = 'FueledUtils/Core/**/*.swift'
  end

  s.subspec 'iOS8' do |s|
    s.dependency 'FueledUtils/Core'

    s.ios.deployment_target = '8.0'
    s.osx.deployment_target = '10.9'
    s.watchos.deployment_target = '2.0'
    s.tvos.deployment_target = '9.0'
  end

  s.subspec 'iOS13' do |s|
    s.dependency 'FueledUtils/Core'

    s.ios.deployment_target = '13.0'
    s.osx.deployment_target = '10.15'
    s.watchos.deployment_target = '6.0'
    s.tvos.deployment_target = '13.0'
  end

  s.subspec 'ReactiveSwift' do |s|
    s.dependency 'FueledUtils/iOS8'
    s.dependency 'ReactiveSwift', '~> 6.0'
    s.dependency 'ReactiveCocoa', '~> 10.0'

    s.source_files = 'FueledUtils/ReactiveSwift/**/*.swift'
  end

  s.subspec 'UIKit' do |s|
    s.dependency 'FueledUtils/iOS8'
    s.source_files = 'FueledUtils/UIKit/**/*.swift'
  end

  s.subspec 'ReactiveSwiftUIKit' do |s|
    s.dependency 'FueledUtils/ReactiveSwift'
    s.dependency 'FueledUtils/UIKit'

    s.source_files = 'FueledUtils/ReactiveSwiftUIKit/**/*.swift'
  end

  s.subspec 'Combine' do |s|
    s.dependency 'FueledUtils/iOS13'

    s.source_files = 'FueledUtils/Combine/**/*.swift'
  end

  s.subspec 'CombineOperators' do |s|
    s.dependency 'FueledUtils/Combine'

    s.source_files = 'FueledUtils/CombineOperators/**/*.swift'
  end

  s.subspec 'SwiftUI' do |s|
    s.dependency 'FueledUtils/Core'
    s.dependency 'FueledUtils/Combine'

    s.source_files = 'FueledUtils/SwiftUI/**/*.swift'
  end

  s.osx.exclude_files = ['FueledUtils/FueledUtils.h', 'FueledUtils/ButtonWithTitleAdjustment.swift', 'FueledUtils/DecoratingTextFieldDelegate.swift', 'FueledUtils/DimmingButton.swift', 'FueledUtils/HairlineView.swift', 'FueledUtils/HairlineView.swift', 'FueledUtils/KeyboardInsetHelper.swift', 'FueledUtils/LabelWithTitleAdjustment.swift', 'FueledUtils/ReactiveCocoaExtensions.swift', 'FueledUtils/ScrollViewPage.swift', 'FueledUtils/SetRootViewController.swift', 'FueledUtils/SignalingAlert.swift', 'FueledUtils/UIExtensions.swift', 'FueledUtils/GradientView.swift']
  s.ios.exclude_files = ['FueledUtils/FueledUtils.h']
  s.watchos.exclude_files = ['FueledUtils/FueledUtils.h', 'FueledUtils/ButtonWithTitleAdjustment.swift', 'FueledUtils/DecoratingTextFieldDelegate.swift', 'FueledUtils/DimmingButton.swift', 'FueledUtils/HairlineView.swift', 'FueledUtils/HairlineView.swift', 'FueledUtils/KeyboardInsetHelper.swift', 'FueledUtils/LabelWithTitleAdjustment.swift', 'FueledUtils/ReactiveCocoaExtensions.swift', 'FueledUtils/ScrollViewPage.swift', 'FueledUtils/SetRootViewController.swift', 'FueledUtils/SignalingAlert.swift', 'FueledUtils/UIExtensions.swift', 'FueledUtils/GradientView.swift']
  s.tvos.exclude_files = ['FueledUtils/FueledUtils.h', 'FueledUtils/KeyboardInsetHelper.swift']

  s.default_subspecs = 'Core'
end
