platform :ios, '16.0'
# Uncomment the next line to define a global platform for your project
# platform :ios, '16.0'

target 'MarketWatch' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MarketWatch
  pod 'Alamofire', '~> 5.8'
  pod 'RxSwift', '~> 6.6'
  pod 'RxCocoa', '~> 6.6'
  pod 'Kingfisher', '~> 7.10'   # opcional para ícones/logos

  target 'MarketWatchTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking'
    pod 'RxTest'
    pod 'Quick'
    pod 'Nimble'
  end

  target 'MarketWatchUITests' do
    # Pods for testing
  end

end

# Ensure pods respect minimum deployment target and Swift concurrency leniency
post_install do |installer|
  installer.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
      config.build_settings['SWIFT_STRICT_CONCURRENCY'] = 'minimal'
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
    end
  end
  
  installer.aggregate_targets.each do |agg|
      agg.user_targets.each do |ut|
        ut.build_configurations.each do |config|
          config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
        end
      end
    end
end
