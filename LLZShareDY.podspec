Pod::Spec.new do |s|
  s.name             = 'LLZShareDY'
  s.version          = '0.1.0'
  s.summary          = '第三方分享平台抖音'

  s.description      = <<-DESC
  第三方分享平台抖音组件，提供抖音分享渠道处理类，抖音sdk等
                       DESC

  s.homepage         = 'https://github.com/Lizhao-Liu/LLZShare'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lizhao' => 'lizhaoliu97@gmail.com' }
  s.source           = { :git => 'git@github.com:Lizhao-Liu/LLZShare.git', :tag => "LLZShareDY_#{s.version.to_s}" }


  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.vendored_frameworks = 'LLZShareDY/Classes/SocialPlatform/DouyinOpenSDK.framework'

  s.source_files = 'LLZShareDY/Classes/**/*.{h,m,mm}'
#  s.exclude_files = 'LLZShareDY/Classes/SocialPlatform/DouyinOpenSDK.framework'
  s.dependency 'LLZShareLib', '~> 0.1'
end
