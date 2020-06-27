#import "IntercomPlugin.h"
#if __has_include(<intercom_plugin/intercom_plugin-Swift.h>)
#import <intercom_plugin/intercom_plugin-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "intercom_plugin-Swift.h"
#endif

@implementation IntercomPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftIntercomPlugin registerWithRegistrar:registrar];
}
@end
