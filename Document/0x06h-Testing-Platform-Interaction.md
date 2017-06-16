## Testing Platform Interaction on iOS

### Testing App permissions

#### Overview

-- TODO [Provide a general description of the issue "Testing App permissions".] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of remark "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

-- TODO [Add content on Static analysis of "Testing App permissions" with source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing App permissions" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing App permissions".] --

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage - https://www.owasp.org/index.php/Mobile_Top_10_2016-M1-Improper_Platform_Usage

##### OWASP MASVS
* V6.1: "The app only requires the minimum set of permissions necessary."

##### CWE
* CWE-250 - Execution with Unnecessary Privileges

##### Info
* [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx

##### Tools
-- TODO [Add tools for "Testing App permissions"] --



### Testing Input Validation and Sanitization

#### Overview

-- TODO [Provide a general description of the issue "Testing Input Validation and Sanitization".] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of remark "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

-- TODO [Add content for static analysis of "Testing Input Validation and Sanitization" with source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Input Validation and Sanitization".] --

#### References

##### OWASP Mobile Top 10 2016
* M7 - Poor Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
* V6.2: "All inputs from external sources and the user are validated and if necessary sanitized. This includes data received via the UI, IPC mechanisms such as intents, custom URLs, and network sources."

##### CWE
* CWE-20 - Improper Input Validation

##### Info
* [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx

##### Tools
-- TODO [Add relevant tools for "Testing Input Validation and Sanitization"] --



### Testing Custom URL Schemes

#### Overview


Check: https://developer.apple.com/library/content/documentation/iPhone/Conceptual/iPhoneOSProgrammingGuide/Inter-AppCommunication/Inter-AppCommunication.html
https://labs.mwrinfosecurity.com/blog/needle-how-to/ (dynamic/ipc/open_uri: Test IPC attacks by launching URI Handlers)
-- TODO [Provide a general description of the issue "Testing Custom URL Schemes".]

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of remark "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

-- TODO [Add content on static analysis for "Testing Custom URL Schemes" with source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing Custom URL Schemes" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Custom URL Schemes".] --

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage - https://www.owasp.org/index.php/Mobile_Top_10_2016-M1-Improper_Platform_Usage

##### OWASP MASVS
* V6.3: "The app does not export sensitive functionality via custom URL schemes, unless these mechanisms are properly protected."

##### CWE
-- TODO [Add relevant CWE for "Testing Custom URL Schemes"] --

##### Info
* [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx


##### Tools
-- TODO [Add relevant tools for "Testing Custom URL Schemes"] --



### Testing for Sensitive Functionality Exposed Through IPC

#### Overview

-- TODO [Provide a general description of the issue "Testing for Sensitive Functionality Exposed Through IPC".] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of remark "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

-- TODO [Add content on static analysis of "Testing for Sensitive Functionality Exposed Through IPC" with source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing for Sensitive Functionality Exposed Through IPC" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing for Sensitive Functionality Exposed Through IPC".] --

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage - https://www.owasp.org/index.php/Mobile_Top_10_2016-M1-Improper_Platform_Usage

##### OWASP MASVS
- V6.4: "The app does not export sensitive functionality through IPC facilities, unless these mechanisms are properly protected."

##### CWE
-- TODO [Add relevant CWE for "Testing for Sensitive Functionality Exposed Through IPC"] --

##### Info
- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx

##### Tools
-- TODO [Add relevant tools for "Testing for Sensitive Functionality Exposed Through IPC"] --



### Testing JavaScript Execution in WebViews

#### Overview

The WebView object is used to embed a web browser in your iOS application. It is a convenient way to display a web page in your application without any interaction with your native mobile browser. WebView even allows you to interact with JavaScript code in pages it has loaded. This great opportunity however may expose your application for a big risk if no security controls are applied. One of such big risk is a possibility to execute a malicious JavaScript code in your application via WebView object.

#### Static Analysis

Depending on your iOS version a WebView object can be implemented using UIWebView (for iOS versions 7.1.2 and older)<sup>[1]</sup> or WKWebView (for iOS in version 8.0 and later)<sup>[2]</sup>. WKWebView is recommended to be used.

The WKWebView object allows for JavaScript execution by default. That may raise a serious risk of running arbitrary code on user's device via WebView object. If your WebView does not require executing JavaScript as it's just display a static web page, you should definitely disable it. You can do it using preferences of an object WKPreferences<sup>[3]</sup>, like in the following example:

```
#import "ViewController.h"
#import <WebKit/WebKit.h>
@interface ViewController ()<WKNavigationDelegate,WKUIDelegate>
@property(strong,nonatomic) WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad {

    NSURL *url = [NSURL URLWithString:@"http://www.example.com/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    WKPreferences *pref = [[WKPreferences alloc] init];

    //Disable javascript execution:
    [pref setJavaScriptEnabled:NO];
    [pref setJavaScriptCanOpenWindowsAutomatically:NO];

    WKWebViewConfiguration *conf = [[WKWebViewConfiguration alloc] init];
    [conf setPreferences:pref];
    _webView = [[WKWebView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x,85, self.view.frame.size.width, self.view.frame.size.height-85) configuration:conf] ;
    [_webView loadRequest:request];
    [self.view addSubview:_webView];

}

```

If there is no explicitly disabled JavaScript execution via WKPreferences object, then it means it is enabled.


#### Dynamic Analysis

A Dynamic Analysis depends on different surrounding conditions, as there are different possibilities to inject JavaScript into a WebView of an application:

* Stored Cross-Site Scripting (XSS) vulnerability in an endpoint, where the exploit will be sent to the WebView of the Mobile App when navigating to the vulnerable function.
* Man-in-the-middle (MITM) position by an attacker where he is able to tamper the response by injecting JavaScript.

#### Remediation

The UIWebView should be avoided and WKWebView used instead. JavaScript is enabled by default in a WKWebView and should be disabled if not needed. This reduces the attack surface and potential threats to the application.

In order to address these attack vectors, the outcome of the following checks should be verified:

* that all functions offered by the endpoint need to be free of XSS vulnerabilities<sup>[4]</sup>.

* that the HTTPS communication need to be implemented according to the best practices to avoid MITM attacks (see "Testing Network Communication").


#### References

##### OWASP Mobile Top 10 2016

* M7 - Client Side Injection - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS

- V6.5: "JavaScript is disabled in WebViews unless explicitly required."

##### CWE

- CWE-79 - Improper Neutralization of Input During Web Page Generation https://cwe.mitre.org/data/definitions/79.html

##### Info

- [1] UIWebView reference documentation - https://developer.apple.com/reference/uikit/uiwebview
- [2] WKWebView reference documentation - https://developer.apple.com/reference/webkit/wkwebview
- [3] WKPreferences - https://developer.apple.com/reference/webkit/wkpreferences#//apple_ref/occ/instp/WKPreferences/javaScriptEnabled
- [4] XSS (Cross Site Scripting) Prevention Cheat Sheet - https://www.owasp.org/index.php/XSS_(Cross_Site_Scripting)_Prevention_Cheat_Sheet


### Testing WebView Protocol Handlers

#### Overview

-- TODO [Provide a general description of the issue "Testing WebView Protocol Handlers".] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of remark "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

-- TODO [Add content on static analysis of "Testing WebView Protocol Handlers" with source code) --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing WebView Protocol Handlers" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing WebView Protocol Handlers".] --

#### References

##### OWASP Mobile Top 10 2016
* M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V6.6: "WebViews are configured to allow only the minimum set of protocol handlers required (ideally, only https is supported). Potentially dangerous handlers, such as file, tel and app-id, are disabled."

##### CWE
-- TODO [Add relevant CWE for "Testing WebView Protocol Handlers"] --

##### Info
- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx

##### Tools
-- TODO [Add relevant tools for "Testing WebView Protocol Handlers"] --



### Testing for Local File Inclusion in WebViews

#### Overview

-- TODO [Provide a general description of the issue "Testing for Local File Inclusion in WebViews".] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of remark "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

-- TODO [Add content on static analysis of "Testing for Local File Inclusion in WebViews" with source code] --


#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing for Local File Inclusion in WebViews" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing for Local File Inclusion in WebViews".] --

#### References

##### OWASP Mobile Top 10 2016
* M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V6.7: "The app does not load user-supplied local resources into WebViews."

##### CWE
-- TODO [Add relevant CWE for "Testing for Local File Inclusion in WebViews"] --

##### Info
- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx

##### Tools
-- TODO [Add relevant tools for "Testing for Local File Inclusion in WebViews"] --



### Testing Whether Java Objects Are Exposed Through WebViews

It is important to clarify that this control is only applicable on the Android Platform. Please look at "Testing Whether Java Objects Are Exposed Through WebViews" in Android for a detailed explanation of this test case.



### Testing Object persistance

#### Overview

-- TODO [Add overview for "Testing Object Serialization"] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of remark "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

-- TODO [Add content on static analysis of "Testing Object Serialization" with source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing Object Serialization" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Object Serialization".] --

#### References

##### OWASP Mobile Top 10 2016
* M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
* V6.9: "Object serialization, if any, is implemented using safe serialization APIs."

##### CWE
-- TODO [Add relevant CWE for "Testing Object Serialization"] --

##### Info
* [1] Update Security Provider - https://developer.android.com/training/articles/security-gms-provider.html

##### Tools
-- TODO [Add relevant tools for "Testing Object Serialization"] --



### Testing Jailbreak Detection

#### Overview

iOS implements containerization so that each app is restricted to its own sandbox. A regular app cannot access files outside its dedicated data directories, and access to system APIs is restricted via app privileges. As a result, an app’s sensitive data as well as the integrity of the OS is guaranteed under normal conditions. However, when an adversary gains root access to the mobile operating system, the default protections can be bypassed completely.

The risk of malicious code running as root is higher on jailbroken devices, as many of the default integrity checks are disabled. Developers of apps that handle highly sensitive data should therefore consider implementing checks that either prevent the app from running under these conditions, or at least warn the user about the increased risks.

#### Static Analysis

Look for a function with a name like isJailBroken in the code. If none of these are available, look for code checking for the following:
1. Existence of files (such as anything with cydia or substrate in the name (such as `/private/var/lib/cydia or /Library/MobileSubstrate/MobileSubstrate.dylib`), `/var/lib/apt, /bin/bash, /usr/sbin/sshd, sftp`, etc). In swift this is done with the `FileManager.default.fileExists(atPath: filePath)` function and objective-c uses `[NSFileManager defaultManager] fileExistsAtPath:filePath`, so grepping for fileExists should show you a good list.
2. Changes of directory permissions (ie being able to write to a file outside the the apps own directory - common examples are `/, /private, /lib, /etc, /System, /bin, /sbin, /cores, /etc`). /private and / seem to be the most commonly used for testing.

	2.1 Check actual permissions themselves: Swift uses `NSFilePosixPermissions` and objective-c uses `directoryAttributes`, so grep for these.

	2.2 Check if you can write a file: Swift and objective-c both use the key words `write` and `create` for file and directory writing and creation. So grep for this and pipe to a grep for `/private` (or others) to get a reference.
3. Checking size of `/etc/fstab` - a lot of tools modify this file, but this method is uncommon as an update from apple may break this check.
4. Creation of symlinks due to the jailbreak taking up space on the system partition. Look for references to `/Library/Ringtones,/Library/Wallpaper,/usr/arm-apple-darwin9,/usr/include,/usr/libexec,/usr/share,/Applications` in the code.


#### Dynamic Analysis

First try running on a jailbroken device and see what happens. If a jailbreak detection is implemented use Cycript<sup>[3]</sup> to examine the methods for any obvious anti-Jailbreak type name (e.g. `isJailBroken`). Note this requires a jailbroken iOS device with Cycript installed and shell access (via ssh). Also, at time of writing, Cycript cannot manipulate native Swift code (but can still look at any Objective-C libraries that are called). To tell if the app is written in Swift use the nm<sub>[4]</sub> tool:

```
nm <appname> | grep swift
```
For an Objective-C only app there will be no output. However, it is still possible the app is mixed Swift and Objective-C.

```
cycript -p <AppName>
cy#[ObjectiveC.classes allKeys]
```

It is recommended you pipe this to a file, then search for something that sounds like a promising classname like jailbreak, startup, system, initial, load, etc. Once you have a candidate list the methods:

```
cy#printMethods(<classname>)
```

Again, you may want to pipe to a file and go through it for a promising sounding method (e.g. has jail or root in the title).

#### Remediation

For iOS jailbreaking, it is worth noting that a determined hacker (or tester!) could use Cycript's method swizzling to modify this function to always return true. Of course there are more complex implementations, but nearly all can be subverted - the idea is just to make it harder. As such the following is recommended:
1. Use more than 1 of the above methods to check if a device is jailbroken.
2. Call the class and method something that is not immediately obvious (but it well commented).
3. Use Swift instead of Objective-C.

#### References

##### OWASP Mobile Top 10 2016
* M8 - Code Tampering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M8-Code_Tampering
* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS
* V6.10: "The app detects whether it is being executed on a rooted or jailbroken device. Depending on the business requirement, users are warned, or the app is terminated if the device is rooted or jailbroken."

##### CWE
Not covered.

##### Info
[4] - nm tool (part of XCode) - https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/nm.1.html

##### Tools

[3] cycript - http://www.cycript.org/
