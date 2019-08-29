//
//  OptimizedBannerAdManager.m
//  Solitaire
//
//  Created by Ryan Schweter on 5/25/17.
//  Copyright © 2017 Zynga, Inc. All rights reserved.
//

#import "OptimizedBannerAdManager.h"
#import "ZAnalytics.h"
#import "MPAdTargeting.h"

// provides access to base class private members
@interface MPBannerAdManager ()

@property (nonatomic, strong) MPAdConfiguration *requestingConfiguration;

- (void)presentRequestingAdapter;
- (void)didFailToLoadAdapterWithError:(NSError *)error;

@end


@interface OptimizedBannerAdManager ()

@property (nonatomic, retain) NSMutableArray *loadTimes;
@property (nonatomic, retain) NSDate *viewStart;
@property (nonatomic, retain) NSDate *loadStart;

@end

static const NSUInteger DEFAULT_REFRESH_INTERVAL = 30; // refresh interval used if we haven't received a value from mopub yet
static const NSUInteger LOAD_ERROR_REFRESH_INTERVAL = 15; // how long to wait if we fail to retrieve a response from mopub
static const NSUInteger LOAD_TIME_HISTORY_COUNT = 5; // how many historical values we want to retain to calculate the next load delay
static const NSUInteger TYPICAL_LOAD_TIME = 5; // used to preload the historical data
static const NSUInteger MINIMUM_PRELOAD_DELAY = 15; // shortest delay allowed
static const NSUInteger PRELOAD_BUFFER = 1; // small time buffer added to the load time before calculating the delay

@implementation OptimizedBannerAdManager

- (id)initWithDelegate:(id<MPBannerAdManagerDelegate>)delegate {
    if (self = [super initWithDelegate:delegate]) {
        [self initLoadTimes];
        self.viewStart = [NSDate distantPast];
    }
    
    return self;
}

- (void)scheduleRefreshTimer {
    // we'll handle all refreshing
}

// Convenience method to get at parent method so any subclasses
// can avoid runtime inspection to get at it.
- (void)superPresentRequestingAdapter {
    [super presentRequestingAdapter];
}

- (void)presentRequestingAdapter {
    [self processLoadTime];
    
    // let's make sure that we've displayed the ad for the configured
    // time before swapping in the new ad
    NSTimeInterval targetTime = [self getTargetDisplayTime];
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:self.viewStart];
    NSTimeInterval delta = targetTime - elapsedTime;
    
    // if we haven't displayed the ad for the full duration wait to swap the ad
    if (delta > 0) {
        [self performSelector:@selector(swapAd) withObject:self afterDelay:delta];
    } else {
        [self swapAd];
    }
}

- (void)didFailToLoadAdapterWithError:(NSError *)error {
    // if the communicator failed to retrieve an ad retry again after
    // the configured interval
    [self performSelector:@selector(loadAd) withObject:self afterDelay:LOAD_ERROR_REFRESH_INTERVAL];
}

- (void)swapAd {
    // use the base impl of presentRequestingAdapter to swap out the displayed
    // ad with the most recently retrieved ad
    [super presentRequestingAdapter];
    
    NSTimeInterval delay = [self getLoadDelay];
    [self performSelector:@selector(loadAd) withObject:self afterDelay:delay];
    
    if (![self.viewStart isEqualToDate:[NSDate distantPast]]) {
        NSLog(@"SHOWING AD %f", [[NSDate date] timeIntervalSinceDate:self.viewStart]);
    }

    self.viewStart = [NSDate date];
}

- (void)loadAd {
    self.loadStart = [NSDate date];
    
    MPAdTargeting * targeting = [[MPAdTargeting alloc] init];
    targeting.keywords = self.banner.keywords;
    targeting.localExtras = self.banner.localExtras;
    targeting.location = self.banner.location;
    targeting.userDataKeywords = self.banner.userDataKeywords;
    [super loadAdWithTargeting:targeting];

//    [[ZAnalytics sharedManager] trackBannerRequested];
}

- (NSTimeInterval)getLoadDelay {
    NSTimeInterval delay = 0;
    NSUInteger denom = pow(2, LOAD_TIME_HISTORY_COUNT);
    
    // calculate the power of 2 based weighted average from the history
    // of load times
    for (int i = 0; i < self.loadTimes.count; i++) {
        NSNumber *value = [self.loadTimes objectAtIndex:i];
        float mod = (pow(2, LOAD_TIME_HISTORY_COUNT - (i + 1)) / denom);
        delay += value.doubleValue * mod;
    }
    
    return MAX(MINIMUM_PRELOAD_DELAY, [self getTargetDisplayTime] - delay - PRELOAD_BUFFER);
}

- (NSTimeInterval)getTargetDisplayTime {
    return self.requestingConfiguration ? self.requestingConfiguration.refreshInterval : DEFAULT_REFRESH_INTERVAL;
}

- (void)processLoadTime {
    // remove the oldest load time record and add in the newly calculated one
    NSDate *end = [NSDate date];
    NSTimeInterval loadTime = [end timeIntervalSinceDate:self.loadStart];
    if (self.loadTimes.count > 0) {
        [self.loadTimes removeLastObject];
    }
    [self.loadTimes insertObject:@(loadTime) atIndex:0];
}

- (void)initLoadTimes {
    self.loadTimes = [NSMutableArray array];
    
    // preload with typical load times to compensate for an occasionally
    // longer initial load time
    for (int i = 0; i < LOAD_TIME_HISTORY_COUNT; i++) {
        [self.loadTimes addObject:@(TYPICAL_LOAD_TIME)];
    }
}

@end
