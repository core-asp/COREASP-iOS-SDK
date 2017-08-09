//
//  AppDelegate.swift
//  CorePushSample_Swift
//
//  Copyright © 2017年 株式会社ブレスサービス. All rights reserved.
//

import UIKit
import COREASP
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //*********************************************************************************************
    // 通知のコンフィグキーの設定
    //*********************************************************************************************
    let CONFIG_KEY = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //*********************************************************************************************
        // CorePushManagerクラスの初期化
        //*********************************************************************************************
        CoreAspManager.shared.debugEnabled = true                // デバッグログを有効
        CorePushManager.shared.configKey = CONFIG_KEY             // コンフィグキーの設定
        CorePushManager.shared.delegate = self                    // CorePushManagerDelegateの設定
        CorePushManager.shared.registerForRemoteNotifications()   // 通知の登録
        
        // iOS10以上の場合の通知のデリゲート設定
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
        }
        
        //*********************************************************************************************
        // アプリのプロセスが起動していない状態で通知からアプリを起動した時の処理を定義する。
        // launchOptionsに通知のUserInfoが存在する場合は、CorePushManagerDelegate#handleLaunchingNotificationを
        // 呼び出し、存在しない場合は何も行わない。
        //*********************************************************************************************
        CorePushManager.shared.handleLaunchingNotification(withOption: launchOptions)
        
        //*********************************************************************************************
        // アイコンバッジ数をリセットする
        //*********************************************************************************************
        CorePushManager.resetApplicationIconBadgeNumber()
        
        // //アプリ内のユーザーIDの設定
        // CorePushManager.shared.appUserId = "username"
        
        return true
    }
    
    // 通知サービスの登録成功時に呼ばれる。
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NSLog("---- application:didRegisterForRemoteNotificationsWithDeviceToken ----")
        
        //*********************************************************************************************
        // APNSの通知登録の成功時に呼び出される。デバイストークンをcore-aspサーバに登録する。
        //*********************************************************************************************    
        CorePushManager.shared.registerDeviceToken(deviceToken)
    }
    
    // 通知サービスの登録失敗時に呼ばれる。
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("---- application:didFailToRegisterForRemoteNotificationsWithError ----")
        
        //*********************************************************************************************
        // APNSの通知登録の失敗時に呼び出される。
        // 通知サービスの登録に失敗する場合は、iPhoneシミュレータでアプリを実行しているかプッシュ通知が有効化されていない
        // プロビジョニングでビルドしたアプリを実行している可能性があります。
        //*********************************************************************************************
        NSLog("error: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NSLog("---- application:didReceiveRemoteNotification:fetchCompletionHandler: ----")
        
        //*********************************************************************************************
        // アプリがフォアグランド・バックグランド状態で動作中に通知を受信した時の動作を定義する。
        // バックラウンド状態で通知を受信後に通知からアプリを起動した場合、
        // CorePushManagerDelegate#handleBackgroundNotificationが呼び出されます。
        // フォアグランド状態で通知を受信した場合、CorePushManagerDelegate#handleForegroundNotificationが呼び出されます。
        //*********************************************************************************************
        CorePushManager.shared.handleRemoteNotification(userInfo)
        
        //*********************************************************************************************
        // アイコンバッジ数をリセットする
        //*********************************************************************************************
        CorePushManager.resetApplicationIconBadgeNumber()
        
        completionHandler(.noData)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        //*********************************************************************************************
        // アイコンバッジ数をリセットする
        //*********************************************************************************************
        CorePushManager.resetApplicationIconBadgeNumber()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        //*********************************************************************************************
        // フォアグランド復帰時にcore-aspサーバにデバイストークンを登録する。
        //*********************************************************************************************
        //   if let deviceToken = CorePushManager.shared.deviceToken, deviceToken != "" {
        //       CorePushManager.shared.registerDeviceTokenString(deviceToken)
        //   }
    }

}

// MARK: - CorePushManagerDelegate

