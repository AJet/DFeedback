//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------

@class DFKeyTabView;
@class DFBounceIconView;
@class DFSystemProfileFetcher;
@class DFFeedbackSender;
@class DFPlaceholderTextView;

//-------------------------------------------------------------------------------------------------
// Feedback window controller
//-------------------------------------------------------------------------------------------------
@interface DFFeedbackWindowController : NSWindowController 
//-------------------------------------------------------------------------------------------------
{
	// tab control
	IBOutlet NSSegmentedControl* tabsSegmentedControl;
	IBOutlet DFKeyTabView* tabView;
    
	// text view
	IBOutlet NSView* textContainer;
	IBOutlet DFPlaceholderTextView* textView;
    
	// system profile controls
	IBOutlet NSView* systemProfileContainer;
	IBOutlet NSButton* includeSystemProfileCheckBox;
    
	// email controls
	IBOutlet NSButton* includeEmailCheckBox;
	IBOutlet NSComboBox* emailComboBox;
	IBOutlet DFBounceIconView* emailBounceIcon;
    
	// progress controls
	IBOutlet NSView* progressContainer;
	IBOutlet NSProgressIndicator* progressIndicator;
	IBOutlet NSTextField* sendingProgressLabel;
	IBOutlet NSTextField* profilingProgressLabel;
    
	// footer controls
	IBOutlet NSButton* sendButton;
    
	// details window controls
	IBOutlet NSWindow* detailsWindow;
	IBOutlet NSView* detailsTextContainer;
	IBOutlet NSTextView* detailsTextView;
	IBOutlet NSProgressIndicator* detailsProgressIndicator;
	IBOutlet NSTextField* detailsProgressLabel;
	
	// workers
	DFSystemProfileFetcher* _systemProfileFetcher;
	DFFeedbackSender* _feedbackSender;
	BOOL _isSendingReport;
}

//-------------------------------------------------------------------------------------------------
// Initialization, call before first use
+ (void)initializeWithFeedbackURL:(NSString*)feedbackURL;

//-------------------------------------------------------------------------------------------------
// Shows the feedback window on the specified tab
+ (void)showGeneralQuestion;
+ (void)showBugReport;
+ (void)showFeatureRequest;
// default first page
+ (void)show;

@end
