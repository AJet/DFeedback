//-------------------------------------------------------------------------------------------------
// Copyright (c) 2008 DaisyDisk Team: <http://www.daisydiskapp.com>
// Some rights reserved: <http://opensource.org/licenses/mit-license.php>
//-------------------------------------------------------------------------------------------------

#import <AddressBook/AddressBook.h>
#import "DFFeedbackWindowController.h"
#import "DFSystemProfileFetcher.h"
#import "DFFeedbackSender.h"
#import "DFPlaceholderTextView.h"
#import "DFStyleSheet.h"
#import "DFBounceIconView.h"
#import "DFKeyTabView.h"
#import "OSVersionChecker.h"

//-------------------------------------------------------------------------------------------------
// Private constants
//-------------------------------------------------------------------------------------------------
static NSString* const NIB_NAME = @"DFFeedbackWindow";
typedef enum
{
	DFFeedback_General = 0,
	DFFeedback_Feature = 1,
	DFFeedback_Bug = 2
} DFFeedbackType;

//-------------------------------------------------------------------------------------------------
static NSString* const STATE_MESSAGE = @"DFeedback_Message";
static NSString* const STATE_EMAILADDRESS = @"DFeedback_EmailAddress";
static NSString* const STATE_FEEDBACKTYPE = @"DFeedback_FeedbackType";
static NSString* const STATE_INCLUDESYSTEMPROFILE = @"DFeedback_IncludeSystemProfile";
static NSString* const STATE_INCLUDEEMAILADDRESS = @"DFeedback_IncludeEmailAddress";

//-------------------------------------------------------------------------------------------------
// Private static data
//-------------------------------------------------------------------------------------------------
static DFFeedbackWindowController* s_singleton = nil;
static NSString* s_feedbackURL = nil;

//-------------------------------------------------------------------------------------------------
@implementation DFFeedbackWindowController
//-------------------------------------------------------------------------------------------------
+ (DFFeedbackWindowController*)singleton
{
	if (s_singleton == nil)
	{
        // initialize styles if not already
        initializeDFStyles();
        // create singleton
		s_singleton = [[DFFeedbackWindowController alloc] init];
	}
	return s_singleton;
}

//-------------------------------------------------------------------------------------------------
- (NSUInteger)tabIndexFromFeedbackType:(DFFeedbackType)feedbackType
{
	return (DFFeedbackType)feedbackType;
}

//-------------------------------------------------------------------------------------------------
- (DFFeedbackType)feedbackTypeFromTabIndex:(NSUInteger)tabIndex
{
	return (NSUInteger)tabIndex;
}

//-------------------------------------------------------------------------------------------------
- (NSString*)feedbackTypeStringFromType:(DFFeedbackType)feedbackType
{
	switch(feedbackType)
	{
		case DFFeedback_Bug:
			return @"Bug Report";
		case DFFeedback_Feature:
			return @"Feature Request";
		case DFFeedback_General:
			return @"General Question";
		default:
			NSAssert (false, @"Invalid case for feedback type");
			break;
	}
	return nil;
}

//-------------------------------------------------------------------------------------------------
- (DFFeedbackType)currentFeedbackType;
{
	NSUInteger tabIndex = [tabView indexOfTabViewItem:[tabView selectedTabViewItem]];
	return [self feedbackTypeFromTabIndex:tabIndex];
}


//-------------------------------------------------------------------------------------------------
- (void)showEmailWarning
{
	[emailBounceIcon fadeIn];
	[emailBounceIcon bounce];
}

//-------------------------------------------------------------------------------------------------
- (void)resetEmailWarning
{
	[emailBounceIcon fadeOut];
}

//-------------------------------------------------------------------------------------------------
- (void)showProgress:(bool)profilingOrSending
{
	// progress in the main window
	[progressContainer setHidden:!(profilingOrSending || [self currentFeedbackType] != DFFeedback_General)];
	[progressIndicator setHidden:NO];
	[progressIndicator startAnimation:self];
	[profilingProgressLabel setHidden:profilingOrSending];
	[sendingProgressLabel setHidden:!profilingOrSending];
	
	// progress in the details window
	[detailsProgressLabel setHidden:NO];
	[detailsProgressIndicator startAnimation:self];
	[detailsProgressIndicator setHidden:NO];
	[detailsTextContainer setHidden:YES];
}

