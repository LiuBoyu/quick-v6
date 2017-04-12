
#import "SDKRateUs.h"
#import "CCLuaBridge.h"

static SDKRateUs *s_sharedInstance                = NULL;
static int        s_sharedCompletionHandler       = 0;

@implementation SDKRateUs

//
// objc interface
//

+ (SDKRateUs *) sharedInstance
{
    if (!s_sharedInstance)
    {
        [s_sharedInstance = [SDKRateUs alloc] init];
    }
    return s_sharedInstance;
}

+ (void) purgeSharedInstance
{
    if (s_sharedInstance)
    {
        [s_sharedInstance release];
        s_sharedInstance = NULL;
    }
}

- (SDKRateUs *) init
{
    if (self = [super init])
    {
        s_sharedCompletionHandler = 0;
        
        [iRate sharedInstance].delegate = self;
    }
    return self;
}

- (void) dealloc
{
    [iRate sharedInstance].delegate = nil;
    
    if (s_sharedCompletionHandler != 0)
    {
        LuaBridge::releaseLuaFunctionById(s_sharedCompletionHandler);
    }
    
    [super dealloc];
}

//
// lua interface
//

+ (void) load:(NSDictionary *)dict
{
    [SDKRateUs sharedInstance];
    
    id promptAtLaunch       = [dict objectForKey:@"promptAtLaunch"];
    id usesUntilPrompt      = [dict objectForKey:@"usesUntilPrompt"];
    id daysUntilPrompt      = [dict objectForKey:@"daysUntilPrompt"];
    id remindPeriod         = [dict objectForKey:@"remindPeriod"];
    
    int completionHandler   = [[dict objectForKey:@"completionHandler"] intValue];
    
    if (promptAtLaunch)
    {
        [iRate sharedInstance].promptAtLaunch = [promptAtLaunch boolValue];
    }
    if (usesUntilPrompt)
    {
        [iRate sharedInstance].usesUntilPrompt = [usesUntilPrompt integerValue];
    }
    if (daysUntilPrompt)
    {
        [iRate sharedInstance].daysUntilPrompt = [daysUntilPrompt floatValue];
    }
    if (remindPeriod)
    {
        [iRate sharedInstance].remindPeriod = [remindPeriod floatValue];
    }
    if (completionHandler != 0)
    {
        s_sharedCompletionHandler = completionHandler;
    }
}

+ (BOOL) shouldRateUs
{
    return [[iRate sharedInstance] shouldPromptForRating];
}

+ (void)   showRateUs
{
    [[iRate sharedInstance] promptIfNetworkAvailable];
}

+ (void)   openRateUsPage
{
    [[iRate sharedInstance] openRatingsPageInAppStore];
}

+ (void) rateus
{
    [[iRate sharedInstance] rate];
}

+ (void) remind
{
    [[iRate sharedInstance] remindLater];
}

+ (void) decline
{
    [[iRate sharedInstance] declineThisVersion];
}

+ (BOOL) isRatedUs
{
    return [[iRate sharedInstance] ratedAnyVersion];
}

+ (BOOL) isDeclined
{
    return [[iRate sharedInstance] declinedAnyVersion];
}

+ (void) reset
{
    [iRate sharedInstance].firstUsed           = nil;
    [iRate sharedInstance].lastReminded        = nil;
    [iRate sharedInstance].usesCount           = 0;
    [iRate sharedInstance].eventCount          = 0;
    [iRate sharedInstance].declinedThisVersion = false;
    [iRate sharedInstance].ratedThisVersion    = false;
}

//
// iRateDelegate
//

- (void) iRateDidPromptForRating
{
    [self executeFunctionWithEvent:@"ShowRateUs"];
}

- (void) iRateDidOpenAppStore
{
    [self executeFunctionWithEvent:@"OpenRateUsPage"];
}

- (void) iRateUserDidAttemptToRateApp
{
    [self executeFunctionWithEvent:@"RateUs"];
}

- (void) iRateUserDidRequestReminderToRateApp
{
    [self executeFunctionWithEvent:@"Remind"];
}

- (void) iRateUserDidDeclineToRateApp
{
    [self executeFunctionWithEvent:@"Decline"];
}

- (void) executeFunctionWithEvent:(NSString *)event
{
    if (s_sharedCompletionHandler != 0)
    {
        LuaBridge::pushLuaFunctionById(s_sharedCompletionHandler);
        LuaBridge::getStack()->pushString(event.UTF8String);
        LuaBridge::getStack()->executeFunction(1);
    }
}

@end
