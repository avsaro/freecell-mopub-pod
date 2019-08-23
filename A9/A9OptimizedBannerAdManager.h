//
//  A9OptimizedBannerAdManager.h
//  Solitaire
//
//  Created by Corey O'Neil on 6/13/17.
//  Copyright © 2017 Zynga, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OptimizedBannerAdManager.h"
#import "DTBAdWatcher.h"

@interface A9OptimizedBannerAdManager : OptimizedBannerAdManager
- (id)initWithDelegate:(id<MPBannerAdManagerDelegate>)delegate andWatcher:(DTBAdWatcher *)watcher;
@end
