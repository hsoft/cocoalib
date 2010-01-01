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
+ (BOOL)showNagWithApp:(PyRegistrable *)app name:(NSString *)appName limitDescription:(NSString *)limitDescription
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
        RegistrationInterface *ri = [[RegistrationInterface alloc] initWithApp:app name:appName
            limitDescription:limitDescription];
        r = [ri showNag];
        [ri release];
    }
    return r;
}

- (id)initWithApp:(PyRegistrable *)aApp name:(NSString *) appName limitDescription:(NSString *)limitDescription
{
    self = [super init];
    _nib = [[NSNib alloc] initWithNibNamed:@"registration" bundle:[NSBundle bundleForClass:[self class]]];
    app = aApp;
    [_nib instantiateNibWithOwner:self topLevelObjects:nil];
    [nagPanel update];
    [codePanel update];
    [nagPanel setTitle:[NSString stringWithFormat:[nagPanel title],appName]];
    [nagTitleTextField setStringValue:[NSString stringWithFormat:[nagTitleTextField stringValue],appName]];
    [nagPromptTextField setStringValue:[NSString stringWithFormat:[nagPromptTextField stringValue],appName]];
    [codePromptTextField setStringValue:[NSString stringWithFormat:[codePromptTextField stringValue],appName]];
    [limitDescriptionTextField setStringValue:limitDescription];
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
    BOOL r = [app isCodeValid:code withEmail:email];
    if (r)
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
        NSString *msg = @"Your code is invalid. Make sure that you wrote the good code. Also make sure that the e-mail you gave is the same as the e-mail you used for your purchase.";
        // Try with other app ids to see if the user just used a wrong key
        // NSArray *appIds = [NSArray arrayWithObjects:i2n(DUPEGURU_ID),i2n(DUPEGURU_ME_ID),i2n(DUPEGURU_PE_ID),i2n(MUSICGURU_ID),i2n(MONEYGURU_ID),nil];
        // NSArray *appNames = [NSArray arrayWithObjects:DUPEGURU_NAME,DUPEGURU_ME_NAME,DUPEGURU_PE_NAME,MUSICGURU_NAME,MONEYGURU_NAME,nil];
        // for (int i=0; i<[appIds count];i++)
        // {
        //     int appId = n2i([appIds objectAtIndex:i]);
        //     if ([isa isCode:code validForEmail:email appId:appId])
        //     {
        //         NSString *appName = [appNames objectAtIndex:i];
        //         msg = [NSString stringWithFormat:@"This code is a %@ code. You can download it at http://www.hardcoded.net",appName];
        //         break;
        //     }
        // }
        [Dialogs showMessage:msg];
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
    int r;
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

- (int)enterCode
{
    return [NSApp runModalForWindow:codePanel];
}

@end
