## Testing Data Storage on iOS

For all test cases it need to be known what sensitive information is, in context of the app. Please have a look at "Classification of data" for further details.

### Testing Local Data Storage

#### Overview

Storing data is essential for many mobile applications, for example in order to keep track of user settings or data a user might has keyed in that needs to stored locally or offline. Data can be stored persistently by a mobile application in various ways. The following table shows mechanisms that are available on the iOS platform, that should usually not be considered to store sensitive data.

* CoreData/SQLite Databases
* NSUserDefaults
* Property List (Plist) files
* Plain files

#### Static Analysis

Ideally sensitive information should not be stored on the device at all. If there is a requirement to store sensitive information on the device itself, several functions/API calls are available to protect the data on IOS devices by using for example the Keychain.

During the static analysis it should be checked if sensitive data is stored permanently on the device. The following frameworks and functions should be checked when handling sensitive data.

##### CoreData/SQLite Databases

* `Core Data` is a framework that you use to manage the model layer objects in your application. It provides generalized and automated solutions to common tasks associated with object life cycle and object graph management, including persistence. Core Data operates on a sqlite database at lower level.

* `sqlite3`: The `libsqlite3.dylib` library in framework section is required to be added in an application, which is a C++ wrapper that provides the API to the SQLite commands.


##### NSUserDefaults

The `NSUserDefaults` class provides a programmatic interface for interacting with the default system. The default system allows an application to customize its behavior to match a user’s preferences. Data saved by NSUserDefaults can be viewed from the application bundle. It also stores data in a plist file, but it's meant for smaller amounts of data.

##### Plain files / Plist files

* `NSData`: Creates static data objects, and NSMutableData creates dynamic data objects. NSData and NSMutableData are typically used for data storage and are also useful in Distributed Objects applications, where data contained in data objects can be copied or moved between applications.
  * Options for methods used to write NSData objects: `NSDataWritingWithoutOverwriting, NSDataWritingFileProtectionNone, NSDataWritingFileProtectionComplete, NSDataWritingFileProtectionCompleteUnlessOpen, NSDataWritingFileProtectionCompleteUntilFirstUserAuthentication`
  * Store Data as part of the NSData class with: `writeToFile`
* Managing File Paths: `NSSearchPathForDirectoriesInDomains, NSTemporaryDirectory`
* The `NSFileManager` object lets you examine the contents of the file system and make changes to it. A way to create a file and write to it can be done through `createFileAtPath`.


#### Dynamic Analysis

A way to identify if sensitive information like credentials and keys are stored insecurely and without leveraging the native functions from iOS is to analyse the app data directory. It is important to trigger as much app functionality as possible before the data is analysed, as the app might only store system credentials as specific functionality is triggered by the user. A static analysis can then be performed for the data dump based on generic keywords and app specific data.

The following steps can be used to identify how the application stores data locally on the iOS device.

1. Proceed to trigger functionality that stores potential sensitive data.
2. Connect to the iOS device and browse to the following directory (this is applicable to iOS version 8.0 and higher): `/var/mobile/Containers/Data/Application/$APP_ID/`
3. Perform a grep command of the data that you have stored, such as: `grep -irn "USERID"`.
4. If the sensitive data is being stored in plaintext, it fails this test.

Manual dynamic analysis such as debugging can also be leveraged to verify how specific system credentials are stored and processed on the device. As this approach is more time consuming and is likely conducted manually, it might be only feasible for specific use cases.

-- TODO [Add content on Dynamic Testing of "Testing Local Data Storage "] --

#### Remediation

If sensitive information (credentials, keys, PII, etc.) is needed locally on the device, several best practices are offered by iOS that should be used to store data securely instead of reinventing the wheel or leave it unencrypted on the device.

The following is a list of best practices used for secure storage of certificates and keys and sensitive data in general:
* For small amounts of sensitive data such as credentials or keys use the Keychain Services<sup>[1]</sup> to securely store it locally on the device. Keychain data is protected using a class structure similar to the one used in file Data Protection. These classes have behaviors equivalent to file Data Protection classes, but use distinct keys and are part of APIs that are named differently. The the default behaviour is `kSecAttrAccessibleWhenUnlocked`. For more information have a look at the available modes Keychain Item Accessibility<sup>[8]</sup>.
* Cryptographic functions that have been self implemented to encrypt or decrypt local files should be avoided.  


