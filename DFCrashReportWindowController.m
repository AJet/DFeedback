//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import "DFCrashReportWindowController.h"
#import "DFSystemProfileFetcher.h"
#import "DFFeedbackSender.h"
#import "DFPlaceholderTextView.h"
#import "DFStyleSheet.h"
#import "DFApplication.h"
#import "GTMStackTrace.h"

//-------------------------------------------------------------------------------------------------
// Private constants
//-------------------------------------------------------------------------------------------------
static NSString* const NIB_NAME = @"DFCrashReportWindow";

//-------------------------------------------------------------------------------------------------
// Private static data
//-------------------------------------------------------------------------------------------------
static DFCrashReportWindowController* _singleton = nil;
static NSImage* _icon = nil;
static NSString* _feedbackURL = nil;

//-------------------------------------------------------------------------------------------------
@implementation DFCrashReportWindowController
//-------------------------------------------------------------------------------------------------
+ (void)initializeWithFeedbackURL:(NSString*)feedbackURL
                             icon:(NSImage*)icon
{
    [icon retain];
    [_icon release];
    _icon = icon;
    
    [feedbackURL retain];
    [_feedbackURL release];
    _feedbackURL = feedbackURL;
}

//-------------------------------------------------------------------------------------------------
+ (DFCrashReportWindowController*)singleton
{
	if (_singleton == nil)
	{
        initializeDFStyles();

		_singleton = [[DFCrashReportWindowController alloc] init];
	}
	return _singleton;
}

//-------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super initWithWindowNibName:NIB_NAME];
    if (self != nil) 
	{
		_systemProfileFetcher = [[DFSystemProfileFetcher alloc] initWithCallbackTarget:self action:@selector(systemProfileDidFetch:)];
    }
    return self;
}

//-------------------------------------------------------------------------------------------------
- (void)setException:(NSException*)exception
{
    [_exceptionMessage release];
    _exceptionMessage = [[exception reason] retain];
    [_exceptionStackTrace release];
    _exceptionStackTrace = [GTMStackTraceFromException(exception) retain];
}

