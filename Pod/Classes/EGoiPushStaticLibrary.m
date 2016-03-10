//
//  EGoiPushStaticLibrary.m
//  EGoiPushStaticLibrary
//
//  Created by Miguel Angelo on 29/09/14.
//  Copyright (c) 2014 E-Goi. All rights reserved.
//

#import <sys/utsname.h>
#import <sys/sysctl.h>
#import "EGoiPushStaticLibrary.h"
#import "EGoiCommunicationManager.h"
#import "EGoiAlertViewHandler.h"
#import <CoreLocation/CoreLocation.h>
#import "EGHelper.h"

@interface EGoiPushStaticLibrary ()
<
    CLLocationManagerDelegate,
    UIAlertViewDelegate
>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIAlertView *twoStepsAlertView;
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSString *iOSplafform;

@end

@implementation EGoiPushStaticLibrary

#pragma mark -
#pragma mark - Shared instance and initialization

static EGoiPushStaticLibrary *sharedMyManager = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance
{
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    
    return sharedMyManager;
}

#pragma mark -
#pragma mark - Application finished launching

- (void)didFinishLaunchingWithOptions:(NSDictionary *)options
                        inApplication:(UIApplication *)application
{
    if (0 == self.clientId.length)
    {
        [EGHelper log:@"ERROR: Missing client ID. The E-goi framework is disabled!"];
        return;
    }
        
    // Init the location engine
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    [EGoiCommunicationManager sharedInstance].latitude = @"";
    [EGoiCommunicationManager sharedInstance].longitude = @"";
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
    [self setDevicePlatform];

    // Catch launch from notification
    if (options)
    {
        NSDictionary *userInfo = [options valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
        
        if (apsInfo)
        {
            NSDictionary *tempDic = @{
                                      @"aps": userInfo,
                                      @"app": application };
            
            [NSTimer scheduledTimerWithTimeInterval:1.8f
                                             target:self
                                           selector:@selector(fireTimer:)
                                           userInfo:tempDic
                                            repeats:NO];
        }
    }
}

- (void)fireTimer:(NSTimer *)timer
{
    NSDictionary *temp = timer.userInfo;
    
    [self didReceiveRemoteNotification:[temp objectForKey:@"aps"]
                         inApplication:[temp objectForKey:@"app"]];
}

#pragma mark -
#pragma mark - Register for remote notification

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (0 == self.clientId.length)
    {
        [EGHelper log:@"ERROR: Missing client ID. The E-goi framework is disabled!"];
        return;
    }
    
    [EGHelper log:@"Aplication registered for remote notification with success. Will register now in E-Goi server."];
    
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *deviceId = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    
    NSString *iOSVersion = [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]];
    
    [EGoiCommunicationManager sharedInstance].appId = self.applicationId;
    [EGoiCommunicationManager sharedInstance].clientId = self.clientId;
    [EGoiCommunicationManager sharedInstance].deviceToken = deviceId;
    [EGoiCommunicationManager sharedInstance].logActive = self.logActive;
    [EGoiCommunicationManager sharedInstance].iOSversion = iOSVersion;
    [EGoiCommunicationManager sharedInstance].deviceModel = self.iOSplafform;
    
    if (self.isTwoStepRegistration)
    {
        self.token = deviceId;
    }
    else
    {        
        [[EGoiCommunicationManager sharedInstance] applicationRegisteredDeviceForPushNotification];
    }
}

#pragma mark -
#pragma mark - Registration in two steps

- (void)registerDeviceInTwoStepsWithTitle:(NSString *)title
                               andMessage:(NSString *)message
                           positiveAnswer:(NSString *)yesMessage
                          negativeMessage:(NSString *)noMessage
{
    if (self.isTwoStepRegistration)
    {
        self.twoStepsAlertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:noMessage
                                                  otherButtonTitles:yesMessage, nil];
        
        self.twoStepsAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [self.twoStepsAlertView show];
    }
}

#pragma mark -
#pragma mark - Alertview delegate (two steps registration)

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        
        NSString *fieldValue = [alertView textFieldAtIndex:0].text;
        
        if (fieldValue.length == 0)
        {
            [[EGoiCommunicationManager sharedInstance] applicationRegisteredDeviceForPushNotification];
        }
        else
        {
            [[EGoiCommunicationManager sharedInstance] applicationRegisteredDeviceForPushNotificationInTwoSteps:self.twoStepRegistrationFieldName fieldValue:fieldValue];
        }
    }
    else
    {
        [[EGoiCommunicationManager sharedInstance] applicationRegisteredDeviceForPushNotification];
    }
}

#pragma mark -
#pragma mark - Failed to register for remote notification

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (0 == self.clientId.length)
    {
        [EGHelper log:@"ERROR: Missing client ID. The E-goi framework is disabled!"];
        return;
    }
    
    [EGHelper log:@"Application failed to register for push notification."];
    
    [EGoiCommunicationManager sharedInstance].appId = self.applicationId;
    [EGoiCommunicationManager sharedInstance].clientId = self.clientId;
    [EGoiCommunicationManager sharedInstance].logActive = self.logActive;
    [EGoiCommunicationManager sharedInstance].iOSversion = [NSString stringWithFormat:@"iOS %@", [[UIDevice currentDevice] systemVersion]];
    [EGoiCommunicationManager sharedInstance].deviceModel = self.iOSplafform;
    
    [[EGoiCommunicationManager sharedInstance] applicationFailedToRegisterDevice:error];
}

#pragma mark -
#pragma mark - Application received push notification

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo
                       inApplication:(UIApplication *)application
{
    if (0 == self.clientId.length)
    {
        [EGHelper log:@"ERROR: Missing client ID. The E-goi framework is disabled!"];
        return;
    }
    
    [EGHelper log:@"Received push notification"];
    
    application.applicationIconBadgeNumber = 0;

    NSString *mid;
    
    if ([userInfo objectForKey:@"mid"]) {
        mid = [userInfo objectForKey:@"mid"];
    } else {
        mid = @"0";
    }
    
    [[EGoiCommunicationManager sharedInstance] applicationReceivedPushNotification:mid];
    
    [EGoiAlertViewHandler sharedInstance].logActive = self.logActive;
    [EGoiAlertViewHandler sharedInstance].defaultBackgroundColor = self.defaultBackgroundColor;
    [EGoiAlertViewHandler sharedInstance].defaultTextColor = self.defaultTextColor;
    [EGoiAlertViewHandler sharedInstance].defaultFont = self.defaultFont;
    [EGoiAlertViewHandler sharedInstance].closeButtonText = self.closeButtonText;
    [EGoiAlertViewHandler sharedInstance].alertViewCloseButtonText = self.alertViewCloseButtonText;
    
    [[EGoiAlertViewHandler sharedInstance] initAlertViewWithDictionary:userInfo
                                                  presentInApplication:application];
}

#pragma mark -
#pragma mark - Location manager delegates

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [EGHelper log:@"Location system: changed authorization status."];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    [EGoiCommunicationManager sharedInstance].latitude = @"";
    [EGoiCommunicationManager sharedInstance].longitude = @"";
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [self.locationManager stopUpdatingLocation];
    
    CLLocation *location = [locations firstObject];
    [EGoiCommunicationManager sharedInstance].latitude = [NSString stringWithFormat:@"%f", location.coordinate.latitude];
    [EGoiCommunicationManager sharedInstance].longitude = [NSString stringWithFormat:@"%f", location.coordinate.longitude];
}

#pragma mark -
#pragma mark - Aux methods

- (void)setDevicePlatform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    self.iOSplafform = [EGHelper platformType:platform];
    
    free(machine);
}

@end
