
#import "SDKApp+Chartboost.h"

#import "SDKConfig.h"
#import "SDKUtils.h"

#import <UMMobClick/MobClick.h>
#import <UMMobClick/MobClickGameAnalytics.h>

@implementation SDKApp (Umeng)

+ (void) startUmengSDK
{
    UMConfigInstance.appKey    = SDKUmengAppKey;
    UMConfigInstance.channelId = SDKUmengChannelId;
    UMConfigInstance.eSType    = E_UM_GAME;
    
    [MobClick startWithConfigure:UMConfigInstance];
}

+ (void) onUserByUmengSDK:(NSDictionary *)dict
{
    NSString *cmd = [dict objectForKey:@"cmd"];
    
    if ([cmd isEqualToString:@"login"]) {
        NSString *playerID = [dict objectForKey:@"playerID"];
        NSString *provider = [dict objectForKey:@"provider"];
        
        if (provider) {
            [MobClickGameAnalytics profileSignInWithPUID:playerID provider:provider];
        } else {
            [MobClickGameAnalytics profileSignInWithPUID:playerID];
        }
    }
    
    if ([cmd isEqualToString:@"logout"]) {
        [MobClickGameAnalytics profileSignOff];
    }
    
    if ([cmd isEqualToString:@"level"]) {
        int level = [[dict objectForKey:@"level"] intValue];
        
        [MobClickGameAnalytics setUserLevelId:level];
    }
}

+ (void) onPayByUmengSDK:(NSDictionary *)dict
{
    NSString *cmd = [dict objectForKey:@"cmd"];
    
    if ([cmd isEqualToString:@"coin"]) {
        double cash = [[dict objectForKey:@"cash"  ] doubleValue];
        int  source = [[dict objectForKey:@"source"] intValue];
        double coin = [[dict objectForKey:@"coin"  ] doubleValue];
        
        [MobClickGameAnalytics pay:cash source:source coin:coin];
    }
    
    if ([cmd isEqualToString:@"item"]) {
        double    cash = [[dict objectForKey:@"cash"  ] doubleValue];
        int     source = [[dict objectForKey:@"source"] intValue];
        NSString *item =  [dict objectForKey:@"item"  ];
        int     amount = [[dict objectForKey:@"amount"] intValue];
        double   price = [[dict objectForKey:@"price" ] doubleValue];
        
        [MobClickGameAnalytics pay:cash source:source item:item amount:amount price:price];
    }
}

+ (void) onBuyByUmengSDK:(NSDictionary *)dict
{
    NSString *item =  [dict objectForKey:@"item"  ];
    int     amount = [[dict objectForKey:@"amount"] intValue];
    double   price = [[dict objectForKey:@"price" ] doubleValue];
    
    [MobClickGameAnalytics buy:item amount:amount price:price];
}

+ (void) oUseByUmengSDK:(NSDictionary *)dict
{
    NSString *item =  [dict objectForKey:@"item"  ];
    int     amount = [[dict objectForKey:@"amount"] intValue];
    double   price = [[dict objectForKey:@"price" ] doubleValue];
    
    [MobClickGameAnalytics use:item amount:amount price:price];
}

+ (void) onBonusByUmengSDK:(NSDictionary *)dict
{
    NSString *cmd = [dict objectForKey:@"cmd"];
    
    if ([cmd isEqualToString:@"coin"]) {
        double coin = [[dict objectForKey:@"coin"  ] doubleValue];
        int  source = [[dict objectForKey:@"source"] intValue];
        
        [MobClickGameAnalytics bonus:coin source:source];
    }
    
    if ([cmd isEqualToString:@"item"]) {
        NSString *item =  [dict objectForKey:@"item"  ];
        int     amount = [[dict objectForKey:@"amount"] intValue];
        double   price = [[dict objectForKey:@"price" ] doubleValue];
        int     source = [[dict objectForKey:@"source"] intValue];
        
        [MobClickGameAnalytics bonus:item amount:amount price:price source:source];
    }
}

+ (void) onEventByUmengSDK:(NSDictionary *)dict
{
}

+ (void) onLevelByUmengSDK:(NSDictionary *)dict
{
    NSString *cmd   = [dict objectForKey:@"cmd"  ];
    NSString *level = [dict objectForKey:@"level"];
    
    if ([cmd isEqualToString:@"start"]) {
        [MobClickGameAnalytics startLevel:level];
    }
    if ([cmd isEqualToString:@"finish"]) {
        [MobClickGameAnalytics finishLevel:level];
    }
    if ([cmd isEqualToString:@"fail"]) {
        [MobClickGameAnalytics failLevel:level];
    }
}

@end

