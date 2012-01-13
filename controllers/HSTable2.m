/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSTable2.h"
#import "Utils.h"

@implementation HSTable2
- (id)initWithModel:(PyTable2 *)aModel tableView:(NSTableView *)aTableView
{
    self = [super initWithModel:aModel view:aTableView];
    columns = [[HSColumns2 alloc] initWithPyRef:[[self model] columns] tableView:aTableView];
    return self;
}

- (id)initWithPyRef:(PyObject *)aPyRef tableView:(NSTableView *)aTableView
{
    PyTable2 *m = [[PyTable2 alloc] initWithModel:aPyRef];
    self = [self initWithModel:m tableView:aTableView];
    [m bindCallback:createCallback(@"TableView", self)];
    [m release];
    return self;
}

- (void)dealloc
{
    [columns release];
    [super dealloc];
}

/* Private */
- (void)setPySelection
{
    NSArray *selection = [Utils indexSet2Array:[[self view] selectedRowIndexes]];
    NSArray *pyselection = [[self model] selectedRows];
    if (![selection isEqualTo:pyselection])
        [[self model] selectRows:selection];
}

- (void)setViewSelection
{
    NSIndexSet *selection = [Utils array2IndexSet:[[self model] selectedRows]];
	[[self view] selectRowIndexes:selection byExtendingSelection:NO];
}

/* HSGUIController */
- (PyTable2 *)model
{
    return (PyTable2 *)model;
}

- (NSTableView *)view
{
    return (NSTableView *)view;
}

- (void)setView:(NSTableView *)aTableView
{
    [super setView:aTableView];
    [aTableView setDataSource:self];
    [aTableView setDelegate:self];
}

/* Data source */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [[self model] numberOfRows];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
    // Cocoa's typeselect mechanism can call us with an out-of-range row
    if (row >= [[self model] numberOfRows]) {
        return @"";
    }
    return [[self model] valueForColumn:[column identifier] row:row];
}

/* NSTableView Delegate */
- (void)tableView:(NSTableView *)aTableView didClickTableColumn:(NSTableColumn *)column
{
    if ([[aTableView sortDescriptors] count] == 0) {
        return;
    }
    NSSortDescriptor *sd = [[aTableView sortDescriptors] objectAtIndex:0];
    [[self model] sortByColumn:[sd key] desc:![sd ascending]];
}

// See HSOutline.outlineViewSelectionIsChanging: to know why we update selection in both notifs
- (void)tableViewSelectionIsChanging:(NSNotification *)notification
{
    [self setPySelection];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    [self setPySelection];
}

/* Public */
- (HSColumns2 *)columns
{
    return columns;
}

- (void)refresh
{
    // If we just deleted the last item, we want to update the selection before we reload
    [self setViewSelection];
    [[self view] reloadData];
    [self setViewSelection];
}

- (void)showSelectedRow
{
    [[self view] scrollRowToVisible:[[self view] selectedRow]];
}

- (void)updateSelection
{
    [self setViewSelection];
}
@end
