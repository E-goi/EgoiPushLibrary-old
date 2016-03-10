#
# Be sure to run `pod lib lint EgoiPushLibrary.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "EgoiPushLibrary"
  s.version          = "1.0.1"
  s.summary          = "Allows to use the Push Notification Channel of the E-Goi company."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
This library should be included in your project. After configure that with the information provided from your E-Goi account, you are able to use that to receive the Push Notification messages.
                       DESC

  s.homepage         = "https://github.com/migchaves/EgoiPushLibrary"
  s.license          = 'MIT'
  s.author           = { "Miguel Chaves" => "mchaves.apps@gmail.com" }
  s.source           = { :git => "https://github.com/migchaves/EgoiPushLibrary.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'EgoiPushLibrary' => ['Pod/Assets/*.png']
  }
end
