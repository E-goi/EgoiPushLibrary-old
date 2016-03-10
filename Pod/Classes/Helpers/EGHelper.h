//
//  EGHelper.h
//  EGoiPushStaticLibrary
//
//  Created by Miguel Chaves on 23/06/15.
//  Copyright (c) 2015 E-Goi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EGHelper : NSObject

/**
 *  Get the platform type
 */
+ (NSString *)platformType:(NSString *)platform;

/**
 *  Log in the console
 */
+ (void)log:(NSString *)input;

/**
 *  Get the phone IP
 */
+ (NSString *)getIP;

/**
 *  Transform to MD5
 */
+ (NSString*)MD5:(NSString *)input;

@end
