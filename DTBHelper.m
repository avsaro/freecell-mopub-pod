//
//  DTBHelper.m
//  freecell-mopub-pod
//
//  Created by Onur Avsar on 1.10.2019.
//

#import "DTBHelper.h"
#import <DTBiOSSDK/DTBiOSSDK.h>
#import "DTBAdWatcher.h"

#ifdef __cplusplus
extern "C" {
#endif
    // life cycle management
    void UnityPause(int pause);
    void UnitySendMessage(const char* obj, const char* method, const char* msg);
#ifdef __cplusplus
}
#endif

static char* cStringCopy(NSString* input)
{
    const char* string = [input UTF8String];
    return string ? strdup(string) : NULL;
}

@interface DTBHelper ()

@property DTBAdWatcher *bannerWatcher;
@property DTBAdWatcher *interstitialWatcher;
@property DTBAdWatcher *interstitialVideoWatcher;
@property int interstitialLoaderCount;

@end

@implementation DTBHelper

+ (DTBHelper *)sharedHelper
{
    static DTBHelper* sharedHelper = nil;
    
    if (!sharedHelper)
        sharedHelper = [[DTBHelper alloc] init];
    
    return sharedHelper;
}

- (void)requestDTBBannerKeywordsForLeaderboard:(bool)isLeaderboard withAdId:(NSString *)adId {
    DTBAdSize *bannerSize;
    
    if (isLeaderboard) {
        bannerSize = [[DTBAdSize alloc] initBannerAdSizeWithWidth:728.0f
                                                           height:90.0f
                                                      andSlotUUID:adId];
    } else {
        bannerSize = [[DTBAdSize alloc] initBannerAdSizeWithWidth:320.0f
                                                           height:50.0f
                                                      andSlotUUID:adId];
    }
    
    self.bannerWatcher = [[DTBAdWatcher alloc] initForReusableLoader:bannerSize andLoadAdSelector:@selector(bannerLoadReady:) withObject:self];
}

- (void)bannerLoadReady:(id)loader {
    NSString *dtbKeywords = [self.bannerWatcher getKeywords];
    [DTBHelper sendUnityEvent:@"BannerKeywordsReady" withStringArg:dtbKeywords];
}

- (void)requestDTBInterstitialKeywordsWithAdId:(NSString *)adId andVideoAdId:(NSString *)videoAdId {
    DTBAdSize *interstitialSize = [[DTBAdSize alloc] initInterstitialAdSizeWithSlotUUID:adId];
    
    DTBAdLoader *interstitialLoader = [DTBAdLoader new];
    [interstitialLoader setSizes:interstitialSize, nil];
    
    self.interstitialWatcher = [[DTBAdWatcher alloc] initWithLoader:interstitialLoader andLoadAdSelector:@selector(interstitialLoadReady:) withObject:self];
    
    interstitialSize = [[DTBAdSize alloc] initVideoAdSizeWithPlayerWidth:480 height:320 andSlotUUID:videoAdId];
    
    DTBAdLoader *videoLoader = [DTBAdLoader new];
    [videoLoader setSizes:interstitialSize, nil];
    
    self.interstitialVideoWatcher = [[DTBAdWatcher alloc] initWithLoader:videoLoader andLoadAdSelector:@selector(interstitialLoadReady:) withObject:self];
}

-(void) interstitialLoadReady:(DTBAdLoader*)loader {
    self.interstitialLoaderCount++;
    if (self.interstitialLoaderCount >= 2) {
        self.interstitialLoaderCount = 0;
        NSString *dtbInterstitialKeywords = [self.interstitialWatcher getKeywords];
        NSString *dtbInterstitialVideoKeywords = [self.interstitialVideoWatcher getKeywords];
        NSString *dtbKeywords = [dtbInterstitialKeywords stringByAppendingFormat:@",%@", dtbInterstitialVideoKeywords];
        [DTBHelper sendUnityEvent:@"InterstitialKeywordsReady" withStringArg:dtbKeywords];
    }
}

+ (void)sendUnityEvent:(NSString *)eventName withStringArg:(NSString *)stringArg
{
    UnitySendMessage("UnsupportedNetworksHelper", eventName.UTF8String, cStringCopy(stringArg));
}

@end