#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.1: "System credential storage facilities are used appropriately to store sensitive data, such as user credentials or cryptographic keys."

##### CWE
* CWE-311 - Missing Encryption of Sensitive Data
* CWE-312 - Cleartext Storage of Sensitive Information
* CWE-522 - Insufficiently Protected Credentials
* CWE-922 - Insecure Storage of Sensitive Information

##### Info

[1] KeyChain Services - https://developer.apple.com/reference/security/1658642-keychain_services?language=objc
[2] Keychain Services Programming Guide - https://developer.apple.com/library/content/documentation/Security/Conceptual/keychainServConcepts/iPhoneTasks/iPhoneTasks.html
[3] iOS Security Guide - https://www.apple.com/business/docs/iOS_Security_Guide.pdf
[4] File System Basics - https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html
[5] Foundation Functions - https://developer.apple.com/reference/foundation/1613024-foundation_functions
[6] NSFileManager - https://developer.apple.com/reference/foundation/nsfilemanager
[7] NSUserDefaults - https://developer.apple.com/reference/foundation/userdefaults
[8] Keychain Item Accessibility -  https://developer.apple.com/reference/security/1658642-keychain_services/1663541-keychain_item_accessibility_cons


### Testing for Sensitive Data in Logs

#### Overview

There are many legit reasons to create log files on a mobile device, for example to keep track of crashes or errors that are stored locally when being offline and being sent to the application developer/company once online again or for usage statistics. However, logging sensitive data such as credit card number and session IDs might expose the data to attackers or malicious applications.
Log files can be created in various ways. The following list shows the mechanisms that are available on iOS:

* NSLog Method
* printf-like function
* NSAssert-like function
* Macro

#### Static Analysis

Check the source code for usage of predefined/custom Logging statements using the following keywords :
* For predefined and built-in functions:
  * NSLog
  * NSAssert
  * NSCAssert
  * fprintf
* For custom functions:
  * Logging
  * Logfile


#### Dynamic Analysis

Proceed to a page on the iOS application that contains input fields which prompt users for their sensitive information. Two different methods are applicable to check for sensitive data in log files:

* Connect to the iOS device and execute the following command:
```
tail -f /var/log/syslog
```

* Connect your iOS device via USB and launch Xcode. Navigate to Windows > Devices, select your device and the respective application.

Proceed to complete the input fields prompt and if the sensitive data are displayed in the output of the above command, it fails this test.


#### Remediation

Use a define to enable NSLog statements for development and debugging, and disable these before shipping the software. This can be done by putting the following code into the appropriate PREFIX_HEADER (\*.pch) file:

```C#
#ifdef DEBUG
#   define NSLog (...) NSLog(__VA_ARGS__)
#else
#   define NSLog (...)
#endif
```

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.2: "No sensitive data is written to application logs."

##### CWE
* CWE-117: Improper Output Neutralization for Logs
* CWE-532: Information Exposure Through Log Files
* CWE-534: Information Exposure Through Debug Log Files



### Testing Whether Sensitive Data Is Sent to Third Parties

#### Overview

Different 3rd party services are available that can be embedded into the app to implement different features. These features can vary from tracker services to monitor the user behaviour within the app, selling banner advertisements or to create a better user experience. Interacting with these services abstracts the complexity and neediness to implement the functionality on its own and to reinvent the wheel.

The downside is that a developer doesn’t know in detail what code is executed via 3rd party libraries and therefore giving up visibility. Consequently it should be ensured that not more information as needed is sent to the service and that no sensitive information is disclosed.

3rd party services are mostly implemented in two ways:
* By using a standalone library.
* By using a full SDK.

#### Static Analysis

API calls and/or functions provided through the 3rd party library should be reviewed on a source code level to identify if they are used accordingly to best practices.

#### Dynamic Analysis

