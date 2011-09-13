/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSPopUpList.h"

@implementation HSPopUpList
- (void)dealloc
{
    [[self view] setTarget:nil];
    [super dealloc];
}

- (NSPopUpButton *)view
{
    return (NSPopUpButton *)view;
}

- (void)setView:(NSPopUpButton *)aPopupView
{
    [super setView:aPopupView];
    [aPopupView setAction:@selector(popupViewSelectionChanged)];
    [aPopupView setTarget:self];
    [self refresh];
}

- (PySelectableList *)py
{
    return (PySelectableList *)py;
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
    [[self view] selectItemAtIndex:[[self py] selectedIndex]];
}
@end