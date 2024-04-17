#
# Be sure to run `pod lib lint LLZShareLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LLZShareLib'
  s.version          = '0.1.0'
  s.summary          = '分享'


  s.description      = <<-DESC
  分享
                       DESC

  s.homepage         = 'https://github.com/Lizhao-Liu/LLZShare'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Lizhao' => 'lizhaoliu97@gmail.com' }
  s.source           = { :git => 'git@github.com:Lizhao-Liu/LLZShare.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'
  s.requires_arc = true
  s.default_subspecs = "Core", "ShareUI"
  s.frameworks = 'WebKit', 'Security'
  
  s.subspec "Core" do |ss|
    ss.source_files = ["LLZShareLib/Classes/Core/**/*.{h,m,mm}", "LLZShareLib/Classes/Utils/**/*.{h,m,mm}"]
    ss.public_header_files = ["LLZShareLib/Classes/Core/**/*.{h}", "LLZShareLib/Classes/Utils/**/*.{h}"]
  end
  
  s.subspec "ShareUI" do |ss|
    ss.source_files = "LLZShareLib/Classes/ShareUI/**/*"
    ss.public_header_files = "LLZShareLib/Classes/ShareUI/**/*.{h}"
    ss.resource_bundles = {
      'ShareUI' => ['LLZShareLib/Assets/ShareUI/**/*.{json,plist,strings,xib,png,jpg,xcassets}'],
    }
    ss.dependency 'Masonry'
  end
  
  s.dependency 'LLZShareService','~> 0.1'
  s.dependency 'YYModel', '~> 1.0'
end
