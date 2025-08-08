//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<package_info_plus/FPPPackageInfoPlusPlugin.h>)
#import <package_info_plus/FPPPackageInfoPlusPlugin.h>
#else
@import package_info_plus;
#endif

#if __has_include(<razorpay_flutter/RazorpayFlutterPlugin.h>)
#import <razorpay_flutter/RazorpayFlutterPlugin.h>
#else
@import razorpay_flutter;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FPPPackageInfoPlusPlugin registerWithRegistrar:[registry registrarForPlugin:@"FPPPackageInfoPlusPlugin"]];
  [RazorpayFlutterPlugin registerWithRegistrar:[registry registrarForPlugin:@"RazorpayFlutterPlugin"]];
}

@end
