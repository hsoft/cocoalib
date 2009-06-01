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
