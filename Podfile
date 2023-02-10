# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'NthKey' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'LibWally', :git => 'https://github.com/sjors/LibWally-Swift.git', :tag => "v0.0.9", :submodules => true
  pod 'OutputDescriptors', :git => 'https://github.com/sjors/output-descriptors-swift.git', :tag => "v0.0.2"

  target 'NthKeyTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'NthKeyUITests' do
    # Pods for testing
  end

end
