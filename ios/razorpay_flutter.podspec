#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint razorpay_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'razorpay_flutter'
  s.version          = '1.1.10'
  s.summary          = 'Flutter plugin for Razorpay SDK.'
  s.description      = <<-DESC
Flutter plugin for Razorpay SDK. To know more about Razorpay, visit http://razorpay.com.
                       DESC
  s.homepage         = 'https://github.com/razorpay/razorpay-flutter'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Chintan Acharya' => 'chintan.acharya@razorpay.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'razorpay-pod'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
