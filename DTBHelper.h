//
//  DTBHelper.h
//  freecell-mopub-pod
//
//  Created by Onur Avsar on 1.10.2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DTBHelper : NSObject

+ (DTBHelper *)sharedHelper;

- (void)requestDTBBannerKeywordsForLeaderboard:(bool)isLeaderboard withAdId:(NSString *)adId;
- (void)requestDTBInterstitialKeywordsWithAdId:(NSString *)adId andVideoAdId:(NSString *)videoAdId;

@end

NS_ASSUME_NONNULL_END
