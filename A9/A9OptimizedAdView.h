//
//  A9OptimizedAdView.h
//  Solitaire
//
//  Created by Corey O'Neil on 6/21/17.
//  Copyright © 2017 Zynga, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OptimizedAdView.h"
#import "DTBAdWatcher.h"

@interface A9OptimizedAdView : OptimizedAdView
- (id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size watcher:(DTBAdWatcher *)watcher;
@end
