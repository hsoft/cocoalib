/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSPopUpList2.h"
#import "Utils.h"

@implementation HSPopUpList2
- (id)initWithPyRef:(PyObject *)aPyRef popupView:(NSPopUpButton *)aPopupView
{
    self = [super init];
    py = [[PySelectableList2 alloc] initWithModel:aPyRef];
    [py bindCallback:createCallback(@"SelectableListView", self)];
    [self setView:aPopupView];
    return self;
}

- (void)dealloc
{
    [[self view] setTarget:nil];
    [view release];
    [py release];
    [super dealloc];
}

- (NSPopUpButton *)view
{
    return (NSPopUpButton *)view;
}

- (void)setView:(NSPopUpButton *)aPopupView
{
    view = [aPopupView retain];
    [aPopupView setAction:@selector(popupViewSelectionChanged)];
    [aPopupView setTarget:self];
    [self refresh];
}

- (PySelectableList2 *)py
{
    return (PySelectableList2 *)py;
}

- (void)popupViewSelectionChanged
{
    [[self py] selectIndex:[[self view] indexOfSelectedItem]];
}

/* model --> view */
- (void)refresh
{
    [[self view] removeAllItems];
    [[self view] addItemsWithTitles:[[self py] items]];
    [self updateSelection];
}

- (void)updateSelection
{
    [[self view] selectItemAtIndex:[[self py] selectedIndex]]; 
}
@end