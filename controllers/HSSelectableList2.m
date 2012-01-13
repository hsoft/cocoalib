/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSSelectableList2.h"
#import "Utils.h"

@implementation HSSelectableList2
- initWithModel:(PySelectableList2 *)aModel tableView:(NSTableView *)aTableView
{
    self = [super init];
    model = [aModel retain];
    [self setView:aTableView];
    return self;
}

- initWithPyRef:(PyObject *)aPyRef tableView:(NSTableView *)aTableView
{
    PySelectableList2 *m = [[PySelectableList2 alloc] initWithModel:aPyRef];
    self = [self initWithModel:m tableView:aTableView];
    [m bindCallback:createCallback(@"SelectableListView", self)];
    [m release];
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
    [model release];
    [super dealloc];
}

/* Private */
- (void)setPySelection
{
    NSArray *selection = [Utils indexSet2Array:[[self view] selectedRowIndexes]];
    NSArray *pyselection = [[self model] selectedIndexes];
    if (![selection isEqualTo:pyselection]) {
        [[self model] selectIndexes:selection];
    }
}

- (void)setViewSelection
{
    NSIndexSet *selection = [Utils array2IndexSet:[[self model] selectedIndexes]];
    [[self view] selectRowIndexes:selection byExtendingSelection:NO];
}

/* HSGUIController */
- (PySelectableList2 *)model
{
    return (PySelectableList2 *)model;
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
    items = [[[self model] items] retain];
    [[self view] reloadData];
    [self setViewSelection];
}

- (void)updateSelection
{
    NSIndexSet *selection = [NSIndexSet indexSetWithIndex:[[self model] selectedIndex]];
    [[self view] selectRowIndexes:selection byExtendingSelection:NO];
}
@end