//-------------------------------------------------------------------------------------------------
- (void)resetProgress
{
	// progress in the main window
	[progressIndicator stopAnimation:self];
	[progressIndicator setHidden:YES];
	[profilingProgressLabel setHidden:YES];
	[sendingProgressLabel setHidden:YES];
	
	// progress in the details window
	[detailsProgressLabel setHidden:YES];
	[detailsProgressIndicator stopAnimation:self];
	[detailsProgressIndicator setHidden:YES];
	[detailsTextContainer setHidden:NO];
}

//-------------------------------------------------------------------------------------------------
- (void)beginSendingFeedback
{
	NSString* userEmail = [includeEmailCheckBox state] == NSOnState ? [emailComboBox stringValue] : nil;
	NSString* feedbackText = [[textView textStorage] string];
	NSString* profile = m_systemProfileFetcher != nil ? [m_systemProfileFetcher profile] : nil;
	m_feedbackSender = [[DFFeedbackSender alloc] initWithCallbackTarget:self action:@selector(feedbackDidSend:)];
	[m_feedbackSender sendFeedbackToURL:s_feedbackURL
							feedbackText:feedbackText 
							feedbackType:[self feedbackTypeStringFromType:[self currentFeedbackType]]
						   systemProfile:profile
							   userEmail:userEmail];
	[self showProgress:true];
}

//-------------------------------------------------------------------------------------------------
- (void)cancelAllPendingStuff
{
	[m_systemProfileFetcher cancel];
	[m_systemProfileFetcher release];
	m_systemProfileFetcher = nil;
	[m_feedbackSender cancel];
	[m_feedbackSender release];
	m_feedbackSender = nil;
}

//-------------------------------------------------------------------------------------------------
- (void)cancelFetchingSystemProfile
{
	[m_systemProfileFetcher cancel];
	[m_systemProfileFetcher release];
	m_systemProfileFetcher = nil;
	[detailsWindow orderOut:self];
	[self resetProgress];
}

//-------------------------------------------------------------------------------------------------
- (void)dismiss
{
	if (s_singleton != nil)
	{
		[self cancelAllPendingStuff];
		[[self window] orderOut:self];
		[detailsWindow orderOut:self];
		[s_singleton release];
		s_singleton = nil;
	}
}

//-------------------------------------------------------------------------------------------------
- (bool)isEmptyString:(NSString*)string
{
	if ([string length] > 0)
	{
		NSString* regEx = @".*[^ \t\r\n]+.*"; 
		NSPredicate* test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx]; 
		if([test evaluateWithObject:string])
		{
			return false;
		}
	}
	return true;
}

//-------------------------------------------------------------------------------------------------
- (bool)isValidEmailAddress
{
	NSString* emailAddress = [emailComboBox stringValue];
	if (emailAddress != nil && ![emailAddress isEqualToString:@""])
	{
		NSString* emailRegEx = @"[ ]*[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}[ ]*"; 
		NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx]; 
		if([emailTest evaluateWithObject:emailAddress])
		{
			return true;
		}
	}
	return false;
}

//-------------------------------------------------------------------------------------------------
- (void)validateSendButton
{
	NSString* message = [[textView textStorage] string];
	[sendButton setEnabled:![self isEmptyString:message]];
}

//-------------------------------------------------------------------------------------------------
- (void)systemProfileDidFetch:(DFSystemProfileFetcher*)profile
{
	if (profile == m_systemProfileFetcher)
	{
		// update details window
		[[detailsTextView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:[m_systemProfileFetcher profile]] autorelease]];
		
		// reset fetching progress
		[self resetProgress];
		
		// begin sending immediately if the send button has been already clicked, or wait until it's clicked
		if (m_isSendingReport)
		{
			[self beginSendingFeedback];
		}
	}
}

