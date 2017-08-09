//
//  AppDelegate.m
//  CorePushSample
//
//  Copyright (c) 2017 株式会社ブレスサービス. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "NotificationHistoryViewController.h"

//*********************************************************************************************
// 通知のコンフィグキーの設定
//*********************************************************************************************

#define CONFIG_KEY @"XXXXXXXXXXXXXXXXXXXXXXXXXXXX"

@implementation AppDelegate

// アプリの起動時に呼ばれる。
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    //プッシュ通知のON•OFFを設定するビューコントローラを作成
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    ViewController* view1Ctrl = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    view1Ctrl.delegate = self;
    
    //通知履歴画面のビューコントローラを作成
    NotificationHistoryViewController* view2Ctrl = [[NotificationHistoryViewController alloc] initWithNibName:@"NotificationHistoryViewController" bundle:nil];
    
    //タブバーコントローラを作成
    UINavigationController* nav1Ctrl = [[UINavigationController alloc] initWithRootViewController:view1Ctrl];
    UINavigationController* nav2Ctrl = [[UINavigationController alloc] initWithRootViewController:view2Ctrl];
    self.tabBarController = [[UITabBarController alloc] init];
    NSArray* viewControllers = [NSArray arrayWithObjects:nav1Ctrl,nav2Ctrl,nil];
    [self.tabBarController setViewControllers:viewControllers];
    
    self.window.rootViewController = self.tabBarController;
    
    // サーバのレスポンスデータを格納するオブジェクトを作成
    [self.window makeKeyAndVisible];
    
    //*********************************************************************************************
    // CorePushManagerクラスの初期化
    //*********************************************************************************************
    CoreAspManager.shared.debugEnabled = YES; // デバッグログを有効化
    CorePushManager.shared.configKey = CONFIG_KEY; // コンフィグキーの設定
    CorePushManager.shared.delegate = self; // CorePushManagerDelegateの設定
    [CorePushManager.shared registerForRemoteNotifications]; // 通知の登録
    
    // iOS10以上の場合の通知のデリゲート設定
    if ([[[UIDevice currentDevice] systemVersion] compare:@"10.0" options:NSNumericSearch] != NSOrderedAscending) {
        UNUserNotificationCenter.currentNotificationCenter.delegate = self;
    }
    
    //*********************************************************************************************
    // アプリのプロセスが起動していない状態で通知からアプリを起動した時の処理を定義する。
    // launchOptionsに通知のUserInfoが存在する場合は、CorePushManagerDelegate#handleLaunchingNotificationを
    // 呼び出し、存在しない場合は何も行わない。
    //*********************************************************************************************
    [CorePushManager.shared handleLaunchingNotificationWithOption:launchOptions];
    
    //*********************************************************************************************
    // アイコンバッジ数をリセットする
    //*********************************************************************************************
    [CorePushManager resetApplicationIconBadgeNumber];
    
    //    // アプリ内のユーザーIDの設定
    //    [CorePushManager.shared setAppUserId:@"username"];
    
    return YES;
}

// 通知サービスの登録成功時に呼ばれる。
- (void) application:(UIApplication*) application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"---- application:didRegisterForRemoteNotificationsWithDeviceToken ----");
    //*********************************************************************************************
    // APNSの通知登録の成功時に呼び出される。デバイストークンをcore-aspサーバに登録する。
    //*********************************************************************************************
    [CorePushManager.shared registerDeviceToken:deviceToken];
}

// 通知サービスの登録失敗時に呼ばれる。
- (void) application:(UIApplication*) application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"---- application:didFailToRegisterForRemoteNotificationsWithError ----");
    //*********************************************************************************************
    // APNSの通知登録の失敗時に呼び出される。
    // 通知サービスの登録に失敗する場合は、iPhoneシミュレータでアプリを実行しているかプッシュ通知が有効化されていない
    // プロビジョニングでビルドしたアプリを実行している可能性があります。
    //*********************************************************************************************
    NSLog(@"error: %@", [error description]);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    NSLog(@"---- application:didReceiveRemoteNotification:fetchCompletionHandler: ----");
    //*********************************************************************************************
    // アプリがフォアグランド・バックグランド状態で動作中に通知を受信した時の動作を定義する。
    // バックラウンド状態で通知を受信後に通知からアプリを起動した場合、
    // CorePushManagerDelegate#handleBackgroundNotificationが呼び出されます。
    // フォアグランド状態で通知を受信した場合、CorePushManagerDelegate#handleForegroundNotificationが呼び出されます。
    //*********************************************************************************************
    [CorePushManager.shared handleRemoteNotification:userInfo];
    
    //*********************************************************************************************
    // アイコンバッジ数をリセットする
    //*********************************************************************************************
    [CorePushManager resetApplicationIconBadgeNumber];
    
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //*********************************************************************************************
    // アイコンバッジ数をリセットする
    //*********************************************************************************************
    [CorePushManager resetApplicationIconBadgeNumber];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    //*********************************************************************************************
    // フォアグランド復帰時にcore-aspサーバにデバイストークンを登録する。
    //*********************************************************************************************
    //    NSString* deviceToken = CorePushManager.shared.deviceToken;
    //    if (deviceToken && ![deviceToken isEqualToString:@""]) {
    //        [CorePushManager.shared registerDeviceTokenString:deviceToken];
    //    }
}