extension AppDelegate: CorePushManagerDelegate {
    
    func handleBackgroundNotification(_ userInfo: [AnyHashable: Any]) {
         NSLog("---- handleBackgroundNotification ----- \(userInfo)")
        
        //*********************************************************************************************
        //    // アプリがバックグランドで動作中に通知からアプリを起動した時の動作を定義
        //    if let url = userInfo["url"] as? String, url != "" {
        //        NSLog("url: \(url)")
        //    }
        //*********************************************************************************************
        
        //*********************************************************************************************
        //    // 通知からの起動を把握するためのアクセス解析用のパラメータを送信
        //    if let pushId = userInfo["push_id"] as? String {
        //        CorePushAnalyticsManager.shared.requestAppLaunchAnalytics(pushId, latitude: "0", longitude: "0")
        //    }
        //*********************************************************************************************
    }
    
    func handleForegroundNotifcation(_ userInfo: [AnyHashable: Any]) {
        NSLog("---- handleForegroundNotifcation ----- \(userInfo)")
        
        //*********************************************************************************************
        //    //アプリがフォアグランドで動作中に通知を受信した時の動作を定義
        //    if let url = userInfo["url"] as? String, url != "" {
        //        NSLog("url: \(url)")
        //    }
        //
        //    // リッチ通知ではない場合 userInfoオブジェクトから通知メッセージを取得
        //    if let aps = userInfo["aps"] as? [String: Any], let message = aps["alert"] as? String  {
        //       NSLog("message: \(message)")
        //    }
        //*********************************************************************************************
        
        //*********************************************************************************************
        //    // 通知からの起動を把握するためのアクセス解析用のパラメータを送信
        //    if let pushId = userInfo["push_id"] as? String {
        //        CorePushAnalyticsManager.shared.requestAppLaunchAnalytics(pushId, latitude: "0", longitude: "0")
        //    }
        //*********************************************************************************************
    }
    
    func handleLaunchingNotification(_ userInfo: [AnyHashable: Any]) {
        NSLog("---- handleLaunchingNotification ----- \(userInfo)")
        
        //*********************************************************************************************
        //    //アプリが起動中でない状態で通知からアプリを起動した時の動作を定義
        //
        //    if let url = userInfo["url"] as? String, url != "" {
        //        NSLog("url: \(url)")
        //    }
        //
        //    //userInfoオブジェクトから通知メッセージを取得
        //    if let aps = userInfo["aps"] as? [String: Any], let message = aps["alert"] as? String  {
        //       NSLog("message: \(message)")
        //    }
        //********************************************************************************************
        
        //*********************************************************************************************
        //    //通知からの起動を把握するためのアクセス解析用のパラメータを送信
        //    if let pushId = userInfo["push_id"] as? String {
        //        CorePushAnalyticsManager.shared.requestAppLaunchAnalytics(pushId, latitude: "0", longitude: "0")
        //    }
        //*********************************************************************************************
    }
}

// MARK: - UNUserNotificationCenterDelegate (iOS10以上の場合)

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        if response.notification.request.trigger is UNPushNotificationTrigger {
            let userInfo = response.notification.request.content.userInfo
            NSLog("---- userNotificationCenter:didReceive:withCompletionHandler ----- \(userInfo)")
            CorePushManager.shared.handleRemoteNotification(userInfo)
        }
        
        completionHandler()
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        NSLog("---- userNotificationCenter:willPresent:withCompletionHandler ----- \(userInfo)")

        if notification.request.trigger is UNPushNotificationTrigger {
            CorePushManager.shared.handleRemoteNotification(userInfo)
            completionHandler([])
            
            //*********************************************************************************************
            //    // フォアグランド時に通知センターに通知を表示する場合の設定 (こちらの設定を使用する場合は、上記の２行のコードを削除する)
            //    completionHandler([.badge, .sound, .alert])
            //*********************************************************************************************
        }
    }
}
