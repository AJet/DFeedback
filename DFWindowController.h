//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008-2011 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <Cocoa/Cocoa.h>

//-------------------------------------------------------------------------------------------------

@class DFSystemProfileFetcher;
@class DFFeedbackSender;
@class DFPlaceholderTextView;
@class DFBounceIconView;
@class DFKeyTabView;

//-------------------------------------------------------------------------------------------------
// Feedback window controller
//-------------------------------------------------------------------------------------------------
@interface DFWindowController : NSWindowController 
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
	DFSystemProfileFetcher* m_systemProfileFetcher;
	DFFeedbackSender* m_feedbackSender;
	bool m_isSendingReport;
}

//-------------------------------------------------------------------------------------------------
// Public methods
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

//-------------------------------------------------------------------------------------------------
// Private actions (visible for IB)
//-------------------------------------------------------------------------------------------------
- (IBAction)sendReport:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)includeEmailCheckBoxChanged:(id)sender;
- (IBAction)emailChanged:(id)sender;
- (IBAction)tabsSegmentedControlChanged:(id)sender;
- (IBAction)showDetails:(id)sender;
@end