//-------------------------------------------------------------------------------------------------
- (void)feedbackDidSend:(NSError*)error
{
	// cleanup
	[m_feedbackSender release];
	m_feedbackSender = nil;
	[self resetProgress];
	
	// check error
	if (error == nil)
	{
		[self dismiss];
	}
	else
	{
		[sendButton setEnabled:YES];
		NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedStringFromTable(@"DF_ALERT_SENDFAILED_TITLE", @"DFLocalizable", nil)
										 defaultButton:NSLocalizedStringFromTable(@"DF_ALERT_SENDFAILED_DISMISS_BUTTON_TITLE", @"DFLocalizable", nil)
									   alternateButton:nil
										   otherButton:nil
							 informativeTextWithFormat:NSLocalizedStringFromTable(@"DF_ALERT_SENDFAILED_MESSAGE", @"DFLocalizable", nil), [error localizedDescription]];
		[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:nil contextInfo:NULL];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)initializeFirstResponder
{
	// this is needed to prevent the focus ring to appear on the tab buttons, each time the window is shown
	[[self window] makeFirstResponder:tabView];
}

//-------------------------------------------------------------------------------------------------
- (void)beginFetchingSystemProfile
{
	if (m_systemProfileFetcher == nil)
	{
		m_systemProfileFetcher = [[DFSystemProfileFetcher alloc] initWithCallbackTarget:self action:@selector(systemProfileDidFetch:)];
		[m_systemProfileFetcher fetch];
		
		[self showProgress:false];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)tabView:(NSTabView*)sender didSelectTabViewItem:(NSTabViewItem*)tabViewItem
{
	if (sender == tabView)
	{
		// switch variants of the window when the system profile is visible/hidden

		// system profile controls
		[systemProfileContainer setHidden:[self currentFeedbackType] == DFFeedback_General];

		// text container
		NSRect textContainerFrame = [textContainer frame];
		NSRect systemProfileFrame = [systemProfileContainer frame];
		if ([self currentFeedbackType] == DFFeedback_General)
		{
			// expand text container
			if (textContainerFrame.origin.y > systemProfileFrame.origin.y)
			{
				CGFloat diffHeight = textContainerFrame.origin.y - systemProfileFrame.origin.y;
				textContainerFrame.origin.y -= diffHeight;
				textContainerFrame.size.height += diffHeight;
			}
		}
		else
		{
			// shrink text container
			if (textContainerFrame.origin.y == systemProfileFrame.origin.y)
			{
				CGFloat diffHeight = systemProfileFrame.size.height;
				textContainerFrame.origin.y += diffHeight;
				textContainerFrame.size.height -= diffHeight;
			}
		}
		[textContainer setFrame:textContainerFrame];

		// progress controls
		[progressContainer setHidden:[self currentFeedbackType] == DFFeedback_General && !m_isSendingReport];
		
		// send button
		[self validateSendButton];
		
		// begin fetching profile immediately after switching to a page that contains it
		if ([self currentFeedbackType] != DFFeedback_General)
		{
			[self beginFetchingSystemProfile];
		}
	}
}

//-------------------------------------------------------------------------------------------------
- (void)initializeControls:(DFFeedbackType)feedbackType
{
	// cleanup, just in case
	[m_systemProfileFetcher cancel];
	[m_systemProfileFetcher release];
	m_systemProfileFetcher = nil;
	m_isSendingReport = false;
	[sendButton setEnabled:YES];
	[self resetProgress];
	[self resetEmailWarning];
	
	// window title
	NSString* windowTitle = [[self window] title];
	windowTitle = [NSString stringWithFormat:windowTitle, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]]; 
	[[self window] setTitle:windowTitle];
	
	// select tab
	NSUInteger tabIndex = [self tabIndexFromFeedbackType:feedbackType];
	[tabsSegmentedControl setSelectedSegment:tabIndex];
	[tabView selectTabViewItemAtIndex:tabIndex];
	[self tabView:tabView didSelectTabViewItem:[tabView tabViewItemAtIndex:tabIndex]];
}