- (void)handleBackgroundNotification:(NSDictionary*)userInfo {
    NSLog(@"---- handleBackgroundNotification ----- %@", userInfo);

    //*********************************************************************************************
    //    // アプリがバックグランドで動作中に通知からアプリを起動した時の動作を定義
    //    // userInfoオブジェクトからリッチ通知のURLを取得
    //    NSString* url = (NSString*) userInfo[@"url"];
    //    if (url && ![url isEqualToString:@""]) {
    //        NSLog(@"url: %@", url);
    //    }
    //    //*********************************************************************************************
    //
    //    //*********************************************************************************************
    //    // 通知からの起動を把握するためのアクセス解析用のパラメータを送信
    //    NSString* pushId = (NSString*) userInfo[@"push_id"];
    //    if (pushId) {
    //        [CorePushAnalyticsManager.shared requestAppLaunchAnalytics:pushId latitude:@"0" longitude:@"0"];
    //    }
    //*********************************************************************************************
    
}

- (void)handleForegroundNotifcation:(NSDictionary*)userInfo {
    NSLog(@"---- handleForegroundNotifcation ----- %@", userInfo);

    //*********************************************************************************************
    //    // アプリがフォアグランドで動作中に通知を受信した時の動作を定義
    //    // userInfoオブジェクトかリッチ通知のURLを取得
    //    NSString* url = (NSString*) userInfo[@"url"];
    //    if (url && ![url isEqualToString:@""]) {
    //        NSLog(@"url: %@", url);
    //    }
    //    
    //    // リッチ通知ではない場合、userInfoオブジェクトから通知メッセージを取得
    //    NSString* message = (NSString*) userInfo[@"aps"][@"alert"];
    //    if (message) {
    //        NSLog(@"message: %@", message);
    //    }
    //*********************************************************************************************
    
    //*********************************************************************************************
    //    // 通知からの起動を把握するためのアクセス解析用のパラメータを送信
    //    NSString* pushId = (NSString*) userInfo[@"push_id"];
    //    if (pushId) {
    //      [[CorePushAnalyticsManager shared] requestAppLaunchAnalytics:pushId latitude:@"0" longitude:@"0"];
    //    }
    //*********************************************************************************************
}

- (void)handleLaunchingNotification:(NSDictionary*)userInfo {
    NSLog(@"---- handleLaunchingNotification ----- %@", userInfo);
    
    //*********************************************************************************************
    //    // アプリが起動中でない状態で通知からアプリを起動した場合に呼び出される。
    //    // userInfoオブジェクトからリッチ通知のURLを取得
    //    NSString* url = (NSString*) userInfo[@"url"];
    //    if (url && ![url isEqualToString:@""]) {
    //        NSLog(@"url: %@", url);
    //    }
    //    
    //    // リッチ通知ではない場合、userInfoオブジェクトから通知メッセージを取得
    //    NSString* message = (NSString*) userInfo[@"aps"][@"alert"];
    //    NSLog(@"message: %@", message);
    //*********************************************************************************************
    
    //*********************************************************************************************
    //    // 通知からの起動を把握するためのアクセス解析用のパラメータを送信
    //    NSString* pushId = (NSString*) userInfo[@"push_id"];
    //    if (pushId) {
    //        [[CorePushAnalyticsManager shared] requestAppLaunchAnalytics:pushId latitude:@"0" longitude:@"0"];
    //    }
    //*********************************************************************************************
}

#pragma UNUserNotificationCenterDelegate (iOS10以上の場合)

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    if ([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSDictionary* userInfo = response.notification.request.content.userInfo;
        NSLog(@"---- userNotificationCenter:didReceive:withCompletionHandler ----- %@", userInfo);
        [CorePushManager.shared handleRemoteNotification:userInfo];
    }
    
    completionHandler();
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    NSDictionary* userInfo = notification.request.content.userInfo;
    NSLog(@"---- userNotificationCenter:willPresent:withCompletionHandler ----- %@", userInfo);
    if ([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [CorePushManager.shared handleRemoteNotification:userInfo];
        completionHandler(UNNotificationPresentationOptionNone);
        //*********************************************************************************************
        //    // フォアグランド時に通知センターに通知を表示する場合の設定 (こちらの設定を使用する場合は、上記の２行のコードを削除する)
        //        completionHandler(UNNotificationPresentationOptionBadge
        //                          | UNNotificationPresentationOptionSound
        //                          | UNNotificationPresentationOptionAlert);
        //*********************************************************************************************
    }
}

@end
