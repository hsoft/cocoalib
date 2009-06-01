//
//  ValueTransformers.h
//  dupeguru
//
//  Created by Virgil Dupras on 2006/02/09.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface VTIsIntIn :  NSValueTransformer
{
    NSIndexSet *ints;
    BOOL reverse;
}
- (id)initWithValues:(NSIndexSet *)values;
- (id)initWithValues:(NSIndexSet *)values reverse:(BOOL)doReverse;
@end

@interface HSVTAdd : NSValueTransformer
{
    int toAdd;
}
- (id)initWithValue:(int)value;
@end
