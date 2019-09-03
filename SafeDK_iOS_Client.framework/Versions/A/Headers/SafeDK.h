//
//  SafeDK.h
//  SafeDK_iOS_Client
//
//  Copyright © 2018 SafeDK. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum SafeDK_Region
{
    SAFEDK_REGION_AFRICA,
    SAFEDK_REGION_ANTARCTICA,
    SAFEDK_REGION_ASIA,
    SAFEDK_REGION_EUROPE,
    SAFEDK_REGION_NORTH_AMERICA,
    SAFEDK_REGION_OCEANIA,
    SAFEDK_REGION_SOUTH_AMERICA,
} SafeDK_Region;

@interface SafeDK : NSObject

+(NSString*)getUserId;
+(void)enable;
+(void)disable;
+(void)setAge:(int)age;
+(void)setRegion:(SafeDK_Region)region;
+(void)resetUserID;

@end
