//
//  OptimizedAdView.m
//  Solitaire
//
//  Created by Ryan Schweter on 5/25/17.
//  Copyright © 2017 Zynga, Inc. All rights reserved.
//

#import "OptimizedAdView.h"
#import "OptimizedBannerAdManager.h"
#import "MPBannerAdManagerDelegate.h"

// provides access to base class private members
@interface MPAdView () <MPBannerAdManagerDelegate>

@property (nonatomic, strong) MPBannerAdManager *adManager;

@end


@implementation OptimizedAdView

- (id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size {
    if (self = [super initWithAdUnitId:adUnitId size:size]) {
        self.adManager = [[OptimizedBannerAdManager alloc] initWithDelegate:self];
    }
    
    return self;
}

@end