All requests made to external services should be analyzed if any sensitive information is embedded into them. Dynamic analysis can be performed by launching a Man-in-the-middle (MITM) attack using _Burp Proxy_ or _OWASP ZAP_, to intercept the traffic exchanged between client and server. . Once we are able to route the traffic to the interception proxy, we can try to sniff the traffic from the app. When using the app all requests that are not going directly to the server where the main function is hosted should be checked, if any sensitive information is sent to a 3rd party. This could be for example PII (Personal Identifiable Information) in a tracker or ad service.

#### Remediation

All data that is sent to 3rd Party services should be anonymized, so no PII data is available. Also all other data, like IDs in an application that can be mapped to a user account or session should not be sent to a third party.  

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.3: "No sensitive data is shared with third parties unless it is a necessary part of the architecture."

##### CWE
- CWE-359 "Exposure of Private Information ('Privacy Violation')": [Link to CWE issue]

##### Tools
* OWASP ZAP
* Burp Suite Professional


### Testing for Sensitive Data in the Keyboard Cache

#### Overview

In order to simplify keyboard input by providing autocorrection, predicative input, spell checking, etc., most of keyboard input by default is cached in /private/var/mobile/Library/Keyboard/dynamic-text.dat

This behavior is achieved by means of UITextInputTraits<sup>[1]</sup> protocol, which is adopted by UITextField, UITextView and UISearchBar. Keyboard caching is influenced by following properties:

* `var autocorrectionType: UITextAutocorrectionType` determines whether autocorrection is enabled or disabled during typing. With autocorrection enabled, the text object tracks unknown words and suggests a more suitable replacement candidate to the user, replacing the typed text automatically unless the user explicitly overrides the action. The default value for this property is `UIText​Autocorrection​Type​Default`, which for most input methods results in autocorrection being enabled.
* `var secureTextEntry: BOOL` identifies whether text copying and text caching should be disabled and in case of UITextField hides the text being entered. This property is set to `NO` by default.

####  Static Analysis


* Search through the source code provided to look the following similar implementations.

  ```
  textObject.autocorrectionType = UITextAutocorrectionTypeNo;
  textObject.secureTextEntry = YES;
  ```

* Open xib and storyboard files in Interface Builder and verify states of Secure Text Entry and Correction in Attributes Inspector for appropriate objects.


#### Dynamic Analysis

1. Reset your iOS device keyboard cache by going through: Settings > General > Reset > Reset Keyboard Dictionary

2. Proceed to use the application's functionalities. Identify the functions which allow users to enter sensitive data.

3. Dump the keyboard cache file dynamic-text.dat at the following directory (Might be different in iOS below 8.0):
/private/var/mobile/Library/Keyboard/

4. Look for sensitive data such as username, passwords, email addresses, credit card numbers, etc. If the sensitive data can be obtained through the keyboard cache file, it fails this test.

#### Remediation

The application must ensure that data typed into text fields which contains sensitive information are not cached. This can be achieved by disabling the feature programmatically by using the `textObject.autocorrectionType = UITextAutocorrectionTypeNo` directive in the desired UITextFields, UITextViews and UISearchBars. For data that should be masked such as PIN and passwords, set the `textObject.secureTextEntry` to `YES`.

```#ObjC
UITextField *textField = [ [ UITextField alloc ] initWithFrame: frame ];
textField.autocorrectionType = UITextAutocorrectionTypeNo;
```

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.4: "The keyboard cache is disabled on text inputs that process sensitive data."

##### CWE
- CWE-524: Information Exposure Through Caching

#### Info
[1] UIText​Input​Traits protocol - https://developer.apple.com/reference/uikit/uitextinputtraits



### Testing for Sensitive Data in the Clipboard

#### Overview

When keying in data into input fields, the clipboard can be used to copy data in. The clipboard is accessible systemwide and therefore shared between the apps. This feature can be misused by malicious apps in order to get sensitive data.

#### Static Analysis

Search through the source code provided to look for any implemented subclass of `UITextField`.

```
@interface name_of_sub_class : UITextField
action == @select(cut:)
action == @select(copy:)
```

#### Dynamic Analysis

