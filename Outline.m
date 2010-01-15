/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "Outline.h"
#import "Utils.h"

@implementation OVNode
- (id)initWithParent:(OVNode *)aParent index:(NSInteger)aIndex childrenCount:(NSInteger)aChildrenCount
{
    self = [super init];
    _parent = aParent;
    _index = aIndex;
    _py = nil;
    _ovTag = -1;
    _level = 0;
    _maxLevel = -1; // undefined
    if (aParent != nil)
    {
        _py = [aParent py];
        _ovTag = [aParent tag];
        _level = [aParent level] + 1;
        _maxLevel = [aParent maxLevel];
    }
    _buffer = nil;
    _marked = -1; //undefined
    _children = nil;
    if (aChildrenCount >= 0)
    {
        _children = [[NSMutableArray array] retain];
        for (NSInteger i=0; i<aChildrenCount; i++)
        {
            [_children addObject:[NSNull null]];
        }
    }
    if (aParent == nil)
        _indexPath = nil;
    else if ([aParent indexPath] == nil)
        _indexPath = [[NSIndexPath alloc] initWithIndex:_index];
    else
        _indexPath = [[[_parent indexPath] indexPathByAddingIndex:_index] retain];
    return self;
}

- (void)dealloc
{
    [_buffer release];
    [_children release];
    [_indexPath release];
    [super dealloc];
}

- (OVNode *)getChildAtIndex:(NSInteger)aIndex
{
    [self childrenCount]; // initialize if needed;
    id child = [_children objectAtIndex:aIndex];
    if (child == [NSNull null])
    {
        child = [[[OVNode alloc] initWithParent:self index:aIndex childrenCount:-1] autorelease];
        [_children replaceObjectAtIndex:aIndex withObject:child];
    }
    return child;
}

- (OVNode *)nodeAtPath:(NSIndexPath *)path
{
	NSInteger pathLength = [self indexPath] == nil ? 0 : [[self indexPath] length];
	if ([path length] <= pathLength)
		return ([path compare:[self indexPath]] == NSOrderedSame) ? self : nil;
	NSInteger childIndex = [path indexAtPosition:pathLength];
	if (childIndex >= [self childrenCount])
		return nil;
	OVNode *child = [self getChildAtIndex:childIndex];
	return [child nodeAtPath:path];
}

- (void)invalidateBufferRecursively
{
	[_buffer release];
	_buffer = nil;
    if (_children == nil)
        return; // nothing cached
    for (NSInteger i=0;i<[_children count];i++)
    {
        OVNode *child = [_children objectAtIndex:i];
        [child invalidateBufferRecursively];
    }
}

- (void)invalidateMarkingRecursively:(BOOL)aRecursive
{
    if (_children == nil)
        return; // nothing cached
    _marked = -1;
    if (aRecursive)
    {
        for (NSInteger i=0;i<[_children count];i++)
        {
            OVNode *child = [_children objectAtIndex:i];
            [child invalidateMarkingRecursively:YES];
        }
    }
}

- (BOOL)isMarked
{
    if (_marked < 0)
        _marked = n2i([_py getOutlineView:i2n(_ovTag) markedAtIndexes:p2a([self indexPath])]);
    return _marked == 1;
}

- (BOOL)isMarkable
{
    [self isMarked]; // force fetch
    return _marked != 2;
}

- (NSInteger)level
{
    return _level;
}

- (NSInteger)maxLevel
{
    return _maxLevel;
}

- (NSInteger)childrenCount
{
    if (_children == nil)
    {
        // Needs initialisation
        if (_maxLevel == -1)
            _maxLevel = [_py getOutlineViewMaxLevel:_ovTag];
        _children = [[NSMutableArray array] retain];
        if ((_maxLevel == 0) || ([self level] < _maxLevel)) // max level not reached
        {
            NSArray *counts = [_py getOutlineView:_ovTag childCountsForPath:p2a([self indexPath])];
            for (NSInteger i=0; i<[counts count]; i++)
            {
                NSInteger childCount = n2i([counts objectAtIndex:i]);
                OVNode *child = [[[OVNode alloc] initWithParent:self index:i childrenCount:childCount] autorelease];
                [_children addObject:child];
            }
        }
    }
    return [_children count];
}

- (void)resetAllBuffers
{
    [self setBuffer:nil];
    if (_children == nil)
        return; // nothing cached
    [_children release];
    _children = nil;
    _maxLevel = -1;
}

- (OVNode *)parent {return _parent;}
- (NSInteger)index {return _index;}
- (NSIndexPath *)indexPath {return _indexPath;}
- (NSArray *)buffer {return _buffer;}
- (void)setBuffer:(NSArray *)aBuffer 
{
    [_buffer release];
    _buffer = [aBuffer retain];
    [self invalidateMarkingRecursively:NO];
}

- (NSInteger)tag
{
    return _ovTag;
}

- (void)setTag:(NSInteger)aNewTag
{
    if (aNewTag == _ovTag)
        return;
    _ovTag = aNewTag;
    [self resetAllBuffers];
}

