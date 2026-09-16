#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'razorpay_flutter'
  s.version          = '1.1.10'
  s.summary          = 'Flutter plugin for Razorpay SDK.'
  s.description      = 'Flutter plugin for Razorpay SDK.'
  s.homepage         = 'https://github.com/razorpay/razorpay-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Chintan Acharya' => 'chintan.acharya@razorpay.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'razorpay-pod'

  s.ios.deployment_target = '10.0'
end
