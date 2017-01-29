//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFCrashReportWindowController.h"
#import "DFSystemProfileFetcher.h"
#import "DFFeedbackSenderDelegate.h"
#import "DFFeedbackSender.h"
#import "DFPlaceholderTextView.h"
#import "DFLinkLabel.h"
#import "DFStyleSheet.h"
#import "DFApplication.h"
#import "StringAnonymizer.h"
#import "LiteralHelpers.h"

//-------------------------------------------------------------------------------------------------
static NSString* const kNibName = @"DFCrashReportWindow";

//-------------------------------------------------------------------------------------------------
static DFCrashReportWindowController* _singleton = nil;
static NSImage* _icon = nil;
static NSString* _feedbackUrl = nil;
static NSString* _updateUrl = nil;
static DFSystemProfileDataType _systemProfileDataTypes = DFSystemProfileData_All;

//-------------------------------------------------------------------------------------------------
@interface DFCrashReportWindowController()
// icon
@property (nonatomic, assign) IBOutlet NSImageView* iconImageView;

// comments controls
@property (nonatomic, assign) IBOutlet NSView* commentsBoxView;
@property (nonatomic, assign) IBOutlet NSButton* commentsDisclosureButton;
@property (nonatomic, assign) IBOutlet NSScrollView* commentsScrollView;
@property (nonatomic, assign) IBOutlet DFPlaceholderTextView* commentsTextView;

// details controls
@property (nonatomic, assign) IBOutlet NSView* detailsBoxView;
@property (nonatomic, assign) IBOutlet NSButton* detailsDisclosureButton;
@property (nonatomic, assign) IBOutlet NSScrollView* detailsScrollView;
@property (nonatomic, assign) IBOutlet NSTextView* detailsTextView;

// update link label
@property (nonatomic, assign) IBOutlet NSTextField* updateLabel;

// progress controls
@property (nonatomic, assign) IBOutlet NSProgressIndicator* progressIndicator;
@property (nonatomic, assign) IBOutlet NSTextField* fetchingSystemProfileProgressLabel;
@property (nonatomic, assign) IBOutlet NSTextField* sendingReportProgressLabel;
@property (nonatomic, assign) IBOutlet NSTextField* anonymousLabel;

// footer controls
@property (nonatomic, assign) IBOutlet NSButton* sendButton;

// exception data
@property (nonatomic, retain) NSString* exceptionMessage;
@property (nonatomic, retain) NSString* exceptionStackTrace;
@property (nonatomic, retain) NSString* systemProfile;

@end

//-------------------------------------------------------------------------------------------------
@implementation DFCrashReportWindowController
{
    // runtime controls
    DFLinkLabel* _updateLinkLabel;
	
    // workers
	DFSystemProfileFetcher* _systemProfileFetcher;
	DFFeedbackSender* _feedbackSender;
    
    // stored info and flags
	BOOL _sendButtonWasClicked;
	BOOL _cancelButtonWasClicked;
    
    // animations
    NSViewAnimation* _windowAnimation;
    
    // saved sizes
    CGFloat _detailsTextViewDefaultHeight;
    CGFloat _commentsTextViewDefaultHeight;
}

//-------------------------------------------------------------------------------------------------
+ (void)initializeWithFeedbackUrl:(NSString*)feedbackUrl
                        updateUrl:(NSString*)updateUrl
                             icon:(NSImage*)icon
           systemProfileDataTypes:(DFSystemProfileDataType)systemProfileDataTypes;
{
    [icon retain];
    [_icon release];
    _icon = icon;
    
    [feedbackUrl retain];
    [_feedbackUrl release];
    _feedbackUrl = feedbackUrl;

    [updateUrl retain];
    [_updateUrl release];
    _updateUrl = updateUrl;
    
    _systemProfileDataTypes = systemProfileDataTypes;
}

//-------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super initWithWindowNibName:kNibName];
    if (self != nil) 
	{
		_systemProfileFetcher = [[DFSystemProfileFetcher alloc] init];
        _systemProfileFetcher.delegate = self;
    }
    return self;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[self cancelPendingStuff];
    [_exceptionMessage release];
    [_exceptionStackTrace release];
    [_systemProfile release];
    [_updateLinkLabel release];
    _windowAnimation.delegate = nil;
    [_windowAnimation release];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
