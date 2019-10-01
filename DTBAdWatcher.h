//
//  DTBAdWatcher.h
//  FreeCell
//
//  Created by Corey O'Neil on 5/2/17.
//  Copyright © 2017 Zynga, Inc. All rights reserved.
//

#import <DTBiOSSDK/DTBiOSSDK.h>
#import <Foundation/Foundation.h>

@interface DTBAdWatcher : NSObject <DTBAdCallback>
- (instancetype) initWithLoader:(DTBAdLoader *)loader andLoadAdSelector:(SEL)callback withObject:(id)object;
- (instancetype) initForReusableLoader:(DTBAdSize*)adSize andLoadAdSelector:(SEL)callback withObject:(id)object;
- (NSString*)getKeywords;
- (void) loadAd;
- (NSTimeInterval) getLoadDelay;
- (void) destroy;
@end
