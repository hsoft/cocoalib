/* 
Copyright 2009 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import <Cocoa/Cocoa.h>

/*
This whole class exists because up until 10.5, NSTableColumn doesn't have a setHidden: method. That
sucks because we have to add/remove columns in a complicated way to preserve order and stuff.

It's in cocoalib because it should also be used in dupeguru at some point.
*/
@interface HSTableColumnManager : NSObject {
    NSTableView *table;
    NSMutableArray *columns;
    NSMutableDictionary *defaulName2Column;
}

- (id)initWithTable:(NSTableView *)table;

- (NSTableColumn *)getColumn:(NSString *)columnId;
- (BOOL)isColumnVisible:(NSString *)columnId;
- (void)linkColumn:(NSString *)columnId toUserDefault:(NSString *)udName;
- (void)setColumn:(NSString *)columnId visible:(BOOL)visible;
- (void)toggleColumnVisibility:(NSString *)columnId;

@end