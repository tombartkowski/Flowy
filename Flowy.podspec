#
# Be sure to run `pod lib lint Flowy.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Flowy'
  s.version          = '0.0.2'
  s.summary          = 'Reactive, event-driven coordination in Swift.'
  s.homepage         = 'https://github.com/tombartkowski/Flowy'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tomasz Bartkowski' => 'tomaszbartkowski.studio@gmail.com' }
  s.source           = { :git => 'https://github.com/tombartkowski/Flowy.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'Flowy/Classes/**/*'
  
  s.dependency 'RxSwift'
  s.dependency 'RxSwiftExt'
  s.dependency 'RxCocoa'
end
