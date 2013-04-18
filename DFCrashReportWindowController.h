//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>
#import "DFLinkLabelDelegate.h"
#import "DFSystemProfileDataType.h"

//-------------------------------------------------------------------------------------------------
// Crash report window controller
@interface DFCrashReportWindowController : NSWindowController<DFLinkLabelDelegate, NSAnimationDelegate>

// Initialization, call before first use
+ (void)initializeWithFeedbackUrl:(NSString*)feedbackUrl
                        updateUrl:(NSString*)updateUrl
                             icon:(NSImage*)icon
           systemProfileDataTypes:(DFSystemProfileDataType)systemProfileDataTypes;

// Singleton
+ (DFCrashReportWindowController*)singleton;

// Shows the crash report window for the specified exception
- (void)showReportForException:(NSException*)exception;


@end
