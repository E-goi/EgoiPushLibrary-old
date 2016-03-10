//
//  EGoiAlertViewHandler.m
//  EGoiPushStaticLibrary
//
//  Created by Miguel Chaves on 06/10/14.
//  Copyright (c) 2014 E-Goi. All rights reserved.
//

#import "EGoiAlertViewHandler.h"
#import "EGoiCommunicationManager.h"
#import "NSString+HTML.h"
#import "EGHelper.h"

@interface EGoiAlertViewHandler ()
<
    UIAlertViewDelegate,
    UIWebViewDelegate
>

@property (strong, nonatomic) UIApplication *backupReferenceApplication;
@property (strong, nonatomic) NSMutableArray *actionsArray;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UIWebView *mainWebView;
@property (strong, nonatomic) UIImageView *backImageView;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;
@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) NSString *mID;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIView *navigationView;
@property (strong, nonatomic) UILabel *navigationLabel;

@end

@implementation EGoiAlertViewHandler

#pragma mark -
#pragma mark - Shared instance

static EGoiAlertViewHandler *sharedInstance = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance
{
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark -
#pragma mark - Init components

- (void)initAlertViewWithDictionary:(NSDictionary *)dic
               presentInApplication:(UIApplication *)application
{
    self.backupReferenceApplication = application;
    self.actionsArray = [NSMutableArray new];
    
    NSString *alertTitle = @"";
    NSString *alertMessage = @"";
    
    if ([dic objectForKey:@"t"]) {
        alertTitle = [dic objectForKey:@"t"];
    } else {
        alertTitle = @"";
    }
    
    self.title = alertTitle;
    
    if ([dic objectForKey:@"aps"])
    {
        NSDictionary *aps = [dic objectForKey:@"aps"];
        
        if ([aps objectForKey:@"alert"]) {
            alertMessage = [aps objectForKey:@"alert"];
        } else {
            alertMessage = @"Message";
        }
    }
    else
    {
        alertMessage = @"Message";
    }
    
    // Get the IDs
    if ([dic objectForKey:@"mid"])
    {
        self.mID = [dic objectForKey:@"mid"];
    }
    else
    {
        self.mID = @"ERROR";
    }
    
    if ([dic objectForKey:@"al"])
    {
        if (![[[dic objectForKey:@"al"] decodeHTMLCharacterEntities] isEqualToString:@"undefined"])
        {
            [self.actionsArray addObject:[dic objectForKey:@"al"]];
        }
    }
    
    if (self.alertViewCloseButtonText) {
        self.alertViewCloseButtonText = @"Close";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:self.alertViewCloseButtonText
                                          otherButtonTitles:nil, nil];
    
    if ([dic objectForKey:@"at"])
    {
        if (![[dic objectForKey:@"at"] isKindOfClass:[NSNull class]])
        {
            if (![[[dic objectForKey:@"at"] decodeHTMLCharacterEntities] isEqualToString:@"undefined"])
            {
                @try {
                    NSString *correctString = [NSString stringWithCString:[[dic objectForKey:@"at"] cStringUsingEncoding:NSISOLatin1StringEncoding] encoding:NSUTF8StringEncoding];
                    
                    if (correctString) {
                        [alert addButtonWithTitle:correctString];
                    } else {
                        [alert addButtonWithTitle:[dic objectForKey:@"at"]];
                    }
                }
                @catch (NSException *exception) {
                    [EGHelper log:exception.reason];
                    [alert addButtonWithTitle:[dic objectForKey:@"at"]];
                }                
            }
        }
    }
    
    [alert show];
}

#pragma mark -
#pragma mark - Alertview delegates

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        [[EGoiCommunicationManager sharedInstance] userDidOpenPushNotification:self.mID];
        
        NSString *url = [self.actionsArray firstObject];
        
        [self initWebViewWithUrl:url];
    }
    else
    {
        [[EGoiCommunicationManager sharedInstance] userDismissedPushNotification:self.mID];
    }
}

#pragma mark -
#pragma mark - WebView

