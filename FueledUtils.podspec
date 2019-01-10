Pod::Spec.new do |s|
	s.name             = 'FueledUtils'
	s.version          = '1.4'
	s.summary          = 'A collection of utilities used at Fueled'

	s.description      = <<-DESC
			This is a collection of classes, extensions, methods and functions used within Fueled projects that aims at decomplexifying tasks that should be easy.
	                   DESC

	s.homepage         = 'https://github.com/Fueled/ios-utilities'
	s.license          = { :type => 'MIT', :file => 'LICENSE' }
	s.author           = { 'vadim-fueled' => 'vadim@fueled.com', 'stephane-fueled' => 'stephane@fueled.com', 'leonty-fueled' => 'leonty@fueled.com', 'bastien-fueled' => 'bastien@fueled.com', 'ivan-fueled' => 'ivan@fueled.com', 'thib4ult' => 'thibault@fueled.com', 'benoit-fueled' => 'benoit@fueled.com' }
	s.source           = { :git => 'https://github.com/Fueled/ios-utilities.git', :tag => s.version.to_s }

	s.ios.deployment_target = '8.0'

	s.exclude_files = 'FueledUtils/FueledUtils.h'

	s.source_files = "FueledUtils/*.swift"

	s.dependency "ReactiveCocoa", "~> 8.0"
end