+ (DFCrashReportWindowController*)singleton
{
	if (_singleton == nil)
	{
        InitializeDFStyles();
        
		_singleton = [[DFCrashReportWindowController alloc] init];
	}
	return _singleton;
}


//-------------------------------------------------------------------------------------------------
- (void)initializeControls
{
	_sendButtonWasClicked = NO;
	_cancelButtonWasClicked = NO;
    
	_sendButton.enabled = YES;
    
    NSString* details = [NSString stringWithFormat:@"MESSAGE:\n%@\n\nSTACK TRACE:\n%@", _exceptionMessage, _exceptionStackTrace];
	_detailsTextView.textStorage.attributedString = [[[NSAttributedString alloc] initWithString:details] autorelease];
    
    _detailsDisclosureButton.state = NSOffState;
    
	[self expandOrCollapseBox:_detailsBoxView
					 textView:_detailsScrollView
        textViewDefaultHeight:_detailsTextViewDefaultHeight
				 alternateBox:_commentsBoxView
	   shouldCollapseOrExpand:NO
			   isLowerOrUpper:NO
				withAnimation:NO];
    
    [self beginFetchingSystemProfile];
}

//-------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
	[self.window setContentBorderThickness:DFCrashReportWindow_bottomBarHeight forEdge: NSMinYEdge];
	
	NSString* windowTitle = self.window.title;
	windowTitle = [NSString stringWithFormat:windowTitle, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]];
	self.window.title = windowTitle;
    
    _iconImageView.image = _icon;
    
	_commentsTextView.placeholderText = NSLocalizedStringFromTable(@"DFeedback_PlaceholderText", @"DFLocalizable", nil);
    
    // replace update label with link label
    if (_updateLabel != nil)
    {
        if (_updateUrl != nil)
        {
            _updateLinkLabel = [[DFLinkLabel alloc] initWithTextField:_updateLabel];
            _updateLinkLabel.delegate = self;
            [_updateLabel.superview replaceSubview:_updateLabel with:_updateLinkLabel];
        }
        else
        {
            // no update url, simply remove
            [_updateLabel removeFromSuperview];
        }
    }

    // save some sizes
    _detailsTextViewDefaultHeight = _detailsTextView.frame.size.height;
    _commentsTextViewDefaultHeight = _commentsTextView.frame.size.height;

    
    // make sure the key view loop is correct after all manipulations
    [self.window recalculateKeyViewLoop];
}

//-------------------------------------------------------------------------------------------------
- (void)showReportForException:(NSException*)exception
           exceptionStackTrace:(NSString*)exceptionStackTrace
{
    // save exception
    self.exceptionMessage = exception.reason;
    self.exceptionStackTrace = AnonymizeString(exceptionStackTrace);
	
	// center the window
	NSWindow* window = self.window;
	if (!window.isVisible)
	{
		[window center];
	}
	
	// show window
	[self initializeControls];
    [NSApp runModalForWindow:window];
}

//-------------------------------------------------------------------------------------------------
- (void)beginFetchingSystemProfile
{
    self.systemProfile = nil;
    _fetchingSystemProfileProgressLabel.hidden = NO;
    [_progressIndicator startAnimation:nil];
    [_systemProfileFetcher fetchDataTypes:_systemProfileDataTypes];
}

//-------------------------------------------------------------------------------------------------
- (void)beginSendingFeedback
{
	// update controls
	_anonymousLabel.hidden = YES;
	[_progressIndicator startAnimation:nil];
	_progressIndicator.hidden = NO;
	_sendingReportProgressLabel.hidden = NO;
	_sendButton.enabled = NO;

	// begin sending feedback
    NSString* feedbackText = [NSString stringWithFormat:@"MESSAGE:\n%@\n\nCOMMENTS:\n%@\n\nSTACK TRACE:\n%@", 
                              _exceptionMessage, 
                              _commentsTextView.textStorage.string,
                              _exceptionStackTrace];
    [_feedbackSender cancel];
    _feedbackSender.delegate = nil;
    [_feedbackSender release];
    _feedbackSender = nil;
    
	_feedbackSender = [[DFFeedbackSender alloc] init];
    _feedbackSender.delegate = self;
	[_feedbackSender sendFeedbackToUrl:_feedbackUrl
                          feedbackText:feedbackText
                          feedbackType:@"Crash"
                         systemProfile:_systemProfile
                             userEmail:nil];
}