Proceed to a view in the app that has input fields which prompt the user for sensitive information such as username, password, credit card number, etc. Enter some values and double tap on the input field. If the "Select", "Select All", and "Paste" option shows up, proceed to tap on the "Select", or "Select All" option, it should allow you to "Cut", "Copy", "Paste", or "Define". The "Cut" and "Copy" option should be disabled for sensitive input fields, since it will be possible to retrieve the value by pasting it. If the sensitive input fields allow you to "Cut" or "Copy" the values, it fails this test.


#### Remediation

Possible remediation method<sup>[1]</sup>:

```#ObjC
@interface NoSelectTextField : UITextField

@end

@implementation NoSelectTextField

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (action == @selector(paste:) ||
        action == @selector(cut:) ||
        action == @selector(copy:) ||
        action == @selector(select:) ||
        action == @selector(selectAll:) ||
        action == @selector(delete:) ||
        action == @selector(makeTextWritingDirectionLeftToRight:) ||
        action == @selector(makeTextWritingDirectionRightToLeft:) ||
        action == @selector(toggleBoldface:) ||
        action == @selector(toggleItalics:) ||
        action == @selector(toggleUnderline:)
        ) {
            return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

@end
```


#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.5: "The clipboard is deactivated on text fields that may contain sensitive data."

##### CWE
- CWE

#### Info
[1] Disable clipboard on iOS - http://stackoverflow.com/questions/1426731/how-disable-copy-cut-select-select-all-in-uitextview



### Testing Whether Sensitive Data Is Exposed via IPC Mechanisms

#### Overview

-- TODO [Add content on overview of "Testing Whether Sensitive Data Is Exposed via IPC Mechanisms"] --

#### Static Testing

-- TODO [Add content on white-box testing of "Testing Whether Sensitive Data Is Exposed via IPC Mechanisms"] --

#### Dynamic Testing

-- TODO [Add content on black-box testing of "Testing Whether Sensitive Data Is Exposed via IPC Mechanisms"] --

#### Remediation

-- TODO [Add remediation on "Testing Whether Sensitive Data Is Exposed via IPC Mechanisms"] --

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.6: "No sensitive data is exposed via IPC mechanisms."

##### CWE
- CWE

#### Info
-- TODO --




### Testing for Sensitive Data Disclosure Through the User Interface

##### Overview

-- TODO [Add content on overview for "Testing for Sensitive Data Disclosure Through the User Interface"] --

#### Static Analysis

-- TODO [Add content on white-box testing of "Testing for Sensitive Data Disclosure Through the User Interface"] --

#### Dynamic Analysis

-- TODO [Add content on black-box testing of "Testing for Sensitive Data Disclosure Through the User Interface"] --


#### Remediation

-- TODO [Add remediation of "Testing for Sensitive Data Disclosure Through the User Interface"] --

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.7: "No sensitive data, such as passwords or pins, is exposed through the user interface."

##### CWE
- CWE

#### Info
-- TODO --



### Testing for Sensitive Data in Backups

#### Overview

-- TODO [Add content on overview of "Testing for Sensitive Data in Backups"] --

#### Static Analysis

-- TODO [Add content on white-box testing of "Testing for Sensitive Data in Backups"] --

#### Dynamic Analysis

-- TODO [Add content on black-box testing of "Testing for Sensitive Data in Backups"] --

#### Remediation

-- TODO [Add content on remediation of "Testing for Sensitive Data in Backups"] --

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.8: "No sensitive data is included in backups generated by the mobile operating system."

##### CWE
- CWE

#### Info
-- TODO [Add references for "Testing for Sensitive Data in Backups"] --



### Testing For Sensitive Information in Auto-Generated Screenshots

#### Overview

Manufacturers want to provide device users an aesthetically pleasing effect when an application is entered or exited, hence they introduced the concept of saving a screenshot when the application goes into the background. This feature could potentially pose a security risk for an application, as the screenshot containing sensitive information (e.g. a screenshot of an email or corporate documents) is written to local storage, where it can be recovered either by a rogue application on a jailbroken device, or by someone who steals the device.

#### Static Analysis

While analyzing the source code, look for the fields or screens where sensitive data is involved. Identify if the application sanitize the screen before being backgrounded.

#### Dynamic Analysis

