//
//  NotificationHistoryViewController.h
//  CorePushSample
//
//  Copyright (c) 2017年 株式会社ブレスサービス. All rights reserved.
//

@import COREASP;

@interface NotificationHistoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CorePushNotificationHistoryManagerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end
