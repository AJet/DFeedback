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
#import "ApplicationSandboxInfo.h"
#import "DFComboBoxCell.h"
#import "OSXVersion.h"
#import "StringAnonymizer.h"
#import "EmailValidation.h"

//-------------------------------------------------------------------------------------------------
#pragma mark - Private constants
//-------------------------------------------------------------------------------------------------
static NSString* const NIB_NAME = @"DFFeedbackWindow";
typedef enum : NSUInteger
{
	DFFeedback_General = 0,
	DFFeedback_Feature = 1,
	DFFeedback_Bug = 2
} DFFeedbackType;

typedef enum : NSUInteger
{
    DFProgress_None = 0,
    DFProgress_Profiling,
    DFProgress_Sending
} DFProgressMode;

static NSString* const kStateMessage = @"DFeedback_Message";
static NSString* const kStateFeedbackType = @"DFeedback_FeedbackType";
static NSString* const kStateIncludeSystemProfile = @"DFeedback_IncludeSystemProfile";
static NSString* const kStateIncludeEmailAddress = @"DFeedback_IncludeEmailAddress";
static NSString* const kStateEmailAddress = @"DFeedback_EmailAddress";

//-------------------------------------------------------------------------------------------------
#pragma mark - Private static variables
//-------------------------------------------------------------------------------------------------
static DFFeedbackWindowController* _singleton = nil;
static NSString* _feedbackUrl = nil;
static DFSystemProfileDataType _systemProfileDataTypes = DFSystemProfileData_All;


//-------------------------------------------------------------------------------------------------
#pragma mark - Private interface
//-------------------------------------------------------------------------------------------------
@interface DFFeedbackWindowController()

// tab control
@property (nonatomic, assign) IBOutlet NSSegmentedControl* tabsSegmentedControl;
@property (nonatomic, assign) IBOutlet DFKeyTabView* tabView;

// text view
@property (nonatomic, assign) IBOutlet NSView* textContainer;
@property (nonatomic, assign) IBOutlet DFPlaceholderTextView* textView;

// system profile controls
@property (nonatomic, assign) IBOutlet NSView* systemProfileContainer;
@property (nonatomic, assign) IBOutlet NSButton* includeSystemProfileCheckBox;

// email controls
@property (nonatomic, assign) IBOutlet NSButton* includeEmailCheckBox;
@property (nonatomic, assign) IBOutlet NSComboBox* emailComboBox;
@property (nonatomic, assign) IBOutlet DFBounceIconView* emailBounceIcon;

// progress controls
@property (nonatomic, assign) IBOutlet NSView* progressContainer;
@property (nonatomic, assign) IBOutlet NSProgressIndicator* progressIndicator;
@property (nonatomic, assign) IBOutlet NSTextField* sendingProgressLabel;
@property (nonatomic, assign) IBOutlet NSTextField* profilingProgressLabel;
@property (nonatomic) DFProgressMode progressMode;

// footer controls
@property(nonatomic, assign) IBOutlet NSButton* sendButton;

// details window controls
@property (nonatomic, assign) IBOutlet NSWindow* detailsWindow;
@property (nonatomic, assign) IBOutlet NSView* detailsTextContainer;
@property (nonatomic, assign) IBOutlet NSTextView* detailsTextView;
@property (nonatomic, assign) IBOutlet NSProgressIndicator* detailsProgressIndicator;
@property (nonatomic, assign) IBOutlet NSTextField* detailsProgressLabel;

// Displayed data
@property (nonatomic, retain) NSString* systemProfile;

@end

//-------------------------------------------------------------------------------------------------
#pragma mark - Implementation
//-------------------------------------------------------------------------------------------------
@implementation DFFeedbackWindowController
{
	DFSystemProfileFetcher* _systemProfileFetcher;
	DFFeedbackSender* _feedbackSender;
	BOOL _isSendingReport;
    BOOL _isFetchingSystemProfile;
    NSRect _emailBounceIconSavedFrame;
}

