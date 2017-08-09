# COREASP iOS SDK

## 概要

COREASP iOS SDK は、プッシュ通知ASPサービス「CORE ASP」の iOS用のSDKになります。 ドキュメントは CORE ASP Developer Supportサイトに掲載しております。

■公式サイト

CORE ASP：<a href="http://core-asp.com">http://core-asp.com</a>

CORE ASP Developer Support（開発者向け）：<a href="http://developer.core-asp.com">http://developer.core-asp.com</a>

## 前提
* iOSバージョンは8.0以上が動作対象になります。
* Xcodeバージョンは8.0以上が動作対象になります。
* Xcodeのプロジェクトのターゲットを選択し、[Build Phases]の[Link Binary With Libraries]から SDK/COREASP.framework を追加してください。

## アプリの通知設定

### CORE PUSHの設定キーの指定
CORE ASP管理画面 にログインし、ホーム画面からiOSアプリの設定キーを確認してください。 この設定キーをCorePushManager#setConfigKey で指定します。

```swift
CorePushManager.shared.configKey = "＜設定キーの値＞"
```
### CorePushManagerクラスのデリゲートクラスの指定
アプリケーションの動作状態に応じて通知をハンドリングするために、CorePushManagerDelegateプロトコルを実装した
クラスを CorePushManager#setDelegate で指定します。

```swift
CorePushManager.shared.delegate = self
```    

### UNUserNotificationCenterDelegateのデリゲートクラスの指定

iOS10以上の場合は、UNUserNotificationCenterDelegateのデリゲートクラスを別途指定します。

```swift
// iOS10以上の場合の通知のデリゲート設定
if #available(iOS 10.0, *) {
	UNUserNotificationCenter.current().delegate = self
}
```

### XcodeのCapabilitiesの設定

Xcodeの[Capabilities]の設定において、[Push Notifications]と[Background Modes]をONに指定してください。また、[Background Modes]の[Modes]において、[Remote notifications]にチェックを入れてください。

## デバイスの通知登録解除
デバイスが通知を受信できるようにするには、CORE ASPサーバにデバイストークンを送信します。またデバイスが通知を受信できないようにするには、CORE ASPサーバからデバイストークンを削除します。

### 通知登録
CorePushManager#registerForRemoteNotifications を呼び出すことで APNSサーバからデバイストークンを取得し、デバイストークンをCORE ASPサーバに送信します。また、デバイストークンの送信時に 端末名、OSバージョン、最終利用時間を自動送信します。

```swift
CorePushManager.shared.registerForRemoteNotifications()
```

本メソッドはアプリの初回起動時かON/OFFスイッチなどで通知をONにする場合に使用してください。

### 通知解除

CorePushManager#unregisterDeviceToken を呼び出すことで CORE ASPサーバからデバイストークンを削除します。

```swift
CorePushManager.shared.unregisterDeviceToken()

```

本メソッドはON/OFFスイッチなどで通知をOFFにする場合に使用してください。	
	
## 通知受信後の動作設定

アプリケーションの動作状態に応じて通知をハンドリングすることができます。
	
### バックグランド状態で動作中に通知から起動した場合

バックラウンド状態からの通知起動をハンドリングするために、以下のメソッドを呼び出します。

```swift
CorePushManager.shared.handleRemoteNotification(userInfo)
```

