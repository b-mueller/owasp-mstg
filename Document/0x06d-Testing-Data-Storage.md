## Testing Data Storage on iOS

The protection of sensitive data, such as user credentials and private information, is a key focus in mobile security. In this chapter, you will learn about the APIs iOS offers for local data storage, as well as best practices for using those APIs.

Note that "sensitive data" needs to be identified in the context of each specific app. Data classification is described in detail in the chapter "Mobile AppSec Best Practices and Pitfalls".

### Testing Local Data Storage

#### Overview

As already mentioned many times in this guide, as little sensitive data as possible should be saved on permanent local storage. However, in most practical scenarios, at least some type of user-related data needs to be stored. Fortunately, iOS offers secure storage APIs which allow developers to make use of the crypto hardware available in every iOS device. Provided that these APIs are used correctly, key data and files can be secured using hardware-backed 256 bit AES encryption.

##### Data Protection API

App developers can leverage the iOS *Data Protection* APIs to implement fine-grained access controls for user data stored in flash memory. The API is built on top of the Secure Enclave, a coprocessor that provides cryptographic operations for Data Protection key management. A device-specific hardware key - the device UID - is embedded into the secure enclave, ensuring the integrity of Data Protection even if the operating system kernel is compromised.

The data protection architecture is based on a hierarchy of keys. The UID and the user passcode key, which is derived from the user's passphrase using the PBKDF2 algorithm, sit at the top of this hierarchy. Together, they can be used to "unlock" so-called class keys which are associated with different device states (e.g. device is locked / unlocked).

Every file stored in the iOS file system is encrypted with its own individual per-file key, which is contained in the file metadata. The metadata is encrypted with the file system key and wrapped with one of the class keys, depending on the protection class selected by the app when creating the file.

<img src="Images/Chapters/0x06d/key_hierarchy_apple.jpg" width="500px"/>
*iOS Data Protection Key Hierarchy <sup>[3]</sup>*

Files can be assigned one of four protection classes:

- Complete Protection (NSFileProtectionComplete): This class key is protected with a key derived from the user passcode and the device UID. It is wiped from memory shortly after the device is locked, making the data inaccessible until the user unlocks the device.

- Protected Unless Open (NSFileProtectionCompleteUnlessOpen): Behaves similar to Complete Protection, but if the file is opened when unlocked, the app can continue to access the file even if the user locks the device. This is implemented using asymmetric elliptic curve cryptography <sup>[3]</sip>.

- Protected Until First User Authentication (NSFileProtectionCompleteUntilFirstUserAuthentication): The file can be accessed from the moment the user unlocks the device for the first time after booting. It can be accessed even if the user subsequently locks the device.

- No Protection (NSFileProtectionNone): This class key is protected only with the UID and is kept in Effaceable Storage. This protection class exists to enable fast remote wipe: Deleting the class key immediately makes the data inaccessible.

All class keys except <code>NSFileProtectionNone</code> are encrypted with a key derived from the device UID and the user's passcode. As a result, decryption can only happen on the device itself, and requires the correct passcode to be entered.

Since iOS 7, the default data protection class is "Protected Until First User Authentication".

##### The Keychain

The iOS Keychain is used to securely store short, sensitive bits of data, such as encryption keys and session tokens. It is implemented as a SQLite database that can be accessed only through Keychain APIs. The Keychain database is encrypted using the device Key and the user PIN/password (if one has been set by the user).

By default, each app can only access the Keychain created by itself. Access can however be shared between apps signed by the same developer by using the "access groups" feature. Access to the Keychain is managed by the <code>securityd</code> daemon, which grants access based on the app's <code>Keychain-access-groups</code>, <code>application-identifier</code> and <code>application-group</code> entitlements.

The KeyChain API consists of the following main operations with self-explanatory names:

- SecItemAdd
- SecItemUpdate
- SecItemCopyMatching
- SecItemDelete

Keychain data is protected using a class structure similar to the one used for file encryption. Items added to the Keychain are encoded as a binary plist and encrypted using a 128 bit AES per-item key. Note that larger blobs of data are not meant to be saved directly in the keychain - that's what the Data Protection API is for. Data protection is activated by setting the <code>kSecAttrAccessible</code> attribute in the <code>SecItemAdd</code> or <code>SecItemUpdate</code> call. The following settings are available:

