# Uncomment the next line to define a global platform for your project
platform :ios, '13.2'

target 'Multisig' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Multisig
  pod 'LibWally', :git => 'https://github.com/sjors/LibWally-Swift.git', :branch => 'dev', :submodules => true
  pod 'OutputDescriptors', :git => 'https://github.com/sjors/output-descriptors-swift.git', :tag => "v0.0.1"

  target 'MultisigTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MultisigUITests' do
    # Pods for testing
  end

end
