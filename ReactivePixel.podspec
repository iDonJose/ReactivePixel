#  Validate Podspec by running 'pod spec lint <Framework>.podspec'
#  Podspec attributes : http://docs.cocoapods.org/specification.html
#  Podspecs examples : https://github.com/CocoaPods/Specs/

Pod::Spec.new do |s|

    s.name         = "ReactivePixel"
    s.version      = "1.0.0"
    s.summary      = "Reactive extensions of UIKit and Texture (AsyncDisplayKit)"
    s.description  = <<-DESC
                        `ReactivePixel` extends UIKit and Texture (ASyncDisplayKit) with signals of UI events.
                        DESC
    s.homepage     = "https://github.com/iDonJose/ReactivePixel"
    s.source       = { :git => "https://github.com/iDonJose/ReactivePixel.git", :tag => "#{s.version}" }

    s.license      = { :type => "Apache 2.0", :file => "LICENSE" }

    s.author       = { "iDonJose" => "donor.develop@gmail.com" }


	s.frameworks = "Foundation", "UIKit"


	s.subspec 'UIKit' do |uikit|

    	uikit.deployment_target = "8.0"

		uikit.dependency 'ReactiveSwifty', '~> 1.0'

		uikit.source_files = [
			'Sources/ReactivePixel.h',
			'Sources/Reactive UIKit/**/*.{swift}'
		]

	end

	s.subspec 'Texture' do |texture|

    	texture.deployment_target = "9.0"

		texture.dependency 'ReactivePixel/UIKit'

		texture.dependency 'ReactiveSwifty', '~> 1.0'
		texture.dependency 'Texture/Core', '~> 2.7'

		texture.source_files = [
			'Sources/ReactivePixel.h',
			'Sources/Reactive Texture/**/*.{swift}'
		]

	end

	s.default_subspecs = 'Texture'

end