- kSecAttrAccessibleAfterFirstUnlock: The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
- kSecAttrAccessibleAlways: The data in the keychain item can always be accessed regardless of whether the device is locked.
- kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly: The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device. The data will not be included in an iCloud or iTunes backup.
- kSecAttrAccessibleAlwaysThisDeviceOnly: The data in the keychain item can always be accessed regardless of whether the device is locked. The data will not be included in an iCloud or iTunes backup.
- kSecAttrAccessibleWhenUnlocked: The data in the keychain item can be accessed only while the device is unlocked by the user.
- kSecAttrAccessibleWhenUnlockedThisDeviceOnly: The data in the keychain item can be accessed only while the device is unlocked by the user. The data will not be included in an iCloud or iTunes backup.

#### Static Analysis

When having access to the source code of the iOS app, try to spot sensitive data that is saved and processed throughout the app. This includes in general passwords, secret keys, and personally identifiable information (PII), but might as well also include other data identified as sensitive through industry regulations, laws or internal policies. Look for instances where this data is saved using any of the local storage APIs listed below. Make sure that sensitive data is never stored without appropriate protection. For example, authentication tokens should not be saved in NSUserDefaults without additional encryption. In any case, the encryption must be implemented such that the secret key is stored in the Keychain using secure settings, ideally <code>kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly</code>.

When looking for instances of insecure data storage in an iOS app you should consider the following possible means of storing data.

##### CoreData/SQLite Databases

* `Core Data`<sup>[10]</sup>: Is a framework that you use to manage the model layer of objects in your application. It provides generalized and automated solutions to common tasks associated with object life cycle and object graph management, including persistence. Core Data operates on a sqlite database at lower level.

* `sqlite3`: The `libsqlite3.dylib` library is required to be added in an application. This library is a C++ wrapper that provides the API to the SQLite commands.

##### NSUserDefaults

The `NSUserDefaults`<sup>[11]</sup> class provides a programmatic interface for interacting with the default system. The default system allows an application to customize its behavior to match a user’s preferences. Data saved by NSUserDefaults can be viewed from the application bundle. It also stores data in a plist file, but it's meant for smaller amounts of data.

##### File system

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

Important filesystem locations are:

* AppName.app
  * The app’s bundle, contains the app and all of its resources
  * Visible to users but users cannot write to this directory
  * Content in this directory is not backed up
* Documents/
  * Use this directory to store user-generated content
  * Visible to users and users can write to this directory
  * Content in this directory is being backed up
  * App can disable paths by setting `NSURLIsExcludedFromBackupKey`
* Library/
  * This is the top-level directory for any files that are not user data files
  * iOS apps commonly use the `Application Support` and `Caches` subdirectories, but you can create custom subdirectories
* Library/Caches/
  * Semi-persistent cached files
  * Not visible to users and users cannot write to this directory
  * Content in this directory is not backed up
  * OS may delete the files automatically when app is not running (e.g. storage space running low)
* Library/Application Support/
  * Persistent files necessary to run the app
  * Not visible to users and users cannot write to this directory
  * Content in this directory is being backed up
  * App can disable paths by setting `NSURLIsExcludedFromBackupKey`
* tmp/
  * Use this directory to write temporary files that do not need to persist between launches of your app
  * Non-persistent cached files
  * Not visible to the user
  * Content in this directory is not backed up
  * OS may delete the files automatically when app is not running (e.g. storage space running low).

For a more detailed analysis, use an API monitoring tool such as IntroSpy to instrument the app.

If necessary during dynamic analysis, the contents of the Keychain can be dumped using keychain dumper <sup>[9]</sup> as described in the chapter "Basic Security Testing on iOS". The keychain file is located at:

```
/private/var/Keychains/keychain-2.db
```

#### Remediation

Hardware-backed storage mechanisms must be used for storing sensitive data. Permitted options for storing sensitive data are:

