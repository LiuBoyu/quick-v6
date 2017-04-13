
#import <Foundation/Foundation.h>
#import "SDKApp.h"

@interface SDKApp (Chartboost)

+ (void) startChartboostSDK;

+ (void) playAdByChartboostSDK:(NSDictionary *)dict;
+ (BOOL) isAdPlayableByChartboostSDK;

+ (void) setOnAdPlayableChangedByChartboostSDK:(NSDictionary *)dict;

+ (void) playItByChartboostSDK;
+ (BOOL) isItPlayableByChartboostSDK;

+ (void) setOnItPlayableChangedByChartboostSDK:(NSDictionary *)dict;

@end
