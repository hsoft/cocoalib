/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSTableColumnManager.h"
#import "Utils.h"

@implementation HSTableColumnManager
- (id)initWithTable:(NSTableView *)aTable
{
    self = [super init];
    table = [aTable retain];
    columns = [[NSMutableArray alloc] initWithArray:[aTable tableColumns]];
    defaulName2Column = [[NSMutableDictionary dictionary] retain];
    return self;
}

- (void)dealloc
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSEnumerator *e = [[defaulName2Column allKeys] objectEnumerator];
    NSString *udName;
    while (udName = [e nextObject])
        [ud removeObserver:self forKeyPath:udName];
    [defaulName2Column release];
    [table release];
    [columns release];
    [super dealloc];
}

- (NSTableColumn *)getColumn:(NSString *)columnId
{
    for (NSTableColumn *col in columns) {
        if ([[col identifier] isEqualTo:columnId])
            return col;
    }
    return nil;
}

- (BOOL)isColumnVisible:(NSString *)columnId
{
    NSTableColumn *col = [self getColumn:columnId];
    if (col != nil)
        return ![col isHidden];
    else
        return NO;
}

- (void)linkColumn:(NSString *)columnId toUserDefault:(NSString *)udName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [defaulName2Column setValue:columnId forKey:udName];
    [ud addObserver:self forKeyPath:udName options:NSKeyValueObservingOptionNew context:NULL];
    [self setColumn:columnId visible:[ud boolForKey:udName]];
}

- (void)setColumn:(NSString *)columnId visible:(BOOL)visible
{
    NSTableColumn *col = [self getColumn:columnId];
    if (col == nil)
        return;
    if ([col isHidden] == !visible)
        return;
    // Before changing the columns, we must stop edition if it is ongoing
    if ([table editedColumn] >= 0)
        [[table window] makeFirstResponder:table]; // This will abort edition
    [col setHidden:!visible];
}

- (void)toggleColumnVisibility:(NSString *)columnId
{
    [self setColumn:columnId visible:![self isColumnVisible:columnId]];
}

/* Delegate */

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL visible = n2b([change objectForKey:NSKeyValueChangeNewKey]);
    NSString *columnId = [defaulName2Column objectForKey:keyPath];
    [self setColumn:columnId visible:visible];
}

@end