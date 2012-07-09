//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------

@class DFSystemProfileFetcher;
@class DFFeedbackSender;
@class DFPlaceholderTextView;

//-------------------------------------------------------------------------------------------------
// Crash report window controller
//-------------------------------------------------------------------------------------------------
@interface DFCrashReportWindowController : NSWindowController 
{
    // icon
    IBOutlet NSImageView* iconImageView;
	
    // comments controls
    IBOutlet NSView* commentsBoxView;
	IBOutlet NSButton* commentsDisclosureButton;
	IBOutlet NSScrollView* commentsScrollView;
	IBOutlet DFPlaceholderTextView* commentsTextView;

    // details controls
	IBOutlet NSView* detailsBoxView;
	IBOutlet NSButton* detailsDisclosureButton;
	IBOutlet NSScrollView* detailsScrollView;
	IBOutlet NSTextView* detailsTextView;
	
    // progress controls
	IBOutlet NSProgressIndicator* progressIndicator;
	IBOutlet NSTextField* fetchingSystemProfileProgressLabel;
	IBOutlet NSTextField* sendingReportProgressLabel;
	IBOutlet NSTextField* anonymousLabel;
    
    // footer controls
	IBOutlet NSButton* sendButton;
	
    // workers
	DFSystemProfileFetcher* _systemProfileFetcher;
	DFFeedbackSender* _feedbackSender;
    
    // stored info and flags
	NSString* _exceptionMessage;
    NSString* _exceptionStackTrace;
	BOOL _sendButtonWasClicked;
	BOOL _cancelButtonWasClicked;
}

//-------------------------------------------------------------------------------------------------
// Public methods
//-------------------------------------------------------------------------------------------------
// Initialization, call before first use
+ (void)initializeWithFeedbackURL:(NSString*)feedbackURL
                             icon:(NSImage*)icon;

//-------------------------------------------------------------------------------------------------
// Singleton
+ (DFCrashReportWindowController*)singleton;

//-------------------------------------------------------------------------------------------------
// Shows the crash report window for the specified exception
- (void)showReportForException:(NSException*)exception;


@end
