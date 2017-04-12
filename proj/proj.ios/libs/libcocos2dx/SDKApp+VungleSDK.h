
#import <Foundation/Foundation.h>
#import "SDKApp.h"

@interface SDKApp (VungleSDK)

+ (void) startVungleSDK;
+ (void) playAdByVungleSDK:(NSDictionary *)dict;

+ (BOOL) isAdPlayableByVungleSDK;
+ (void) setOnAdPlayableChangedByVungleSDK:(NSDictionary *)dict;

@end
