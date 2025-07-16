#import "RazorpayFlutterPlugin.h"
#import <razorpay_turbo_standard/razorpay_turbo_standard-Swift.h>

@implementation RazorpayFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
  [SwiftRazorpayFlutterPlugin registerWithRegistrar:registrar];
}
@end
