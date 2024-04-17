Pod::Spec.new do |s|
  s.name             = 'LLZShareQQ'
  s.version          = '0.1.0'
  s.summary          = '第三方分享平台QQ'

  s.description      = <<-DESC
  第三方分享平台QQ组件，提供QQ分享渠道处理类，QQsdk等
                       DESC

  s.homepage         = 'https://github.com/Lizhao-Liu/LLZShare'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lizhao' => 'lizhaoliu97@gmail.com' }
  s.source           = { :git => 'git@github.com:Lizhao-Liu/LLZShare.git', :tag => "LLZShareQQ_#{s.version.to_s}" }


  s.ios.deployment_target = '10.0'
  s.requires_arc = true

  s.source_files = 'LLZShareQQ/Classes/**/*'
  s.dependency 'TencentOpenAPI', '~> 1.2'
  s.dependency 'LLZShareLib', '~> 0.1'
end
