//
//  A9OptimizedBannerAdManager.m
//  Solitaire
//
//  Created by Corey O'Neil on 6/13/17.
//  Copyright © 2017 Zynga, Inc. All rights reserved.
//

#import "A9OptimizedBannerAdManager.h"
#import "DTBAdWatcher.h"
#import "MPAdTargeting.h"

// provides access to base class private members
@interface OptimizedBannerAdManager ()

- (void)superPresentRequestingAdapter;
- (NSTimeInterval)getLoadDelay;
@property (nonatomic, retain) NSDate *viewStart;

@end

@interface A9OptimizedBannerAdManager ()

@property (nonatomic, retain) DTBAdWatcher *watcher;
@property (nonatomic, retain) NSDate *a9Start;

@end

@implementation A9OptimizedBannerAdManager
- (id)initWithDelegate:(id<MPBannerAdManagerDelegate>)delegate andWatcher:(DTBAdWatcher *)watcher {
    if (self = [super initWithDelegate:delegate]) {
        self.watcher = watcher;
        self.a9Start = [NSDate distantPast];
    }
    return self;
}

- (void)swapAd {
    // use the base impl of presentRequestingAdapter to swap out the displayed
    // ad with the most recently retrieved ad. This is the grandparent impl and
    // a convenience method exists in the parent to accdess it.
    [super superPresentRequestingAdapter];
    
    self.viewStart = [NSDate date];
    
    [self.watcher loadAd];
    self.a9Start = [NSDate date];
}

- (void)loadAd {
    // This method is hijacked to account for A9 delay in addition to banner load delay
    // prior to loading the actual ad.
    NSDate *end = [NSDate date];
    NSTimeInterval a9LoadTime = [end timeIntervalSinceDate:self.a9Start];
    NSTimeInterval delay = [self getLoadDelay];
    delay = MAX(0, delay - a9LoadTime);
    
    if (delay > 0) {
        [self performSelector:@selector(loadAdActual) withObject:self afterDelay:delay];
    } else {
        [self loadAdActual];
    }
    
    if (![self.viewStart isEqualToDate:[NSDate distantPast]]) {
        NSLog(@"SHOWING AD %f", [[NSDate date] timeIntervalSinceDate:self.viewStart]);
    }
}

- (void)loadAdActual {
    MPAdTargeting * targeting = [[MPAdTargeting alloc] init];
    targeting.keywords = self.banner.keywords;
    targeting.localExtras = self.banner.localExtras;
    targeting.location = self.banner.location;
    targeting.userDataKeywords = self.banner.userDataKeywords;
    
    [super loadAdWithTargeting:targeting];
}
@end
