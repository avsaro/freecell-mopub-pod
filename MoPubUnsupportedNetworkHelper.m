//
//  MoPubUnsupportedNetworkHelper.m
//  FBSDKCoreKit
//
//  Created by Onur Avsar on 1.10.2019.
//

#import <InMobiSDK/InMobiSDK.h>
#import <IASDKCore/IASDKCore.h>
#import <DTBiOSSDK/DTBiOSSDK.h>
#import "DTBHelper.h"

// Converts C style string to NSString
#define GetStringParam(_x_) ((_x_) != NULL ? [NSString stringWithUTF8String:_x_] : [NSString stringWithUTF8String:""])
#define GetNullableStringParam(_x_) ((_x_) != NULL ? [NSString stringWithUTF8String:_x_] : nil)

// Converts an NSString into a const char* ready to be sent to Unity
static char* cStringCopy(NSString *input){
    const char *string = [input UTF8String];
    return string ? strdup(string) : NULL;
}

static void initializeDTB(const char* a9Id) {
    [[DTBAds sharedInstance] setAppKey:GetStringParam(a9Id)];
    [[DTBAds sharedInstance] setUseGeoLocation:YES];
    [[DTBAds sharedInstance] setLogLevel:DTBLogLevelAll];
}

static void initializeInMobi(const char* inMobiId) {
    [IMSdk initWithAccountID:GetStringParam(inMobiId)];
}

static void initializeFyber(const char* fyberId) {
    [[IASDKCore sharedInstance] initWithAppID:GetStringParam(fyberId)];
}

static void requestDTBBannerKeywords(bool isLeaderboard, const char* adId) {
    [[DTBHelper sharedHelper] requestDTBBannerKeywordsForLeaderboard:isLeaderboard withAdId:GetStringParam(adId)];
}

static void requestDTBInterstitialKeywords(const char* adId, const char* videoAdId) {
    [[DTBHelper sharedHelper] requestDTBInterstitialKeywordsWithAdId:GetStringParam(adId) andVideoAdId:GetStringParam(videoAdId)];
}
