##Intro

DFeedback (DaisyDisk Feedback) is a component for providing in-app feedback and requesting support. Along with the text, the component can send the user's e-mail and optional system configuration profile.

Here's how it looks:

<img src="ReadMeScreenshot.png">

##Usage

DFeedback is a package of source code (Cocoa, Obj-C) that you simply add to your project.

The API is simple: 

- First, call +[DFWindowController initializeWithFeedbackURL:] once to initialize the component and provide a URL for sending the feedback.
- Call one of +[DFWindowController show*] methods to display the feedback dialog.
- If you want to do some fine-tuning, there is DFStyleSheet.m file containing some appearance/behavior constants.

Don't forget to link to the following frameworks:

- QuatzCore
- AddressBook

##Origin, credits and legal stuff

DFeedback was inspired by [JRFeedbackProvider](https://github.com/rentzsch/jrfeedbackprovider), but totally rewritten from scratch (except maybe some tiny portions of code).

The component is available under the terms of non-restrictive [MIT license](http://en.wikipedia.org/wiki/MIT_License).

DFWarningIcon.png from the [Basic Set](http://pixel-mixer.com/BASIC_SET/) © 2009 by Ekaterina Prokofieva can be used under the following terms:
"These icons are free for commercial use. A link to [pixel-mixer.com](http://pixel-mixer.com) is required.
Otherwise, please purchase a commercial license for 35$."

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
