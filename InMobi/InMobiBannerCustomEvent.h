//
//  InMobiBannerCustomEvent.h
//  InMobi
//
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPBannerCustomEvent.h"
#endif
#import <InMobiSDK/IMBanner.h>


@interface InMobiBannerCustomEvent : MPBannerCustomEvent <IMBannerDelegate>

@end
