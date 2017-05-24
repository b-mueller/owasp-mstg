## Testing Code Quality and Build Settings of iOS Apps

### Verifying that the App is Properly Signed

#### Overview

-- TODO [Give an overview about the functionality and it's potential weaknesses] --

#### Static Analysis

-- TODO [Add content on white-box testing of "Verifying that the App is Properly Signed"] --

#### Dynamic Analysis

-- TODO [Add content on black-box testing of "Verifying that the App is Properly Signed"] --

#### Remediation

-- TODO [Add remediation for "Verifying that the App is Properly Signed"] --

#### References

##### OWASP Mobile Top 10 2016
- M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V7.1: "The app is signed and provisioned with valid certificate."

##### CWE
-- TODO [Add relevant CWE for "Verifying that the App is Properly Signed"] --

##### Info
- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx

##### Tools
-- TODO [Add tools for "Verifying that the App is Properly Signed"] --

### Testing If the App is Debuggable

#### Overview

-- TODO [Give an overview about the functionality "Testing Whether the App is Debuggable" and it's potential weaknesses] --

#### Static Analysis

- Import the source code into the xCode Editor.
- Check the project's build settings for 'DEBUG' parameter under "Apple LVM – Preprocessing" -> "Preprocessor Macros".
- Check the source code for NSAsserts method and its companions.

#### Dynamic Analysis

This test case should be performed through Static Analysis.
-- TODO [Develop content on black-box testing of "Testing Whether the App is Debuggable"] --

#### Remediation

Once you have deployed an iOS application, either through the App Store or as an Ad Hoc or Enterprise build, you won't be able to attach Xcode's debugger to it. To debug problems, you need to analyze Crash Logs and Console output from the device itself. Remove any NSLog calls to prevent debug leakage through the Console.

#### References

##### OWASP Mobile Top 10 2016
- M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V7.2: "The app has been built in release mode, with settings appropriate for a release build (e.g. non-debuggable)."

##### CWE
-- TODO [Add relevant CWE for "Testing Whether the App is Debuggable"] --

##### Info
- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx

##### Tools
-- TODO [Add tools for "Testing Whether the App is Debuggable"] --


### Testing for Debugging Symbols

#### Overview

As a general rule of thumb, as little explanative information as possible should be provided along with the compiled code. Some metadata such as debugging information, line numbers and descriptive function or method names make the binary or bytecode easier to understand for the reverse engineer, but isn’t actually needed in a release build and can therefore be safely discarded without impacting the functionality of the app.

These symbols can be saved either in "Stabs" format or the DWARF format. When using the Stabs format, debugging symbols, like other symbols, are stored in the regular symbol table. With the DWARF format, debugging symbols are stored in a special "\_\_DWARF" segment within the the binary. DWARF debugging symbols can also be saved as a separate debug-information file. In this test case, you verify that no debug symbols are contained in the release binary itself (either in the symbol table, or the \_\_DWARF segment).

#### Static Analysis

Use gobjdump to inspect the main binary and any included dylibs for Stabs and DWARF symbols.

```
$ gobjdump --stabs --dwarf TargetApp
In archive MyTargetApp:

armv5te:     file format mach-o-arm


aarch64:     file format mach-o-arm64
```

Gobjdump is part of binutils<sup>[1]</sup> and can be installed via Homebrew on Mac OS X.

#### Dynamic Analysis

Not applicable.

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Verifying that Debugging Symbols Have Been Removed"] --

#### References

##### OWASP Mobile Top 10 2016
- M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V7.3: "Debugging symbols have been removed from native binaries."

##### CWE
-- TODO [Add relevant CWE for "Verifying that Debugging Symbols Have Been Removed"] --

##### Info
- [1] Binutils - https://www.gnu.org/s/binutils/



### Testing for Debugging Code and Verbose Error Logging

#### Overview
Developers often include debugging code, such as verbose logging statements (using `NSLog`, `println`, `print`, `dump`, `debugPrint`) about responses from their APIs, about the progress and/or state of their application in order to speed up verification and get a better understand on errors.
Furthermore, there can be debugging code in terms of a "management-functionality" which is used by the developer to set state of the application, mock responses from an API, et cetera.
This information can easily be used by the reverse-engineer to track back what is happening with the application. Therefore, the debugging code should be removed from the release version of the application.

#### Static Analysis
For static analysis, you can take the following approach regarding the logging statements:
1. Import the code of the application into Xcode.
2. Do a search over the code on the following printing functions:`NSLog`, `println`, `print`, `dump`, `debugPrint`.
3.  When one of them is found, please check whether the developers used a wrapping function around the logging function for better markup of the to be logged statements, start adding that function to your search.
4. For every ocurence found in step 2 and 3, verify whether Macro's or debug-state related guards have been set to turn the logging off in the release build. Please note the change in how objective-C can make use of pre-processor macro's:
```objc
#ifdef DEBUG
    // Debug-only code
#endif
```
Whereas in Swift this has changed: there you need to set either environment-variables in your scheme or as custom flags in the Build settings of a target to make this work. Please note that the following functions, which allow to check on whether the app is build in release-configuration in Swift 2.1, should be recommended against (As Xcode 8 & Swift3 do not support them): `_isDebugAssertConfiguration()`, `_isReleaseAssertConfiguration()`, `_isFastAssertConfiguration()`.

Please note that there are more logging functions, depending on the setup of the application, for instance, when  CocoaLumberjack is used (https://github.com/CocoaLumberjack/CocoaLumberjack), then the static analysis is a bit different.

On the "debug-management" code which is built in: inspect the storyboards to see if there are any flows and/or view-controllers that provide different functionality than the ones that should be supported by the application.
--TODO: reviewer: should we go in depth on different patterns one can find on this subject? --

#### Dynamic Analysis
The dynamic analysis should be executed on both a simulator as well as a device, as we sometimes see that developers use target-based functions (instead of release/debug-mode based functions) to execute the debugging code or not.
1. Run the application on a simulator, check if you can find any output during the execution of the app in the console.
2. Attach a device to your Mac, run the application on the device via Xcode and verify whether you can find any output during the execution of the app in the console.

For the other "manager-based" debug code: click through the application on both a simulator and device and see if you can find any functionality which allows for pre-setting profiles for an app, for selecting the actual server, for selecting possible responses from the API, et cetera.

#### Remediation
As a developer, it should not be a problem to incorporate debug statements in your debug version of the application as long as you realize that the statements made for debugging should never:
- have impact on the actual computational results in such a way that the code should be present in the release version of the application;
- end up in the release-configuration of the application.

In Objective-C, developers can use pre-processor macro's to filter out debug code:
```objc
#ifdef DEBUG
    // Debug-only code
#endif
```
In Swift 2, using xCode 7, one has to set custom compiler flags for every target, where the compiler flag has to start with -D. So, when the debug flag -DMSTG-DEBUG is set, you can use the following annotations:

```swift
#if MSTG-DEBUG
    // Debug-only code
#endif
```

In swift 3, using xCode 8, one can set Active Compilation Conditions setting in Build settings / Swift compiler - Custom flags. Swift3 does not use a pre-processor, but instead makes use of conditional compilation blocks based on the conditions defined:

```swift3
#if DEBUG_LOGGING
    // Debug-only code
#endif
```

#### References

##### OWASP Mobile Top 10 2016
- M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V7.4: "Debugging code has been removed, and the app does not log verbose errors or debugging messages."

##### CWE
-- TODO [Add relevant CWE for "Testing for Debugging Code and Verbose Error Logging"] --

##### Info
- [1] CocoaLumberjack - [https://github.com/CocoaLumberjack/CocoaLumberjack]
- [2] Swift conditional compilation blocks - [https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html#//apple_ref/doc/uid/TP40014216-CH8-ID34]

##### Tools
- XCode & simulator
- A standard iPhone/iPad



### Testing Exception Handling

#### Overview

-- TODO [Give an overview about the functionality "Testing Exception Handling" and it's potential weaknesses] --

#### Static Analysis

Review the source code to understand/identify who the application handle various types of errors (IPC communications, remote services invocation, etc). Here are some examples of the checks to be performed at this stage :

- Verify that the application use a [well-designed] (https://www.securecoding.cert.org/confluence/pages/viewpage.action?pageId=18581047) (and unified) scheme to handle exceptions.
- Verify that the application doesn't expose sensitive information while handling exceptions, but are still verbose enough to explain the issue to the user.

#### Dynamic Testing

-- TODO [Describe how to test for this issue "Testing Exception Handling" using static and dynamic analysis techniques. This can include everything from simply monitoring aspects of the app’s behavior to code injection, debugging, instrumentation, etc. ] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Exception Handling"] --

#### References

##### OWASP Mobile Top 10 2016
- M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V7.5: "The app catches and handles possible exceptions."
- V7.6: "Error handling logic in security controls denies access by default."

##### CWE
-- TODO [Add relevant CWE for "Testing Exception Handling"] --

##### Info
- [1] https://www.gnu.org/s/binutils/

##### Tools
-- TODO [Add tools for "Testing Exception Handling"] --



### Testing for Memory Bugs in Unmanaged Code

#### Overview

-- TODO [Give an overview about the functionality "Testing for Memory Management Bugs" and it's potential weaknesses] --

#### Static Analysis

-- TODO [Add content for white-box testing of "Testing for Memory Management Bugs"] --

#### Dynamic Analysis

-- TODO [Add content for black-box testing of "Testing for Memory Management Bugs"] --

#### Remediation

-- TODO

#### References

##### OWASP Mobile Top 10 2016
- M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V7.7: "In unmanaged code, memory is allocated, freed and used securely."

##### CWE
-- TODO [Add relevant CWE for "Testing for Memory Management Bugs"] --

##### Info
-- TODO [Add info sor "Testing for Memory Management Bugs"] --

##### Tools
-- TODO [Add tools for "Testing for Memory Management Bugs"] --


### Verify That Free Security Features Are Activated

#### Overview

Although XCode set all binary security features by default, it still might be relevant to some old application or to check compilation options misconfiguration. The following features are applicable:

- **ARC** - Automatic Reference Counting - memory management feature
  * adds retain and release messages when required
- **Stack Canary** - helps preventing buffer overflow attacks
- **PIE** - Position Independent Executable - enables full ASLR for binary

#### Static Analysis

-- TODO

#### Dynamic Analysis

##### With otool:

Below are examples on how to check for these features. Please note that all of them are enabled in these examples:

- PIE:
```
$ unzip DamnVulnerableiOSApp.ipa
$ cd Payload/DamnVulnerableIOSApp.app
$ otool -hv DamnVulnerableIOSApp
DamnVulnerableIOSApp (architecture armv7):
Mach header
magic cputype cpusubtype caps filetype ncmds sizeofcmds flags
MH_MAGIC ARM V7 0x00 EXECUTE 38 4292 NOUNDEFS DYLDLINK TWOLEVEL
WEAK_DEFINES BINDS_TO_WEAK PIE
DamnVulnerableIOSApp (architecture arm64):
Mach header
magic cputype cpusubtype caps filetype ncmds sizeofcmds flags
MH_MAGIC_64 ARM64 ALL 0x00 EXECUTE 38 4856 NOUNDEFS DYLDLINK TWOLEVEL
WEAK_DEFINES BINDS_TO_WEAK PIE
```

- Stack Canary:
```
$ otool -Iv DamnVulnerableIOSApp | grep stack
0x0046040c 83177 ___stack_chk_fail
0x0046100c 83521 _sigaltstack
0x004fc010 83178 ___stack_chk_guard
0x004fe5c8 83177 ___stack_chk_fail
0x004fe8c8 83521 _sigaltstack
0x00000001004b3fd8 83077 ___stack_chk_fail
0x00000001004b4890 83414 _sigaltstack
0x0000000100590cf0 83078 ___stack_chk_guard
0x00000001005937f8 83077 ___stack_chk_fail
0x0000000100593dc8 83414 _sigaltstack
```

- Automatic Reference Counting:
```
$ otool -Iv DamnVulnerableIOSApp | grep release
0x0045b7dc 83156 ___cxa_guard_release
0x0045fd5c 83414 _objc_autorelease
0x0045fd6c 83415 _objc_autoreleasePoolPop
0x0045fd7c 83416 _objc_autoreleasePoolPush
0x0045fd8c 83417 _objc_autoreleaseReturnValue
0x0045ff0c 83441 _objc_release
[SNIP]
```

##### With idb:

IDB<sup>[2]</sup> automates the process of checking for both stack canary and PIE support. Select the target binary in the IDB GUI and click the "Analyze Binary…" button.

![alt tag](Images/Chapters/0x06i/idb.png)

#### Remediation

- Stack smashing protection

Steps for enabling Stack smashing protection within an iOS application:

1. In Xcode, select your target in the "Targets" section, then click the "Build Settings" tab to view its settings.
1. Verify that "–fstack-protector-all" option is selected under "Other C Flags" section.

- PIE support

Steps for building an iOS application as PIE :

1. In Xcode, select your target in the "Targets" section, then click the "Build Settings" tab to view its settings.
1. For iOS apps, set iOS Deployment Target to iOS 4.3 or later.
1. Verify that "Generate Position-Dependent Code" is set at its default value of NO.
1. Verify that Don't "Create Position Independent Executables" is set at its default value of NO.

- ARC protection

Steps for enabling ACR protection within an iOS application :

1. In Xcode, select your target in the "Targets" section, then click the "Build Settings" tab to view its settings.
1. Verify that "Objective-C Automatic Reference Counting" is set at its default value of YES.

#### References

##### OWASP Mobile Top 10 2016
- M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V7.8: "Free security features offered by the toolchain, such as byte-code minification, stack protection, PIE support and automatic reference counting, are activated."

##### CWE

-- TODO [Add relevant CWE for "Testing Compiler Settings"] --

##### Info

- [1] Technical Q&A QA1788 Building a Position Independent Executable - https://developer.apple.com/library/mac/qa/qa1788/_index.html
- [2] idb - https://github.com/dmayer/idb

##### Tools
-- TODO [Add tools for "Testing Compiler Settings"] --