iOS10未満ではUIApplication#application:didReceiveRemoteNotification:fetchCompletionHandler: にて、メソッドを呼び出してください。

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    NSLog("---- application:didReceiveRemoteNotification:fetchCompletionHandler: ----")
    
    CorePushManager.shared.handleRemoteNotification(userInfo)
    CorePushManager.resetApplicationIconBadgeNumber()
    
    completionHandler(.noData)
}
```

iOS10以上ではUNUserNotificationCenterDelegate#userNotificationCenter(_:didReceive:withCompletionHandler:) にて、メソッドを呼び出してください。

```swift
@available(iOS 10.0, *)
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

	if response.notification.request.trigger is UNPushNotificationTrigger {
		let userInfo = response.notification.request.content.userInfo
		CorePushManager.shared.handleRemoteNotification(userInfo)
	}
        
	completionHandler()
}
```
	  
アプリケーションがバックグランド状態で動作中の場合は、CorePushManagerDelegate#handleBackgroundNotification が呼び出されます。

### フォアグラウンド状態で動作中に通知を受信した場合

フォアグランド状態からの通知起動をハンドリングするために、以下のメソッドを呼び出します。

```swift
CorePushManager.shared.handleRemoteNotification(userInfo)
```

iOS10未満ではUIApplication#application:didReceiveRemoteNotification:fetchCompletionHandler: にて、メソッドを呼び出してください。

```swift
func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {        
    CorePushManager.shared.handleRemoteNotification(userInfo)
    CorePushManager.resetApplicationIconBadgeNumber()
    
    completionHandler(.noData)
}
```

iOS10以上では userNotificationCenter(_:willPresent:withCompletionHandler:) にて、メソッドを呼び出してください。

```swift
@available(iOS 10.0, *)
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    let userInfo = notification.request.content.userInfo

    if notification.request.trigger is UNPushNotificationTrigger {
        CorePushManager.shared.handleRemoteNotification(userInfo)
        completionHandler([])
        
//*********************************************************************************************
//    // フォアグランド時に通知センターに通知を表示する場合の設定 (こちらの設定を使用する場合は、上記の２行のコードを削除する)
//    completionHandler([.badge, .sound, .alert])
//*********************************************************************************************
    }
}
```

アプリケーションがフォアグラウンド状態で動作中の場合は、CorePushManagerDelegate#handleForegroundNotification が呼び出されます。

### アプリケーションが動作していない状態で通知から起動した場合
UIApplication#application:didFinishLaunchingWithOptions にて、以下のメソッドを呼び出します。

```swift
CorePushManager.shared.handleLaunchingNotification(withOption: launchOptions)
```

アプリケーションが動作していない状態で通知から起動した場合はCorePushManagerDelegate#handleLaunchingNotification が呼び出されます。

## 通知履歴の表示

### 通知履歴の取得
CorePushNotificationHistoryManager#requestNotificationHistory を呼び出すことで通知履歴を最大100件取得できます。

```swift
CorePushNotificationHistoryManager.shared.requestNotificationHistory()
```

取得した通知履歴のオブジェクトの配列は、CorePushNotificationHistoryManager#notificationHistoryModelArray に格納されます。

```swift
CorePushNotificationHistoryManager.shared.notificationHistoryModelArray
```
  
上記の配列により、個々の通知履歴の CorePushNotificationHistoryModel オブジェクトを取得できます。CorePushNotificationHistoryModelオブジェクトには、履歴ID、通知メッセージ、通知日時、リッチ通知URLが格納されます。

```swift
// 例) 451
let historyId = notificationHistoryModel.historyId
	
// 例) CORE PUSH からのお知らせ!
let message = notificationHistoryModel.message

// 例) http://core-asp.com
let url = notificationHistoryModel.url

// 例) 2012-08-18 17:48:30
let regDate = notificationHistoryModel.regDate
```
	
### 通知履歴の未読管理
CorePushNotificationHistoryManager#setRead を呼び出すことで通知履歴の履歴ID毎に未読を管理することができます。以下は、ある履歴IDの
通知メッセージを既読に設定する例になります。

```swift
//タップされた場合、該当する通知メッセージを既読に設定する。
CorePushNotificationHistoryManager.shared.setRead(historyId)
```

また、CorePushNotificationHistoryManager#getUnreadNumber を呼び出すことで 通知履歴の配列全体の未読数を取得することができます。

```swift
CorePushNotificationHistoryManager.shared.getUnreadNumber()
```
	
取得した未読数は、タブのバッジ数やアイコンのバッジ数などに用いることができます。

```swift
//タブのバッジ数に未読数を設定する場合
self.tabBarItem.badgeValue = "\(unreadNumber)"
	 