Proceed to a page on the application which displays sensitive information such as username, email address, account details, etc. Background the application by hitting the Home button on your iOS device. Connect to the iOS device and proceed to the following directory (might be different in iOS below 8.0):

`/var/mobile/Containers/Data/Application/$APP_ID/Library/Caches/Snapshots/`

If the application caches the sensitive information page as a screenshot, it fails this test.

It is highly recommended to have a default screenshot that will be cached whenever the application enters background.


#### Remediation

Possible remediation method that will set a default screenshot:

```
@property (UIImageView *)backgroundImage;
 
- (void)applicationDidEnterBackground:(UIApplication *)application {
    UIImageView *myBanner = [[UIImageView alloc] initWithImage:@"overlayImage.png"];
    self.backgroundImage = myBanner;
    [self.window addSubview:myBanner];
}
```

This will cause the background image to be set to the "overlayImage.png" instead whenever the application is being backgrounded. It will prevent sensitive data leaks as the "overlayImage.png" will always override the current view.

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.9: "The app removes sensitive data from views when backgrounded."

##### CWE
- CWE

#### Info
-- TODO [Add references for "Testing For Sensitive Information in Auto-Generated Screenshots" ] --



### Testing for Sensitive Data in Memory

-- TODO [Add content for "Testing for Sensitive Data in Memory"] --

#### Overview

-- TODO

#### Static Analysis

-- TODO

#### Dynamic Analysis

-- TODO

#### Remediation

-- TODO

#### References

##### OWASP MASVS
- V2.10: "The app does not hold sensitive data in memory longer than necessary, and memory is cleared explicitly after use."

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage

##### CWE
- CWE: -- TODO [Add link to CWE issue] --

#### Info
-- TODO



### Testing the Device-Access-Security Policy

#### Overview

-- TODO [Add content for overview of "Testing the Device-Access-Security Policy"] --

#### Static Analysis

-- TODO [Add content for static analysis of "Testing the Device-Access-Security Policy"] --

#### Dynamic Analysis

-- TODO [Add content for dynamic analysis of "Testing the Device-Access-Security Policy"] --

#### Remediation

-- TODO [Add remediation of "Testing the Device-Access-Security Policy"] --

#### References

##### OWASP MASVS
- V2.11: "The app enforces a minimum device-access-security policy, such as requiring the user to set a device passcode."

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage

##### CWE
- CWE: -- TODO [Add link to CWE issue] --

#### Info
-- TODO


### Verifying User Education Controls

#### Overview

Educating users is a crucial part in the usage of mobile apps. Even though many security controls are already in place, they might be circumvented or misused through the users.

The following list shows potential warnings or advises for a user when opening the app the first time and using it:
* app shows after starting it the first time a list of data it is storing locally and remotely. This can also be a link to an external resource as the information might be quite extensive.
* If a new user account is created within the app it should show the user if the password provided is considered as secure and applies to best practice password policies.
* If the user is installing the app on a rooted device a warning should be shown that this is dangerous and deactivates security controls on OS level and is more likely to be prone to Malware. See also OMTG-DATAST-011 for more details.
* If a user installed the app on an outdated Android version a warning should be shown. See also OMTG-DATAST-010 for more details.

-- TODO [What else can be a warning on iOS?] --

#### Static Analysis

-- TODO [Add content for static analysis of "Verifying User Education Controls"] --

#### Dynamic Analysis

After installing the app and also while using it, it should be checked if any warnings are shown to the user, that have an education purpose.

-- TODO [Further develop content of dynamic analysis of "Verifying User Education Controls"] --

#### Remediation

Warnings should be implemented that address the key points listed in the overview section.

-- TODO [Further develop remediation of "Verifying User Education Controls"] --

#### References

-- TODO [Add references for "Verifying User Education Controls"] --

##### OWASP MASVS

- V2.12: "The app educates the user about the types of personally identifiable information processed, as well as security best practices the user should follow in using the app."

##### OWASP Mobile Top 10 2016

* M1 - Improper Platform Usage

##### CWE
- CWE: -- TODO [Add link to CWE issue for "Verifying User Education Controls"] --

#### Info
-- TODO
