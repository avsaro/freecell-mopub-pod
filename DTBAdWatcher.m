//
//  DTBAdWatcher.m
//  FreeCell
//  Responsible for tracking A9 ad bids from Amazon and updating MoPub
//
//  Created by Corey O'Neil on 5/2/17.
//  Copyright © 2017 Zynga, Inc. All rights reserved.
//

#import "DTBAdWatcher.h"

@interface DTBAdWatcher() {}
@property DTBAdLoader *adLoader;
@property NSString *keywords;
@property id callbackOwner;
@property SEL callback;
@property (nonatomic, retain) NSMutableArray *loadTimes;
@property (nonatomic, retain) NSDate *loadStart;
@property (nonatomic, retain) DTBAdSize *adSize;
@property (nonatomic) BOOL reuse;
@end

static const NSUInteger LOAD_TIME_HISTORY_COUNT = 5; // how many historical values we want to retain to calculate the next load delay
static const NSUInteger TYPICAL_LOAD_TIME = 1; // used to preload the historical data
static const NSUInteger MINIMUM_PRELOAD_DELAY = 1; // shortest delay allowed


@implementation DTBAdWatcher

- (instancetype) initForReusableLoader:(DTBAdSize*)adSize andLoadAdSelector:(SEL)callback withObject:(id)object {
    if (self = [super init]) {
        self.reuse = true;
        self.adSize = adSize;
        [self refreshAdLoader];
        
        self.callback = callback;
        self.callbackOwner = object;
        
        [self initLoadTimes];
        
        [self loadAd];
    }
    
    return self;
}

- (instancetype) initWithLoader:(DTBAdLoader *)loader andLoadAdSelector:(SEL)callback withObject:(id)object {
    if (self = [super init]) {
        self.adLoader = loader;
        self.callback = callback;
        self.callbackOwner = object;
        
        [self initLoadTimes];
        
        [self loadAd];
    }
    
    return self;
}

- (void) initLoadTimes {
    self.loadTimes = [NSMutableArray array];
    
    for (int i = 0; i < LOAD_TIME_HISTORY_COUNT; i++) {
        [self.loadTimes addObject:@(TYPICAL_LOAD_TIME)];
    }
}

- (void) refreshAdLoader {
    if (self.reuse) {
        self.adLoader = [DTBAdLoader new];
        [self.adLoader setSizes:self.adSize, nil];
    }
}

- (NSTimeInterval) getLoadDelay {
    NSTimeInterval delay = 0;
    NSUInteger denom = pow(2, LOAD_TIME_HISTORY_COUNT);
    
    // calculate the power of 2 based weighted average from the history
    // of load times
    for (int i = 0; i < self.loadTimes.count; i++) {
        NSNumber *value = [self.loadTimes objectAtIndex:i];
        float mod = (pow(2, LOAD_TIME_HISTORY_COUNT - (i + 1)) / denom);
        delay += value.doubleValue * mod;
    }
    
    return MAX(MINIMUM_PRELOAD_DELAY, delay);
}

- (void) loadAd {
    self.loadStart = [NSDate date];
    [self.adLoader loadAd:self];
}

- (void) destroy {
    if (self.adLoader) {
        [self.adLoader stop];
        self.adLoader = nil;
    }
}

- (NSString*) getKeywords {
    return self.keywords;
}

#pragma mark DTBAdCallback
- (void)onFailure: (DTBAdError)error {
    [self processLoadTime];
    self.keywords = nil;
    [self refreshAdLoader];
    [self.callbackOwner performSelector:self.callback withObject:self];
}

- (void)onSuccess: (DTBAdResponse *)adResponse {
    [self processLoadTime];
    self.keywords = adResponse.keywordsForMopub;
    [self refreshAdLoader];
    [self.callbackOwner performSelector:self.callback withObject:self];
}
#pragma mark -

- (void)processLoadTime {
    NSDate *end = [NSDate date];
    NSTimeInterval loadTime = [end timeIntervalSinceDate:self.loadStart];
    if (self.loadTimes.count > 0) {
        [self.loadTimes removeLastObject];
    }
    [self.loadTimes insertObject:@(loadTime) atIndex:0];
}
@end
