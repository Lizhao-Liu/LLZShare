#
# Be sure to run `pod lib lint LLZShareService.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LLZShareService'
  s.version          = '0.1.0'
  s.summary          = 'LLZShareService.'

  s.description      = <<-DESC
满帮分享service
                       DESC

  s.homepage         = 'https://github.com/Lizhao-Liu/LLZShare'

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lizhao' => 'lizhaoliu97@gmail.com' }
  s.source           = { :git => 'git@github.com:Lizhao-Liu/LLZShare.git', :tag => "LLZShareService_#{s.version.to_s}"  }

  s.ios.deployment_target = '10.0'

  s.source_files = 'LLZShareService/Classes/**/*'

end
