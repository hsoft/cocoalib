/* 
Copyright 2010 Hardcoded Software (http://www.hardcoded.net)

This software is licensed under the "BSD" License as described in the "LICENSE" file, 
which should be included with this package. The terms are also available at 
http://www.hardcoded.net/licenses/bsd_license
*/

#import "ProgressController.h"
#import "Utils.h"

NSString *JobCompletedNotification = @"JobCompletedNotification";
NSString *JobCancelledNotification = @"JobCancelledNotification";
static ProgressController *_mainPC = nil;

@implementation ProgressController
+ (ProgressController *)mainProgressController
{
    if (_mainPC == nil)
        _mainPC = [[ProgressController alloc] init];
    return _mainPC;
}

- (id)init
{
    self = [super initWithWindowNibName:@"progress"];
    [self window]; // initialize outlets
    [progressBar setUsesThreadedAnimation:YES];
    _worker = nil;
    _running = NO;
    return self;
}

- (IBAction)cancel:(id)sender
{
    [self hide];
}

- (void)hide
{
    if (_worker != nil)
        [_worker cancelJob];
    [[NSNotificationCenter defaultCenter] postNotificationName:JobCancelledNotification object:self];
    [NSApp endSheet:[self window]];
    [[self window] close];
    _running = NO;
}

- (void)show
{
    [self showWithCancelButton:YES];
}

- (void)showWithCancelButton:(BOOL)cancelEnabled
{
    [progressBar setIndeterminate:YES];
    [[self window] makeKeyAndOrderFront:nil];
    [progressBar setUsesThreadedAnimation:YES];
    [progressBar startAnimation:nil];
    [cancelButton setEnabled:cancelEnabled];
    _running = YES;
    [NSThread detachNewThreadSelector:@selector(threadedWorkerProbe) toTarget:self withObject:nil];
}

- (void)showSheetForParent:(NSWindow *) parentWindow
{
    [self showSheetForParent:parentWindow withCancelButton:YES];
}

- (void)showSheetForParent:(NSWindow *) parentWindow withCancelButton:(BOOL)cancelEnabled
{
    [progressBar setIndeterminate:YES];
    [progressBar startAnimation:nil];
    [cancelButton setEnabled:cancelEnabled];
    _running = YES;
    [NSThread detachNewThreadSelector:@selector(threadedWorkerProbe) toTarget:self withObject:nil];
    [NSApp beginSheet:[self window] modalForWindow:parentWindow modalDelegate:NULL didEndSelector:NULL contextInfo:NULL];
}

- (void)updateProgress
{
    if (!_running)
        return;
    NSNumber *progress = [_worker getJobProgress];
    NSString *status = [_worker getJobDesc];
    if ((status != nil) && ([status length] > 0))
    {
        [statusText setStringValue:status];
    }
    if (progress != nil)
    {
        [progressBar setDoubleValue:n2i(progress)];
        [progressBar setIndeterminate: n2i(progress) < 0];
    }
    else
    {
        [self hide];
        [[NSNotificationCenter defaultCenter] postNotificationName:JobCompletedNotification object:self];
    }
}

- (void)threadedWorkerProbe
{
    while (_running && (_worker != nil))
    {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        [self performSelectorOnMainThread:@selector(updateProgress) withObject:nil waitUntilDone:YES];
        [pool release];
    }
}

/* Properties */
- (BOOL)isShown
{
    return _running;
}

- (id)jobId {return _jobId;}
- (void)setJobId:(id)jobId
{
    [_jobId autorelease];
    _jobId = [jobId retain];
}

- (void)setJobDesc:(NSString *)desc
{
    [descText setStringValue:desc];
    [statusText setStringValue:@"Please wait..."];
}

- (void)setWorker:(NSObject<Worker> *)worker
{
    _worker = worker;
}
@end