//-------------------------------------------------------------------------------------------------
- (void)expandOrCollapseBox:(NSView*)box 
				   textView:(NSView*)textView 
			   alternateBox:(NSView*)alternateBox 
	 shouldCollapseOrExpand:(BOOL)shouldCollapseOrExpand
			 isLowerOrUpper:(BOOL)isLowerOrUpper
			  withAnimation:(BOOL)withAnimation
{
	// window frames
	NSRect sourceWindowFrame = [[self window] frame];
	NSRect targetWindowFrame = sourceWindowFrame;
	
	// expand
	if (shouldCollapseOrExpand)
	{
		[box setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[alternateBox setAutoresizingMask:NSViewWidthSizable | (isLowerOrUpper ? NSViewMaxYMargin : NSViewMinYMargin)];
		CGFloat heightDiff = [textView frame].size.height;
		targetWindowFrame.size.height += heightDiff;
		targetWindowFrame.origin.y -= heightDiff;
	}
	// collapse
	else
	{
		[textView setHidden:YES];
		[box setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
		[alternateBox setAutoresizingMask:NSViewWidthSizable | (isLowerOrUpper ? NSViewMaxYMargin : NSViewMinYMargin)];
		CGFloat heightDiff = [textView frame].size.height;
		targetWindowFrame.size.height -= heightDiff;
		targetWindowFrame.origin.y += heightDiff;
	}

	// animate
	[[self window] setFrame:targetWindowFrame display:YES animate:withAnimation];

	// update visibility of controls
	if ([commentsDisclosureButton state] == NSOnState)
	{
		[commentsScrollView setHidden:NO];
	}
	if ([detailsDisclosureButton state] == NSOnState)
	{
		[detailsScrollView setHidden:NO];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)beginFetchingSystemProfile
{
    [fetchingSystemProfileProgressLabel setHidden:NO];
	[progressIndicator startAnimation:nil];
	[_systemProfileFetcher fetch];
}

//-------------------------------------------------------------------------------------------------
- (void)initializeControls
{
	_sendButtonWasClicked = NO;
	_cancelButtonWasClicked = NO;

	[[self window] setContentBorderThickness:DFCrashReportWindow_bottomBarHeight forEdge: NSMinYEdge];
	
	NSString* windowTitle = [[self window] title];
	windowTitle = [NSString stringWithFormat:windowTitle, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]]; 
	[[self window] setTitle:windowTitle];

    [iconImageView setImage:_icon];
    
	[commentsTextView setPlaceholderText:NSLocalizedStringFromTable(@"DF_TEXT_PLACEHOLDER", @"DFLocalizable", nil)];

	[sendButton setEnabled:YES];

    NSString* details = [NSString stringWithFormat:@"MESSAGE:\n%@\n\nSTACK TRACE:\n%@", _exceptionMessage, _exceptionStackTrace];
	[[detailsTextView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:details] autorelease]];

    [detailsDisclosureButton setState:NSOffState];
	[self expandOrCollapseBox:detailsBoxView 
					 textView:detailsScrollView 
				 alternateBox:commentsBoxView 
	   shouldCollapseOrExpand:NO
			   isLowerOrUpper:NO
				withAnimation:NO];

    [self beginFetchingSystemProfile];
}

//-------------------------------------------------------------------------------------------------
- (void)showReportForException:(NSException*)exception
{
    // save exception
    [self setException:exception];
	
	// center the window
	NSWindow* window = [self window];
	if (![window isVisible])
	{
		[window center];
	}
	
	// show window
	[self initializeControls];
    [NSApp runModalForWindow:window];
}

//-------------------------------------------------------------------------------------------------
- (void)cancelPendingStuff
{
	[_systemProfileFetcher cancel];
	[_systemProfileFetcher release];
	_systemProfileFetcher = nil;
	[_feedbackSender cancel];
	[_feedbackSender release];
	_feedbackSender = nil;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[self cancelPendingStuff];
    [_exceptionMessage release];
    [_exceptionStackTrace release];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (void)beginSendingFeedback
{
	// update controls
	[anonymousLabel setHidden:YES];
	[progressIndicator startAnimation:nil];
	[progressIndicator setHidden:NO];
	[sendingReportProgressLabel setHidden:NO];
	[sendButton setEnabled:NO];

	// begin sending feedback
    NSString* feedbackText = [NSString stringWithFormat:@"MESSAGE:\n%@\n\nCOMMENTS:\n%@\n\nSTACK TRACE:\n%@", 
                              _exceptionMessage, 
                              [[commentsTextView textStorage] string], 
                              _exceptionStackTrace];
    [_feedbackSender cancel];
    [_feedbackSender release];
	_feedbackSender = [[DFFeedbackSender alloc] initWithCallbackTarget:self action:@selector(feedbackSenderDidComplete:)];
	[_feedbackSender sendFeedbackToURL:_feedbackURL
							feedbackText:feedbackText
							feedbackType:@"Crash"
						   systemProfile:[_systemProfileFetcher profile]
							   userEmail:nil];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendReport:(id)sender
{
	// fetching system profile should be complete at the moment
	if ([_systemProfileFetcher isDoneFetching])
	{
		[self beginSendingFeedback];
	}
	else
	{
		[sendButton setEnabled:NO];
		_sendButtonWasClicked = YES;
	}
}

//-------------------------------------------------------------------------------------------------
- (void)dismiss
{
	[self cancelPendingStuff];
	[[self window] orderOut:self];
}

//-------------------------------------------------------------------------------------------------
- (void)feedbackSenderDidComplete:(NSError*)error
{
	[_feedbackSender release];
	_feedbackSender = nil;
	[self dismiss];
	[(DFApplication*)NSApp relaunch];
}

//-------------------------------------------------------------------------------------------------
- (void)systemProfileDidFetch:(DFSystemProfileFetcher*)profileFetcher
{
	if (profileFetcher == _systemProfileFetcher)
	{
		[progressIndicator stopAnimation:nil];
		[progressIndicator setHidden:YES];
		[fetchingSystemProfileProgressLabel setHidden:YES];
		[anonymousLabel setHidden:NO];
		NSString* profileString = [NSString stringWithFormat:@"\n\nSYSTEM PROFILE:\n\n%@", [_systemProfileFetcher profile]];
		[[detailsTextView textStorage] appendAttributedString:[[[NSAttributedString alloc] initWithString:profileString] autorelease]];

		if (_sendButtonWasClicked)
		{
			[self beginSendingFeedback];
		}
	}
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
	BOOL shouldCollapseOrExpand = ([commentsDisclosureButton state] == NSOnState);
	[self expandOrCollapseBox:commentsBoxView 
					 textView:commentsScrollView 
				 alternateBox:detailsBoxView 
	   shouldCollapseOrExpand:shouldCollapseOrExpand
			   isLowerOrUpper:YES
				withAnimation:YES];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)expandCollapseDetailsBox:(id)sender
{
	BOOL shouldCollapseOrExpand = ([detailsDisclosureButton state] == NSOnState);
	[self expandOrCollapseBox:detailsBoxView 
					 textView:detailsScrollView 
				 alternateBox:commentsBoxView 
	   shouldCollapseOrExpand:shouldCollapseOrExpand
			   isLowerOrUpper:NO
				withAnimation:YES];
}

@end
