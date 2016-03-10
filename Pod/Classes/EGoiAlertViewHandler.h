//
//  EGoiAlertViewHandler.h
//  EGoiPushStaticLibrary
//
//  Created by Miguel Chaves on 06/10/14.
//  Copyright (c) 2014 E-Goi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EGoiAlertViewHandler : NSObject

/**
 *  Enable or disable the log system
 */
@property (assign, nonatomic) BOOL logActive;

/**
 * Costumize elements
 */
@property (strong, nonatomic) UIColor *defaultBackgroundColor;
@property (strong, nonatomic) UIColor *defaultTextColor;
@property (strong, nonatomic) UIFont *defaultFont;
@property (strong, nonatomic) NSString *closeButtonText;
@property (strong, nonatomic) NSString *alertViewCloseButtonText;

/**
 *  Get the shared instance of EGoiAlertViewHandler
 *
 *  @return the create instance
 */
+ (instancetype)sharedInstance;

/**
 *  Init an Alert View and present it to the user
 *
 *  @param the dic that have the parameters to build the Alert View
 *  @param the application in execution
 */
- (void)initAlertViewWithDictionary:(NSDictionary *)dic
               presentInApplication:(UIApplication *)application;

@end
