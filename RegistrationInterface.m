/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "RegistrationInterface.h"
#import "Dialogs.h"
#import "Utils.h"

@implementation RegistrationInterface
+ (BOOL)showNagWithApp:(PyRegistrable *)app
{
    BOOL r = YES;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *code = [ud stringForKey:@"RegisteredCode"];
    if (code == nil)
        code = @"";
    NSString *email = [ud stringForKey:@"RegisteredEmail"];
    if (email == nil)
        email = @"";
    [app setRegisteredCode:code andEmail:email];
    if (![app isRegistered])
    {
        RegistrationInterface *ri = [[RegistrationInterface alloc] initWithApp:app];
        r = [ri showNag];
        [ri release];
    }
    return r;
}

- (id)initWithApp:(PyRegistrable *)aApp
{
    self = [super init];
    _nib = [[NSNib alloc] initWithNibNamed:@"registration" bundle:[NSBundle bundleForClass:[self class]]];
    app = aApp;
    [_nib instantiateNibWithOwner:self topLevelObjects:nil];
    [nagPanel update];
    [codePanel update];
    [nagPanel setTitle:[NSString stringWithFormat:[nagPanel title],[app appName]]];
    [nagTitleTextField setStringValue:[NSString stringWithFormat:[nagTitleTextField stringValue],[app appName]]];
    [nagPromptTextField setStringValue:[NSString stringWithFormat:[nagPromptTextField stringValue],[app appName]]];
    [codePromptTextField setStringValue:[NSString stringWithFormat:[codePromptTextField stringValue],[app appName]]];
    [limitDescriptionTextField setStringValue:[app demoLimitDescription]];
    return self;
}

- (void)dealloc
{
    [_nib release];
    [super dealloc];
}

- (IBAction)buyNow:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.hardcoded.net/purchase.htm"]];
}

- (IBAction)cancelCode:(id)sender
{
    [codePanel close];
    [NSApp stopModalWithCode:NSCancelButton];
}

- (IBAction)enterCode:(id)sender
{
    [nagPanel close];
    [NSApp stopModalWithCode:NSOKButton];
}

- (IBAction)submitCode:(id)sender
{
    [submitButton setEnabled:NO];
    NSString *code = [codeTextField stringValue];
    NSString *email = [emailTextField stringValue];
    NSString *errorMsg = [app isCodeValid:code withEmail:email];
    if (errorMsg == nil)
    {
        [codePanel close];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setValue:code forKey:@"RegisteredCode"];
        [ud setValue:email forKey:@"RegisteredEmail"];
        [app setRegisteredCode:code andEmail:email];
        [Dialogs showMessage:@"Your code is valid. Thanks!"];
        [NSApp stopModalWithCode:NSOKButton];
    }
    else
    {
        [Dialogs showMessage:errorMsg];
    }
    [submitButton setEnabled:YES];
}

- (IBAction)tryDemo:(id)sender
{
    [nagPanel close];
    [NSApp stopModalWithCode:NSCancelButton];
}

- (BOOL)showNag
{
    NSInteger r;
    while (YES)
    {
        r = [NSApp runModalForWindow:nagPanel];
        if (r == NSOKButton)
        {
            r = [self enterCode];
            if (r == NSOKButton)
                return YES;
        }
        else
            return NO;
    }
}

- (NSInteger)enterCode
{
    return [NSApp runModalForWindow:codePanel];
}

@end
