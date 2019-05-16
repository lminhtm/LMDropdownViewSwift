#
# Be sure to run `pod lib lint LMDropdownViewSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LMDropdownViewSwift'
  s.version          = '1.0.0'
  s.summary          = 'LMDropdownViewSwift is a simple dropdown view inspired by Tappy.'
  s.description      = <<-DESC
LMDropdownViewSwift is a simple dropdown view inspired by Tappy.
                       DESC

  s.homepage         = 'https://github.com/LMinh/LMDropdownViewSwift'
  s.screenshots      = 'https://raw.github.com/lminhtm/LMDropdownViewSwift/master/Screenshots/screenshot1.png', 'https://raw.github.com/lminhtm/LMDropdownViewSwift/master/Screenshots/screenshot2.gif'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'LMinh' => 'lminhtm@gmail.com' }
  s.source           = { :git => 'https://github.com/LMinh/LMDropdownViewSwift.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
  s.source_files = 'LMDropdownViewSwift/Classes/**/*'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
end
