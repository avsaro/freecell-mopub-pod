//
//  OptimizedBannerAdManager.h
//  Solitaire
//
//  Created by Ryan Schweter on 5/25/17.
//  Copyright © 2017 Zynga, Inc. All rights reserved.
//
//  This class is used to preload banner ads to minimize the delay in showing the new
//  ad once the previous ad has expired. We track historical load times in order to
//  get the ad load completed as close as possible to the time it should be displayed
//

#import "MPBannerAdManager.h"

@interface OptimizedBannerAdManager : MPBannerAdManager
@end
