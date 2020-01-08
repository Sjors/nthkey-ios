# Uncomment the next line to define a global platform for your project
platform :ios, '13.2'

target 'NthKey' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'LibWally', :git => 'https://github.com/blockchain/LibWally-Swift.git', :submodules => true
  pod 'OutputDescriptors', :git => 'https://github.com/sjors/output-descriptors-swift.git', :tag => "v0.0.1"

  target 'NthKeyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'NthKeyUITests' do
    # Pods for testing
  end

end
