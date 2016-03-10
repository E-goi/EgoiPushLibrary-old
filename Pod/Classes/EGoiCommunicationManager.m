//
//  EGoiCommunicationManager.m
//  EGoiPushStaticLibrary
//
//  Created by Miguel Angelo on 29/09/14.
//  Copyright (c) 2014 E-Goi. All rights reserved.
//

#import "EGoiCommunicationManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <UIKit/UIKit.h>
#import "EGHelper.h"

@interface EGoiCommunicationManager ()

@property (strong, nonatomic) NSString *deviceID;

@end

@implementation EGoiCommunicationManager

#define kEgoiServerRegisterEndPoint @"https://push.e-goi.com/push/api/devices/%@"
#define kEgoiServerRegisterTwoStepsEndPoint @"https://push.e-goi.com/push/api/devices/%@?field=%@&value=%@"
#define kEgoiLogCancelEventsEndPoint @"https://push.e-goi.com/push/api/events/%@/cancel"
#define kEgoiLogClickEventsEndPoint @"https://push.e-goi.com/push/api/events/%@/click"
#define kEgoiLogOpenEventsEndPoint @"https://push.e-goi.com/push/api/events/%@/open"
#define kEgoiLogReceiveEventsEndPoint @"https://push.e-goi.com/push/api/events/%@/receive"

#pragma mark -
#pragma mark - Shared instance and initialization

static EGoiCommunicationManager *sharedManager = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance
{
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark -
#pragma mark - Application registered for remote notifications

- (void)applicationRegisteredDeviceForPushNotification
{
    if (0 == self.deviceToken.length)
    {
        [EGHelper log:@"ERROR: missing device token. The register failed."];
        return;
    }
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSUUID *UDID = [[UIDevice currentDevice] identifierForVendor];
    
    NSDictionary *jsonDic = @{
                              @"applicationId": self.appId,
                              @"token": self.deviceToken,
                              @"md5Token": [EGHelper MD5:self.deviceToken],
                              @"serial": UDID.UUIDString,
                              @"os": @"IOS",
                              @"version": [[UIDevice currentDevice] systemVersion],
                              @"brand": @"Apple",
                              @"model": self.deviceModel,
                              @"countryCode": [carrier mobileCountryCode] == nil ? @"" : [carrier mobileCountryCode],
                              @"networkCode": [carrier mobileNetworkCode] == nil ? @"" : [carrier mobileNetworkCode],
                              @"networkName": [carrier carrierName] == nil ? @"" : [carrier carrierName],
                              @"platform": @"iOS",
                              @"uid": UDID.UUIDString
                              };
    
    
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDic
                                                       options:kNilOptions
                                                         error:&error];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kEgoiServerRegisterEndPoint, self.clientId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               [self processResponse:data
                                               error:connectionError];
                               
                           }];
}

#pragma mark -
#pragma mark - Application registered for remote notifications in two steps

- (void)applicationRegisteredDeviceForPushNotificationInTwoSteps:(NSString *)field
                                                      fieldValue:(NSString *)value
{
    if (0 == self.deviceToken.length) {
        [EGHelper log:@"ERROR: missing device token. The procedure was interrupted."];
        return;
    }
    
    CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [netinfo subscriberCellularProvider];
    NSUUID *UDID = [[UIDevice currentDevice] identifierForVendor];
    
    NSDictionary *jsonDic = @{
                              @"applicationId": self.appId,
                              @"token": self.deviceToken,
                              @"md5Token": [EGHelper MD5:self.deviceToken],
                              @"serial": UDID.UUIDString,
                              @"os": @"IOS",
                              @"version": [[UIDevice currentDevice] systemVersion],
                              @"brand": @"Apple",
                              @"model": self.deviceModel,
                              @"countryCode": [carrier mobileCountryCode] == nil ? @"" : [carrier mobileCountryCode],
                              @"networkCode": [carrier mobileNetworkCode] == nil ? @"" : [carrier mobileNetworkCode],
                              @"networkName": [carrier carrierName] == nil ? @"" : [carrier carrierName],
                              @"platform": @"iOS",
                              @"uid": UDID.UUIDString
                              };
    
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:jsonDic
                                                       options:kNilOptions
                                                         error:&error];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kEgoiServerRegisterTwoStepsEndPoint, self.clientId, field, value]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               [self processResponse:data
                                               error:connectionError];
                               
                           }];
}

#pragma mark -
#pragma mark - Application failed to register device

- (void)applicationFailedToRegisterDevice:(NSError *)error
{

}

#pragma mark -
#pragma mark - Received push notifications

- (void)applicationReceivedPushNotification:(NSString *)messageID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kEgoiLogReceiveEventsEndPoint, self.clientId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self getLogDictionaryData:messageID]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               [self processResponse:data
                                               error:connectionError];
                           }];
}

#pragma mark -
#pragma mark - Track user actions

- (void)userDidOpenPushNotification:(NSString *)messageID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kEgoiLogOpenEventsEndPoint, self.clientId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self getLogDictionaryData:messageID]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               [self processResponse:data
                                               error:connectionError];
                           }];
}

#pragma mark -
#pragma mark - User dismissed the AlertView

- (void)userDismissedPushNotification:(NSString *)messageID
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:kEgoiLogCancelEventsEndPoint, self.clientId]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self getLogDictionaryData:messageID]];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               
                               [self processResponse:data
                                               error:connectionError];
                           }];
}

#pragma mark -
#pragma mark - Log dictionary

- (NSData *)getLogDictionaryData:(NSString *)messageID
{
    NSDictionary *dic = @{
                          @"messageId": messageID,
                          @"deviceId": self.deviceID,
                          @"applicationId": self.appId,
                          @"latitude": [NSNumber numberWithFloat:[self.latitude floatValue]],
                          @"longitude": [NSNumber numberWithFloat:[self.longitude floatValue]]
                          };
    
    
    NSError *error;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:dic options:kNilOptions error:&error];
    
    if (error) {
        [EGHelper log:@"Error creating the body data."];
        return nil;
    } else {
        return bodyData;
    }
}

#pragma mark -
#pragma mark - Handle response

- (void)processResponse:(NSData *)data
                  error:(NSError *)connectionError
{
    if (connectionError) {
        [EGHelper log:@"Failed to register event."];
    } else {
        if (data) {
            NSError *errorResponse;
            NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:kNilOptions
                                                                           error:&errorResponse];
            
            if (responseJSON) {
                if ([responseJSON objectForKey:@"deviceId"]) {
                    self.deviceID = [responseJSON objectForKey:@"deviceId"];
                    [EGHelper log:@"Device registered"];
                }
            }
        } else {
            [EGHelper log:@"Event not registered"];
        }
    }
}

@end
