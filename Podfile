# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'

target 'N-ber' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for N-ber

pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Firestore'
pod 'Firebase/Storage'
pod 'Firebase/Analytics'
pod 'Firebase/Messaging'
pod 'FirebaseFirestoreSwift'

pod 'Gallery'
pod 'RealmSwift' 

pod 'ProgressHUD'
pod 'SKPhotoBrowser'

pod 'MessageKit'
pod 'InputBarAccessoryView'

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
      File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
    end
  end
end