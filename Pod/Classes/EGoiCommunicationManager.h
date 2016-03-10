//
//  EGoiCommunicationManager.h
//  EGoiPushStaticLibrary
//
//  Created by Miguel Angelo on 29/09/14.
//  Copyright (c) 2014 E-Goi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EGoiCommunicationManager : NSObject

/**
 *  Enable or disable the log system
 */
@property (assign, nonatomic) BOOL logActive;

/**
 *  The device token in use
 */
@property (strong, nonatomic) NSString *deviceToken;

/**
 *  The cliente ID
 */
@property (strong, nonatomic) NSString *clientId;

/**
 *  The app ID
 */
@property (strong, nonatomic) NSString *appId;

/**
 *  The version of the iOS in use
 */
@property (strong, nonatomic) NSString *iOSversion;

/**
 *  The device model
 */
@property (strong, nonatomic) NSString *deviceModel;

/**
 *  The actual latitude
 */
@property (strong, nonatomic) NSString *latitude;

/**
 *  The actual longitude
 */
@property (strong, nonatomic) NSString *longitude;

/**
 *  Method to get the shared instance of EGoiCommunicationManager
 *
 *  @return the create instance
 */
+ (instancetype)sharedInstance;

/**
 *  This method sends to E-goi servers the device Id that registered for push notification
 *  with success
 */
- (void)applicationRegisteredDeviceForPushNotification;

/**
 *  This method sends to E-goi servers the device Id that registered for push notification
 *  with success. This is the registration in two steps
 *
 *  @param the field to use
 *  @param the value to the field
 */
- (void)applicationRegisteredDeviceForPushNotificationInTwoSteps:(NSString *)field
                                                      fieldValue:(NSString *)value;

/**
 *  This method sends to E-goi information about the error obtained when registering device for
 *  remote notifications
 *
 *  @param the generated error
 */
- (void)applicationFailedToRegisterDevice:(NSError *)error;

/**
 *  This method is called when the app receives the push (Without user interaction)
 *
 *  @param the message id
 */
- (void)applicationReceivedPushNotification:(NSString *)messageID;
;

/**
 *  This method is called when the user open the received push notification
 *
 *  @param the message id
 */
- (void)userDidOpenPushNotification:(NSString *)messageID;

/**
 *  This method is called when the user dismiss a push notification
 *
 *  @param the message id
 */
- (void)userDismissedPushNotification:(NSString *)messageID;

@end
