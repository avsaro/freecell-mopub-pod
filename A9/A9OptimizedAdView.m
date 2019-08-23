//
//  OptimizedAdView.m
//  Solitaire
//
//  Created by Corey O'Neil on 6/20/17.
//  Copyright © 2017 Zynga, Inc. All rights reserved.
//

#import "A9OptimizedAdView.h"
#import "OptimizedAdView.h"
#import "A9OptimizedBannerAdManager.h"
#import "MPBannerAdManagerDelegate.h"
#import "DTBAdWatcher.h"

// provides access to base class private members
@interface OptimizedAdView () <MPBannerAdManagerDelegate>

@property (nonatomic, strong) MPBannerAdManager *adManager;

@end


@implementation A9OptimizedAdView

- (id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size watcher:(DTBAdWatcher *)watcher {
    if (self = [super initWithAdUnitId:adUnitId size:size]) {
        self.adManager = [[A9OptimizedBannerAdManager alloc] initWithDelegate:self andWatcher:watcher];
    }
    
    return self;
}

@end
