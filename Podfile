source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!
inhibit_all_warnings!



def pods

  # UI
  pod 'Texture/Core', '~> 2.7'

  # Reactive
  pod 'ReactiveSwifty', '~> 1.0'

  # Linting
  pod 'SwiftLint', '~> 0.28'

end



target 'ReactivePixel-iOS' do
  platform :ios, '9.0'

  pods

end



post_install do |installer|
  installer.pods_project.targets.each do |target|

    target.new_shell_script_build_phase.shell_script = "mkdir -p $PODS_CONFIGURATION_BUILD_DIR/#{target.name}"

    target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '4.2'
        config.build_settings['ENABLE_TESTABILITY'] = 'YES'
        config.build_settings['CONFIGURATION_BUILD_DIR'] = '$PODS_CONFIGURATION_BUILD_DIR'
    end

  end
end
