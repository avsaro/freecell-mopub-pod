//
//  InMobiBannerCustomEvent.m
//  InMobi
//

#import "InMobiBannerCustomEvent.h"
#if __has_include(<MoPub/MoPub.h>)
    #import <MoPub/MoPub.h>
#elif __has_include(<MoPubSDKFramework/MoPub.h>)
    #import <MoPubSDKFramework/MoPub.h>
#else
    #import "MPConstants.h"
    #import "MPLogging.h"
#endif
#import "InMobiGDPR.h"
#import <InMobiSDK/IMSdk.h>

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface InMobiBannerCustomEvent () <CLLocationManagerDelegate>

@property (nonatomic, retain) IMBanner *inMobiBanner;
@property (nonatomic,strong) CLLocationManager *locationManager;

@end

@implementation InMobiBannerCustomEvent

#pragma mark - MPBannerCustomEvent Subclass Methods

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting InMobi banner");
    NSMutableDictionary *gdprConsentObject = [[NSMutableDictionary alloc] init];
    NSString* consent = @"false";
    if([InMobiGDPR getConsent]){
        consent = @"true";
    }
    [gdprConsentObject setObject:consent forKey:IM_GDPR_CONSENT_AVAILABLE];
    [gdprConsentObject setValue:[InMobiGDPR isGDPR] forKey:@"gdpr"];
    //InMobi SDK initialization with the account id setup @Mopub dashboard
    [IMSdk initWithAccountID:[info valueForKey:@"accountid"] consentDictionary:gdprConsentObject];
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    long long placementId = [[info valueForKey:@"placementid"] longLongValue];
    self.inMobiBanner = [[IMBanner alloc] initWithFrame:frame placementId:placementId];
    self.inMobiBanner.delegate = self;
    [self.inMobiBanner shouldAutoRefresh:NO];
    
    /*
     Mandatory params to be set by the publisher to identify the supply source type
     */
    NSMutableDictionary *paramsDict = [[NSMutableDictionary alloc] init];
    [paramsDict setObject:@"c_mopub" forKey:@"tp"];
	[paramsDict setObject:MP_SDK_VERSION forKey:@"tp-ver"];
    
    /*
     Sample for setting up the InMobi SDK Demographic params.
     Publisher need to set the values of params as they want.
     
     [IMSdk setAreaCode:@"1223"];
     [IMSdk setEducation:kIMSDKEducationHighSchoolOrLess];
     [IMSdk setGender:kIMSDKGenderMale];
     [IMSdk setAge:12];
     [IMSdk setPostalCode:@"234"];
     [IMSdk setLogLevel:kIMSDKLogLevelDebug];
     [IMSdk setLocationWithCity:@"BAN" state:@"KAN" country:@"IND"];
     [IMSdk setLanguage:@"ENG"];
     */
    self.inMobiBanner.extras = paramsDict;
    [self.inMobiBanner load];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    // Override this method to return NO to perform impression and click tracking manually.
    return NO;
}

#pragma mark - IMBannerDelegate


-(void)bannerDidFinishLoading:(IMBanner*)banner {
    MPLogInfo(@"InMobi banner did load");
    [self.delegate trackImpression];
    [self.delegate bannerCustomEvent:self didLoadAd:banner];
}

-(void)banner:(IMBanner*)banner didFailToLoadWithError:(IMRequestStatus*)error {
    MPLogInfo(@"InMobi banner did fail with error: %@", error);
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:(NSError *)error];
}

-(void)banner:(IMBanner*)banner didInteractWithParams:(NSDictionary*)params {
    MPLogInfo(@"InMobi banner was clicked");
    [self.delegate trackClick];
}

-(void)userWillLeaveApplicationFromBanner:(IMBanner*)banner {
    MPLogInfo(@"InMobi banner will leave application");
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

-(void)bannerWillPresentScreen:(IMBanner*)banner {
    MPLogInfo(@"InMobi banner will present screen");
    [self.delegate bannerCustomEventWillBeginAction:self];
}

-(void)bannerDidPresentScreen:(IMBanner*)banner {
    NSLog(@"InMobi banner did present screen");
}

-(void)bannerWillDismissScreen:(IMBanner*)banner {
    NSLog(@"InMobi banner will dismiss screen");
}

-(void)bannerDidDismissScreen:(IMBanner*)banner {
    NSLog(@"InMobi banner did dismiss screen");
    [self.delegate bannerCustomEventDidFinishAction:self];
}

-(void)banner:(IMBanner*)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    if(rewards!=nil){
        NSLog(@"InMobi banner reward action completed with rewards: %@", [rewards description]);
    }
}

@end