//アイコンのバッジ数に未読数を設定する場合
CorePushManager.setApplicationIconBadgeNumber(unreadNumber)
```
    
## リッチ通知
    
### リッチ通知用のURLパラメータの取得
   
リッチ通知を受信した場合は、通知オブジェクト内にリッチ通知用のURLが含まれます。
リッチ通知用のURLは、以下の方法で取得できます。

```swift
let url = userInfo["url"]
```
 
### リッチ通知用のURLパラメータの活用(特定の画面への遷移)

<div> 
リッチ通知用のURLのパラメータの使い方は自由なので、通知から起動した際にアプリを表示せずにブラウザで指定のページを直接表示させるような使い方もできます。
</di>
<div>
また、パラメータの中身にはURL以外の文字列も入力可能なので、page=1やpage=2といった内容で通知を送ることでアプリ内の特定の画面を表示させるといった使い方もできます。
</div>

## カテゴリの設定
### １次元カテゴリ設定
デバイストークン登録APIの category_id パラメータの設定を行うことができます。パラメータの設定を行うには、
CorePushManager#setCategoryIds で カテゴリID(文字列型)のリストを指定します。以下はカテゴリIDのリストの作成例になります。<br />
※例は事前に管理画面で1から4までのカテゴリを設定しておいたものと仮定します。

```
// 1:北海道、2:東北 3:関東、4:近畿
let categoryIds = ["1", "2", "3", "4"]
CorePushManager.shared.categoryIds = categoryIds
```

上記カテゴリの設定後にデバイストークンを送信した場合、設定したcategory_id パラメータの値をCORE ASPサーバにPOSTします。
(category_idパラメータを設定しない場合のデフォルト値は 1 になります。)

### 2次元カテゴリ設定
デバイストークン登録APIの category_id パラメータの設定を行うことができます。パラメータの設定を行うには、
CorePushManager#setMultiCategoryIds で カテゴリIDのディクショナリーを指定します。以下はカテゴリIDのディクショナリーの作成例になります。<br />
※例は事前に管理画面で1から4までのカテゴリを設定しておいたものと仮定します。

```
// 1:地域、2:性別 3:年代 4:好きなジャンル(複数選択可の場合)
let multiCategoryIds = [
	"1": ["神奈川"],　    // 地域が「神奈川」の場合
	"2": ["男性"],       // 性別が「男性」の場合
	"3": ["20代"],       // 年代が「20代」の場合
	"4": ["音楽", "読書"] // 好きなジャンルが「音楽」と「読書」の場合
]
CorePushManager.shared.multiCategoryIds = multiCategoryIds 
```

上記カテゴリの設定後にデバイストークンを送信した場合、設定したcategory_id パラメータの値をCORE ASPサーバにPOSTします。
(1次元カテゴリと2次元カテゴリの両方が設定されている場合、category_id パラメータには２次元カテゴリの設定が優先されます。category_idパラメータを設定しない場合のデフォルト値は 1 になります。)

## ユーザー間プッシュ通知

ユーザー間のプッシュ通知を実現するには、事前にアプリ側でユーザーのデバイストークンのCORE ASPサーバへの登録とユーザー属性の御社サーバへの登録を行う必要があります。全体のイメージ図につきましては、<a href="http://developer.core-asp.com/api_image.php">http://developer.core-asp.com/api_image.php</a> をご参照ください。

### CORE ASPサーバへのデバイストークンの登録

CorePushManager#registerForRemtoeNotifications で通知の登録を行う前に、CorePushManager#setAppUserIdでアプリ内のユーザーIDを指定します。

```
//アプリのユーザーIDを登録
CorePushManager.shared.appUserId = "UserId"