- Storing the data in the keychain with the `kSecAttrAccessibleWhenUnlocked` attribute.
- Encrypting the data using standard crypto APIs before storing it, and storing the encryption key in the keychain.
- Creating a file with the `NSFileProtectionComplete` attribute.

The following example shows how to create a securely encrypted file using the `createFileAtPath` method:

```objective-c
[[NSFileManager defaultManager] createFileAtPath:[self filePath]
  contents:[@"secret text" dataUsingEncoding:NSUTF8StringEncoding]
  attributes:[NSDictionary dictionaryWithObject:NSFileProtectionComplete
  forKey:NSFileProtectionKey]];
```

A generic example for using the KeyChain to store, update or delete data can be found in the official Apple documentation<sup>[12]</sup>.

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
[9] Keychain Dumper - https://github.com/ptoomey3/Keychain-Dumper/
[10] Core Data iOS - https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreData/nsfetchedresultscontroller.html#//apple_ref/doc/uid/TP40001075-CH8-SW1
[11] NSUserDefaults - https://developer.apple.com/documentation/foundation/nsuserdefaults
[12] GenericKeyChain - https://developer.apple.com/library/content/samplecode/GenericKeychain/Introduction/Intro.html#//apple_ref/doc/uid/DTS40007797-Intro-DontLinkElementID_2


### Testing for Sensitive Data in Logs

#### Overview

There are many legit reasons to create log files on a mobile device, for example to keep track of crashes or errors that are stored locally when being offline and being sent to the application developer/company once online again or for usage statistics. However, logging sensitive data such as credit card number and session IDs might expose the data to attackers or malicious applications.
Log files can be created in various ways. The following list shows the mechanisms that are available on iOS:

* NSLog Method
* printf-like function
* NSAssert-like function
* Macro

#### Static Analysis

Check the app source code for usage of predefined and/or custom logging statements by using the following keywords:
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
* V2.2: "No sensitive data is written to application logs."

##### CWE
* CWE-117: Improper Output Neutralization for Logs
* CWE-532: Information Exposure Through Log Files
* CWE-534: Information Exposure Through Debug Log Files

##### Tools
* Xcode


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

All requests made to external services should be analyzed if any sensitive information is embedded into them. By using an interception proxy, we can try to investigate the traffic from the app to the 3rd party endpoints. When using the app all requests that are not going directly to the server where the main function is hosted should be checked, if any sensitive information is sent to a 3rd party. This could be for example PII (Personal Identifiable Information) in a tracker or ad service.

#### Remediation

All data that is sent to 3rd Party services should be anonymized, so no PII data is available that would allow the 3rd party to identify the user account. Also all other data, like IDs in an application that can be mapped to a user account or session should not be sent to a third party.  

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
* V2.3: "No sensitive data is shared with third parties unless it is a necessary part of the architecture."

##### CWE
* CWE-359 "Exposure of Private Information ('Privacy Violation')": [Link to CWE issue]

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

* Search through the source code provided to look for similar implementations, like the following:

  ```#ObjC
  textObject.autocorrectionType = UITextAutocorrectionTypeNo;
  textObject.secureTextEntry = YES;
  ```

* Open xib and storyboard files in the `Interface Builder` of Xcode and verify states of `Secure Text Entry` and `Correction` in `Attributes Inspector` for appropriate objects.

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

