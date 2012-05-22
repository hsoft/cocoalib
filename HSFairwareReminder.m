/* 
Copyright 2012 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSFairwareReminder.h"
#import "Dialogs.h"
#import "Utils.h"

@implementation HSFairwareReminder
+ (BOOL)showFairwareNagWithApp:(id <HSFairwareProtocol>)app prompt:(NSString *)prompt
{
    HSFairwareReminder *fr = [[HSFairwareReminder alloc] initWithApp:app];
    BOOL r = [fr showFairwareNagPanelWithPrompt:prompt];
    [fr release];
    return r;
}

+ (BOOL)showDemoNagWithApp:(id <HSFairwareProtocol>)app prompt:(NSString *)prompt
{
    HSFairwareReminder *fr = [[HSFairwareReminder alloc] initWithApp:app];
    BOOL r = [fr showDemoNagPanelWithPrompt:prompt];
    [fr release];
    return r;
}

- (id)initWithApp:(id <HSFairwareProtocol>)aApp
{
    self = [super init];
    _nib = [[NSNib alloc] initWithNibNamed:@"FairwareReminder" bundle:[NSBundle bundleForClass:[self class]]];
    app = aApp;
    [_nib instantiateNibWithOwner:self topLevelObjects:nil];
    [codePanel update];
    [codePromptTextField setStringValue:fmt([codePromptTextField stringValue],[app appName])];
    return self;
}

- (void)dealloc
{
    [_nib release];
    [super dealloc];
}

- (IBAction)contribute:(id)sender
{
    [app contribute];
}

- (IBAction)buy:(id)sender
{
    [app buy];
}

- (IBAction)moreInfo:(id)sender
{
    [app aboutFairware];
}

- (IBAction)cancelCode:(id)sender
{
    [codePanel close];
    [NSApp stopModalWithCode:NSCancelButton];
}

- (IBAction)enterCode:(id)sender
{
    [fairwareNagPanel close];
    [demoNagPanel close];
    [NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)submitCode:(id)sender
{
    NSString *code = [codeTextField stringValue];
    NSString *email = [emailTextField stringValue];
    BOOL registerOperatingSystem = [registerOperatingSystemButton state] == NSOnState;
    if ([app setRegisteredCode:code andEmail:email registerOS:registerOperatingSystem]) {
        [codePanel close];
        [NSApp stopModalWithCode:NSOKButton];
    }
}

- (IBAction)closeDialog:(id)sender
{
    [fairwareNagPanel close];
    [demoNagPanel close];
    [NSApp stopModalWithCode:NSCancelButton];
}

- (BOOL)showNagPanel:(NSPanel *)panel;
{
    NSInteger r;
    while (YES) {
        r = [NSApp runModalForWindow:panel];
        if (r == NSOKButton) {
            r = [self enterCode];
            if (r == NSOKButton) {
                return YES;
            }
        }
        else {
            return NO;
        }
    }
}

- (BOOL)showFairwareNagPanelWithPrompt:(NSString *)prompt
{
    [fairwareNagPanel update];
    [fairwareNagPanel setTitle:fmt([fairwareNagPanel title],[app appName])];
    [fairwareUnpaidHoursTextField setStringValue:fmt([fairwareUnpaidHoursTextField stringValue],n2f([app unpaidHours]))];
    [fairwarePromptTextField setStringValue:prompt];
    return [self showNagPanel:fairwareNagPanel];
}

- (BOOL)showDemoNagPanelWithPrompt:(NSString *)prompt
{
    [demoNagPanel setTitle:fmt([demoNagPanel title],[app appName])];
    [demoPromptTextField setStringValue:prompt];
    return [self showNagPanel:demoNagPanel];
}

- (NSInteger)enterCode
{
    return [NSApp runModalForWindow:codePanel];
}

@end
