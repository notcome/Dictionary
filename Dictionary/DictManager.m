//
//  DictManager.m
//  Dictionary
//
//  Created by 刘 闽晟 on 14-5-10.
//  Copyright (c) 2014年 Minsheng Liu. All rights reserved.
//

#import "DictManager.h"

typedef NS_ENUM(NSInteger, DictSectionType) {
    DictMatchSection,
    DictGuessSection
};

@implementation DictManager

{
    NSMutableArray *history;
    
    NSArray *match;
    NSArray *guess;
    
    NSString *currentSearchText;
    
    id receiver;
}

- (DictManager *)initWithReceiver:(id)tableView
{
    self = [super init];
    
    if (self) {
        history = [[NSMutableArray alloc] init];
        receiver = tableView;
    }
    
    return self;
}

//History/Match/Guess Switch
- (BOOL)showHistory
{
    return currentSearchText == nil || currentSearchText.length <= 3;
}

- (DictSectionType)getSectionType:(NSInteger)section
{
    if (section == 1 || match == nil) {
        return DictGuessSection;
    }
    
    return DictMatchSection;
}

- (NSInteger)numberOfSectionsInTableView
{
    if ([self showHistory]) {
        return 1;
    }
    else {
        if (guess == nil || match == nil) {
            return 1;
        }
        else {
            return 2;
        }
    }
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if ([self showHistory]) {
        return [history count] == 0 ? 0 : [history count] + 1;
    }
    else if ([self getSectionType:section] == DictMatchSection) {
        return [match count];
    }
    else {
        if ([self isNoGuessFound]) {
            return 1;
        }
        else {
            return [guess count];
        }
    }
}

- (NSString *)titleForHeaderInSection:(NSInteger)section
{
    if ([self showHistory]) {
        return @"History";
    }
    else if ([self getSectionType:section] == DictMatchSection) {
        return @"Match";
    }
    else {
        return @"Do you mean these?";
    }
}

- (NSString *)cellContentForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger ID = indexPath.row;
    if ([self showHistory]) {
        return history[[history count] - 1 - ID];
    }
    else if ([self getSectionType:indexPath.section] == DictMatchSection) {
        return match[ID];
    }
    else {
        return guess[ID];
    }
}
//History/Match/Guess Switch

//Special Cell Detector
- (BOOL)isClearHistory:(NSIndexPath *)indexPath
{
    if ([self showHistory] == NO) {
        return NO;
    }
    if ([self numberOfRowsInSection:0] == 0) {
        return NO;
    }
    if ([self numberOfRowsInSection:0] - 1 == indexPath.row) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isNoGuessFound
{
    if ([self numberOfSectionsInTableView] == 2) {
        return NO;
    }
    if ([self getSectionType:0] == DictMatchSection) {
        return NO;
    }
    if ([guess count] > 0) {
        return NO;
    }
    
    return YES;
}

//Special Cell Detector

- (void)clearHistory
{
    [history removeAllObjects];
    [self sendMessageReloadData];
}

- (void)addToHistory:(NSString *)term
{
    [history addObject:term];
}

- (void)searchTextDidChange:(NSString *)searchText
{
    if ([searchText isEqualToString:@""])
        searchText = nil;
    
    currentSearchText = searchText;
    
    if (searchText == nil) {
        match = nil;
        guess = nil;
        
        [self sendMessageReloadData];
        return;
    }
    
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_async(queue, ^{
        NSArray *temp = suggestWords(searchText);
        
        if ([temp count] == 0) {
            @synchronized (self) {
                guess = nil;
                match = nil;
                
                [self sendMessageReloadData];
            }
        }
        else if (searchText == currentSearchText) {
            @synchronized (self) {
                guess = [temp objectAtIndex:0];
                match = [temp objectAtIndex:1];
                
                if ([match count] == 0) {
                    match = nil;
                }
                if ([guess count] == 0) {
                    guess = nil;
                }
                
                
                [self sendMessageReloadData];
            }
        }
    });
}

- (void)sendMessageReloadData
{
    [receiver performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

@end

NSArray* suggestWords (NSString *word)
{
    static UITextChecker *suggestor;

    if (suggestor == nil) {
        suggestor = [[UITextChecker alloc] init];
    }
    
    static NSString *language = @"en_US";
    
    NSArray *guess = nil;
    NSArray *match = nil;
    
    NSInteger length = word.length;
    NSRange range = NSMakeRange(0, length);
    
    if (length > 3) {
        @synchronized (suggestor) {
            guess = [suggestor guessesForWordRange:range inString:word language:language];
            match = [suggestor completionsForPartialWordRange:range inString:word language:language];
        }
    }

    NSArray *ret = [[NSArray alloc] initWithObjects:guess, match, nil];
    return ret;
}