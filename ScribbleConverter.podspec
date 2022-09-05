#
# Be sure to run `pod lib lint ScribbleConverter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ScribbleConverter'
  s.version          = '0.4.2'
  s.license = 'MIT'
  s.summary          = 'A tool to convert Apple PencilKit data to Scribble Proto3.'
  s.homepage         = 'https://github.com/gonft/ScribbleConverter'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Paul Han' => 'gonft.paul@gmail.com' }
  s.source           = { :git => 'https://github.com/gonft/ScribbleConverter.git', :tag => s.version.to_s }

  s.ios.deployment_target = '14.0'
  s.osx.deployment_target = '12.0'

  s.source_files = 'Sources/ScribbleConverter/*.swift'
  s.swift_versions = ['5.0']
  
  s.dependency 'SwiftProtobuf', '~> 1.19.0'
end