//-------------------------------------------------------------------------------------------------
- (id)init 
{
    self = [super initWithWindowNibName:NIB_NAME];
    if (self != nil) 
	{
		// do nothing
    }
    return self;
}

//-------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
	// initialize border
	[[self window] setContentBorderThickness:DFFeedbackWindow_bottomBarHeight forEdge: NSMinYEdge];
	
	// initialize placeholder strings
	[textView setPlaceholderText:NSLocalizedStringFromTable(@"DF_TEXT_PLACEHOLDER", @"DFLocalizable", nil)];
	
	// initialize email bounce icon
	[emailBounceIcon setIcon:DFFeedbackWindow_emailWarningImage];
	
	// initialize email from the address book
	ABMutableMultiValue* emailAddresses = [[[ABAddressBook sharedAddressBook] me] valueForProperty:kABEmailProperty];
    for (NSUInteger addrIndex = 0; addrIndex < [emailAddresses count]; addrIndex++) 
	{
        [emailComboBox addItemWithObjectValue:[emailAddresses valueAtIndex:addrIndex]];
    }
	if ([emailComboBox numberOfItems] > 0)
	{
		[emailComboBox selectItemAtIndex:0];
	}
	
	// restoration
	if ([OSVersionChecker macOsVersion] >= OSVersion_Lion)
	{
		[[self window] performSelector:@selector(setRestorable:) withObject:(id)(NSUInteger)YES];
		[[self window] performSelector:@selector(setRestorationClass:) withObject:[self class]];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)dealloc
{
	[self cancelAllPendingStuff];
	[super dealloc];
}

//-------------------------------------------------------------------------------------------------
- (void)restoreState:(NSCoder*)state
{
	DFFeedbackType feedbackType = DFFeedback_General;
	if ([state containsValueForKey:STATE_FEEDBACKTYPE])
	{
		feedbackType = (DFFeedbackType)[state decodeIntForKey:STATE_FEEDBACKTYPE];
	}
	[self initializeControls:feedbackType];

	NSString* message = [state decodeObjectForKey:STATE_MESSAGE];
	if (message != nil)
	{
		[textView setString:message];
	}
	NSString* emailAddress = [state decodeObjectForKey:STATE_EMAILADDRESS];
	if (emailAddress != nil)
	{
		[emailComboBox setStringValue:emailAddress];
	}
	if ([state containsValueForKey:STATE_INCLUDEEMAILADDRESS])
	{
		BOOL includeEmailAddress = [state decodeBoolForKey:STATE_INCLUDEEMAILADDRESS];
		[includeEmailCheckBox setState:includeEmailAddress ? NSOnState : NSOffState];
	}
	if ([state containsValueForKey:STATE_INCLUDESYSTEMPROFILE])
	{
		BOOL includeSystemProfile = [state decodeBoolForKey:STATE_INCLUDESYSTEMPROFILE];
		[includeSystemProfileCheckBox setState:includeSystemProfile ? NSOnState : NSOffState];
	}
}

//-------------------------------------------------------------------------------------------------
+ (void)restoreWindowWithIdentifier:(NSString*)identifier state:(NSCoder*)state completionHandler:(void (^)(NSWindow*, NSError*))completionHandler
{
	[[self singleton] restoreState:state];
	completionHandler([[self singleton] window], nil);
}

