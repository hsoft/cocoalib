/* 
Copyright 2009 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "Table.h"
#import "Utils.h"

@implementation TableView
/* Initialization */
- (void)doInit
{
    _buffer = [[NSMutableArray array] retain];
    _marked = nil;
    [self setDataSource:self];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    //Happens when loading from NIB.
    self = [super initWithCoder:decoder];
    [self doInit];
    return self;
}

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    [self doInit];
    return self;
}

- (void)dealloc
{
    [_buffer release];
    [self setMarkedIndexes:nil];
    [super dealloc];
}

/* Override */

- (void)reloadData
{
    [_buffer removeAllObjects];
    [self setMarkedIndexes:nil];
    [super reloadData];
}

/* Properties */
- (NSIndexSet *)markedIndexes 
{
    if ((!_marked) && (py))
    {
        NSArray *a = [py getTableViewMarkedIndexes:i2n([self tag])];
        NSMutableIndexSet *i = [NSMutableIndexSet indexSet];
        NSEnumerator *e = [a objectEnumerator];
        NSNumber *n;
        while (n = [e nextObject])
            [i addIndex:[n intValue]];
        [self setMarkedIndexes:i];
    }
    return _marked;
}
- (void)setMarkedIndexes:(NSIndexSet *)aMarkedIndexes
{
    if (_marked)
        [_marked release];
    _marked = aMarkedIndexes;
    if (_marked)
        [_marked retain];
}
- (PyApp *)py {return py;}
- (void)setPy:(PyApp *)aPy
{
    py = aPy;
    [self reloadData];
}

/* Public */

- (id)bufferValueForRow:(int)aRow column:(int)aColumn
{
    while ([_buffer count] <= aRow)
        [_buffer addObject:[NSArray array]];
    NSArray *values = [_buffer objectAtIndex:aRow];
    if (![values count])
    {
        values = [py getTableView:i2n([self tag]) valuesForRow:i2n(aRow)];
        [_buffer replaceObjectAtIndex:aRow withObject:values];
    }
    if (aColumn < [values count])
        return [values objectAtIndex:aColumn];
    else
        return nil;
}

/* Datasource */
- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (!py)
        return 0;
    NSNumber *tag = [NSNumber numberWithInt:[tableView tag]];
    return [[py getTableViewCount:tag] intValue];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{
    if ([(NSString *)[tableColumn identifier] isEqual:@"mark"])
        return b2n([[self markedIndexes] containsIndex:rowIndex]);
    int colIndex = [(NSString *)[tableColumn identifier] intValue];
    return [self bufferValueForRow:rowIndex column:colIndex];
}

/* Notifications */
// make return and tab only end editing, and not cause other cells to edit
- (void) textDidEndEditing: (NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];
    int textMovement = [[userInfo valueForKey:@"NSTextMovement"] intValue];
    if (textMovement == NSReturnTextMovement || textMovement == NSTabTextMovement || textMovement == NSBacktabTextMovement) 
    {
        NSMutableDictionary *newInfo;
        newInfo = [NSMutableDictionary dictionaryWithDictionary: userInfo];
        [newInfo setObject: [NSNumber numberWithInt: NSIllegalTextMovement] forKey: @"NSTextMovement"];
        notification = [NSNotification notificationWithName: [notification name]
                                                     object: [notification object]
                                                   userInfo: newInfo];
    }
    
    [super textDidEndEditing: notification];
    [[self window] makeFirstResponder:self];
}
@end;