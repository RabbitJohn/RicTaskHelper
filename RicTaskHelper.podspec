#
# Be sure to run `pod lib lint RicTaskHelper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'RicTaskHelper'
  s.version          = '0.1.2'
  s.summary          = 'a TaskHelper for uploading or downloading operation using NSOperationQueue.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
a TaskHelper for uploading or downloading operation of easy using NSOperationQueue. 
                       DESC

  s.homepage         = 'https://github.com/zLihuan/RicTaskHelper'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zLihuan' => '625482408@qq.com' }
  s.source           = { :git => 'https://github.com/zLihuan/RicTaskHelper.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'RicTaskHelper/Classes/**/*'
  
  # s.resource_bundles = {
  #   'RicTaskHelper' => ['RicTaskHelper/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