- (PyApp *)py
{
    return _py;
}

- (void)setPy:(PyApp *)aNewPy
{
    if (aNewPy == _py)
        return;
    _py = aNewPy;
    [self resetAllBuffers];
}
@end

@implementation ArrowlessBrowserCell
+ (NSImage *)branchImage {return nil;}
+ (NSImage *)highlightedBranchImage {return nil;}
@end;

@implementation OutlineView
/* Initialization */
- (void)doInit
{
    _root = [[OVNode alloc] initWithParent:nil index:-1 childrenCount:-1];
    [_root setPy:py];
    [_root setTag:[self tag]];
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
    [_root release];
    [super dealloc];
}

/* Overrides */
- (void)reloadData
{
    [_root resetAllBuffers];
    [super reloadData];
}

/* Datasource */
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    OVNode *node = item == nil ? _root : item;
    return [node childrenCount];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    NSNumber *tag = i2n([outlineView tag]);
    NSString *colId = (NSString *)[tableColumn identifier];
    OVNode *node = item;
    if ([colId isEqual:@"mark"])
        return b2n([node isMarked]);
    NSInteger colIndex = [colId intValue];
    if ([node buffer] == nil)
        [node setBuffer:[py getOutlineView:tag valuesForIndexes:p2a([node indexPath])]];
    return [[node buffer] objectAtIndex:colIndex];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    OVNode *parent = item == nil ? _root : item;
    return [parent getChildAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    return [self outlineView:outlineView numberOfChildrenOfItem:item] > 0;
}

/* Notifications */
// make return and tab only end editing, and not cause other cells to edit
- (void) textDidEndEditing: (NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSInteger textMovement = [[userInfo valueForKey:@"NSTextMovement"] intValue];
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

/* Public */
- (OVNode *)findNodeWithName:(NSString *)aName inParentNode:(OVNode *)aParentNode
{
    //This looks into the value of the column 0
    NSInteger childCount = [self outlineView:self numberOfChildrenOfItem:aParentNode];
    NSTableColumn *searchColumn = [[self tableColumns] objectAtIndex:0];
    for (NSInteger i=0;i<childCount;i++)
    {
        OVNode *r = [self outlineView:self child:i ofItem:aParentNode];
        NSString *s = [self outlineView:self objectValueForTableColumn:searchColumn byItem:r];
        if ([s isEqual:aName])
            return r;
    }
    return nil;
}

- (void)invalidateBuffers
{
    [_root invalidateBufferRecursively];
    [self setNeedsDisplay:YES];
}

- (void)invalidateMarkings
{
    [_root invalidateMarkingRecursively:YES];
    [self setNeedsDisplay:YES];
}

- (void)makeImagedColumnWithId:(NSString *)aId;
{
    NSTableColumn *col = [self tableColumnWithIdentifier:aId];
    if (!col)
        return;
    NSCell *oldCell = [[col dataCell] retain];
    [col setDataCell:[[[ArrowlessBrowserCell alloc] init] autorelease]];
    [[col dataCell] setFont:[oldCell font]];
    [oldCell release];
}

- (NSArray *)selectedNodes
{
    //Returns an array of OVNode
    NSMutableArray *r = [NSMutableArray array];
    NSIndexSet *indexes = [self selectedRowIndexes];
    NSInteger i = [indexes firstIndex];
    while (i != NSNotFound)
    {
        [r addObject:[self itemAtRow:i]];
        i = [indexes indexGreaterThanIndex:i];
    }
    return r;
}

- (NSArray *)selectedNodePaths
{
    //Returns an array of NSArray (NOT NSIndexPath, this class sucks for python).
    NSMutableArray *r = [NSMutableArray array];
    NSArray *nodes = [self selectedNodes];
    for (NSInteger i=0;i<[nodes count];i++)
        [r addObject:[Utils indexPath2Array:[[nodes objectAtIndex:i] indexPath]]];
    return r;
}

- (void)selectNodePaths:(NSArray *)nodePaths
{
	NSMutableIndexSet *toSelect = [NSMutableIndexSet indexSet];
	NSEnumerator *e = [nodePaths objectEnumerator];
	NSArray *path;
	while (path = [e nextObject])
	{
		NSIndexPath *p = a2p(path);
		OVNode *node = [_root nodeAtPath:p];
		if (node != nil)
			[toSelect addIndex:[self rowForItem:node]];
	}
	if ([toSelect count] > 0)
	{
		[self selectRowIndexes:toSelect byExtendingSelection:NO];
		[self scrollRowToVisible:[toSelect firstIndex]];
	}
}

/* Properties */
- (PyApp *)py {return py;}
- (void)setPy:(PyApp *)aPy
{
    py = aPy;
    [_root setPy:aPy];
    [self reloadData];
}

- (void)setTag:(NSInteger)aNewTag
{
    if (aNewTag == [self tag])
        return;
    [super setTag:aNewTag];
    [_root setTag:aNewTag];
    [self reloadData];
}
@end