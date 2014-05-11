//
//  DictViewController.m
//  Dictionary
//
//  Created by 刘 闽晟 on 14-5-10.
//  Copyright (c) 2014年 Minsheng Liu. All rights reserved.
//

#import "DictViewController.h"
#import "DictManager.h"

UITableViewCell *getClearHistoryCell ();
UITableViewCell *getNoGuessFoundCell ();

@implementation DictViewController

{
    DictManager *manager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    manager = [[DictManager alloc] initWithReceiver:self.tableView];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

- (void) hideKeyboard {
    [self.searchBar resignFirstResponder];
    [self.tableView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [manager numberOfSectionsInTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [manager numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [manager titleForHeaderInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TableCellID = @"SimpleTableCell";
    
    if ([manager isClearHistory:indexPath]) {
        return getClearHistoryCell();
    }
    else if ([manager isNoGuessFound]) {
        return getNoGuessFoundCell();
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableCellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TableCellID];
    }
    
    cell.textLabel.text = [manager cellContentForRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL clearHistory = [manager isClearHistory:indexPath];
    BOOL noGuessFound = [manager isNoGuessFound];
    
    if (!clearHistory && !noGuessFound) {
        NSString *term = [manager cellContentForRowAtIndexPath:indexPath];
        [manager addToHistory:term];
        UIReferenceLibraryViewController *controller = [[UIReferenceLibraryViewController alloc] initWithTerm:term];
        [self presentViewController:controller animated:YES completion:^{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }];
    }
    else if (clearHistory){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Clear History"
                                                  otherButtonTitles:nil];
        
        [sheet showFromRect:[tableView rectForRowAtIndexPath:indexPath] inView:tableView animated:YES];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [manager clearHistory];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [manager searchTextDidChange:searchText];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *term = searchBar.text;
    [manager addToHistory:term];
	UIReferenceLibraryViewController *controller = [[UIReferenceLibraryViewController alloc] initWithTerm:term];
    [self presentViewController:controller animated:YES completion:nil];
}

@end

UITableViewCell *getClearHistoryCell ()
{
    static UITableViewCell *clearHistoryCell;
    static NSString *content = @"Clear History";
    
    if (clearHistoryCell == nil) {
        clearHistoryCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:content];
        clearHistoryCell.textLabel.text = content;
        clearHistoryCell.textLabel.textAlignment = NSTextAlignmentCenter;
        clearHistoryCell.textLabel.font = [UIFont boldSystemFontOfSize:17.0];
    }
    
    return clearHistoryCell;
}

UITableViewCell *getNoGuessFoundCell ()
{
    static UITableViewCell *noGuessFoundCell;
    static NSString *content = @"No Guess Found";
    
    if (noGuessFoundCell == nil) {
        noGuessFoundCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:content];
        noGuessFoundCell.textLabel.text = content;
        noGuessFoundCell.textLabel.textColor = [UIColor grayColor];
    }
    
    return noGuessFoundCell;
}