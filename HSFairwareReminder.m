/* 
Copyright 2013 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "HSFairwareReminder.h"
#import "HSFairwareReminder_UI.h"
#import "HSDemoReminder_UI.h"
#import "HSEnterCode_UI.h"
#import "Dialogs.h"
#import "Utils.h"

@implementation HSFairwareReminder

@synthesize codePanel;
@synthesize codePromptTextField;
@synthesize codeTextField;
@synthesize emailTextField;
@synthesize registerOperatingSystemButton;
@synthesize fairwareNagPanel;
@synthesize fairwarePromptTextField;
@synthesize fairwareUnpaidHoursTextField;
@synthesize demoNagPanel;
@synthesize demoPromptTextField;

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
    app = aApp;
    [self setFairwareNagPanel:createHSFairwareReminder_UI(self)];
    [self setDemoNagPanel:createHSDemoReminder_UI(self)];
    [self setCodePanel:createHSEnterCode_UI(self)];
    [codePanel update];
    [codePromptTextField setStringValue:fmt([codePromptTextField stringValue],[app appName])];
    return self;
}

- (void)contribute
{
    [app contribute];
}

- (void)buy
{
    [app buy];
}

- (void)moreInfo
{
    [app aboutFairware];
}

- (void)cancelCode
{
    [codePanel close];
    [NSApp stopModalWithCode:NSCancelButton];
}

- (void)showEnterCode
{
    [fairwareNagPanel close];
    [demoNagPanel close];
    [NSApp stopModalWithCode:NSOKButton];
}

- (void)submitCode
{
    NSString *code = [codeTextField stringValue];
    NSString *email = [emailTextField stringValue];
    BOOL registerOperatingSystem = [registerOperatingSystemButton state] == NSOnState;
    if ([app setRegisteredCode:code andEmail:email registerOS:registerOperatingSystem]) {
        [codePanel close];
        [NSApp stopModalWithCode:NSOKButton];
    }
}

- (void)closeDialog
{
    [fairwareNagPanel close];
    [demoNagPanel close];
    [NSApp stopModalWithCode:NSCancelButton];
}

- (BOOL)showNagPanel:(NSWindow *)panel;
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
