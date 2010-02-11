/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSOutline.h"
#import "Utils.h"

#define CHILDREN_COUNT_PROPERTY @"children_count"

@implementation HSOutline
- (id)initWithPyClassName:(NSString *)aClassName pyParent:(id)aPyParent view:(HSOutlineView *)aOutlineView
{
    self = [super initWithPyClassName:aClassName pyParent:aPyParent];
    itemData = [[NSMutableDictionary dictionary] retain];
    outlineView = aOutlineView;
    [outlineView setDataSource:self];
    [outlineView setDelegate:self];
    return self;
}

- (void)dealloc
{
    [itemData release];
    [super dealloc];
}

- (HSOutlineView *)outlineView
{
    return outlineView;
}

- (PyOutline *)py
{
    return (PyOutline *)py;
}

/* Public */
- (void)refresh
{
    [itemData removeAllObjects];
    [outlineView reloadData];
    [self updateSelection];
}

- (NSIndexPath *)selectedIndexPath
{
    return a2p([[self py] selectedPath]);
}

- (void)startEditing
{
    [outlineView startEditing];
}

- (void)stopEditing
{
    [outlineView stopEditing];
}

- (void)updateSelection
{
    [outlineView updateSelection];
}

/* Caching */
- (id)property:(NSString *)property valueAtPath:(NSIndexPath *)path
{
    NSMutableDictionary *props = [itemData objectForKey:path];
    id value = [props objectForKey:property];
    if (value == nil) {
        value = [[self py] property:property valueAtPath:p2a(path)];
        if (value == nil) {
            value = [NSNull null];
        }
        [props setObject:value forKey:property];
    }
    if (value == [NSNull null]) {
        value = nil;
    }
    return value;
}

- (void)setProperty:(NSString *)property value:(id)value atPath:(NSIndexPath *)path
{
    NSMutableDictionary *props = [itemData objectForKey:path];
    [props removeObjectForKey:property];
    [[self py] setProperty:property value:value atPath:p2a(path)];
}

- (NSString *)stringProperty:(NSString *)property valueAtPath:(NSIndexPath *)path
{
    return [self property:property valueAtPath:path];
}

- (void)setStringProperty:(NSString *)property value:(NSString *)value atPath:(NSIndexPath *)path
{
    [self setProperty:property value:value atPath:path];
}

- (BOOL)boolProperty:(NSString *)property valueAtPath:(NSIndexPath *)path
{
    NSNumber *value = [self property:property valueAtPath:path];
    return [value boolValue];
}

- (void)setBoolProperty:(NSString *)property value:(BOOL)value atPath:(NSIndexPath *)path
{
    [self setProperty:property value:[NSNumber numberWithBool:value] atPath:path];
}

- (NSInteger)intProperty:(NSString *)property valueAtPath:(NSIndexPath *)path
{
    NSNumber *value = [self property:property valueAtPath:path];
    return [value intValue];
}

- (void)setIntProperty:(NSString *)property value:(int)value atPath:(NSIndexPath *)path
{
    [self setProperty:property value:[NSNumber numberWithInt:value] atPath:path];
}

- (void)refreshItemAtPath:(NSIndexPath *)path
{
    NSMutableDictionary *props = [itemData objectForKey:path];
    [props removeAllObjects];
}

/* NSOutlineView data source */

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    return [self intProperty:CHILDREN_COUNT_PROPERTY valueAtPath:(NSIndexPath *)item];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    NSIndexPath *parent = item;
    NSIndexPath *child = parent == nil ? [NSIndexPath indexPathWithIndex:index] : [parent indexPathByAddingIndex:index];
    if ([itemData objectForKey:child] == nil) {
        // Note: in general, the dictionary doesn't retain the keys that are given to it, but copies
        // of them. In our case, since a copy of an index path is the same index path, using an index
        // path as a key in actually retains the index path.
        [itemData setObject:[NSMutableDictionary dictionary] forKey:child];
    }
    return child;
}

- (BOOL)outlineView:(NSOutlineView *)theOutlineView isItemExpandable:(id)item
{
    return [self outlineView:outlineView numberOfChildrenOfItem:item] > 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)column item:(id)item
{
    return [[self py] canEditProperty:[column identifier] atPath:p2a((NSIndexPath *)item)];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)column byItem:(id)item
{
    return [self property:[column identifier] valueAtPath:(NSIndexPath *)item];
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)value forTableColumn:(NSTableColumn *)column byItem:(id)item
{
    [self setProperty:[column identifier] value:value atPath:(NSIndexPath *)item];
}

/* We need to change the py selection at both IsChanging and DidChange. We need to set the
py selection at IsChanging before of the arrow clicking. The action launched by this little arrow
is performed before DidChange. However, when using the arrow to change the selection, IsChanging is
never called
*/
- (void)outlineViewSelectionIsChanging:(NSNotification *)notification
{
    NSArray *indexPath = p2a([outlineView itemAtRow:[outlineView selectedRow]]);
    if (![indexPath isEqualTo:[[self py] selectedPath]]) {
        [[self py] setSelectedPath:indexPath];
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSArray *indexPath = p2a([outlineView itemAtRow:[outlineView selectedRow]]);
    if (![indexPath isEqualTo:[[self py] selectedPath]]) {
        [[self py] setSelectedPath:indexPath];
    }
}

- (void)outlineViewDidEndEditing:(HSOutlineView *)outlineView
{
    [[self py] saveEdits];
}

- (void)outlineViewCancelsEdition:(HSOutlineView *)outlineView
{
    [[self py] cancelEdits];
}
@end