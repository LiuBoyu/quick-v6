
#import "SDKIAP.h"
#import "SDKUtils.h"
#import "CCLuaBridge.h"
#import <StoreKit/StoreKit.h>

@interface ProductsRequest : SKProductsRequest
@property (nonatomic, assign) int callback;
@end

@implementation ProductsRequest
- (ProductsRequest *) init
{
    if (self = [super init])
        self.callback = 0;
    return self;
}
- (void) dealloc
{
    [super dealloc];
}
@end

@interface SDKIAP() <SKProductsRequestDelegate>
@end

@interface SDKIAP() <SKPaymentTransactionObserver>
@end

@implementation SDKIAP

static SDKIAP *s_sharedInstance = NULL;

static NSMutableDictionary *s_loadedProducts = NULL;
static NSMutableDictionary *s_loadedTss      = NULL;
static int                  s_tsHandler      = 0;

//
// objc interface
//

+ (SDKIAP *) sharedInstance
{
    if (!s_sharedInstance)
    {
        [s_sharedInstance = [SDKIAP alloc] init];
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

- (SDKIAP *) init
{
    if (self = [super init])
    {
        s_loadedProducts = [[NSMutableDictionary alloc] init];
        s_loadedTss      = [[NSMutableDictionary alloc] init];
        s_tsHandler      = 0;
    }
    return self;
}

- (void) dealloc
{
    [s_loadedProducts release];
    s_loadedProducts = NULL;
    
    [s_loadedTss release];
    s_loadedTss = NULL;
    
    if (s_tsHandler != 0)
    {
        LuaBridge::releaseLuaFunctionById(s_tsHandler);
        s_tsHandler = 0;
    }
    
    [super dealloc];
}

//
// lua interface - 初始化商店·回调
//

+ (void) init:(NSDictionary *)dict
{
    int callback = [[dict objectForKey:@"callback"] intValue];
    
    [SDKIAP sharedInstance];
    
    if (s_tsHandler != 0)
    {
        LuaBridge::releaseLuaFunctionById(s_tsHandler);
        s_tsHandler = 0;
    }
    
    if (callback != 0)
    {
        s_tsHandler = callback;
    }
}

//
// lua interface - 卸载商店
//

+ (void) unload
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:[SDKIAP sharedInstance]];
    [SDKIAP purgeSharedInstance];
}

//
// lua interface - 初始化商店·加载
//

+ (void) loadStore
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[SDKIAP sharedInstance]];
}

//
// lua interface - 加载商店
//

+ (void) loadProducts:(NSDictionary *)dict
{
    NSArray *productIds = [SDKUtils toNSArray:(NSString *)[dict objectForKey:@"productIds"]];
    int        callback = [[dict objectForKey:@"callback"] intValue];
    
    ProductsRequest *request = [[ProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productIds]];
    request.delegate = [SDKIAP sharedInstance];
    request.callback = callback;
    
    [request autorelease];
    [request start];
}

// SKProductsRequestDelegate

- (void) productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *products          = response.products;
    NSArray *invalidProductIds = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products)
    {
        [s_loadedProducts setObject:product forKey:product.productIdentifier];
    }
    
    int callback = ((ProductsRequest *) request).callback;
    
    LuaBridge::pushLuaFunctionById(callback);
    
    LuaBridge::getStack()->pushLuaValue([SDKUtils serializeNSArray:[SDKIAP serializeSKProductsArray:products]]);
    LuaBridge::getStack()->pushLuaValue([SDKUtils serializeNSArray:invalidProductIds]);
    LuaBridge::getStack()->pushNil();
    
    LuaBridge::getStack()->executeFunction(3);
    LuaBridge::releaseLuaFunctionById(callback);
}

- (void) request:(SKRequest *)request didFailWithError:(NSError *)error
{
    int callback = ((ProductsRequest *) request).callback;
    
    LuaBridge::pushLuaFunctionById(callback);
    
    LuaBridge::getStack()->pushNil();
    LuaBridge::getStack()->pushNil();
    LuaBridge::getStack()->pushLuaValue([SDKUtils serializeNSError:error]);
    
    LuaBridge::getStack()->executeFunction(3);
    LuaBridge::releaseLuaFunctionById(callback);
}

//
// lua interface - 加载商店·非消耗品
//

+ (void) restore
{
    // todo
}

// SKPaymentTransactionObserver

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    // todo
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    // todo
}

//
// lua interface - 查询商品
//

+ (NSDictionary *) getProduct:(NSDictionary *)dict
{
    NSString *productId = [dict objectForKey:@"productId"];
    SKProduct  *product = [s_loadedProducts objectForKey:productId];
    
    if (product)
    {
        return [SDKIAP serializeSKProduct:product];
    }
    else
    {
        return nil;
    }
}

+ (BOOL) isPurchased:(NSDictionary *)dict
{
    // todo
    return false;
}

//
// lua interface - 购买商品
//