//-------------------------------------------------------------------------------------------------
- (void)window:(NSWindow*)window willEncodeRestorableState:(NSCoder*)state
{
	[state encodeObject:[textView string] forKey:STATE_MESSAGE];
	[state encodeObject:[emailComboBox stringValue] forKey:STATE_EMAILADDRESS];
	[state encodeInt:[self currentFeedbackType] forKey:STATE_FEEDBACKTYPE];
	[state encodeBool:[includeEmailCheckBox state] == NSOnState forKey:STATE_INCLUDEEMAILADDRESS];
	[state encodeBool:[includeSystemProfileCheckBox state] == NSOnState forKey:STATE_INCLUDESYSTEMPROFILE];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)sendReport:(id)sender
{
	bool shouldBlinkInvalidEmail = [includeEmailCheckBox intValue] != 0	&& ![self isValidEmailAddress];
	if (shouldBlinkInvalidEmail)
	{
		[self showEmailWarning];
	}
	else
	{
		// change state
		m_isSendingReport = true;
		[sendButton setEnabled:NO];
		[self resetEmailWarning];

		// begin fetching system profile
		bool isSystemProfileNeeded = [self currentFeedbackType] != DFFeedback_General && [includeSystemProfileCheckBox state] == NSOnState;
		if (isSystemProfileNeeded && ![m_systemProfileFetcher isDoneFetching])
		{
			[self beginFetchingSystemProfile];
		}
		
		// the profile already there, begin sending immediately
		else
		{
			if (!isSystemProfileNeeded)
			{
				[self cancelFetchingSystemProfile];
			}
			[self beginSendingFeedback];
		}
	}
}

//-------------------------------------------------------------------------------------------------
- (IBAction)close:(id)sender
{
	[self dismiss];
}

//-------------------------------------------------------------------------------------------------
- (void)windowWillClose:(NSNotification*)notification 
{
	[self dismiss];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)cancel:(id)sender
{
	[self dismiss];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)includeEmailCheckBoxChanged:(id)sender
{
	// hide the email warning when the user unchecks the include e-mail box
	if ([includeEmailCheckBox intValue] == 0)
	{
		[self resetEmailWarning];
	}
}

//-------------------------------------------------------------------------------------------------
- (IBAction)emailChanged:(id)sender
{
	// hide the email warning when the user selects an e-mail from the dropdown
	[self resetEmailWarning];
}

//-------------------------------------------------------------------------------------------------
- (void)controlTextDidChange:(NSNotification*)notification
{
	NSView* view = [notification object];
	// hide the email warning when the user types in a valid address into the email input field
	if (view == emailComboBox)
	{
		[self resetEmailWarning];
	}
}

//-------------------------------------------------------------------------------------------------
- (IBAction)tabsSegmentedControlChanged:(id)sender
{
	// sync tab view with the tab buttons
	[tabView selectTabViewItemAtIndex:[tabsSegmentedControl selectedSegment]];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)showDetails:(id)sender
{
	if (![detailsWindow isVisible])
	{
		[detailsWindow center];
	}
	[detailsWindow makeKeyAndOrderFront:self];
}

//-------------------------------------------------------------------------------------------------
- (void)textViewDidChangeSelection:(NSNotification*)notification
{
	[self validateSendButton];
}

//-------------------------------------------------------------------------------------------------
+ (void)initializeWithFeedbackURL:(NSString*)feedbackURL
{
	// save params
	[feedbackURL retain];
	[s_feedbackURL release];
	s_feedbackURL = feedbackURL;
}

//-------------------------------------------------------------------------------------------------
+ (void)showFeedback:(DFFeedbackType)feedbackType
{
	
	// center the window
	NSWindow* window = [[self singleton] window];
	if (![window isVisible])
	{
		[window center];
	}
	
	// initialize
	[[self singleton] initializeControls:feedbackType];
	
	// show window non-modally
	[[self singleton] showWindow:nil];
	
	// initialize first responder
	[[self singleton] initializeFirstResponder];
}

//-------------------------------------------------------------------------------------------------
+ (void)showGeneralQuestion
{
	[self showFeedback:DFFeedback_General];
}

//-------------------------------------------------------------------------------------------------
+ (void)showBugReport
{
	[self showFeedback:DFFeedback_Bug];
}

//-------------------------------------------------------------------------------------------------
+ (void)showFeatureRequest
{
	[self showFeedback:DFFeedback_Feature];
}

//-------------------------------------------------------------------------------------------------
+ (void)show
{
	[self showFeedback:DFFeedback_General];
}

@end
