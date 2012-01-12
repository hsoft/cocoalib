/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSSelectableList2.h"
#import "Utils.h"

@implementation HSSelectableList2
- initWithPy:(id <PySelectableList2>)aPy tableView:(NSTableView *)aTableView
{
    self = [super init];
    py = [aPy retain];
    [self setView:aTableView];
    return self;
}

- (void)setView:(NSTableView *)aTableView
{
    view = [aTableView retain];
    [aTableView setDataSource:self];
    [aTableView setDelegate:self];
    [self refresh];
}

- (void)dealloc
{
    [items release];
    [view release];
    [py release];
    [super dealloc];
}

/* Private */
- (void)setPySelection
{
    NSArray *selection = [Utils indexSet2Array:[[self view] selectedRowIndexes]];
    NSArray *pyselection = [[self py] selectedIndexes];
    if (![selection isEqualTo:pyselection]) {
        [[self py] selectIndexes:selection];
    }
}

- (void)setViewSelection
{
    NSIndexSet *selection = [Utils array2IndexSet:[[self py] selectedIndexes]];
    [[self view] selectRowIndexes:selection byExtendingSelection:NO];
}

/* HSGUIController */
- (id <PySelectableList2>)py
{
    return (id <PySelectableList2>)py;
}

- (NSTableView *)view
{
    return (NSTableView *)view;
}

/* Data source */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [items count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
    // Cocoa's typeselect mechanism can call us with an out-of-range row
    if (row >= [items count]) {
        return @"";
    }
    return [items objectAtIndex:row];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    [self setPySelection];
}

/* Public */

- (void)refresh
{
    // If we just deleted the last item, we want to update the selection before we reload
    [items release];
    items = [[[self py] items] retain];
    [[self view] reloadData];
    [self setViewSelection];
}

- (void)updateSelection
{
    NSIndexSet *selection = [NSIndexSet indexSetWithIndex:[[self py] selectedIndex]];
    [[self view] selectRowIndexes:selection byExtendingSelection:NO];
}
@end
