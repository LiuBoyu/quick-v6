
#import <Foundation/Foundation.h>
#import "SDKApp.h"

@interface SDKApp (TalkingData)

+ (void) startTalkingDataSDK;

+ (void) onUserByTalkingDataSDK:(NSDictionary *)dict;

+ (void) onPayByTalkingDataSDK:(NSDictionary *)dict;
+ (void) onBuyByTalkingDataSDK:(NSDictionary *)dict;
+ (void) onUseByTalkingDataSDK:(NSDictionary *)dict;

+ (void) onBonusByTalkingDataSDK:(NSDictionary *)dict;
+ (void) onEventByTalkingDataSDK:(NSDictionary *)dict;
+ (void) onLevelByTalkingDataSDK:(NSDictionary *)dict;

@end

