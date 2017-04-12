
#import "SDKApp+ShareSDK.h"
#import "SDKAppConfig.h"
#import "SDKUtils.h"

#import <VungleSDK/VungleSDK.h>

@interface SDKAppVungleDelegate : NSObject <VungleSDKDelegate>
@end

static int onCloseAd = 0;
static int onAdPlayableChanged = 0;

@implementation SDKApp (VungleSDK)

+ (void) startVungleSDK
{
    [[VungleSDK sharedSDK] startWithAppId:SDKVungleAppId];
    [[VungleSDK sharedSDK] setDelegate:[[SDKAppVungleDelegate alloc] init]];
}

+ (void) playAdByVungleSDK:(NSDictionary *)dict
{
    if (!onCloseAd)
    {
        onCloseAd = [SDKUtils getParamF:dict key:@"callback"];
        
        [[VungleSDK sharedSDK] playAd:nil error:nil];
    }
}

+ (BOOL) isAdPlayableByVungleSDK
{
    return [[VungleSDK sharedSDK] isAdPlayable];
}

+ (void) setOnAdPlayableChangedByVungleSDK:(NSDictionary *)dict
{
    if (onAdPlayableChanged)
    {
        LuaBridge::releaseLuaFunctionById(onAdPlayableChanged);
    }
    onAdPlayableChanged = [SDKUtils getParamF:dict key:@"callback"];
}

@end

@implementation SDKAppVungleDelegate

- (void) vungleSDKwillShowAd
{
    
}

- (void) vungleSDKwillCloseAdWithViewInfo:(NSDictionary *)viewInfo willPresentProductSheet:(BOOL)willPresentProductSheet
{
    if (onCloseAd)
    {
        LuaBridge::pushLuaFunctionById(onCloseAd);
        LuaBridge::getStack()->pushLuaValue([SDKUtils serializeNSDictionary:viewInfo]);
        LuaBridge::getStack()->executeFunction(1);
        LuaBridge::releaseLuaFunctionById(onCloseAd);
        onCloseAd = 0;
    }
}

- (void) vungleSDKAdPlayableChanged:(BOOL)isAdPlayable
{
    if (onAdPlayableChanged)
    {
        LuaBridge::pushLuaFunctionById(onAdPlayableChanged);
        LuaBridge::getStack()->pushBoolean(isAdPlayable);
        LuaBridge::getStack()->executeFunction(1);
    }
}

@end
