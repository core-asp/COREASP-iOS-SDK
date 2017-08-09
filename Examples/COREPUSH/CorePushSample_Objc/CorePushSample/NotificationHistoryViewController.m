//
//  NotificationHistoryViewController.m
//  CorePushSample
//
//  Copyright (c) 2017年 株式会社ブレスサービス. All rights reserved.
//

#import "NotificationHistoryViewController.h"

@interface NotificationHistoryViewController ()

@end

@implementation NotificationHistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"通知履歴";
        self.tabBarItem.image = [UIImage imageNamed:@"history.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"通知履歴";
    self.tableView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    CorePushNotificationHistoryManager.shared.delegate = self;
    
    // 通知履歴一覧を取得する
     UIApplication.sharedApplication.networkActivityIndicatorVisible = YES;
    
    [CorePushNotificationHistoryManager.shared requestNotificationHistory];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return CorePushNotificationHistoryManager.shared.notificationHistoryModelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    CorePushNotificationHistoryModel* historyModel = CorePushNotificationHistoryManager.shared.notificationHistoryModelArray[indexPath.row];
    cell.textLabel.text = historyModel.message;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    CorePushNotificationHistoryModel* historyModel = CorePushNotificationHistoryManager.shared.notificationHistoryModelArray[indexPath.row];
    NSString* historyId = historyModel.historyId;
    
    //タップされた場合、該当する通知メッセージを既読に設定する。
    [CorePushNotificationHistoryManager.shared setRead:historyId];
    
    //未読数をタブに設定する。
    [self setUnreadNumber];
    
     UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
    [tableView reloadData];
}

//通知履歴の取得成功
- (void)notificationHistoryManagerSuccess {
    [self setUnreadNumber];
    
    UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
    [_tableView reloadData];
}

//通知履歴の取得失敗
- (void)notificationHistoryManagerFail {
     UIApplication.sharedApplication.networkActivityIndicatorVisible = NO;
}

//未読数をタブに表示する。
- (void)setUnreadNumber {
    int unreadNumber = [CorePushNotificationHistoryManager.shared getUnreadNumber];
    self.tabBarItem.badgeValue = (unreadNumber > 0) ?  [NSString stringWithFormat:@"%d", unreadNumber] : nil;
}

@end