```#ObjC
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

To clear the pasteboard<sup>[2]</sup>:

```
UIPasteboard *pb = [UIPasteboard generalPasteboard];
[pb setValue:@"" forPasteboardType:UIPasteboardNameGeneral];
```

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.5: "The clipboard is deactivated on text fields that may contain sensitive data."

##### CWE
- CWE-200: Information Exposure

#### Info
[1] Disable clipboard on iOS - http://stackoverflow.com/questions/1426731/how-disable-copy-cut-select-select-all-in-uitextview
[2] UIPasteboardNameGeneral - https://developer.apple.com/reference/uikit/uipasteboardnamegeneral?language=objc


### Testing Whether Sensitive Data Is Exposed via IPC Mechanisms

#### Overview

Inter Process Communication (IPC) is a method that allows processes to send each other messages and data<sup>[1]</sup>. In case two processes need to communicate with each other, different methods are available to implement IPC on iOS:

* **XPC Services**<sup>[3]</sup>: XPC is a structured, asynchronous interprocess communication library which provides basic interprocess communication and is managed by `launchd`. It runs with the most restricted environment possible: sandboxed with minimal file system access, network access, and no root privilege escalation. There are two different APIs, when working with XPC Services:
  * NSXPCConnection API and
  * XPC Services API
* **Mach Ports**<sup>[5]</sup>: All IPC communication ultimately relies on the Mach Kernel API. Mach Ports allow for local communication (on the same device) only. They can either be implemented natively or by using Core Foundation (CFMachPort) and Foundation (NSMachPort) wrappers.
* **NSFileCoordinator**: The class NSFileCoordinator can be used to manage and exchange data between apps through files that are accessible on the local file system for different processes.


#### Static Testing

The following section summarizes different keywords that you should look for in order to identify IPC implementations within iOS source code.

##### XPC Services

Several classes might be used when implementing the NSXPCConnection API:

* NSXPCConnection
* NSXPCInterface
* NSXPCListener
* NSXPCListenerEndpoint

Several security attributes for the connection can be set and should be verified<sup>[7]</sup>.

For the XPC Services API, which are C-based, the availability of the following two files in the Xcode project should be checked:

* xpc.h<sup>[4]</sup>
* connection.h

##### Mach Ports

Keywords to look for in low-level implementations:
* mach_port_t
* mach_msg_*

Keywords to look for in high-level implementations (Core Foundation and Foundation wrappers):
* CFMachPort
* CFMessagePort
* NSMachPort
* NSMessagePort


##### NSFileCoordinator

Keywords to look for:
* NSFileCoordinator

#### Dynamic Testing

IPC mechanisms should be verified via static analysis in the iOS source code. At this point of time no tool is availalbe on iOS to verify IPC usage.

#### Remediation

XPC services is the most secure and flexible way when implementing IPC on iOS and should be used primarily. 

NSFileCoordinator<sup>[6]</sup> methods run synchronously, so your code will block until they complete. That's convenient since you don't have to wait for an asynchronous block callback. But it also means that they block the current thread.

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.6: "No sensitive data is exposed via IPC mechanisms."

##### CWE
- CWE-634 - Weaknesses that Affect System Processes

#### Info
[1] iPhoneDevWiki IPC - http://iphonedevwiki.net/index.php/IPC
[2] Inter-Process Communication - http://nshipster.com/inter-process-communication/
[3] XPC Services - https://developer.apple.com/library/content/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html
[4] xpc.h - https://developer.apple.com/documentation/xpc/xpc_services_xpc.h
[5] NSMachPort - https://developer.apple.com/documentation/foundation/nsmachport
[6] NSFileCoordinator - http://www.atomicbird.com/blog/sharing-with-app-extensions
[7] Security Attributes of NSXPCConnection -  https://www.objc.io/issues/14-mac/xpc/#security-attributes-of-the-connection


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

Like other modern mobile operating systems iOS offers auto-backup features that create copies of the data on the device. On iOS, backups can be made either through iTunes, or the the cloud using the iCloud backup feature. In both cases, the backup includes nearly all data stored on the device, except some highly sensitive things like Apple Pay information and TouchID settings.

Since iOS backs up installed apps and their data, an obvious concern is whether sensitive user data stored by the app might unintentionally leak through the backup. The answer to this question is "yes" - but only if the app insecurely stores sensitive data in the first place.

##### How the Keychain is Backed Up

When a user backs up their iPhone, the keychain data is backed up as well, but the secrets in the keychain remain encrypted. The class keys needed to decrypt they keychain data are not included in the backup. To restore the keychain data, the backup must be restored to a device, and the device must be unlocked with the same passcode.

Keychain items with the <code>kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly</code> attribute set can be decrypted only if the backup is restored to the same device. An evildoer trying to extract this Keychain data from the backup would be unable to decrypt it without access to the crypto hardware inside the originating device.

The takeaway: As long as sensitive data is handled as recommended earlier in this chapter (stored in the Keychain, or encrypted with a key locked inside the Keychain), then backups aren't an issue.

##### Excluding Items from Backup

the <code>NSURLIsExcludedFromBackupKey</code> <sup>[1]</sup> and <code>CFURLIsExcludedFromBackupKey</code> <sup>[2]</sup> file system properties can be used to exclude files and directories from backups. Apps that need to exclude a large number of files can exclude them by creating their own sub-directory and marking that directory as excluded. Apps should create their own directories for exclusion, rather than excluding the system defined directories.

Either of these APIs is preferred over the older, deprecated approach of directly setting an extended attribute. All apps running on iOS 5.1 and later should use these APIs to exclude data from backups.

The following is a sample code for excluding a file from backup on iOS 5.1 and later (Objective-C)<sup>[3]</sup>:

```#ObjC
- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString
{
    NSURL* URL= [NSURL fileURLWithPath: filePathString];
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);

    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}
