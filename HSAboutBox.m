/* 
Copyright 2011 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSAboutBox.h"
#import "HSFairwareReminder.h"

@implementation HSAboutBox
- (id)initWithApp:(PyFairware *)aApp
{
    self = [super initWithWindowNibName:@"about"];
    [self window];
    app = [aApp retain];
    [self updateFields];
    return self;
}

- (void)dealloc
{
    [app release];
    [super dealloc];
}

- (void)updateFields
{
    [titleTextField setStringValue:[app appName]];
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    [versionTextField setStringValue:[NSString stringWithFormat:@"Version: %@",version]];
    NSString *copyright = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSHumanReadableCopyright"];
    [copyrightTextField setStringValue:copyright];
    if ([app isRegistered]) {
        [registeredTextField setHidden:NO];
        [registerButton setHidden:YES];
    }
    else {
        [registeredTextField setHidden:YES];
        [registerButton setHidden:NO];
    }    
}

- (IBAction)showRegisterDialog:(id)sender
{
    HSFairwareReminder *fr = [[HSFairwareReminder alloc] initWithApp:app];
    [fr enterCode];
    [fr release];
    [self updateFields];
}
@end
