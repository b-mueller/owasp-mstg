## iOS Platform Overview

-- [TODO - iOS Platform introduction --]

### The iOS Security Architecture

The core features of the iOS security architecture:

- Secure Boot
- Sandbox
- Code Signing
- Encryption and Data Protection
- General Exploit Mitigations

A very good and detailed analysis of iOS security architecture has been done by Johnatan Levin in MacOS and iOS Internals Vol. 3 - http://www.newosxbook.com/2ndUpdate.html <sup>[4]</sup>
 
#### Hardware Security

The security architecture makes heavy use of hardware-based security features that enhance overall performance and security. The Secure Enclave (SE) is a cryptographic coprocessor that is part of the A7 and newer chips. 

Each device comes with two built-in AES 256-bit keys, UID and GID, fused/compiled into the application processor and Secure Enclave during manufacturing. There is no way to directly read these keys through software or debugging interfaces such as JTAG. Encryption and decryption operations are performed by hardware AES crypto-engines with exclusive access to the keys. 

The GID is a common value shared between all processors in a class of devices and known to Apple, and is used to prevent tampering with firmware files and other cryptographic tasks not directly related to the user's private data. UIDs, which are unique to each device, are used to protect the key hierarchy used for device-level file system encrytion. Because they are not recorded during manufacturing, not even Apple can restore the file encryption keys for a particular device.

To enable secure deletion of sensitive data on flash memory, iOS devices inlcude a feature called Effaceable Storage. This feature provides direct low-level access to the storage technology, making it possible to securely erase selected blocks <sup>[6]</sup>.

#### Secure Boot

When the iOS device is powered on, it reads the initial instructions from the read-only Boot ROM, which bootstraps the system. This memory contains immutable code, together with Apple Root CA, which is etched in the silicon die during fabrication process, creating root of trust. In the next step, the Boot ROM code checks if signature of iBoot bootloader is correct. Once the signature is validated, the iBoot checks the signature of next boot stage, which is iOS kernel. If any of these step failed, the boot process is immediately terminated and the devices enters recovery mode and displays "Connect to iTunes" screen. If, however, the Boot ROM fails to load, the device enters special low level recovery mode, which is called Device Firmware Upgrade (DFU). This is the last resort to recover the device to original state. There will be no sign of activity of the device, i.e. the screen will not display anything. 

The entire process is called "Secure Boot Chain" and ensures that it is running only on Apple-manufactured devices. The Secure Boot chain consists of kernel, bootloaders, kernel extensions and baseband firmware. 
All new devices that have Secure Enclave coprocessor, i.e. starting from iPhone 5s also use secure boot process to ensure that the firmware within Secure Enclave is trusted. 

#### Sandbox

The sandbox is an access control technology that was provided for iOS and it is enforced at kernel level. It's purpose is to limit the impact and damage to the system and user data that may occur when an app is compromised.

