/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "PyApp.h"

@interface OVNode: NSObject
{
    NSArray *_buffer;
    NSMutableArray *_children;
    int _index;
    NSIndexPath *_indexPath;
    int _marked;
    int _ovTag;
    int _level;
    int _maxLevel;
    OVNode *_parent;
    PyApp *_py;
}
// childrenCount == -1 if you don't know
- (id)initWithParent:(OVNode *)aParent index:(int)aIndex childrenCount:(int)aChildrenCount;
- (void)dealloc;

- (OVNode *)getChildAtIndex:(int)aIndex;
- (OVNode *)nodeAtPath:(NSIndexPath *)path;
- (void)invalidateMarkingRecursively:(BOOL)aRecursive;
- (BOOL)isMarked;
- (BOOL)isMarkable;
- (int)level;
- (int)maxLevel;
- (int)childrenCount;
- (void)resetAllBuffers;

- (NSArray *)buffer;
- (void)setBuffer:(NSArray *)aBuffer;
- (int)index;
- (NSIndexPath *)indexPath;
- (OVNode *)parent;

- (int)tag;
- (void)setTag:(int)aNewTag;
- (PyApp *)py;
- (void)setPy:(PyApp *)aNewPy;
@end

@interface ArrowlessBrowserCell : NSBrowserCell
@end;

@interface OutlineView : NSOutlineView
{
    IBOutlet PyApp *py;
    
    OVNode *_root;
}
- (void)doInit;
- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
/* Public */
- (OVNode *)findNodeWithName:(NSString *)aName inParentNode:(OVNode *)aParentNode;
- (void)invalidateBuffers;
- (void)invalidateMarkings;
- (void)makeImagedColumnWithId:(NSString *)aId;
- (NSArray *)selectedNodes;
- (NSArray *)selectedNodePaths;
- (void)selectNodePaths:(NSArray *)nodePaths;

/* Properties */
- (PyApp *)py;
- (void)setPy:(PyApp *)aPy;
@end

@interface DraggableOutlineView : OutlineView
{
    NSArray *_draggedNodes;
}
/* Virtual */
- (NSColor *)determineDragCircleColor;
- (NSArray *)determineDraggedNodesForDraggedRow:(int)aDraggedRow;
- (NSImage *)determineDragImage;
- (BOOL)performDragFrom:(DraggableOutlineView *)aSource withNodes:(NSArray *)aSourceNodes to:(OVNode *)aDestNode;

/* Properties */
- (NSArray *)draggedNodes;
- (void)setDraggedNodes:(NSArray *)aNodes;
@end

@protocol DraggableOutlineViewDelegate
- (void)outlineView:(DraggableOutlineView *)aDest draggedFrom:(DraggableOutlineView *)aDest;
@end