+ (void) purchase:(NSDictionary *)dict
{
    NSString *productId = [dict objectForKey:@"productId"];
    SKProduct  *product = [s_loadedProducts objectForKey:productId];
    
    if (product)
    {
        [[SKPaymentQueue defaultQueue] addPayment:[SKPayment paymentWithProduct:product]];
    }
    else
    {
        if (s_tsHandler != 0)
        {
            LuaBridge::pushLuaFunctionById(s_tsHandler);
            
            LuaBridge::getStack()->pushNil();
            
            LuaBridge::getStack()->executeFunction(1);
        }
    }
}

// SKPaymentTransactionObserver

- (void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *ts in transactions)
    {
        if ((ts.transactionState == SKPaymentTransactionStatePurchased) ||
            (ts.transactionState == SKPaymentTransactionStateFailed))
        {
            if (s_tsHandler != 0)
            {
                LuaBridge::pushLuaFunctionById(s_tsHandler);
                
                LuaBridge::getStack()->pushLuaValue([SDKUtils serializeNSDictionary:[SDKIAP serializeSKTransaction:ts]]);
                
                LuaBridge::getStack()->executeFunction(1);
            }
        }
        
        if (ts.transactionState != SKPaymentTransactionStatePurchasing)
        {
            [[SKPaymentQueue defaultQueue] finishTransaction: ts];
        }
    }
}

//
// lua interface
//

// 校验收据
+ (void) verifyReceipt
{
    NSURL  *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt    =  [NSData dataWithContentsOfURL:receiptURL];
    
    NSDictionary *requestContents = @{ @"receipt-data":[receipt base64EncodedStringWithOptions:0] };
    NSData       *requestData     = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:nil];
    
#if !defined(DEBUG)
    NSURL        *requestURL      = [NSURL URLWithString:@"https://buy.itunes.apple.com/verifyReceipt"];
#else
    NSURL        *requestURL      = [NSURL URLWithString:@"https://sandbox.itunes.apple.com/verifyReceipt"];
#endif
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         // todo
     }];
}

//
// tools
//

+ (NSDictionary *) serializeSKProductsDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    for (NSString *key in dict)
    {
        NSDictionary *productObj = [SDKIAP serializeSKProduct:[dict objectForKey:key]];
        
        [ret setObject:productObj forKey:key];
    }
    
    return ret;
}

+ (NSArray      *) serializeSKProductsArray:(NSArray *)array
{
    NSMutableArray *ret = [NSMutableArray array];
    
    for (SKProduct *product in array)
    {
        NSDictionary *productObj = [SDKIAP serializeSKProduct:product];
        
        [ret addObject:productObj];
    }
    
    return ret;
}

+ (NSDictionary *) serializeSKProduct:(SKProduct *)product
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    [ret setObject:product.productIdentifier    forKey:@"id"];
    [ret setObject:product.price                forKey:@"price"];
    [ret setObject:product.localizedTitle       forKey:@"title"];
    [ret setObject:product.localizedDescription forKey:@"description"];
    
    return ret;
}

+ (NSDictionary *) serializeSKTransaction:(SKPaymentTransaction *)ts
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    
    if (ts.transactionState == SKPaymentTransactionStatePurchased)
    {
        NSNumber *date = [NSNumber numberWithInt:[ts.transactionDate timeIntervalSince1970]];
        [ret setObject:@"Purchased"                                             forKey:@"state"];
        [ret setObject:ts.transactionIdentifier                                 forKey:@"id"];
        [ret setObject:date                                                     forKey:@"date"];
        [ret setObject:ts.payment.productIdentifier                             forKey:@"productId"];
        [ret setObject:[ts.transactionReceipt base64EncodedStringWithOptions:0] forKey:@"receipt"];
    }
    
    if (ts.transactionState == SKPaymentTransactionStateFailed)
    {
        if (ts.error.code == SKErrorPaymentCancelled) {
            [ret setObject:@"Cancelled"                                         forKey:@"state"];
        } else {
            [ret setObject:@"Failed"                                            forKey:@"state"];
        }
        [ret setObject:ts.transactionIdentifier                                 forKey:@"id"];
        [ret setObject:[SDKIAP serializeSKError:ts.error]                     forKey:@"error"];
    }
    
    return ret;
}

+ (NSDictionary *) serializeSKError:(NSError *)error
{
    NSString *code = @"-1";
    NSString *text = @"Unknown";
    
    if (error.code == SKErrorClientInvalid)
    {
        code = @"401";
        text = @"ClientInvalid";
    }
    if (error.code == SKErrorPaymentCancelled)
    {
        code = @"402";
        text = @"PaymentCancelled";
    }
    if (error.code == SKErrorPaymentInvalid)
    {
        code = @"403";
        text = @"PaymentInvalid";
    }
    if (error.code == SKErrorPaymentNotAllowed)
    {
        code = @"404";
        text = @"PaymentNotAllowed";
    }
    if (error.code == SKErrorStoreProductNotAvailable)
    {
        code = @"405";
        text = @"StoreProductNotAvailable";
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:code, @"code", text, @"text", nil];
}

@end

