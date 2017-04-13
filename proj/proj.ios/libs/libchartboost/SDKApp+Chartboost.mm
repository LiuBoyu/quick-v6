
#import "SDKApp+Chartboost.h"

#import "SDKConfig.h"
#import "SDKUtils.h"

#import <Chartboost/Chartboost.h>

@interface SDKAppChartboostDelegate : NSObject <ChartboostDelegate>
@end

// static int onCloseAd = 0;
// static int onAdPlayableChanged = 0;

@implementation SDKApp (Chartboost)

+ (void) startChartboostSDK
{
    [Chartboost startWithAppId:SDKChartboostAppId appSignature:SDKChartboostAppSignature delegate:[[SDKAppChartboostDelegate alloc] init]];
    [Chartboost setShouldRequestInterstitialsInFirstSession:NO];
}

+ (void) playAdByChartboostSDK:(NSDictionary *)dict
{
    [Chartboost showRewardedVideo:CBLocationHomeScreen];
}

+ (BOOL) isAdPlayableByChartboostSDK
{
    if ([Chartboost hasRewardedVideo:CBLocationHomeScreen])
    {
        return YES;
    }
    return NO;
}

+ (void) setOnAdPlayableChangedByChartboostSDK:(NSDictionary *)dict
{
    // todo
}

+ (void) playItByChartboostSDK
{
    [Chartboost showInterstitial:CBLocationHomeScreen];
}

+ (BOOL) isItPlayableByChartboostSDK
{
    if ([Chartboost hasInterstitial:CBLocationHomeScreen])
    {
        return YES;
    }
    return NO;
}

+ (void) setOnItPlayableChangedByChartboostSDK:(NSDictionary *)dict
{
    // todo
}

@end

/*
 * Chartboost Delegate Methods
 *
 */

@implementation SDKAppChartboostDelegate

/*
 * didInitialize
 *
 * This is used to signal when Chartboost SDK has completed its initialization.
 *
 * status is YES if the server accepted the appID and appSignature as valid
 * status is NO if the network is unavailable or the appID/appSignature are invalid
 *
 * Is fired on:
 * -after startWithAppId has completed background initialization and is ready to display ads
 */
- (void)didInitialize:(BOOL)status {
    if (status)
    {
        // chartboost is ready
        [Chartboost cacheRewardedVideo:CBLocationHomeScreen];
        [Chartboost cacheInterstitial:CBLocationHomeScreen];
    }
}

/*
 * shouldDisplayInterstitial
 *
 * This is used to control when an interstitial should or should not be displayed
 * The default is YES, and that will let an interstitial display as normal
 * If it's not okay to display an interstitial, return NO
 *
 * For example: during gameplay, return NO.
 *
 * Is fired on:
 * -Interstitial is loaded & ready to display
 */

- (BOOL)shouldDisplayInterstitial:(NSString *)location {
    return YES;
}

@end
