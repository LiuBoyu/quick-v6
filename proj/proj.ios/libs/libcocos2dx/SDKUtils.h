
#import <Foundation/Foundation.h>
#import "CCLuaValue.h"

using namespace cocos2d;

@interface SDKUtils : NSObject

// tools

+ (UIViewController *) getViewController;
+ (void)               setViewController:(UIViewController *) viewController;

// tools

+ (NSString *) getParamS:(NSDictionary *)dict key:(NSString *)key;
+ (BOOL)       getParamB:(NSDictionary *)dict key:(NSString *)key;
+ (int)        getParamI:(NSDictionary *)dict key:(NSString *)key;
+ (int)        getParamF:(NSDictionary *)dict key:(NSString *)key;

// tools

+ (NSArray *)      toNSArray:(NSString *)json;
+ (NSDictionary *) toNSDictionary:(NSString *)json;

// tools

+ (LuaValue) serializeNSError:(NSError *)error;

+ (LuaValue) serializeNSNumber:(NSNumber *)val;
+ (LuaValue) serializeNSString:(NSString *)val;
+ (LuaValue) serializeNSDictionary:(NSDictionary *)dict;
+ (LuaValue) serializeNSArray:(NSArray *)array;

@end

