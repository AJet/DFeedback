##Intro

DFeedback (DaisyDisk Feedback) is a two-in-one component for providing user feedback:

1. It allows the user to send feedback and request support from within your app. Along with the message, the component can optionally send the user's e-mail and system configuration profile.
![Screenshot](http://www.daisydiskapp.com/img/DFFeedbackScreenshot.png)
2. It automatically catches all unhandled exceptions and shows a crash report window suggesting the user to send an anonymous crash report, along with the stack trace, system configuration profile and optional user comments.
![Screenshot](http://www.daisydiskapp.com/img/DFCrashReportScreenshot.png)

##Usage

DFeedback is a package of source code (Cocoa, Obj-C) that you simply add to your project.

The API is simple:

1. The feedback window:
 - First, call +[DFFeedbackWindowController initializeWithFeedbackURL:] once to initialize the component and provide a URL for sending the feedback. (For example, in your -[NSApplicationDelegate applicationWillFinishLaunching:])

 - Call one of +[DFFeedbackWindowController show*] methods to display the feedback dialog.

2. The crash reporter:
 - First, call +[DFCrashReporterWindowController initializeWithFeedbackURL:icon:] once to initialize the component and provide a URL for sending the feedback. (For example, in your -[NSApplicationDelegate applicationWillFinishLaunching:])
 - Specify DFApplication class as the principle class in your application's Info.plist file. Or, if you already use your own application principal class subclassed from NSApplication, subclass it from the DFApplication class instead. 
 - Use -[DFApplication isPortmortem] flag:
  a) In your -[NSApplicationDelegate applicationShouldTerminateAfterLastWindowClosed:], if your app should normally quit on last window closed, but not so after a crash, when the crash reporter will forcedly close all windows and show the report window, like this: 

        - (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)application
        {
            // don't quit at this point and allow the crash reporter to show first
            return ![(DFApplication*)NSApp isPostmortem];
        }

  b) In your -[NSUserInterfaceValidations validateUserInterfaceItem:], in order to disable all (or some) menu items while the app is being terminated due to an uncaught exception, like this:

        - (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)item
        {
            // disable all menu items while showing the crash reporter
            if ([(DFApplication*)NSApp isPostmortem])
            {
                return NO;
            }
            ...
        }


The two above components are independent on each other, you can use any or both of them.

If you want to do some fine-tuning, there is DFStyleSheet.m file containing some appearance/behavior constants.

Don't forget to link to the following frameworks:

- QuatzCore
- AddressBook

##Origin, credits and legal stuff

DFeedback was inspired by [JRFeedbackProvider](https://github.com/rentzsch/jrfeedbackprovider) and [FeedbackReporter](https://github.com/tcurdt/feedbackreporter), but totally rewritten from scratch (except maybe some tiny portions of code).

The component is available under the terms of non-restrictive [MIT license](http://en.wikipedia.org/wiki/MIT_License).

DFWarningIcon.png from the [Basic Set](http://pixel-mixer.com/BASIC_SET/) © 2009 by Ekaterina Prokofieva can be used under the following terms:
"These icons are free for commercial use. A link to [pixel-mixer.com](http://pixel-mixer.com) is required.
Otherwise, please purchase a commercial license for 35$."

The stack trace for the crash reporter is obtained using the [Google Toolbox for Mac](http://code.google.com/p/google-toolbox-for-mac/).

Portions of the software may contain third party code distributed under other non-restrictive licenses.

##FAQ

__What license does it use?__<br />
We selected [MIT License](http://en.wikipedia.org/wiki/MIT_License). It's simple, it's fair and it's free of all the [GPL's](http://en.wikipedia.org/wiki/GPL) bullshit.

__Why not just use JRFeedbackProvider?__<br />
We used [JRFeedbackProvider](https://github.com/rentzsch/jrfeedbackprovider) in the very first versions of [DaisyDisk](http://www.daisydiskapp.com), but later replaced it with a custom component. While both look similar on screenshots, DFeedback has the following advantages:

* polished look and feel
* visual feedback for missing e-mail address when "reply to" is checked
* optional system info (collected in the background, can be previewed by users)

__Are there any downsides?__<br />
We haven't build DFeedback as an all-purpose ultra-flexible component. It's designed with DaisyDisk in mind, but you're free to modify it to fit your special needs.

Love DFeedback and use it in your own projects? Feel free to [send](http://www.daisydiskapp.com/support.php) us a link/screenshot.