The iOS Sandbox is derived from TrustedBSD MAC framework implemented as kernel extension 'Seatbelt'. 
iPhone Dev Wiki (http://iphonedevwiki.net/index.php/Seatbelt) provides some (a bit outdated) information about the sandbox. 
As a principle, all user applications run under the same user `mobile`, with only a few system applications and services running as `root`. Access to all resources, like files, network sockets, IPCs, shared memory, etc. will be then controlled by the sandbox.

#### Code Signing

Application code signing is different than in Android. In the latter you can sign with self-signed key and main purpose would be to establish root of trust for future application updates. In other words, to make sure that only the original developer of a given application would be able to update it. In Android, applications can be distributed freely as APK files or from Google Play. 
On the contrary, Apple allows app distribution only via App Store.

There exist at least two scenarios where you can install an application without App Store:
1. via Enterprise Mobile Device Management. This requires the company to have company-wise certificate signed by Apple
2. via sideloading - i.e. by signing the app with developer's certificate and installing it on one device. There is an upper limit of number of devices that can be used with the same certificate

Developer Profile and Apple-signed certificate is required in order to deploy and run an application. 
Developers need to register with Apple and join the Apple Developer Program and pay subscription fee (https://developer.apple.com/support/compare-memberships/) to get full range of development and deployment possibilites. Free account still allows you to compile and deploy an application via sideload.  

#### Encryption and Data Protection

Apple has built encryption into the hardware and firmware of its iOS devices since the release of the iPhone 3GS. Every device has a dedicated hardware level based crypto engine, based on 256-bit Advanced Encryption Standard (AES), that works in conjunction with a SHA-1 cryptographic hash function.

Besides that, there is unique identifier (UID) built into the device's hardware with an AES 256-bit key fused into the application processor. This UID is specific to the device and is not recorded else. As of writing, it is not possible for software or firmware to read it directly. As the key is burnt into the silicon chip, it cannot be tampered with or bypassed. It is only the crypto engine which can access it. It is through this that data is eventually cryptographically tied to a specific device and therefore cannot be related to any other identifier or device.

Building encryption into the physical architecture makes it easier to encrypt all data stored on an iOS device. This allows Apple to enable this level of encryption by default and disabling this is not permitted. The use of this encryption only functions as a way to only facilitate a fast, secure wipe of the system. This is an important feature, especially if a device is lost or stolen and remote wipe has been configured beforehand. Under such circumstances, a device's data can theoretically be erased before someone can hack or jailbreak it. But if a device can't be wiped quickly enough, a hacker can crack the security and get at sensitive data.

Data protection is implemented at the software level and works with the hardware and firmware encryption to provide a greater degree of security.

When data protection is enabled, each data file is associated with a specific class that supports a different level of accessibility and protects data based on when it needs to be accessed. The encryption and decryption operations associated with each class are based on multiple key mechanisms that utilizes the device's UID and passcode, plus a class key, file system key and per-file key. The per-file key is used to encrypt the file content. The class key is wrapped around the per file key and stored in the file's metadata. The file system key is used to encrypt the metadata. The UID and passcode protect the class key. This operation is invisible to users and for a device to utilize data protection, a passcode must be used when accessing that device. The passcode not only unlocks the device, but also combined with the UID to create iOS encryption keys that are more resistant to hacking efforts and brute-force attacks. It is with this that users need to enable passcodes on their devices to enable data protection.

#### General Exploit Mitigations

iOS currently implements two specific security mechanisms, namely address space layout randomization (ASLR) and eXecute Never (XN) bit, to prevent code execution attacks.

ASLR is a technique that does the job of randomizing the memory location of the program executable, data, heap and stack on every execution of the program. As the shared libraries need to be static in order to be shared by multiple processes, the addresses of shared libraries are randomized every time the OS boots instead of every time when the program is invoked.

Thus, this makes the specific memory addresses of functions and libraries hard to predict, thereby preventing attacks such as a return-to-libc attack, which relies upon knowing the memory addresses of basic libc functions. 

-- TODO [Further develop section on iOS General Exploit Mitigation] --

![iOS Security Architecture (iOS Security Guide)](http://bb-conservation.de/sven/iOS_Security_Architecture.png)
*iOS Security Architecture (iOS Security Guide)*

### Software Development on iOS 

As with other platforms, Apple provides a Software Development Kit (SDK) for iOS that helps developers to develop, install, run and test native iOS Apps by offering different tools and interfaces. XCode Integrated Development Environment (IDE) is used for this purpose and iOS applications are implemented either by using Objective-C or Swift.

Objective-C is an object-oriented programming language that adds Smalltalk-style messaging to the C programming language and is used on macOS and iOS to develop desktop and mobile applications respectively. Both macOS and iOS are implemented by using Objective-C.

Swift is the successor of Objective-C and allows interoperability with the same and was introduced with Xcode 6 in 2014.

### Understanding iOS Apps

iOS applications are distributed in IPA (iOS App Store Package) archives. This IPA file contains all the necessary (for ARM compiled) application code and resources required to execute the application. The container is in fact a ZIP compressed file, which can be easily decompressed.

An IPA has a built-in structure for iTunes and App Store to recognize, The example below shows the high level structure of an IPA.

* /Payload/ folder contains all the application data. We will come back to the content of this folder in more detail.
* /Payload/Application.app contains the application data itself (ARM compiled code) and associated static resources
* /iTunesArtwork is a 512x512 pixel PNG images used as the application’s icon
* /iTunesMetadata.plist contains various bits of information, ranging from the developer's name and ID, the bundle identifier, copyright information, genre, the name of the app, release date, purchase date, etc.
* /WatchKitSupport/WK is an example of an extension bundle. This specific bundle contains the extension delegate and the controllers for managing the interfaces and for responding to user interactions on an Apple watch.

#### IPA Payloads - A Closer Look

Let’s take a closer look now at the different files that are to be found in the ZIP compressed IPA container. It is necessary to understand that this is the raw architecture of the bundle container and not the definitive form after installation on the device. It uses a relatively flat structure with few extraneous directories in an effort to save disk space and simplify access to the files. The bundle contains the application executable and any resources used by the application (for instance, the application icon, other images, and localized content) in the top-level bundle directory.

* **MyApp**: The executable containing the application’s code, which is compiled and not in a ‘readable’ format.
* **Application**: Icons used at specific times to represent the application.
* **Info.plist**: Containing configuration information, such as its bundle ID, version number, and display name.
* **Launch images**: Images showing the initial interface of the application in a specific orientation. The system uses one of the provided launch images as a temporary background until the application is fully loaded.
* **MainWindow.nib**: Contains the default interface objects to load at application launch time. Other interface objects are then either loaded from additional nib files or created programmatically by the application.
* **Settings.bundle**: Contains any application-specific preferences using property lists and other resource files to configure and display them.
* **Custom resource files**: Non-localized resources are placed at the top level directory and localized resources are placed in language-specific subdirectories of the application bundle. Resources consist of nib files, images, sound files, configuration files, strings files, and any other custom data files you need for your application.

A language.lproj folder is defined for each language that the application supports. It contains the a storyboard and strings files.
* A storyboard is a visual representation of the user interface of an iOS application, showing screens of content and the connections between those screens.
* The strings file format consists of one or more key-value pairs along with optional comments.

![iOS App Folder Structure](http://bb-conservation.de/sven/iOS_project_folder.png)

On a jailbroken device, you can recover the IPA for an installed iOS app using IPA Installer (see also [Testing Processes and Techniques](Document/0x05b-Testing-Process-and-Techniques-iOS.md)). Note that during mobile security assessments, developers will often provide you with the IPA directly. They could send you the actual file, or provide access to the development specific distribution platform they use e.g. HockeyApp<sup>[12]</sup> or Testflight<sup>[13]</sup>.

#### App Structure on the iOS File System

Since iOS 8, changes were made to the way an application is stored on the device. On versions before iOS 8, applications would be unpacked to a folder in the /var/mobile/applications/ folder. The application would be identified by its UUID (Universal Unique Identifier), a 128-bit number. This would be the name of the folder in which we will find the application itself. Since iOS 8 this has changed however, so we will see that the static bundle and the application data folders are now stored in different locations on the filesystem. These folders contain information that we will need to closely examine during application security assessments.

* /var/mobile/Containers/Bundle/Application/[UUID]/Application.app contains the previously mentioned application.app data and stores the static content as well as the ARM compiled binary of the application. The content of this folder will be used to validate the code signature.
* /var/mobile/Containers/Data/Application/[UUID]/Documents contains all the data stored for the application itself. The creation of this data is initiated by the application’s end user.
* /var/mobile/Containers/Data/Application/[UUID]/Library contains files necessary for the application e.g. caches, preferences, cookies, property list (plist) configuration files, etc.
* /var/mobile/Containers/Data/Application/[UUID]/Temp contains temporary files which do not need persistence in between application launches.

The following figure represents the application’s folder structure:

![iOS App Folder Structure](http://bb-conservation.de/sven/iOS.png)

#### The Installation Process

Different methods exist to install an IPA package on the device. The easiest solution is to use iTunes, which is the default media player from Apple. ITunes Packages exist for OS X as well as for Windows. iTunes allows you to download applications through the App Store, after which you can synchronise them to an iOS device. The App store is the official application distribution platform from Apple. You can also use iTunes to load an ipa to a device. This can be done by adding “dragging” it into the Apps section, after which we can then add it to a device.

On Linux we can make use of libimobiledevice, a cross-platform software protocol library and set of tools to communicate with iOS devices natively. Through ideviceinstaller we can install packages over an USB connection. The connection is implemented using USB multiplexing daemon usbmuxd<sup>[8]</sup> which provides a TCP tunnel over USB. During normal operations, iTunes communicates with the iPhone using this usbmux, multiplexing several “connections” over the one USB pipe. Processes on the host machine open up connections to specific, numbered ports on the mobile device<sup>[9]</sup>.

On the iOS device, the actual installation process is then handled by installd daemon, which will unpack and install it. Before your app can integrate app services, be installed on a device, or be submitted to the App Store, it must be signed with a certificate issued by Apple. This means that we can only install it after the code signature is valid. On a jailbroken phone this can however be circumvented using AppSync <sup>[10]</sup>, a package made available on the Cydia store. This is an alternate app store containing a lot of useful applications which leverage root privileges provided through the jailbreak in order to execute advanced functionalities. AppSync is a tweak that patches installd to allow for the installation of fake-signed IPA packages.

The IPA can also be installed directly from command line by using ipainstaller <sup>[11]</sup>. After copying the IPA onto the device, for example by using scp (secure copy), the ipainstaller can be executed with the filename of the IPA:

```bash
$ ipainstaller App_in_scope.ipa
```

#### Code Signing and Encryption

Apple has implemented an intricate DRM system to make sure that only valid & approved code runs on Apple devices. In other words, on a non-jailbroken device, you won't be able to run any code unless Apple explicitly allows you to. You can't even opt to run code on your own device unless you enroll with the Apple developer program and obtain a provisioning profile and signing certificate. For this and other reasons, iOS has been compared to a crystal prison <sup>[1]</sup>.

-- TODO [Develop section on iOS Code Signing and Encryption] --

In addition to code signing, *FairPlay Code Encryption* is applied to apps downloaded from the App Store. Originally, FairPlay was developed as a means of DRM for multimedia content purchased via iTunes. In that case, encryption was applied to MPEG and Quicktime streams, but the same basic concepts can also be applied to executable files. The basic idea is as follows: Once you register a new Apple user account, a public/private key pair is created and assigned to your account. The private key is stored securely on your device. This means that Fairplay-encrypted code can be decrypted only on devices associated with your account -- TODO [Be more specific] --. The usual way to obtain reverse FairPlay encryption is to run the app on the device and then dump the decrypted code from memory (see also "Basic Security Testing on iOS").

#### The App Sandbox

In line with the "crystal prison" theme, sandboxing has been is a core security feature since the first releases of iOS. Regular apps on iOS are confined to a "container" that restrict access to the app's own files and a very limited amount of system APIs. Restrictions include <sup>[3]</sup>:

- The app process is restricted to it's own directory(below /var/mobile/Containers/Bundle/Application/) using a chroot-like mechanism.
- The mmap and mmprotect() system calls are modified to prevent apps from make writeable memory pages executable, preventing processes  from executing dynamically generated code. In combination with code signing and FairPlay, this places strict limitations on what code can be run under specific circumstances (e.g., all code in apps distributed via the app store is approved by Apple).
- Isolation from other running processes, even if they are owned by the same UID;
- Hardware drivers cannot be accessed directly. Instead, any access goes through Apple's frameworks.

### References

- [1] Apple's Crystal Prison and the Future of Open Platforms - https://www.eff.org/deeplinks/2012/05/apples-crystal-prison-and-future-open-platforms
- [2] Decrypting iOS binaries - https://mandalorian.com/2013/05/03/decrypting-ios-binaries/
- [3] Jonathan Levin, Mac OS X and iOS Internals, Wiley, 2013
- [4] Johnatan Levin, MacOS and iOS Internals, Volume III: Security & Insecurity
- [5] iOS Technology Overview - https://developer.apple.com/library/content/documentation/Miscellaneous/Conceptual/iPhoneOSTechOverview/Introduction/Introduction.html#//apple_ref/doc/uid/TP40007898-CH1-SW1
- [6] iOS Security Guide - https://www.apple.com/business/docs/iOS_Security_Guide.pdf
- [7] How iOS Security Really Works - https://developer.apple.com/videos/play/wwdc2016/705/
- [8] libimobiledevice - http://www.libimobiledevice.org/
- [9] USB Layered Communications - http://wikee.iphwn.org/usb:usbmux
- [10] AppSync - https://cydia.angelxwind.net/?page/net.angelxwind.appsyncunified
- [11] ipainstaller - https://github.com/autopear/ipainstaller
- [12] Hockey Flight - https://hockeyapp.net/
- [13] Testflight - https://developer.apple.com/testflight/
