//
//  DictManager.h
//  Dictionary
//
//  Created by 刘 闽晟 on 14-5-10.
//  Copyright (c) 2014年 Minsheng Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UITextChecker.h>

NSArray* suggestWords (NSString *word);

@interface DictManager : NSObject

- (DictManager *) initWithReceiver:(id)tableView;

- (NSInteger)numberOfSectionsInTableView;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString *)titleForHeaderInSection:(NSInteger)section;
- (NSString *)cellContentForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)addToHistory:(NSString *)term;
- (void)searchTextDidChange:(NSString *)searchText;
- (BOOL)isClearHistory:(NSIndexPath *)indexPath;
- (BOOL)isNoGuessFound;
- (void)clearHistory;

@end
