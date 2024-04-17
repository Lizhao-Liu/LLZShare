#
# Be sure to run `pod lib lint LLZShareKS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LLZShareKS'
  s.version          = '0.1.0'
  s.summary          = '第三方分享平台快手'

  s.description      = <<-DESC
  第三方分享平台快手组件，提供快手分享渠道处理类，快手sdk等
                       DESC

  s.homepage         = 'https://github.com/Lizhao-Liu/LLZShare'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lizhao' => 'lizhaoliu97@gmail.com' }
  s.source           = { :git => 'git@github.com:Lizhao-Liu/LLZShare.git', :tag => "LLZShareKS_#{s.version.to_s}" }
  s.vendored_libraries = 'LLZShareKS/Classes/SocialPlatform/libKwaiSDK/ios/libKwaiSDK.a'

  s.ios.deployment_target = '10.0'
  s.requires_arc = true

  s.source_files = 'LLZShareKS/Classes/**/*'
  s.dependency 'LLZShareLib', '~> 0.1'
end
