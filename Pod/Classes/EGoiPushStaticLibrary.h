//
//  EGoiPushStaticLibrary.h
//  EGoiPushStaticLibrary
//
//  Created by Miguel Chaves on 06/07/15.
//  Copyright (c) 2015 E-Goi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EGoiPushStaticLibrary : NSObject

/**
 *  Enable or disable the log system. Default is NO
 */
@property (assign, nonatomic) BOOL logActive;

/**
 *  The client number given by the E-goi
 */
@property (strong, nonatomic) NSString *clientId;

/**
 *  The application ID obtained in the E-goi platform
 */
@property (strong, nonatomic) NSString *applicationId;

/**
 *  Indicates if the registration of the device is made in two steps.
 *
 *  Normal registration only stores the device token, two steps registration
 *  also registers an value related to one field (ex: email or phone)
 */
@property (assign, nonatomic) BOOL isTwoStepRegistration;

/**
 *  The field to use in the two step registration process.
 */
@property (strong, nonatomic) NSString *twoStepRegistrationFieldName;

/**
 * Use this options to costumize the navigation bar when the user opens the Push Notification
 */
@property (strong, nonatomic) UIColor *defaultBackgroundColor;
@property (strong, nonatomic) UIColor *defaultTextColor;
@property (strong, nonatomic) UIFont *defaultFont;
@property (strong, nonatomic) NSString *closeButtonText;
@property (strong, nonatomic) NSString *alertViewCloseButtonText;

/**
 *  Method to get the shared instance of EGoiPushStaticLibrary
 *
 *  @return the create instance
 */
+ (instancetype)sharedInstance;

/**
 *  Called when the app finish launching
 *
 *  @param the launching options
 *  @param the application launched
 */
- (void)didFinishLaunchingWithOptions:(NSDictionary *)options
                        inApplication:(UIApplication *)application;

/**
 *  Register the device in two steps and save the state of the operation
 *
 *  @param the message title
 *  @param the message to display to the user
 *  @param the text for the "yes" button
 *  @param the text for the "no" button
 */
- (void)registerDeviceInTwoStepsWithTitle:(NSString *)title
                               andMessage:(NSString *)message
                           positiveAnswer:(NSString *)yesMessage
                          negativeMessage:(NSString *)noMessage;

/**
 *  Register the device in two steps without the alertview
 *
 *  @param the value for the registration
 */
- (void)registerDeviceInTwoStepsWithFieldValue:(NSString *)value;

/**
 *  Called when the app did registered the device for push notifications with success
 *
 *  @param the device token
 */
- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 *  Called when the app did fail to register the device for push notifications
 *
 *  @param the returned error
 */
- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/**
 *  Called when the app receive a push notification
 *
 *  @param the push notification dictionary
 *  @param the application where will be oppened the banner/web view
 */
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
                       inApplication:(UIApplication *)application;

@end
