# What's the buzz?

DFeedback (DaisyDisk Feedback) is a two-in-one component for providing user feedback:

It allows the user to send feedback and request support from within your app. Along with the message, the component can optionally send the user's e-mail and system configuration profile.
![Screenshot](http://f.cl.ly/items/0v3j0Y371q230s3n3b3J/DFeedback.png)

It automatically catches all unhandled exceptions and shows a crash report window suggesting the user to send an anonymous crash report, along with the stack trace, system configuration profile and optional user comments.
![Screenshot](http://f.cl.ly/items/3J291y25373q413C0N0x/DDFeedback_crash.png)

# Usage

DFeedback is a package of source code files (Cocoa, Obj-C) that you need to add to your project.

## The feedback window
First, call `DFFeedbackWindowController initializeWithFeedbackUrl:systemProfileDataTypes:` once to initialize the component and provide a URL for sending the feedback. (For example, in your `NSApplicationDelegate applicationWillFinishLaunching:`)
Call one of `DFFeedbackWindowController show*` methods to display the feedback dialog.

The `systemProfileDataTypes` parameter allows to filter the system profile string, to remove long unnecessary parts, such as Printer Software. There is a hidden feature: if you hold OPT key when calling `DFFeedbackWindowController showBugReport` or `DFFeedbackWindowController showFeatureRequest`, or switching to Bug Report or Feature Request tabs, in other words, whenever the system profile begins fetching, you can gather the entire unfiltered profile. You can tell the user to do so if you happen to need the full profile instead of the filtered one.

## The crash reporter
First, call `DFCrashReporterWindowController initializeWithFeedbackUrl:updateUrl:icon:systemProfileDataTypes:` once to initialize the component and provide a URL for sending the feedback. (For example, in your -`NSApplicationDelegate applicationWillFinishLaunching:`)
Specify `DFApplication` class as the principle class in your application's Info.plist file. Or, if you already use your own application principal class subclassed from `NSApplication`, subclass it from the `DFApplication` class instead. 

Use `DFApplication isPortmortem` flag:
In your `NSApplicationDelegate applicationShouldTerminateAfterLastWindowClosed:`, if your app should normally quit on last window closed, but not so after a crash, when the crash reporter will forcedly close all windows and show the report window, like this: 

    (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)application
                {
                    // don't quit at this point and allow the crash reporter to show first
                    return ![(DFApplication*)NSApp isPostmortem];
                }

In your application delegate's `NSUserInterfaceValidations validateUserInterfaceItem:`, in order to disable all (or some) menu items while the app is being terminated due to an uncaught exception (no need to do the same in window delegates, because all windows will be forcedly closed by the crash reporter), like this:

                (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item
                {
                    // disable all menu items while showing the crash reporter
                    if ([(DFApplication*)NSApp isPostmortem])
                    {
                        return NO;
                    }
                    …
                }


The two above components are independent on each other, you can use any or both of them.

If you want to do some fine-tuning, there is DFStyleSheet.m file containing some appearance/behavior constants.

Don't forget to link to the following frameworks:
- QuatzCore
- AddressBook

# Origin, credits and legal stuff

DFeedback was inspired by [JRFeedbackProvider](https://github.com/rentzsch/jrfeedbackprovider) and [FeedbackReporter](https://github.com/tcurdt/feedbackreporter), but totally rewritten from scratch (except maybe some tiny portions of code) to provide better experience.

The component is available under the terms of non-restrictive [MIT license](http://en.wikipedia.org/wiki/MIT_License).

The stack trace for the crash reporter is obtained using the [Google Toolbox for Mac](http://code.google.com/p/google-toolbox-for-mac/).

Portions of the software may contain third party code distributed under other non-restrictive licenses.

Love DFeedback and use it in your own projects? Feel free to [send](http://www.daisydiskapp.com/support.php) us a link/screenshot.
