
#import <Foundation/Foundation.h>
#import "SDKApp.h"

@interface SDKApp (Umeng)

+ (void) startUmengSDK;

+ (void) onUserByUmengSDK:(NSDictionary *)dict;

+ (void) onPayByUmengSDK:(NSDictionary *)dict;
+ (void) onBuyByUmengSDK:(NSDictionary *)dict;
+ (void) onUseByUmengSDK:(NSDictionary *)dict;

+ (void) onBonusByUmengSDK:(NSDictionary *)dict;
+ (void) onEventByUmengSDK:(NSDictionary *)dict;
+ (void) onLevelByUmengSDK:(NSDictionary *)dict;

@end

