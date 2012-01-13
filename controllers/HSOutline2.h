/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>
#import "HSOutlineView.h"
#import "PyOutline2.h"
#import "NSIndexPathAdditions.h"

@interface HSOutline2 : NSObject <HSOutlineViewDelegate, NSOutlineViewDataSource> {
    PyOutline2 *py;
    HSOutlineView *outlineView;
    NSMutableDictionary *itemData;
    NSMutableSet *itemRetainer;
}
- (id)initWithPy:(PyOutline2 *)aPy view:(HSOutlineView *)aOutlineView;
- (PyOutline2 *)py;
- (HSOutlineView *)outlineView;

/* Public */
- (void)refresh;
- (NSIndexPath *)selectedIndexPath;
- (NSArray *)selectedIndexPaths;
- (NSString *)dataForCopyToPasteboard;
- (void)startEditing;
- (void)stopEditing;
- (void)updateSelection;

/* Caching */
- (id)property:(NSString *)property valueAtPath:(NSIndexPath *)path;
- (void)setProperty:(NSString *)property value:(id)value atPath:(NSIndexPath *)path;
- (NSString *)stringProperty:(NSString *)property valueAtPath:(NSIndexPath *)path;
- (void)setStringProperty:(NSString *)property value:(NSString *)value atPath:(NSIndexPath *)path;
- (BOOL)boolProperty:(NSString *)property valueAtPath:(NSIndexPath *)path;
- (void)setBoolProperty:(NSString *)property value:(BOOL)value atPath:(NSIndexPath *)path;
- (NSInteger)intProperty:(NSString *)property valueAtPath:(NSIndexPath *)path;
- (void)setIntProperty:(NSString *)property value:(int)value atPath:(NSIndexPath *)path;
- (void)refreshItemAtPath:(NSIndexPath *)path;
@end