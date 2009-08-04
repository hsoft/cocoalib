/* 
Copyright 2009 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "Dialogs.h"

@implementation Dialogs
+ (void)showMessage:(NSString *)message
{
    NSAlert *a = [[NSAlert alloc] init];
    [a addButtonWithTitle:@"OK"];
    [a setMessageText:message];
    [a runModal];
    [a release];
}

+ (int)askYesNo:(NSString *)message
{
    NSAlert *a = [[NSAlert alloc] init];
    [a addButtonWithTitle:@"Yes"];
    [[a addButtonWithTitle:@"No"] setKeyEquivalent:@"\E"];
    [a setMessageText:message];
    int r = [a runModal];
    [a release];
    return r;
}
@end
