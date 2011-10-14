/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSComboBox.h"

@implementation HSComboBox
- (void)dealloc
{
    [[self view] setTarget:nil];
    [[self view] setDataSource:nil];
    [items release];
    [super dealloc];
}

- (NSComboBox *)view
{
    return (NSComboBox *)view;
}

- (void)setView:(NSComboBox *)aComboboxView
{
    [super setView:aComboboxView];
    [aComboboxView setDataSource:self];
    [aComboboxView setAction:@selector(comboboxViewSelectionChanged)];
    [aComboboxView setTarget:self];
    [self refresh];
}

- (PySelectableList *)py
{
    return (PySelectableList *)py;
}

- (void)comboboxViewSelectionChanged
{
    NSInteger index = [[self view] indexOfSelectedItem];
    if (index >= 0) {
        [[self py] selectIndex:index];
    }
}

/* data source */
- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    if (index < 0) {
        return nil;
    }
    return [items objectAtIndex:index];
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return [items count];
}

- (NSUInteger)comboBox:(NSComboBox *)aComboBox indexOfItemWithStringValue:(NSString *)aString
{
    NSInteger index = [[self py] searchByPrefix:aString];
    if (index >= 0) {
        return index;
    }
    else {
        return NSNotFound;
    }
}

- (NSString *)comboBox:(NSComboBox *)aComboBox completedString:(NSString *)uncompletedString
{
    NSInteger index = [[self py] searchByPrefix:uncompletedString];
    if (index >= 0) {
        return [items objectAtIndex:index];
    }
    else {
        return nil;
    }
}

/* model --> view */
- (void)refresh
{
    [items release];
    items = [[[self py] items] retain];
    [[self view] reloadData];
    [self updateSelection];
}

- (void)updateSelection
{
    [[self view] selectItemAtIndex:[[self py] selectedIndex]]; 
}
@end