//-------------------------------------------------------------------------------------------------
- (void)cancelPendingStuff
{
	[_systemProfileFetcher cancel];
    _systemProfileFetcher.delegate = nil;
	[_systemProfileFetcher release];
	_systemProfileFetcher = nil;
	[_feedbackSender cancel];
    _feedbackSender.delegate = nil;
	[_feedbackSender release];
	_feedbackSender = nil;
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendReport:(id)sender
{
	// fetching system profile should be complete at the moment
	if (_systemProfileFetcher.isDoneFetching)
	{
		[self beginSendingFeedback];
	}
	else
	{
		_sendButton.enabled = NO;
		_sendButtonWasClicked = YES;
	}
}

//-------------------------------------------------------------------------------------------------
- (void)feedbackSender:(DFFeedbackSender*)sender didFinishWithError:(NSError*)error
{
    if (sender == _feedbackSender)
    {
        [_feedbackSender release];
        _feedbackSender = nil;
        [self dismiss];
        [(DFApplication*)NSApp relaunch];
    }
}

//-------------------------------------------------------------------------------------------------
- (void)systemProfileFetcherDidFinish:(DFSystemProfileFetcher*)sender
{
    if (sender == _systemProfileFetcher)
    {
        [_progressIndicator stopAnimation:nil];
        _progressIndicator.hidden = YES;
        _fetchingSystemProfileProgressLabel.hidden = YES;
        _anonymousLabel.hidden = NO;
        if (_systemProfileFetcher.profile != nil)
        {
            self.systemProfile = AnonymizeString(_systemProfileFetcher.profile);
            NSString* profileString = [NSString stringWithFormat:@"\n\nSYSTEM PROFILE:\n\n%@", _systemProfile];
            [_detailsTextView.textStorage appendAttributedString:[[[NSAttributedString alloc] initWithString:profileString] autorelease]];
        }
        if (_sendButtonWasClicked)
        {
            [self beginSendingFeedback];
        }
    }
}

//-------------------------------------------------------------------------------------------------
- (void)dismiss
{
	[self cancelPendingStuff];
	[self.window orderOut:self];
}

//-------------------------------------------------------------------------------------------------
- (void)windowWillClose:(NSNotification*)notification 
{
	if (!_sendButtonWasClicked && !_cancelButtonWasClicked)
	{
        [self dismiss];
        // on close just terminate without relaunching and sending the report
        [NSApp terminate:self];
	}
}

//-------------------------------------------------------------------------------------------------
- (IBAction)cancel:(id)sender
{
	// relaunch without sending report
	_cancelButtonWasClicked = YES;
	[self dismiss];
	[(DFApplication*)NSApp relaunch];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)close:(id)sender
{
	[self cancel:sender];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)expandCollapseCommentsBox:(id)sender
{
	BOOL shouldCollapseOrExpand = (_commentsDisclosureButton.state == NSOnState);
	[self expandOrCollapseBox:_commentsBoxView
					 textView:_commentsScrollView
        textViewDefaultHeight:_commentsTextViewDefaultHeight
				 alternateBox:_detailsBoxView
	   shouldCollapseOrExpand:shouldCollapseOrExpand
			   isLowerOrUpper:YES
				withAnimation:YES];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)expandCollapseDetailsBox:(id)sender
{
	BOOL shouldCollapseOrExpand = (_detailsDisclosureButton.state == NSOnState);
	[self expandOrCollapseBox:_detailsBoxView
					 textView:_detailsScrollView
        textViewDefaultHeight:_detailsTextViewDefaultHeight
				 alternateBox:_commentsBoxView
	   shouldCollapseOrExpand:shouldCollapseOrExpand
			   isLowerOrUpper:NO
				withAnimation:YES];
}

//-------------------------------------------------------------------------------------------------
- (void)expandOrCollapseBox:(NSView*)box
				   textView:(NSView*)textView
      textViewDefaultHeight:(CGFloat)textViewDefaultHeight
			   alternateBox:(NSView*)alternateBox
	 shouldCollapseOrExpand:(BOOL)shouldCollapseOrExpand
			 isLowerOrUpper:(BOOL)isLowerOrUpper
			  withAnimation:(BOOL)withAnimation
{
    // reset previous animation if any
    if (_windowAnimation != nil)
    {
        NSDictionary* viewAnimation = _windowAnimation.viewAnimations[0];
        NSRect endWindowFrame = ((NSValue*)viewAnimation[NSViewAnimationEndFrameKey]).rectValue;
        [self.window setFrame:endWindowFrame
                      display:YES
                      animate:NO];
        [_windowAnimation stopAnimation];
        _windowAnimation.delegate = nil;
        [_windowAnimation release];
        _windowAnimation = nil;
    }

    // window frames
	NSRect sourceWindowFrame = self.window.frame;
    NSRect targetWindowFrame = sourceWindowFrame;

	// expand
	if (shouldCollapseOrExpand)
	{
		box.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		alternateBox.autoresizingMask = NSViewWidthSizable | (isLowerOrUpper ? NSViewMaxYMargin : NSViewMinYMargin);
		CGFloat heightDiff = textViewDefaultHeight;
		targetWindowFrame.size.height += heightDiff;
		targetWindowFrame.origin.y -= heightDiff;
	}
	// collapse
	else
	{
		textView.hidden = YES;
		box.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
		alternateBox.autoresizingMask = NSViewWidthSizable | (isLowerOrUpper ? NSViewMaxYMargin : NSViewMinYMargin);
		CGFloat heightDiff = textViewDefaultHeight;
		targetWindowFrame.size.height -= heightDiff;
		targetWindowFrame.origin.y += heightDiff;
	}
    
	// animate
    if (withAnimation)
    {
        // with animation, need non-blocking mode or disclosure button animation will appear jerky
        _windowAnimation = [[NSViewAnimation alloc] init];
        _windowAnimation.animationBlockingMode = NSAnimationNonblocking;
        _windowAnimation.animationCurve = NSAnimationEaseInOut;
        _windowAnimation.duration = [self.window animationResizeTime:targetWindowFrame];
        _windowAnimation.delegate = self;
        NSDictionary* windowAnimDict = NSDictionaryWithKeysAndValues(NSViewAnimationTargetKey, self.window,
                                                                     NSViewAnimationStartFrameKey, [NSValue valueWithRect:sourceWindowFrame],
                                                                     NSViewAnimationEndFrameKey, [NSValue valueWithRect:targetWindowFrame],
                                                                     nil);
        _windowAnimation.viewAnimations = @[windowAnimDict];
        [_windowAnimation startAnimation];
    }
    else
    {
        // without animation
        [self.window setFrame:targetWindowFrame
                      display:YES
                      animate:NO];
        // emulate animation ended event
        [self animationDidEnd:_windowAnimation];
    }
}

//-------------------------------------------------------------------------------------------------
- (void)animationDidEnd:(NSAnimation*)animation
{
	if (animation == _windowAnimation)
	{
        // update visibility of controls after animation edns
        if (_commentsDisclosureButton.state == NSOnState)
        {
            _commentsScrollView.hidden = NO;
        }
        if (_detailsDisclosureButton.state == NSOnState)
        {
            _detailsScrollView.hidden = NO;
        }
        _windowAnimation.delegate = nil;
        [_windowAnimation release];
        _windowAnimation = nil;
	}
}

//-------------------------------------------------------------------------------------------------
- (void)linkLabel:(DFLinkLabel*)sender didClickLinkNo:(NSUInteger)linkIndex
{
    if (_updateUrl != nil)
    {
        if (sender == _updateLinkLabel)
        {
            if (linkIndex == 0)
            {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:_updateUrl]];
            }
        }
    }
}

@end
