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
#import "DFApplicationSandboxInfo.h"

//-------------------------------------------------------------------------------------------------
// Private constants
//-------------------------------------------------------------------------------------------------
static NSString* const NIB_NAME = @"DFFeedbackWindow";
typedef enum DFFeedbackType : NSUInteger
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
static DFFeedbackWindowController* _singleton = nil;
static NSString* _feedbackURL = nil;

//-------------------------------------------------------------------------------------------------
// Private static functions
//-------------------------------------------------------------------------------------------------
static BOOL IsEmptyMessage(NSString* string)
{
    BOOL result = YES;
	if ([string length] > 0)
	{
		NSString* regEx = @".*[^ \t\r\n]+.*";
		NSPredicate* test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regEx];
		if([test evaluateWithObject:string])
		{
			result = NO;
		}
	}
	return result;
}

//-------------------------------------------------------------------------------------------------
static BOOL IsValidEmailAddress(NSString* emailAddress)
{
	if (emailAddress != nil && ![emailAddress isEqualToString:@""])
	{
		NSString* emailRegEx = @"[ ]*[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}[ ]*";
		NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
		if([emailTest evaluateWithObject:emailAddress])
		{
			return YES;
		}
	}
	return NO;
}


//-------------------------------------------------------------------------------------------------
@implementation DFFeedbackWindowController
//-------------------------------------------------------------------------------------------------
+ (void)initializeWithFeedbackURL:(NSString*)feedbackURL
{
	// save params
	[feedbackURL retain];
	[_feedbackURL release];
	_feedbackURL = feedbackURL;
}