//デバイストークンの登録
CorePushManager.shared.registerForRemoteNotifications()
```

上記により、api.core-asp.com/iphone_token_regist.php のトークン登録APIに
対して、app_user_id のパラメータが送信され、アプリ内でのユーザーの識別IDとデバイストークンが
紐づいた形でDBに保存されます。
  
### 御社サーバへのユーザー属性の登録

CorePushManager#registerUserAttributes:api: で御社サーバにユーザー属性の登録を行う前に
、CorePushManager#setAppUserIdでアプリ内でのユーザーの識別IDを指定します。

```swift
// アプリ内でのユーザーの識別IDを登録
CorePushManager.shared.appUserId = "UserId"
```

ユーザー属性を定義した配列を作成します。

```
// ユーザー属性の配列を作成。例) 1:いいね時の通知許可、3:コメント時の通知許可、7:フォロー時の通知許可
let attributes = ["1", "3", "7"]
```

ユーザー属性を送信する御社サーバ上の任意のURLを指定します。

```swift
//ユーザー属性を送信する御社の任意のURLを指定
let userAttributeApi = "ユーザ属性を送信する御社の任意のURL"
```

作成したユーザー属性を定義した配列とユーザー属性を送信するAPIのURLを引数として CorePushManager#registerUserAttributes:api: を呼び出し、アプリ内でのユーザーの識別IDとユーザー属性を御社サーバに送信します。

```swift
//アプリ内でのユーザーの識別IDとユーザー属性の送信
 CorePushManager.shared.registerUserAttributes(attributes, api: userAttributeApi)
```

特定のユーザーに対してプッシュ通知を行うには、通知送信リクエストAPIに対して、御社サーバから通知の送信依頼を行います。詳細につきましては、<a href="http://developer.core-asp.com/api_request.php">http://developer.core-asp.com/api_request.php</a> をご参照ください。

## アクセス解析

### 通知からのアプリ起動数の把握

通知からのアプリの起動時にアクセス解析用のパラメータをCORE ASPサーバに対して送信することで、管理画面の通知履歴から通知からのアプリ起動数を把握することができます（ただし、通知からのアプリ起動数の把握は、本番環境のプッシュ通知のみに制限されます。開発環境のプッシュ通知では、後述の通知IDを取得することができません)。

アクセス解析用のパラメータを CORE ASPサーバに対して送信するには、userInfo オブジェクトから push_id をキーとして通知IDを取得し、CorePushAnalyticsManager#requestAppLaunchAnalytics:latitude:longitude で
通知IDを送信します。

```swift
//通知IDの取得
if let pushId = userInfo["push_id"] as? String {
	// 通知IDを送信します。通知IDは userInfoオブジェクトから push_id キーで
	// 取得できます。また、通知から起動した地点の緯度・経度を指定することができます。緯度・経度を
	// 送信しない場合は latitude、longitudeパラメータに 0 を指定します。
	CorePushAnalyticsManager.shared.requestAppLaunchAnalytics(pushId, latitude: "0", longitude: "0")
}
```

また、通知からの起動数を正確に把握するために、通知受信後の動作設定の項目で説明した以下の３つのメソッド内でアクセス解析用のパラメータを CORE ASPサーバに対して送信してください。

*	バックグランド状態で動作中に通知から起動した場合に呼び出されるCorePushManagerDelegate#handleBackgroundNotification メソッド
*	フォアグラウンド状態で動作中に通知を受信した場合に呼び出される CorePushManagerDelegate#handleForegroundNotification 
*	アプリケーションが動作していない状態で通知から起動した場合に呼び出される　CorePushManagerDelegate#handleLaunchingNotification

## プッシュ通知の送信エラー

### エラー内容の把握

プッシュ通知の送信に失敗した場合、管理画面の送信履歴のエラー数のリンク先からエラー画面を確認できます。
エラー区分としては下記に分類されます。

1. アプリ削除でトークンが無効となった場合や、形式不正なトークンなどによるエラー
2. 上記以外のエラー（通信失敗、その他）

## 通知メッセージの制限について
メッセージペイロード(JSON形式)の長さは256バイトに制限されています。
実際に入力可能なメッセージのバイト数はおよそ236バイトになります。
 (全角:3バイト、半角カナ:3バイト、記号:1バイト、半角英数:1バイト) 
<div> ※全角60文字もしくは半角英数112文字が目安。</div>
<div> ※メッセージが236バイト以内で上記の文字数を超えた場合は、以降の文字列はロック画面や通知センターにおいて「…」のように省略表示されます。</div>
