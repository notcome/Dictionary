//
//  DictViewController.h
//  Dictionary
//
//  Created by 刘 闽晟 on 14-5-10.
//  Copyright (c) 2014年 Minsheng Liu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UITextChecker.h>

@interface DictViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