//-------------------------------------------------------------------------------------------------
+ (DFFeedbackWindowController*)singleton
{
	if (_singleton == nil)
	{
        // initialize styles if not already
        initializeDFStyles();
        // create singleton
		_singleton = [[DFFeedbackWindowController alloc] init];
	}
	return _singleton;
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
	[self initializeControlsForFeedbackType:feedbackType];
    
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
- (void)awakeFromNib
{
	// initialize border
	[[self window] setContentBorderThickness:DFFeedbackWindow_bottomBarHeight forEdge: NSMinYEdge];
	
	// initialize placeholder strings
	[textView setPlaceholderText:NSLocalizedStringFromTable(@"DF_TEXT_PLACEHOLDER", @"DFLocalizable", nil)];
	
	// initialize email bounce icon
	[emailBounceIcon setIcon:DFFeedbackWindow_emailWarningImage];
	
	// initialize email from the address book
    // unless the app is sandboxed and doesn't have the entitlement
    // or if we are on 10.8 - we don't want the user to see the dreaded message box
    if ([self shouldAccessContacts])
    {
        ABMutableMultiValue* emailAddresses = [[[ABAddressBook sharedAddressBook] me] valueForProperty:kABEmailProperty];
        for (NSUInteger addrIndex = 0; addrIndex < [emailAddresses count]; addrIndex++)
        {
            [emailComboBox addItemWithObjectValue:[emailAddresses valueAtIndex:addrIndex]];
        }
        if ([emailComboBox numberOfItems] > 0)
        {
            [emailComboBox selectItemAtIndex:0];
        }
    }
	
	// restoration
	if ([OSVersionChecker macOsVersion] >= OSVersion_Lion)
	{
		[[self window] performSelector:@selector(setRestorable:) withObject:(id)(NSUInteger)YES];
		[[self window] performSelector:@selector(setRestorationClass:) withObject:[self class]];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)initializeControlsForFeedbackType:(DFFeedbackType)feedbackType
{
	// cleanup, just in case
	[_systemProfileFetcher cancel];
	[_systemProfileFetcher release];
	_systemProfileFetcher = nil;
	_isSendingReport = NO;
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
- (void)initializeFirstResponder
{
	// this is needed to prevent the focus ring to appear on the tab buttons, each time the window is shown
	[[self window] makeFirstResponder:tabView];
}

//-------------------------------------------------------------------------------------------------
- (BOOL)shouldAccessContacts
{
    BOOL result = YES;
    if ([OSVersionChecker macOsVersion] >= OSVersion_MountainLion)
    {
        // we don't want the dreaded dialog that the app wants to access your contacts
        result = NO;
    }
    else
    {
        // check if sandboxed at all
        if ([DFApplicationSandboxInfo isSandboxed])
        {
            // check if has address book access
            if (![DFApplicationSandboxInfo hasAddressBookDataEntitlement])
            {
                result = NO;
            }
        }
    }
    return result;
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
			NSAssert (NO, @"Invalid case for feedback type");
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
- (void)showProgress:(BOOL)profilingOrSending
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
- (void)beginFetchingSystemProfile
{
	if (_systemProfileFetcher == nil)
	{
		_systemProfileFetcher = [[DFSystemProfileFetcher alloc] initWithCallbackTarget:self action:@selector(systemProfileDidFetch:)];
		[_systemProfileFetcher fetch];
		
		[self showProgress:NO];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)systemProfileDidFetch:(DFSystemProfileFetcher*)profile
{
	if (profile == _systemProfileFetcher)
	{
		// update details window
		[[detailsTextView textStorage] setAttributedString:[[[NSAttributedString alloc] initWithString:[_systemProfileFetcher profile]] autorelease]];
		
		// reset fetching progress
		[self resetProgress];
		
		// begin sending immediately if the send button has been already clicked, or wait until it's clicked
		if (_isSendingReport)
		{
			[self beginSendingFeedback];
		}
	}
}

//-------------------------------------------------------------------------------------------------
- (void)cancelFetchingSystemProfile
{
	[_systemProfileFetcher cancel];
	[_systemProfileFetcher release];
	_systemProfileFetcher = nil;
	[detailsWindow orderOut:self];
	[self resetProgress];
}

//-------------------------------------------------------------------------------------------------
- (void)beginSendingFeedback
{
	NSString* userEmail = [includeEmailCheckBox state] == NSOnState ? [emailComboBox stringValue] : nil;
	NSString* feedbackText = [[textView textStorage] string];
	NSString* profile = _systemProfileFetcher != nil ? [_systemProfileFetcher profile] : nil;
	_feedbackSender = [[DFFeedbackSender alloc] initWithCallbackTarget:self action:@selector(feedbackDidSend:)];
	[_feedbackSender sendFeedbackToURL:_feedbackURL
                          feedbackText:feedbackText
                          feedbackType:[self feedbackTypeStringFromType:[self currentFeedbackType]]
                         systemProfile:profile
                             userEmail:userEmail];
	[self showProgress:YES];
}

//-------------------------------------------------------------------------------------------------
- (void)feedbackDidSend:(NSError*)error
{
	// cleanup
	[_feedbackSender release];
	_feedbackSender = nil;
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
- (void)cancelAllPendingStuff
{
	[_systemProfileFetcher cancel];
	[_systemProfileFetcher release];
	_systemProfileFetcher = nil;
	[_feedbackSender cancel];
	[_feedbackSender release];
	_feedbackSender = nil;
}

//-------------------------------------------------------------------------------------------------
- (void)validateSendButton
{
	NSString* message = [[textView textStorage] string];
	[sendButton setEnabled:!IsEmptyMessage(message)];
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
		[progressContainer setHidden:[self currentFeedbackType] == DFFeedback_General && !_isSendingReport];
		
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
- (IBAction)sendReport:(id)sender
{
	BOOL shouldBlinkInvalidEmail = [includeEmailCheckBox intValue] != 0	&& !IsValidEmailAddress([emailComboBox stringValue]);
	if (shouldBlinkInvalidEmail)
	{
		[self showEmailWarning];
	}
	else
	{
		// change state
		_isSendingReport = YES;
		[sendButton setEnabled:NO];
		[self resetEmailWarning];

		// begin fetching system profile
		BOOL isSystemProfileNeeded = [self currentFeedbackType] != DFFeedback_General && [includeSystemProfileCheckBox state] == NSOnState;
		if (isSystemProfileNeeded && ![_systemProfileFetcher isDoneFetching])
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
- (void)showForFeedbackType:(DFFeedbackType)feedbackType
{
	// center the window
	NSWindow* window = [self window];
	if (![window isVisible])
	{
		[window center];
	}
	
	// initialize
	[self initializeControlsForFeedbackType:feedbackType];
	
	// show window non-modally
	[self showWindow:nil];
	
	// initialize first responder
	[self initializeFirstResponder];
}

//-------------------------------------------------------------------------------------------------
- (void)showGeneralQuestion
{
	[self showForFeedbackType:DFFeedback_General];
}

//-------------------------------------------------------------------------------------------------
- (void)showBugReport
{
	[self showForFeedbackType:DFFeedback_Bug];
}

//-------------------------------------------------------------------------------------------------
- (void)showFeatureRequest
{
	[self showForFeedbackType:DFFeedback_Feature];
}

//-------------------------------------------------------------------------------------------------
- (void)show
{
	[self showForFeedbackType:DFFeedback_General];
}

//-------------------------------------------------------------------------------------------------
- (void)dismiss
{
	if (_singleton != nil)
	{
		[self cancelAllPendingStuff];
		[[self window] orderOut:self];
		[detailsWindow orderOut:self];
		[_singleton release];
		_singleton = nil;
	}
}

//-------------------------------------------------------------------------------------------------
- (IBAction)close:(id)sender
{
	[self dismiss];
}

//-------------------------------------------------------------------------------------------------
- (IBAction)cancel:(id)sender
{
	[self dismiss];
}

//-------------------------------------------------------------------------------------------------
- (void)windowWillClose:(NSNotification*)notification
{
	[self dismiss];
}


@end

