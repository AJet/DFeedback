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
static DFCrashReportWindowController* s_singleton = nil;
static NSImage* s_icon = nil;
static NSString* s_feedbackURL = nil;

//-------------------------------------------------------------------------------------------------
@implementation DFCrashReportWindowController
//-------------------------------------------------------------------------------------------------
+ (void)initializeWithFeedbackURL:(NSString*)feedbackURL
                             icon:(NSImage*)icon
{
    [icon retain];
    [s_icon release];
    s_icon = icon;
    
    [feedbackURL retain];
    [s_feedbackURL release];
    s_feedbackURL = feedbackURL;
}

//-------------------------------------------------------------------------------------------------
+ (DFCrashReportWindowController*)singleton
{
	if (s_singleton == nil)
	{
        initializeDFStyles();

		s_singleton = [[DFCrashReportWindowController alloc] init];
	}
	return s_singleton;
}

//-------------------------------------------------------------------------------------------------
- (id)init
{
    self = [super initWithWindowNibName:NIB_NAME];
    if (self != nil) 
	{
		m_systemProfileFetcher = [[DFSystemProfileFetcher alloc] initWithCallbackTarget:self action:@selector(systemProfileDidFetch:)];
    }
    return self;
}

//-------------------------------------------------------------------------------------------------
- (void)setException:(NSException*)exception
{
    [m_exceptionMessage release];
    m_exceptionMessage = [[exception reason] retain];
    [m_exceptionStackTrace release];
    m_exceptionStackTrace = [GTMStackTraceFromException(exception) retain];
}

//-------------------------------------------------------------------------------------------------
- (void)expandOrCollapseBox:(NSView*)box 
				   textView:(NSView*)textView 
			   alternateBox:(NSView*)alternateBox 
	 shouldCollapseOrExpand:(bool)shouldCollapseOrExpand
			 isLowerOrUpper:(bool)isLowerOrUpper
			  withAnimation:(bool)withAnimation
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
	[m_systemProfileFetcher fetch];
}

//-------------------------------------------------------------------------------------------------
- (void)initializeControls
{
	m_sendButtonWasClicked = false;
	m_cancelButtonWasClicked = false;

	[[self window] setContentBorderThickness:DFCrashReportWindow_bottomBarHeight forEdge: NSMinYEdge];
	
	NSString* windowTitle = [[self window] title];
	windowTitle = [NSString stringWithFormat:windowTitle, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]]; 
	[[self window] setTitle:windowTitle];

    [iconImageView setImage:s_icon];
    
	[commentsTextView setPlaceholderText:NSLocalizedStringFromTable(@"DF_TEXT_PLACEHOLDER", @"DFLocalizable", nil)];

	[sendButton setEnabled:true];

    NSString* details = [NSString stringWithFormat:@"MESSAGE:\n%@\n\nSTACK TRACE:\n%@", m_exceptionMessage, m_exceptionStackTrace];
	[[detailsTextView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:details] autorelease]];

    [detailsDisclosureButton setState:NSOffState];
	[self expandOrCollapseBox:detailsBoxView 
					 textView:detailsScrollView 
				 alternateBox:commentsBoxView 
	   shouldCollapseOrExpand:false
			   isLowerOrUpper:false
				withAnimation:false];

    [self beginFetchingSystemProfile];
}

//-------------------------------------------------------------------------------------------------
+ (void)showReportForException:(NSException*)exception
{
    // save exception
    [[self singleton] setException:exception];
	
	// center the window
	NSWindow* window = [[self singleton] window];
	if (![window isVisible])
	{
		[window center];
	}
	
	// show window
	[[self singleton] initializeControls];
	[[self singleton] showWindow:nil];
}

//-------------------------------------------------------------------------------------------------
- (void)cancelPendingStuff
{
	[m_systemProfileFetcher cancel];
	[m_systemProfileFetcher release];
	m_systemProfileFetcher = nil;
	[m_feedbackSender cancel];
	[m_feedbackSender release];
	m_feedbackSender = nil;
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[self cancelPendingStuff];
    [m_exceptionMessage release];
    [m_exceptionStackTrace release];
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
	[sendButton setEnabled:false];

	// begin sending feedback
    NSString* feedbackText = [NSString stringWithFormat:@"MESSAGE:\n%@\n\nCOMMENTS:\n%@\n\nSTACK TRACE:\n%@", 
                              m_exceptionMessage, 
                              [[commentsTextView textStorage] string], 
                              m_exceptionStackTrace];
    [m_feedbackSender cancel];
    [m_feedbackSender release];
	m_feedbackSender = [[DFFeedbackSender alloc] initWithCallbackTarget:self action:@selector(feedbackSenderDidComplete:)];
	[m_feedbackSender sendFeedbackToURL:s_feedbackURL
							feedbackText:feedbackText
							feedbackType:@"Crash"
						   systemProfile:[m_systemProfileFetcher profile]
							   userEmail:nil];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendReport:(id)sender
{
	// fetching system profile should be complete at the moment
	if ([m_systemProfileFetcher isDoneFetching])
	{
		[self beginSendingFeedback];
	}
	else
	{
		[sendButton setEnabled:false];
		m_sendButtonWasClicked = true;
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
	[m_feedbackSender release];
	m_feedbackSender = nil;
	[self dismiss];
	[(DFApplication*)NSApp relaunch];
}

//-------------------------------------------------------------------------------------------------
- (void)systemProfileDidFetch:(DFSystemProfileFetcher*)profileFetcher
{
	if (profileFetcher == m_systemProfileFetcher)
	{
		[progressIndicator stopAnimation:nil];
		[progressIndicator setHidden:YES];
		[fetchingSystemProfileProgressLabel setHidden:YES];
		[anonymousLabel setHidden:NO];
		NSString* profileString = [NSString stringWithFormat:@"\n\nSYSTEM PROFILE:\n\n%@", [m_systemProfileFetcher profile]];
		[[detailsTextView textStorage] appendAttributedString:[[[NSAttributedString alloc] initWithString:profileString] autorelease]];

		if (m_sendButtonWasClicked)
		{
			[self beginSendingFeedback];
		}
	}
}

//-------------------------------------------------------------------------------------------------
- (void)windowWillClose:(NSNotification*)notification 
{
	if (!m_sendButtonWasClicked && !m_cancelButtonWasClicked)
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
	m_cancelButtonWasClicked = true;
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
	bool shouldCollapseOrExpand = ([commentsDisclosureButton state] == NSOnState);
	[self expandOrCollapseBox:commentsBoxView 
					 textView:commentsScrollView 
				 alternateBox:detailsBoxView 
	   shouldCollapseOrExpand:shouldCollapseOrExpand
			   isLowerOrUpper:true
				withAnimation:true];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)expandCollapseDetailsBox:(id)sender
{
	bool shouldCollapseOrExpand = ([detailsDisclosureButton state] == NSOnState);
	[self expandOrCollapseBox:detailsBoxView 
					 textView:detailsScrollView 
				 alternateBox:commentsBoxView 
	   shouldCollapseOrExpand:shouldCollapseOrExpand
			   isLowerOrUpper:false
				withAnimation:true];
}

@end
