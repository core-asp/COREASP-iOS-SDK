//
//  AppDelegate.h
//  CorePushSample
//
//  Copyright (c) 2017 株式会社ブレスサービス. All rights reserved.
//

@import COREASP;
@import UserNotifications;

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CorePushManagerDelegate, UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController* tabBarController;

@end
