
#import "SDKApp+TalkingData.h"

#import "SDKConfig.h"
#import "SDKUtils.h"

#import "TalkingDataGA.h"

@implementation SDKApp (TalkingData)

static TDGAAccount *player = NULL;

+ (void) startTalkingDataSDK
{
    [TalkingDataGA onStart:SDKTalkingDataAppId withChannelId:SDKTalkingDataChannelId];
}

+ (void) onUserByTalkingDataSDK:(NSDictionary *)dict
{
    NSString *cmd = [dict objectForKey:@"cmd"];
    
    if ([cmd isEqualToString:@"login"]) {
        NSString *playerID = [dict objectForKey:@"playerID"];
        NSString *provider = [dict objectForKey:@"provider"];
        
        player = [TDGAAccount setAccount:playerID];
        
        if        ([provider isEqualToString:@"registered"]) {
            [player setAccountType:kAccountRegistered];
        } else if ([provider isEqualToString:@"facebook"  ]) {
            [player setAccountType:kAccountType1];
        } else {
            [player setAccountType:kAccountAnonymous];
        }
    }
    
    if ([cmd isEqualToString:@"logout"]) {
    }
    
    if ([cmd isEqualToString:@"level"]) {
        int level = [[dict objectForKey:@"level"] intValue];
        
        if (player) {
            [player setLevel:level];
        }
    }
}

+ (void) onPayByTalkingDataSDK:(NSDictionary *)dict
{
    NSString *cmd = [dict objectForKey:@"cmd"];
    
    if ([cmd isEqualToString:@"coin"]) {
        NSString *orderId =  [dict objectForKey:@"orderId"];
        NSString   *iapId =  [dict objectForKey:@"iapId"  ];
        double       cash = [[dict objectForKey:@"cash"   ] doubleValue];
        double       coin = [[dict objectForKey:@"coin"   ] doubleValue];
        NSString  *source =  [dict objectForKey:@"source" ];
        
        [TDGAVirtualCurrency onChargeRequst:orderId iapId:iapId currencyAmount:cash currencyType:@"USD" virtualCurrencyAmount:coin paymentType:source];
        [TDGAVirtualCurrency onChargeSuccess:orderId];
    }
}

+ (void) onBuyByTalkingDataSDK:(NSDictionary *)dict
{
    NSString *item =  [dict objectForKey:@"item"  ];
    int     amount = [[dict objectForKey:@"amount"] intValue];
    double   price = [[dict objectForKey:@"price" ] doubleValue];
    
    [TDGAItem onPurchase:item itemNumber:amount priceInVirtualCurrency:price];
}

+ (void) onUseByTalkingDataSDK:(NSDictionary *)dict
{
    NSString *item =  [dict objectForKey:@"item"  ];
    int     amount = [[dict objectForKey:@"amount"] intValue];
    
    [TDGAItem onUse:item itemNumber:amount];
}

+ (void) onBonusByTalkingDataSDK:(NSDictionary *)dict
{
    NSString *cmd = [dict objectForKey:@"cmd"];
    
    if ([cmd isEqualToString:@"coin"]) {
        double      coin = [[dict objectForKey:@"coin"  ] doubleValue];
        NSString *reason =  [dict objectForKey:@"reason"];
        
        [TDGAVirtualCurrency onReward:coin reason:reason];
    }
}

+ (void) onEventByTalkingDataSDK:(NSDictionary *)dict
{
}

+ (void) onLevelByTalkingDataSDK:(NSDictionary *)dict
{
    NSString *cmd   = [dict objectForKey:@"cmd"  ];
    NSString *level = [dict objectForKey:@"level"];
    NSString *cause = [dict objectForKey:@"cause"];
    
    if ([cmd isEqualToString:@"start"]) {
        [TDGAMission onBegin:level];
    }
    if ([cmd isEqualToString:@"finish"]) {
        [TDGAMission onCompleted:level];
    }
    if ([cmd isEqualToString:@"fail"]) {
        [TDGAMission onFailed:level failedCause:cause];
    }
}

@end