//-------------------------------------------------------------------------------------------------
#pragma mark - Initialization
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
+ (void)initializeWithFeedbackUrl:(NSString*)feedbackUrl
           systemProfileDataTypes:(DFSystemProfileDataType)systemProfileDataTypes;
{
	// save params
	[feedbackUrl retain];
	[_feedbackUrl release];
	_feedbackUrl = feedbackUrl;
    
    _systemProfileDataTypes = systemProfileDataTypes;
}

//-------------------------------------------------------------------------------------------------
+ (DFFeedbackWindowController*)singleton
{
	if (_singleton == nil)
	{
        // initialize styles if not already
        InitializeDFStyles();
        // create singleton
		_singleton = [[DFFeedbackWindowController alloc] init];
	}
	return _singleton;
}

//-------------------------------------------------------------------------------------------------
- (void)initializeEmailBounceIcon
{
	_emailBounceIcon.icon = DFFeedbackWindow_emailWarningImage;
    NSRect emailBounceIconFrame = _emailBounceIconSavedFrame;
    CGFloat emailBounceIconCenterX = emailBounceIconFrame.origin.x + .5 * emailBounceIconFrame.size.width;
    CGFloat emailBounceIconCenterY = emailBounceIconFrame.origin.y + .5 * emailBounceIconFrame.size.height;
    emailBounceIconFrame.size.width = DFFeedbackWindow_emailWarningImage.size.width + DFFeedbackWindow_emailWarningImageZoomIncrement;
    emailBounceIconFrame.size.height = DFFeedbackWindow_emailWarningImage.size.height + DFFeedbackWindow_emailWarningImageZoomIncrement;
    emailBounceIconFrame.origin.x = round(emailBounceIconCenterX - emailBounceIconFrame.size.width * .5);
    emailBounceIconFrame.origin.y = round(emailBounceIconCenterY - emailBounceIconFrame.size.height * .5);
    _emailBounceIcon.frame = emailBounceIconFrame;
    self.emailComboBoxCell.rightMargin = _emailBounceIcon.icon.size.width;
}

//-------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
	// initialize border
	[self.window setContentBorderThickness:DFFeedbackWindow_bottomBarHeight
                                   forEdge:NSMinYEdge];
	
	// initialize placeholder strings
	_textView.placeholderText = NSLocalizedStringFromTable(@"DFeedback_PlaceholderText", @"DFLocalizable", nil);
	
	// initialize email bounce icon
    _emailBounceIconSavedFrame = _emailBounceIcon.frame;
    [self initializeEmailBounceIcon];

	// initialize email from the address book
    // unless the app is sandboxed and doesn't have the entitlement
    // or if we are on 10.8 - we don't want the user to see the dreaded message box
    if (self.shouldAccessContacts)
    {
        ABMutableMultiValue* emailAddresses = [[ABAddressBook sharedAddressBook].me valueForProperty:kABEmailProperty];
        for (NSUInteger addrIndex = 0; addrIndex < emailAddresses.count; addrIndex++)
        {
            [_emailComboBox addItemWithObjectValue:[emailAddresses valueAtIndex:addrIndex]];
        }
        if (_emailComboBox.numberOfItems > 0)
        {
            [_emailComboBox selectItemAtIndex:0];
        }
    }
	
	// restoration
    [self.window performSelector:@selector(setRestorable:)
                      withObject:(id)(NSUInteger)YES];
    [self.window performSelector:@selector(setRestorationClass:)
                      withObject:self.class];
}

