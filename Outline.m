/* 
Copyright 2009 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "Outline.h"
#import "Utils.h"

@implementation OVNode
- (id)initWithParent:(OVNode *)aParent index:(int)aIndex childrenCount:(int)aChildrenCount
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
        for (int i=0; i<aChildrenCount; i++)
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

- (OVNode *)getChildAtIndex:(int)aIndex
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
	int pathLength = [self indexPath] == nil ? 0 : [[self indexPath] length];
	if ([path length] <= pathLength)
		return ([path compare:[self indexPath]] == NSOrderedSame) ? self : nil;
	int childIndex = [path indexAtPosition:pathLength];
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
    for (int i=0;i<[_children count];i++)
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
        for (int i=0;i<[_children count];i++)
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

- (int)level
{
    return _level;
}

- (int)maxLevel
{
    return _maxLevel;
}

- (int)childrenCount
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
            for (int i=0; i<[counts count]; i++)
            {
                int childCount = n2i([counts objectAtIndex:i]);
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
- (int)index {return _index;}
- (NSIndexPath *)indexPath {return _indexPath;}
- (NSArray *)buffer {return _buffer;}
- (void)setBuffer:(NSArray *)aBuffer 
{
    [_buffer release];
    _buffer = [aBuffer retain];
    [self invalidateMarkingRecursively:NO];
}

- (int)tag
{
    return _ovTag;
}

- (void)setTag:(int)aNewTag
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
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
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
    int colIndex = [colId intValue];
    if ([node buffer] == nil)
        [node setBuffer:[py getOutlineView:tag valuesForIndexes:p2a([node indexPath])]];
    return [[node buffer] objectAtIndex:colIndex];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item
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

/* Public */
- (OVNode *)findNodeWithName:(NSString *)aName inParentNode:(OVNode *)aParentNode
{
    //This looks into the value of the column 0
    int childCount = [self outlineView:self numberOfChildrenOfItem:aParentNode];
    NSTableColumn *searchColumn = [[self tableColumns] objectAtIndex:0];
    for (int i=0;i<childCount;i++)
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
    int i = [indexes firstIndex];
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
    for (int i=0;i<[nodes count];i++)
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

- (void)setTag:(int)aNewTag
{
    if (aNewTag == [self tag])
        return;
    [super setTag:aNewTag];
    [_root setTag:aNewTag];
    [self reloadData];
}
@end

@implementation DraggableOutlineView
/* Initialization */
- (void)doInit
{
    [super doInit];
    _draggedNodes = nil;
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSStringPboardType]];
}

- (void)dealloc
{
    [self setDraggedNodes:nil];
    [super dealloc];
}

/* Drag source/dest protocol */
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    return NSDragOperationGeneric;
}

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    return NSDragOperationGeneric;
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    return NSDragOperationGeneric;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    DraggableOutlineView *source = [sender draggingSource];
    NSPoint mouseLoc = [self convertPoint:[sender draggingLocation] fromView:nil];
    OVNode *destNode = [self itemAtRow:[self rowAtPoint:mouseLoc]];
    BOOL r = [self performDragFrom:source withNodes:[source draggedNodes] to:destNode];
    [source selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    [self reloadData];
    if (source != self)
        [source reloadData];
    if ([self delegate] != nil)
        if ([[self delegate] respondsToSelector:@selector(outlineView:draggedFrom:)])
            [[self delegate] outlineView:self draggedFrom:source];
    return r;
}

/* Events override */
- (void)mouseDown:(NSEvent *)aEvent
{
    NSDate *limitDate = [NSDate date];
    /*For the first 0.3 seconds, we don't want a MouseDragged event to initiate
    a drag because makes the drag initiation too sensible. */
    limitDate = [limitDate addTimeInterval:0.3];
    NSEvent *mouseUp = [[self window] nextEventMatchingMask:NSLeftMouseUpMask untilDate:limitDate inMode:NSDefaultRunLoopMode dequeue:NO];
    if (mouseUp) //it's a click, do not go any further
        [super mouseDown:aEvent];
    else
    {
        /*For the next second, we look for what the next event will be, if it's
        a drag event, we drag, if it's a mouse_up event, we click, and if it's
        None, we drag.*/
        limitDate = [limitDate addTimeInterval:1.1];
        NSEvent *nextEvent = [[self window] nextEventMatchingMask:(NSLeftMouseUpMask|NSLeftMouseDraggedMask) 
            untilDate:limitDate inMode:NSDefaultRunLoopMode dequeue:NO];
        if (nextEvent && ([nextEvent type] == NSLeftMouseUp))
            [super mouseDown:aEvent];
        else
            [self mouseDragged:aEvent];
    }
}

- (void)mouseDragged:(NSEvent *)aEvent
{
    NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
    NSPoint mouseLoc = [self convertPoint:[aEvent locationInWindow] fromView:nil];
    NSPoint dragAt = NSMakePoint(mouseLoc.x - 26,mouseLoc.y + 8);
    int draggedRow = [self rowAtPoint:mouseLoc];
    if (draggedRow < 0)
        return; //Trying to drag empty space
    NSArray *draggedNodes = [self determineDraggedNodesForDraggedRow:draggedRow];
    if ((!draggedNodes) || (![draggedNodes count]))
        return;
    NSImage *baseDragImage = [self determineDragImage];
    if (!baseDragImage)
        return;
    NSColor *circleColor = [self determineDragCircleColor];
    [self setDraggedNodes:draggedNodes];
    NSImage *ghostedImage = [[[NSImage alloc] initWithSize:[baseDragImage size]] autorelease];
    [ghostedImage lockFocus];
    [baseDragImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy fraction:0.7];
    [ghostedImage unlockFocus];
    NSImage *cellImage = [Utils addCircleWithCount:[draggedNodes count] ofColor:circleColor 
        withTextColor:[NSColor whiteColor] toImage:ghostedImage];
    [pb declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:self];
    [pb setString:@"" forType:NSStringPboardType];
    [self dragImage:cellImage at:dragAt offset:NSZeroSize event:aEvent pasteboard:pb source:self slideBack:YES];
}

/* Virtual */
- (NSColor *)determineDragCircleColor
{
    //Override this to have the little circle ofer the drag image something else than red.
    //This is called just after determineDragImage.
    return [NSColor redColor];
}

- (NSArray *)determineDraggedNodesForDraggedRow:(int)aDraggedRow
{
    //Override this and return a list of the nodes that should be dragged.
    // It is called on mouseDragged.
    //If the result is empty or nil, no drag will take place.
    if ([[self selectedRowIndexes] containsIndex:aDraggedRow])
        //Drag everything that is selected
        return [self selectedNodes];
    else
        //Drag only what the mouse is currently pointing.
        return [NSArray arrayWithObject:[self itemAtRow:aDraggedRow]];
}

- (NSImage *)determineDragImage
{
    //Override this and return a base drag image. This image will be ghosted and a little circle with
    //the number of dragged nodes will be added to it.
    //If the result is nil, no drag will take place.
    return nil;
}
- (BOOL)performDragFrom:(DraggableOutlineView *)aSource withNodes:(NSArray *)aSourceNodes to:(OVNode *)aDestNode
{
    //Override this and perform the drag operation. Return YES if the drag operation could be performed.
    return NO;
}


/* Properties */
- (NSArray *)draggedNodes {return _draggedNodes;}
- (void)setDraggedNodes:(NSArray *)aNodes
{
    if (_draggedNodes)
        [_draggedNodes release];
    _draggedNodes = [aNodes retain];
}
@end