- (void)initWebViewWithUrl:(NSString *)stringUrl
{
    CGRect finalFrame = [[self.backupReferenceApplication delegate] window].rootViewController.view.frame;
    CGRect initialFrame = finalFrame;
    initialFrame.origin.y = initialFrame.size.height;
    
    self.contentView = [[UIView alloc] initWithFrame:finalFrame];
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleTopMargin;
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.alpha = 0.0f;
    
    self.navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 64)];
    self.navigationView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleTopMargin;
    self.navigationView.backgroundColor = self.defaultBackgroundColor == nil ? [UIColor whiteColor] : self.defaultBackgroundColor;
    self.navigationView.alpha = 0.0f;
    [self.contentView addSubview:self.navigationView];
    
    self.navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, self.contentView.frame.size.width - 70, 30)];
    self.navigationLabel.backgroundColor = [UIColor clearColor];
    self.navigationLabel.text = self.title;
    self.navigationLabel.textColor = self.defaultTextColor == nil ? [UIColor whiteColor] : self.defaultTextColor;
    
    if (self.defaultFont)
    {
        self.navigationLabel.font = self.defaultFont;
    }
    
    self.navigationLabel.alpha = 0.0f;
    [self.navigationView addSubview:self.navigationLabel];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    closeButton.frame = CGRectMake(self.contentView.frame.size.width - 70,
                                   25,
                                   65,
                                   30);
    
    closeButton.backgroundColor = [UIColor clearColor];
    [closeButton setTitleColor:[UIColor whiteColor]
                      forState:UIControlStateNormal];

    if (self.defaultFont)
    {
        [closeButton.titleLabel setFont:self.defaultFont];
    }
    
    NSString *closeTitle = @"";
    
    if (self.closeButtonText.length == 0)
    {
        closeTitle = @"Close";
    }
    else
    {
        closeTitle = self.closeButtonText;
    }
    
    [closeButton setTitle:closeTitle
                 forState:UIControlStateNormal];
    
    [closeButton addTarget:self
                    action:@selector(closeWebView)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationView addSubview:closeButton];
    
    self.mainWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, self.contentView.frame.size.width, self.contentView.frame.size.height - 64)];
    self.mainWebView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleTopMargin;
    self.mainWebView.delegate = self;
    self.mainWebView.backgroundColor = [UIColor whiteColor];
    self.mainWebView.alpha = 0.0f;
    
    [self.contentView addSubview:self.mainWebView];
    
    self.request = [NSURLRequest requestWithURL:[NSURL URLWithString:stringUrl]];
    [self.mainWebView loadRequest:self.request];
    [self initLoadingElements:self.contentView];
    
    [[[self.backupReferenceApplication delegate] window].rootViewController.view addSubview:self.contentView];
    
    [UIView animateWithDuration:1.5f
                     animations:^{
                         
                         self.contentView.alpha = 1.0f;
                         self.navigationView.alpha = 1.0f;
                         self.mainWebView.alpha = 1.0f;
                         self.navigationLabel.alpha = 1.0f;
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)initLoadingElements:(UIView *)view
{
    self.backImageView = [[UIImageView alloc] initWithFrame:view.frame];
    self.backImageView.userInteractionEnabled = YES;
    self.backImageView.backgroundColor = [UIColor blackColor];
    self.backImageView.alpha = 0.6f;
    
    [view addSubview:self.backImageView];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.center = view.center;
    [self.spinner startAnimating];
    
    [view addSubview:self.spinner];
}

- (void)removeLoadingScreen
{
    [UIView animateWithDuration:1.5f
                     animations:^{
                         
                         self.backImageView.alpha = 0.0f;
                         self.spinner.alpha = 0.0f;
                         
                     } completion:^(BOOL finished) {
                         
                         [self.backImageView removeFromSuperview];
                         [self.spinner removeFromSuperview];
                         
                     }];
}

#pragma mark -
#pragma mark - Webview delegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self removeLoadingScreen];
    [EGHelper log:@"EGoi Framework: Failed to load the requested URL."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self removeLoadingScreen];
    [EGHelper log:@"EGoi Framework: finished loading request."];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [EGHelper log:@"EGoi Framework: started loading request."];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

#pragma mark -
#pragma mark - Close button action

- (void)closeWebView
{
    [self removeLoadingScreen];
    
    CGRect finalFrame = self.contentView.frame;
    finalFrame.origin.y = finalFrame.size.height;
    
    [self.mainWebView stopLoading];
    [self.mainWebView setDelegate:nil];
    
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:self.request];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [UIView animateWithDuration:0.5f
                     animations:^{
                         
                         self.contentView.frame = finalFrame;
                         
                     } completion:^(BOOL finished) {
                         
                         [self.mainWebView removeFromSuperview];
                         [self.contentView removeFromSuperview];
                         
                     }];
}

@end