//-------------------------------------------------------------------------------------------------
- (void)initializeControlsForFeedbackType:(DFFeedbackType)feedbackType
{
    // force window to load
    if (self.window != nil)
    {
        // cleanup, just in case
        [_systemProfileFetcher cancel];
        [_systemProfileFetcher release];
        _systemProfileFetcher = nil;
        _isSendingReport = NO;
        _sendButton.enabled = YES;
        self.progressMode = DFProgress_None;
        [self resetEmailWarning];
        
        // window title
        NSString* windowTitle = self.window.title;
        windowTitle = [NSString stringWithFormat:windowTitle, [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"]];
        self.window.title = windowTitle;
        
        // select tab
        NSUInteger tabIndex = [self tabIndexFromFeedbackType:feedbackType];
        _tabsSegmentedControl.selectedSegment = tabIndex;
        [_tabView selectTabViewItemAtIndex:tabIndex];
        [self tabView:_tabView didSelectTabViewItem:[_tabView tabViewItemAtIndex:tabIndex]];

        // load previous e-mail
        NSString* previousEmail = [[NSUserDefaults standardUserDefaults] objectForKey:kStateEmailAddress];
        if (previousEmail != nil)
        {
            _emailComboBox.stringValue = previousEmail;
        }
    }
}

//-------------------------------------------------------------------------------------------------
- (void)initializeFirstResponder
{
	// this is needed to prevent the focus ring to appear on the tab buttons, each time the window is shown
	[self.window makeFirstResponder:_tabView];
}

//-------------------------------------------------------------------------------------------------
#pragma mark - Restore
//-------------------------------------------------------------------------------------------------
+ (void)restoreWindowWithIdentifier:(NSString*)identifier
                              state:(NSCoder*)state
                  completionHandler:(void (^)(NSWindow*, NSError*))completionHandler
{
    // force nib to load
    if (self.singleton.window != nil)
    {
        [self.singleton restoreState:state];
        completionHandler(self.singleton.window, nil);
    }
}

//-------------------------------------------------------------------------------------------------
- (void)restoreState:(NSCoder*)state
{
	DFFeedbackType feedbackType = DFFeedback_General;
	if ([state containsValueForKey:kStateFeedbackType])
	{
		feedbackType = (DFFeedbackType)[state decodeIntForKey:kStateFeedbackType];
	}
	[self initializeControlsForFeedbackType:feedbackType];
    
	NSString* message = [state decodeObjectForKey:kStateMessage];
	if (message != nil)
	{
		_textView.string = message;
	}
	NSString* emailAddress = [state decodeObjectForKey:kStateEmailAddress];
	if (emailAddress != nil)
	{
		_emailComboBox.stringValue = emailAddress;
	}
	if ([state containsValueForKey:kStateIncludeEmailAddress])
	{
		BOOL includeEmailAddress = [state decodeBoolForKey:kStateIncludeEmailAddress];
		_includeEmailCheckBox.state = includeEmailAddress ? NSOnState : NSOffState;
	}
	if ([state containsValueForKey:kStateIncludeSystemProfile])
	{
		BOOL includeSystemProfile = [state decodeBoolForKey:kStateIncludeSystemProfile] && [DFSystemProfileFetcher canFetch];
		_includeSystemProfileCheckBox.state = includeSystemProfile ? NSOnState : NSOffState;
	}
}

//-------------------------------------------------------------------------------------------------
- (void)window:(NSWindow*)window willEncodeRestorableState:(NSCoder*)state
{
	[state encodeObject:_textView.string forKey:kStateMessage];
	[state encodeObject:_emailComboBox.stringValue forKey:kStateEmailAddress];
	[state encodeInt:self.currentFeedbackType forKey:kStateFeedbackType];
	[state encodeBool:_includeEmailCheckBox.state == NSOnState forKey:kStateIncludeEmailAddress];
	[state encodeBool:_includeSystemProfileCheckBox.state == NSOnState forKey:kStateIncludeSystemProfile];
}

//-------------------------------------------------------------------------------------------------
#pragma mark - Tab control
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
	NSUInteger tabIndex = [_tabView indexOfTabViewItem:_tabView.selectedTabViewItem];
	return [self feedbackTypeFromTabIndex:tabIndex];
}

//-------------------------------------------------------------------------------------------------
- (void)tabView:(NSTabView*)sender didSelectTabViewItem:(NSTabViewItem*)tabViewItem
{
	if (sender == _tabView)
	{
		// switch window views when the system profile is visible/hidden
        BOOL isSystemProfileAvailable = self.currentFeedbackType != DFFeedback_General && [DFSystemProfileFetcher canFetch];
        
		// system profile controls
		_systemProfileContainer.hidden = !isSystemProfileAvailable;
        
		// text container
		NSRect textContainerFrame = _textContainer.frame;
		NSRect systemProfileFrame = _systemProfileContainer.frame;
		if (!isSystemProfileAvailable)
		{
			// expand text container
			if (textContainerFrame.origin.y > systemProfileFrame.origin.y)
			{
				CGFloat diffHeight = textContainerFrame.origin.y - systemProfileFrame.origin.y;
				textContainerFrame.origin.y -= diffHeight;
				textContainerFrame.size.height += diffHeight;
			}
            // also close details window, it becomes irrelevant
            [self.detailsWindow orderOut:self];
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
		_textContainer.frame = textContainerFrame;

		// send button
		[self validateSendButton];
		
		// begin fetching profile immediately after switching to a page that contains it
		if (isSystemProfileAvailable)
		{
			[self beginFetchingSystemProfile];
		}
        
        [self updateProgressMode];
	}
}

//-------------------------------------------------------------------------------------------------
- (IBAction)tabsSegmentedControlChanged:(id)sender
{
	// sync tab view with the tab buttons
	[_tabView selectTabViewItemAtIndex:_tabsSegmentedControl.selectedSegment];
}

//-------------------------------------------------------------------------------------------------
#pragma mark - Message text view
//-------------------------------------------------------------------------------------------------
- (void)textViewDidChangeSelection:(NSNotification*)notification
{
	[self validateSendButton];
}

//-------------------------------------------------------------------------------------------------
#pragma mark - Details button
//-------------------------------------------------------------------------------------------------
- (IBAction)showDetails:(id)sender
{
	if (!_detailsWindow.isVisible)
	{
		[_detailsWindow center];
	}
	[_detailsWindow makeKeyAndOrderFront:self];
}


//-------------------------------------------------------------------------------------------------
#pragma mark - E-mail field
//-------------------------------------------------------------------------------------------------
- (BOOL)shouldAccessContacts
{
    BOOL result = YES;
    if ([OSXVersion generation] >= OSXGeneration_MountainLion)
    {
        // we don't want the dreaded dialog that the app wants to access your contacts
        result = NO;
    }
    else
    {
        // check if sandboxed at all
        if ([ApplicationSandboxInfo isSandboxed])
        {
            // check if has address book access
            if (![ApplicationSandboxInfo hasAddressBookDataEntitlement])
            {
                result = NO;
            }
        }
    }
    return result;
}

//-------------------------------------------------------------------------------------------------
- (void)showEmailWarning
{
	[_emailBounceIcon showWithAnimation:YES];
}

//-------------------------------------------------------------------------------------------------
- (void)resetEmailWarning
{
	[_emailBounceIcon hideWithAnimation:YES];
}

//-------------------------------------------------------------------------------------------------
- (DFComboBoxCell*)emailComboBoxCell
{
    return (DFComboBoxCell*)_emailComboBox.cell;
}

//-------------------------------------------------------------------------------------------------
- (IBAction)includeEmailCheckBoxChanged:(id)sender
{
	// hide the email warning when the user unchecks the include e-mail box
	if (_includeEmailCheckBox.intValue == 0)
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
	NSView* view = notification.object;
	// hide the email warning when the user types in a valid address into the email input field
	if (view == _emailComboBox)
	{
		[self resetEmailWarning];
	}
}

//-------------------------------------------------------------------------------------------------
#pragma mark - Send button
//-------------------------------------------------------------------------------------------------
- (void)validateSendButton
{
	NSString* message = _textView.textStorage.string;
	_sendButton.enabled = !IsEmptyMessage(message);
}


//-------------------------------------------------------------------------------------------------
- (IBAction)sendReport:(id)sender
{
	BOOL shouldBlinkInvalidEmail = _includeEmailCheckBox.intValue != 0 && !IsValidEmailAddress(_emailComboBox.stringValue);
	if (shouldBlinkInvalidEmail)
	{
		[self showEmailWarning];
	}
	else
	{
        // save e-mail additionally so that the next message can be sent without typing the e-mail again
        if (_includeEmailCheckBox.intValue != 0)
        {
            [[NSUserDefaults standardUserDefaults] setObject:_emailComboBox.stringValue forKey:kStateEmailAddress];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
		// change state
		_isSendingReport = YES;
		_sendButton.enabled = NO;
		[self resetEmailWarning];
        
		// begin fetching system profile
		BOOL isSystemProfileNeeded = self.currentFeedbackType != DFFeedback_General && [DFSystemProfileFetcher canFetch] && _includeSystemProfileCheckBox.state == NSOnState;
		if (isSystemProfileNeeded && !_systemProfileFetcher.isDoneFetching)
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
        
        [self updateProgressMode];
	}
}

//-------------------------------------------------------------------------------------------------
#pragma mark - Progress
//-------------------------------------------------------------------------------------------------
- (void)setProgressMode:(DFProgressMode)value
{
    _progressMode = value;
    
    // progress in main window
    switch (_progressMode)
    {
        case DFProgress_None:

            _progressContainer.hidden = YES;
            [_progressIndicator stopAnimation:self];
            
            break;
        
        case DFProgress_Profiling:

            _progressContainer.hidden = NO;
            _profilingProgressLabel.hidden = NO;
            _sendingProgressLabel.hidden = YES;
            [_progressIndicator startAnimation:self];
            
            break;

        case DFProgress_Sending:

            _progressContainer.hidden = NO;
            _profilingProgressLabel.hidden = YES;
            _sendingProgressLabel.hidden = NO;
            [_progressIndicator startAnimation:self];
            
            break;

        default:
            NSAssert(NO, @"Invalid case for progress mode %lu", _progressMode);
            break;
    }
    
    // progress in details window
    switch (_progressMode)
    {
        case DFProgress_None:
        case DFProgress_Sending:

            _detailsProgressLabel.hidden = YES;
            [_detailsProgressIndicator stopAnimation:self];
            _detailsProgressIndicator.hidden = YES;
            _detailsTextContainer.hidden = NO;
            
            break;
            
        case DFProgress_Profiling:
            
            _detailsProgressLabel.hidden = NO;
            [_detailsProgressIndicator startAnimation:self];
            _detailsProgressIndicator.hidden = NO;
            _detailsTextContainer.hidden = YES;
            
            break;
            
        default:
            NSAssert(NO, @"Invalid case for progress mode %lu", _progressMode);
            break;
    }
    
}

//-------------------------------------------------------------------------------------------------
- (void)updateProgressMode
{
    DFProgressMode result = DFProgress_None;
    if (_isSendingReport)
    {
        result = DFProgress_Sending;
    }
    else if (_isFetchingSystemProfile)
    {
        BOOL isSystemProfileAvailable = [DFSystemProfileFetcher canFetch] && self.currentFeedbackType != DFFeedback_General && _includeSystemProfileCheckBox.state == NSOnState;
        if (isSystemProfileAvailable)
        {
            result = DFProgress_Profiling;
        }
    }
    self.progressMode = result;
}

//-------------------------------------------------------------------------------------------------
#pragma mark - System profile fetching
//-------------------------------------------------------------------------------------------------
- (IBAction)includeSystemProfileCheckBoxDidChange:(id)sender
{
    if (_includeSystemProfileCheckBox.state == NSOnState)
    {
        // begin fetching if not done already
        if (!_isFetchingSystemProfile && !_systemProfileFetcher.isDoneFetching)
        {
            [self beginFetchingSystemProfile];
        }
    }
    else if (_includeSystemProfileCheckBox.state == NSOffState)
    {
        // don't stop fetching system profile, the user may have change his mind
        
        // begin sending immediately if the send button has been already clicked, or wait until it's clicked
        if (_isSendingReport)
        {
            [self beginSendingFeedback];
        }
    }
    
    [self updateProgressMode];

}

//-------------------------------------------------------------------------------------------------
- (void)beginFetchingSystemProfile
{
    self.systemProfile = nil;
	if (_systemProfileFetcher == nil)
	{
		_systemProfileFetcher = [[DFSystemProfileFetcher alloc] init];
        _systemProfileFetcher.delegate = self;
        
        // NOTE: easter egg: hold OPT key to gather all data instead of specified data types
        // tell the user to do this if you happen to find that you have missed some data in the filtered profile
        DFSystemProfileDataType dataTypes = _systemProfileDataTypes;
        if (([NSEvent modifierFlags] &  NSAlternateKeyMask) != 0)
        {
            dataTypes = DFSystemProfileData_All;
        }
        
		[_systemProfileFetcher fetchDataTypes:dataTypes];
		
        _isFetchingSystemProfile = YES;
        
		[self updateProgressMode];
	}
}

//-------------------------------------------------------------------------------------------------
- (void)systemProfileFetcherDidFinish:(DFSystemProfileFetcher*)sender
{
    if (sender == _systemProfileFetcher)
    {
        self.systemProfile = AnonymizeString(_systemProfileFetcher.profile);
        
        // update details window
        _detailsTextView.textStorage.attributedString = [[[NSAttributedString alloc] initWithString:_systemProfile] autorelease];
        
        // reset fetching progress
        _isFetchingSystemProfile = NO;
        
        // begin sending immediately if the send button has been already clicked, or wait until it's clicked
        if (_isSendingReport)
        {
            [self beginSendingFeedback];
        }
        
        [self updateProgressMode];
    }
}

//-------------------------------------------------------------------------------------------------
- (void)cancelFetchingSystemProfile
{
	[_systemProfileFetcher cancel];
	[_systemProfileFetcher release];
	_systemProfileFetcher = nil;
    _isFetchingSystemProfile = NO;
    self.systemProfile = nil;
	[_detailsWindow orderOut:self];
	[self updateProgressMode];
}

//-------------------------------------------------------------------------------------------------
#pragma mark - Sending feedback over network
//-------------------------------------------------------------------------------------------------
- (void)beginSendingFeedback
{
	NSString* userEmail = _includeEmailCheckBox.state == NSOnState ? _emailComboBox.stringValue : nil;
	NSString* feedbackText = _textView.textStorage.string;

    [_feedbackSender cancel];
    _feedbackSender.delegate = nil;
    [_feedbackSender release];
    _feedbackSender = nil;
    
	_feedbackSender = [[DFFeedbackSender alloc] init];
    _feedbackSender.delegate = self;
	[_feedbackSender sendFeedbackToUrl:_feedbackUrl
                          feedbackText:feedbackText
                          feedbackType:[self feedbackTypeStringFromType:self.currentFeedbackType]
                         systemProfile:_systemProfile
                             userEmail:userEmail];
    
	[self updateProgressMode];
}

//-------------------------------------------------------------------------------------------------
- (void)feedbackSender:(DFFeedbackSender*)sender didFinishWithError:(NSError*)error
{
    if (sender == _feedbackSender)
    {
        // cleanup
        [_feedbackSender release];
        _feedbackSender = nil;
        [self updateProgressMode];
        
        // check error
        if (error == nil)
        {
            [self dismiss];
        }
        else
        {
            _sendButton.enabled = YES;
            NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedStringFromTable(@"DFeedback_Alert_SendFailed_Title", @"DFLocalizable", nil)
                                             defaultButton:NSLocalizedStringFromTable(@"DFeedback_Alert_SendFailed_Button_Dismiss", @"DFLocalizable", nil)
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:NSLocalizedStringFromTable(@"DFeedback_Alert_SendFailed_Message", @"DFLocalizable", nil), error.localizedDescription];
            [alert beginSheetModalForWindow:self.window
                              modalDelegate:self
                             didEndSelector:nil
                                contextInfo:NULL];
        }
    }
}

//-------------------------------------------------------------------------------------------------
- (void)cancelAllPendingStuff
{
	[_systemProfileFetcher cancel];
    _systemProfileFetcher.delegate = nil;
	[_systemProfileFetcher release];
	_systemProfileFetcher = nil;
    _isFetchingSystemProfile = NO;
    self.systemProfile = nil;
	[_feedbackSender cancel];
    _feedbackSender.delegate = nil;
	[_feedbackSender release];
	_feedbackSender = nil;
    _isSendingReport = NO;
}

//-------------------------------------------------------------------------------------------------
#pragma mark - Window
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
		[self.window orderOut:self];
		[_detailsWindow orderOut:self];
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

//-------------------------------------------------------------------------------------------------
#pragma mark - Show API
//-------------------------------------------------------------------------------------------------
- (void)showForFeedbackType:(DFFeedbackType)feedbackType
{
	// center the window
	NSWindow* window = self.window;
	if (!window.isVisible)
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


@end