```

The following is a sample code for excluding a file from backup on iOS 5.1 and later (Swift)<sup>[3]</sup>:

```
 func addSkipBackupAttributeToItemAtURL(filePath:String) -> Bool
    {
        let URL:NSURL = NSURL.fileURLWithPath(filePath)

        assert(NSFileManager.defaultManager().fileExistsAtPath(filePath), "File \(filePath) does not exist")

        var success: Bool
        do {
            try URL.setResourceValue(true, forKey:NSURLIsExcludedFromBackupKey)
            success = true
        } catch let error as NSError {
            success = false
            print("Error excluding \(URL.lastPathComponent) from backup \(error)");
        }

        return success
    }
```

If your app must support iOS 5.0.1, you can use the following method to set the "do not back up" extended attribute. Whenever you create a file or folder that should not be backed up, write the data to the file and then call the following method, passing in a URL to the file<sup>[3]</sup>:

```
#import <sys/xattr.h>
- (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *) filePathString
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: filePathString]);

    const char* filePath = [filePathString fileSystemRepresentation];

    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;

    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}
```


#### Static Analysis

Review the iOS mobile application source code to see if there is any usage of
#### Dynamic Analysis

After the App data has been backed up, review the data content of the backup files and folders. Specifically, the following directories should be reviewed to check if it contains any sensitive data:

* Documents/
* Library/Caches/
* Library/Application Support/
* tmp/

Refer to the Overview of this section to read up more on the purpose of each of the mentioned directories and the type of information they stores.  

#### Remediation

In performing an iTunes backup of a device on which a particular mobile application has been installed, the backup will include all subdirectories (except for the `Library/Caches/` subdirectory) and files contained within that app's private directory on the device's file system<sup>[4]</sup>.

As such, avoid storing any sensitive data in plaintext within any of the files or folders within the app's private directory or subdirectories.

While all the files in `Documents/` and `Library/Application Support/` are always being backed up by default, it is possible to exclude files from the backup by calling `[NSURL setResourceValue:forKey:error:]` using the `NSURLIsExcludedFromBackupKey` key<sup>[5]</sup>.

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage
* M2 - Insecure Data Storage

##### OWASP MASVS
- V2.8: "No sensitive data is included in backups generated by the mobile operating system."

##### CWE
- CWE-200: Information Exposure
- CWE-538: File and Directory Information Exposure

#### Info
- [1] NSURLIsExcludedFromBackupKey - https://developer.apple.com/reference/foundation/nsurl#//apple_ref/c/data/NSURLIsExcludedFromBackupKey
- [2] kCFURLIsExcludedFromBackupKey - https://developer.apple.com/reference/corefoundation/cfurl-rd7#//apple_ref/c/data/kCFURLIsExcludedFromBackupKey
- [3] How do I prevent files from being backed up to iCloud and iTunes? - https://developer.apple.com/library/content/qa/qa1719/index.html
- [4] Directories of an iOS App - https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW12
- [5] Where You Should Put Your App’s Files - https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW28
- [6] - iOS File System Overview https://developer.apple.com/library/content/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html#//apple_ref/doc/uid/TP40010672-CH2-SW28


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
