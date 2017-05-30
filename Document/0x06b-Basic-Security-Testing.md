## Basic Security Testing on iOS

### Foreword on Swift and Objective-C 

Vast majority of this tutorial is relevant to applications written mainly in Objective-C or having bridged Swift types. Please note that these languages are fundamentally different. Features like method swizzling, which is heavily used by Cycript will not work with Swift methods. At the time of writing of this testing guide, Frida does not support instrumentation of Swift methods. 

### Setting Up Your Testing Environment

**Requirements for iOS testing lab**

Bare minimum is:

- Laptop with admin rights, VirtualBox with Kali Linux
- WiFi network with client to client traffic permitted (multiplexing through USB is also possible)
- Hopper Disassembler 
- At least one jailbroken iOS device (with desired iOS version)
- Burp Suite tool

Recommended is:
- Macbook with XCode and Developer's Profile
- WiFi network as previously
- Hopper Disassembler or IDA Pro with Hex Rays
- At least two iOS devices, one jailbroken, second non-jailbroken
- Burp Suite tool

### Jailbreaking iOS

In the iOS world, jailbreaking means among others disabling Apple's code signing mechanisms so that apps not signed by Apple can be run. If you're planning to do any form of dynamic security testing on an iOS device, you'll have a much easier time on a jailbroken device, as most useful testing tools are only available outside the app store.

There's an important different between exploit chain and jailbreak. The former will disable iOS system protections like code signing or MAC, but will not install Cydia store for you. A jailbreak is a complete tool that will leverage exploit chain, disable system protections and install Cydia. 

In jailbreak lingo, we talk about tethered and untethered jailbreaking methods. In the "tethered" scenario, the jailbreak doesn't persist throughout reboots, so the device must be connected (tethered) to a computer during every reboot to re-apply it. "Untethered" jailbreaks need only be applied once, making them the most popular choice for end users.

Jailbreaking methods vary across iOS versions. Best choice is to check if a public jailbreak is available for your iOS version<sup>[25]</sup>. Beware of fake tools and spyware that is often distributed around the Internet, often hiding behind domain names similar to the jailbreaking group/author.

**Important** caveat regarding jailbreaking iOS: contrary to Android, you **can't** downgrade iOS version with one exception explained below. Naturally, this creates a problem, when there is a major bump in iOS version (e.g. from 9 to 10) and there is no public jailbreak for the new OS. One possible solution is to have at least two iOS devices: one that will be jailbroken and have all necessary tools for testing and second, which will be updated with every major iOS release and wait for public jailbreak to be released. Once a public jailbreak is released, Apple is quite fast in releasing a patch, hence you have only a couple of days to upgrade to the newest iOS version and jailbreak it (if upgrade is necessary). 
The iOS upgrade process is performed online and is based on challenge-response process. The device will perform OS installation if and only if the response to challenge is signed by Apple. This is what researchers call 'signing window' and explains the fact that you can't simply store the OTA firmware package downloaded via iTunes and load it to the device at any time. During minor iOS upgrades, it is possible that two versions are signed at the same time by Apple. This is the only case when you can possibly downgrade iOS version. You can check current signing window and download OTA Firmwares from this site<sup>[30]</sup>. More information on jailbreaking is available on The iPhone Wiki<sup>[26]</sup>.

### Preparing your test environment

![Cydia Store](Images/Chapters/0x06b/cydia.png "Cydia Store")

Once you have your iOS device jailbroken and Cydia is installed (as per screenshot), proceed as following:

1. From Cydia install aptitude and openssh
2. SSH to your iDevice
  * Two users are `root` and `mobile`
  * Default password is `alpine`
3. Add the following repository to Cydia: `https://build.frida.re`
4. Install Frida from Cydia 
5. Install following packages with aptitude

```
inetutils 
syslogd 
less 
com.autopear.installipa 
class-dump 
com.ericasadun.utilities 
odcctools
cycript 
sqlite3 
adv-cmds 
bigbosshackertools
```

Your workstation should have SSH client, Hopper Disassembler, Burp and Frida installed. You can install Frida with pip, for instance:

```
$ sudo pip install frida
```

#### SSH Connection via USB

As per the normal behavior, iTunes communicates with the iPhone via the <code>usbmux</code>, which is a system for multiplexing several "connections" over one USB pipe. This system provides a TCP-like system where multiple processes on the host machine open up connections to specific, numbered ports on the mobile device. 

The *usbmux* is handled by */System/Library/PrivateFrameworks/MobileDevice.framework/Resources/usbmuxd*, which is a socket daemon that watches for iPhone connections via USB<sup>[18]</sup>. You can use it to map listening localhost sockets from the mobile device to TCP ports on your host machine. This conveniently allows you to SSH into your device independent of network settings. When it detects an iPhone running in normal mode, it will connect to it and then start relaying requests that it receives via */var/run/usbmuxd*<sup>[27]</sup>.

On MacOS:

```
$ brew install libimobiledevice
$ iproxy 2222 22
$ ssh -p 2222 root@localhost
iPhone:~ root# 
```

Python client:

```bash
$ ./tcprelay.py -t 22:2222
$ ssh -p 2222 root@localhost
iPhone:~ root# 
```
See also iphonedevwiki <sup>[24]</sup>.

### Typical iOS Application Test Workflow

Typical workflow for iOS Application test is following:
* Obtain IPA file
* Bypass jailbreak detection (if present)
* Bypass certificate pinning (if present)
* Inspect HTTP(S) traffic - usual web app test
* Abuse application logic by runtime manipulation
* Check for local data storage (caches, binary cookies, plists, databases)
* Check for client-specific bugs, e.g. SQLi, XSS
* Other checks like: logging to ASL with NSLog, application compile options, application screenshots, no app backgrounding

### Static Analysis

#### With Source Code

-- TODO [Add content on security Static Analysis of an iOS app with source code] --

#### Without Source Code

##### Folder structure

System applications can be found in `/Applications`
For all the rest you can use `installipa` to navigate to appropriate folders [14]:

```
iOS8-jailbreak:~ root# installipa -l
me.scan.qrcodereader
iOS8-jailbreak:~ root# installipa -i me.scan.qrcodereader
Bundle: /private/var/mobile/Containers/Bundle/Application/09D08A0A-0BC5-423C-8CC3-FF9499E0B19C
Application: /private/var/mobile/Containers/Bundle/Application/09D08A0A-0BC5-423C-8CC3-FF9499E0B19C/QR Reader.app
Data: /private/var/mobile/Containers/Data/Application/297EEF1B-9CC5-463C-97F7-FB062C864E56
```

As you can see, there are three main directories: Bundle, Application and Data. The Application directory is just a subdir of Bundle.
The static installer files are located in Application, whereas all user data resides in the Data directory.
The random string in the URI is application's GUID, which will be different from installation to installation.

##### Recovering an IPA File From an Installed App

###### From Jailbroken devices

You can use Saurik's IPA Installer to recover IPAs from apps installed on the device. To do this, install IPA installer console [1] via Cydia. Then, ssh into the device and look up the bundle id of the target app. For example:

~~~
iPhone:~ root# ipainstaller -l
com.apple.Pages
com.example.targetapp
com.google.ios.youtube
com.spotify.client
~~~

Generate the IPA file for using the following command:

~~~
iPhone:~ root# ipainstaller -b com.example.targetapp -o /tmp/example.ipa
~~~

###### From non-Jailbroken devices

If the app is available on itunes, you are able to recover the ipa on MacOS with the following simple steps:

- Download the app in itunes
- Go to your itunes Apps Library
- Right-click on the app and select show in finder

-- TODO [Further develop section on Static Analysis of an iOS app from non-jailbroken devices without source code] --

#### Dumping Decrypted Executables

On top of code signing, apps distributed via the app store are also protected using Apple's FairPlay DRM system. This system uses asymmetric cryptography to ensure that any app (including free apps) obtained from the app store only executes on the particular device it is approved to run on. The decryption key is unique to the device and burned into the processor. As of now, the only possible way to obtain the decrypted code from a FairPlay-decrypted app is dumping it from memory while the app is running. On a jailbroken device, this can be done with Clutch tool that is included in standard Cydia repositories [2]. Use clutch in interactive mode to get a list of installed apps, decrypt them and pack to IPA file:

~~~
# Clutch -i 
~~~

**NOTE:** Only applications distributed with AppStore are protected with FairPlay DRM. If you obtained your application compiled and exported directly from XCode, you don't need to decrypt it. The easiest way is to load the application into Hopper and check if it's being correctly disassembled. You can also check it with otool:

~~~
# otool -l yourbinary | grep -A 4 LC_ENCRYPTION_INFO
~~~

If the output contains cryptoff, cryptsize and cryptid fields, then the binary is encrypted. If the output of this comand is empty, it means that binary is not encrypted. **Remember** to use otool on binary, not on the IPA file.

#### Getting Basic Information with Class-dump and Hopper Disassembler

Class-dump tool can be used to get information about methods in the application. Example below uses Damn Vulnerable iOS Application [12]. As our binary is so-called fat binary, which means that it can be executed on 32 and 64 bit platforms:

```
$ unzip DamnVulnerableiOSApp.ipa

$ cd Payload/DamnVulnerableIOSApp.app

$ otool -hv DamnVulnerableIOSApp 

DamnVulnerableIOSApp (architecture armv7):
Mach header
      magic cputype cpusubtype  caps    filetype ncmds sizeofcmds      flags
   MH_MAGIC     ARM         V7  0x00     EXECUTE    38       4292   NOUNDEFS DYLDLINK TWOLEVEL WEAK_DEFINES BINDS_TO_WEAK PIE

DamnVulnerableIOSApp (architecture arm64):
Mach header
      magic cputype cpusubtype  caps    filetype ncmds sizeofcmds      flags
MH_MAGIC_64   ARM64        ALL  0x00     EXECUTE    38       4856   NOUNDEFS DYLDLINK TWOLEVEL WEAK_DEFINES BINDS_TO_WEAK PIE

```

Note architecture `armv7` which is 32 bit and `arm64`. This design permits to deploy the same application on all devices. 
In order to analyze the application with class-dump we must create so-called thin binary, which contains only one architecture:

```
iOS8-jailbreak:~ root# lipo -thin armv7 DamnVulnerableIOSApp -output DVIA32
```

And then we can proceed to performing class-dump:

```
iOS8-jailbreak:~ root# class-dump DVIA32 

@interface FlurryUtil : ./DVIA/DVIA/DamnVulnerableIOSApp/DamnVulnerableIOSApp/YapDatabase/Extensions/Views/Internal/
{
}
+ (BOOL)appIsCracked;
+ (BOOL)deviceIsJailbroken;
```

Note the plus sign, which means that this is a class method returning BOOL type. 
A minus sign would mean that this is an instance method. Please refer to further sections to understand the practical difference between both.

Alternatively, you can easily decompile the application with Hopper Disassembler [13]. All these steps will be performed automatically and you will be able to see disassembled binary and class information. 

Your main focus while performing static analysis would be:
* Identifying and undestanding functions responsible for jailbreak detection and certificate pinning
  * For jailbreak detection, look for methods or classess containing words like `jailbreak`, `jailbroken`, `cracked`, etc. Please note that sometimes, the name of function performing jailbreak detection will be 'obfuscated' to slow down the analysis. Your best bet is to look for jailbreak detection mechanisms discussed in further section (cf. Dynamic Analysis - Jailbreak Detection)
  * For certificate pinning, look for keywords like `pinning`, `X509` or for native method calls like `NSURLSession`, `CFStream`, `AFNetworking`
* Understanding application logic and possible ways to bypass it 
* Any hardcoded credentials, certificates
* Any methods that are used for obfuscation and in consequence may reveal sensitive information

#### Copying App Data Files

Files belonging to an app are stored app's data directory. To identify the correct path, ssh into the device and retrieve the package information using IPA Installer Console:

```bash
iPhone:~ root# ipainstaller -l 
sg.vp.UnCrackable-2
sg.vp.UnCrackable1

iPhone:~ root# ipainstaller -i sg.vp.UnCrackable1
Identifier: sg.vp.UnCrackable1
Version: 1
Short Version: 1.0
Name: UnCrackable1
Display Name: UnCrackable Level 1
Bundle: /private/var/mobile/Containers/Bundle/Application/A8BD91A9-3C81-4674-A790-AF8CDCA8A2F1
Application: /private/var/mobile/Containers/Bundle/Application/A8BD91A9-3C81-4674-A790-AF8CDCA8A2F1/UnCrackable Level 1.app
Data: /private/var/mobile/Containers/Data/Application/A8AE15EE-DC8B-4F1C-91A5-1FED35258D87
```

You can now simply archive the data directory and pull it from the device using scp.

```bash
iPhone:~ root# tar czvf /tmp/data.tgz /private/var/mobile/Containers/Data/Application/A8AE15EE-DC8B-4F1C-91A5-1FED35258D87
iPhone:~ root# exit
$ scp -P 2222 root@localhost:/tmp/data.tgz .
```

#### Dumping KeyChain Data

Keychain-Dumper [23] lets you dump the contents of the KeyChain on a jailbroken device. The easiest way of running the tool is to download the binary from its GitHub repo:

``` bash
$ git clone https://github.com/ptoomey3/Keychain-Dumper
$ scp -P 2222 Keychain-Dumper/keychain_dumper root@localhost:/tmp/
$ ssh -p 2222 root@localhost
iPhone:~ root# chmod +x /tmp/keychain_dumper
iPhone:~ root# /tmp/keychain_dumper 

(...)

Generic Password
----------------
Service: myApp
Account: key3
Entitlement Group: RUD9L355Y.sg.vantagepoint.example
Label: (null)
Generic Field: (null)
Keychain Data: SmJSWxEs

Generic Password
----------------
Service: myApp
Account: key7
Entitlement Group: RUD9L355Y.sg.vantagepoint.example
Label: (null)
Generic Field: (null)
Keychain Data: WOg1DfuH
```

Note however that this binary is signed with a self-signed certificate with a "wildcard" entitlement, granting access to *all* items in the Keychain - if you are paranoid, or have highly sensitive private data on your test device, you might want to build the tool from source and manually sign the appropriate entitlements into your build - instructions for doing this are available in the Github repository.

### Dynamic Analysis

-- TODO [Dynamic analysis - copying data files, logs, from device, etc.] --

#### Monitoring Console Logs

Many apps log informative (and potentially sensitive) messages to the console log. Besides that, the log also contains crash reports and potentially other useful information. You can collect console logs through the XCode "Devices" window as follows:

1. Launch Xcode
2. Connect your device to your host computer
3. Choose Devices from the Window menu
4. Click on your connected iOS device in the left section of the Devices window
5. Reproduce the problem
6. Click the triangle in a box toggle located in the lower-left corner of the right section of the Devices
window to expose the console log contents

To save the console output to a text file, click the circle with a downward-pointing arrow at the bottom right.

![Console logs](Images/Chapters/0x06b/device_console.jpg "Monitoring console logs through XCode")

#### Dynamic Analysis On Jailbroken Devices

Life is easy with a jailbroken device: Not only do you gain easy access to the app's sandbox, you can also use more powerful dynamic analysis techniques due to the lack of code singing. On iOS, most dynamic analysis tools are built on top of Cydia Substrate, a framework for developing runtime patches that we will cover in more detail in the "Tampering and Reverse Engineering" chapter. For basic API monitoring purposes however, you can get away without knowing Substrate in detail - you can simply use existing tools built for this purpose.

#### Dynamic Analysis on Non-Jailbroken Devices

If you don't have access to a jailbroken device, you can patch and repackage the target app to load a dynamic library at startup. This way, you can instrument the app and can do pretty much everything you need for a dynamical analysis (of course, you can't break out of the sandbox that way, but you usually don't need to). This technique however works only on if the app binary isn't FairPlay-encrypted (i.e. obtained from the app store).

Thanks to Apple's confusing provisioning and code signing system, re-signing an app is more challenging than one would expect. iOS will refuse to run an app unless you get the provisioning profile and code signature header absolutely right. This requires you to learn about a whole lot of concepts - different types of certificates, BundleIDs, application IDs, team identifiers, and how they are tied together using Apple's build tools. Suffice it to say, getting the OS to run a particular binary that hasn't been built using the default way (XCode) can be an daunting process.

The toolset we're going to use consists of optool, Apple's build tools and some shell commands. Our method is inspired by the resign script from Vincent Tan's Swizzler project [4]. An alternative way of repackaging using different tools was described by NCC group [5].

To reproduce the steps listed below, download "UnCrackable iOS App Level 1" from the OWASP Mobile Testing Guide repo [6]. Our goal is to make the UnCrackable app load FridaGadget.dylib during startup so we can instrument it using Frida. 

##### Getting a Developer Provisioning Profile and Certificate

The *provisioning profile* is a plist file signed by Apple that whitelists your code signing certificate on one or multiple devices. In other words, this is Apple explicitly allowing your app to run in certain contexts, such as debugging on selected devices (development profile). The provisioning profile also includes the *entitlements* granted to your app. The *certificate* contains the private key you'll use to do the actual signing.

Depending on whether you're registered as an iOS developer, you can use one of the following two ways to obtain a certificate and provisioning profile.

**With an iOS developer account:**

If you have developed and deployed apps iOS using Xcode before, you'll already have your own code signing certificate installed. Use the *security* tool to list your existing signing identities:

~~~
$ security find-identity -p codesigning -v
  1) 61FA3547E0AF42A11E233F6A2B255E6B6AF262CE "iPhone Distribution: Vantage Point Security Pte. Ltd."
  2) 8004380F331DCA22CC1B47FB1A805890AE41C938 "iPhone Developer: Bernhard Müller (RV852WND79)"
~~~

Log into the Apple Developer portal to issue a new App ID, then issue and download the profile [8]. The App ID can be anything - you can use the same App ID for re-signing multiple apps. Make sure you create a *development* profile and not a *distribution* profile, as you'll want to be able to debug the app.

In the examples below I'm using my own signing identity which is associated with my company's development team. I created the app-id "sg.vp.repackaged", as well as a provisioning profile aptly named "AwesomeRepackaging" for this purpose, and ended up with the file AwesomeRepackaging.mobileprovision - exchange this with your own filename in the shell commands below.

**With a regular iTunes account:**

Mercifully, Apple will issue a free development provisioning profile even if you're not a paying developer. You can obtain the profile with Xcode using your regular Apple account - simply build an empty iOS project and extract embedded.mobileprovision from the app container. The NCC blog explains this process in great detail [5].

Once you have obtained the provisioning profile, you can check its contents with the *security* tool. Besides the allowed certificates and devices, you'll find the entitlements granted to the app in the profile. You'll need those later for code signing, so extract them to a separate plist file as shown below. It is also worth having a look at the contents of the file to check if everything looks as expected.

~~~
$ security cms -D -i AwesomeRepackaging.mobileprovision > profile.plist
$ /usr/libexec/PlistBuddy -x -c 'Print :Entitlements' profile.plist > entitlements.plist
$ cat entitlements.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>application-identifier</key>
	<string>LRUD9L355Y.sg.vantagepoint.repackage</string>
	<key>com.apple.developer.team-identifier</key>
	<string>LRUD9L355Y</string>
	<key>get-task-allow</key>
	<true/>
	<key>keychain-access-groups</key>
	<array>
		<string>LRUD9L355Y.*</string>
	</array>
</dict>
</plist>
~~~

Note the application identitifier, which is a combination of the Team ID (LRUD9L355Y) and Bundle ID (sg.vantagepoint.repackage). This provisioning profile is only valid for the one app with this particular app id. The "get-task-allow" key is also important - when set to "true", other processes, such as the debugging server, are allowed to attach to the app (consequently, this would be set to "false" in a distribution profile).

##### Other Preparations

To make our app load an additional library at startup we need some way of inserting an additional load command into the Mach-O header of the main executable. Optool [3] can be used to automate this process:

~~~
$ git clone https://github.com/alexzielenski/optool.git
$ cd optool/
$ git submodule update --init --recursive
~~~

We'll also use ios-deploy [10], a tools that enables deploying and debugging of iOS apps without using Xcode:

~~~
git clone https://github.com/alexzielenski/optool.git
cd optool/
git submodule update --init --recursive
~~~

To follow the examples below, you also need FridaGadget.dylib:

~~~
$ curl -O https://build.frida.re/frida/ios/lib/FridaGadget.dylib
~~~

Besides the tools listed above, we'll be using standard tools that come with OS X and Xcode (make sure you have the Xcode command line developer tools installed).

##### Patching, Repackaging and Re-Signing

Time to get serious! As you already now, IPA files are actually ZIP archives, so use any zip tool to unpack the archive. Then, copy FridaGadget.dylib into the app directory, and add a load command to the "UnCrackable Level 1" binary using optool.

~~~
$ unzip UnCrackable_Level1.ipa
$ cp FridaGadget.dylib Payload/UnCrackable\ Level\ 1.app/
$ optool install -c load -p "@executable_path/FridaGadget.dylib" -t Payload/UnCrackable\ Level\ 1.app/UnCrackable\ Level\ 1
Found FAT Header
Found thin header...
Found thin header...
Inserting a LC_LOAD_DYLIB command for architecture: arm
Successfully inserted a LC_LOAD_DYLIB command for arm
Inserting a LC_LOAD_DYLIB command for architecture: arm64
Successfully inserted a LC_LOAD_DYLIB command for arm64
Writing executable to Payload/UnCrackable Level 1.app/UnCrackable Level 1...
~~~

Such blatant tampering of course invalidates the code signature of the main executable, so this won't run on a non-jailbroken device. You'll need to replace the provisioning profile and sign both the main executable and FridaGadget.dylib with the certificate listed in the profile.

First, let's add our own provisioning profile to the package:

~~~
$ cp AwesomeRepackaging.mobileprovision Payload/UnCrackable\ Level\ 1.app/embedded.mobileprovision
~~~

Next, we need to make sure that the BundleID in Info.plist matches the one specified in the profile. The reason for this is that the "codesign" tool will read the Bundle ID from Info.plist during signing - a wrong value will lead to an invalid signature.

~~~
$ /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier sg.vantagepoint.repackage" Payload/UnCrackable\ Level\ 1.app/Info.plist
~~~

Finally, we use the codesign tool to re-sign both binaries:

~~~
$ rm -rf Payload/F/_CodeSignature
$ /usr/bin/codesign --force --sign 8004380F331DCA22CC1B47FB1A805890AE41C938  Payload/UnCrackable\ Level\ 1.app/FridaGadget.dylib
Payload/UnCrackable Level 1.app/FridaGadget.dylib: replacing existing signature
$ /usr/bin/codesign --force --sign 8004380F331DCA22CC1B47FB1A805890AE41C938 --entitlements entitlements.plist Payload/UnCrackable\ Level\ 1.app/UnCrackable\ Level\ 1
Payload/UnCrackable Level 1.app/UnCrackable Level 1: replacing existing signature
~~~

##### Installing and Running the App

Now you should be all set for running the modified app. Deploy and run the app on the device as follows.

~~~
$ ios-deploy --debug --bundle Payload/UnCrackable\ Level\ 1.app/
~~~

If everything went well, the app should launch on the device in debugging mode with lldb attached. Frida should now be able to attach to the app as well. You can verify this with the frida-ps command:
 
~~~
$ frida-ps -U
PID  Name
---  ------
499  Gadget
~~~

![Frida on non-JB device](Images/Chapters/0x06b/fridaStockiOS.png "Frida on non-JB device")

##### Troubleshooting.

If something goes wrong (which it usually does), mismatches between the provisioning profile and code signing header are the most likely suspect. In that case it is helpful to read the official documentation and gaining an understanding of how the whole system works [7][8]. I also found Apple's entitlement troubleshooting page [9] to be a useful resource.

### Setting up Burp

Setting up burp to proxy your traffic through is pretty straightforward. It is assumed that you have both: iDevice and workstation connected to the same WiFi network where client to client traffic is permitted. If client-to-client traffic is not permitted, it should be possible to use usbmuxd [18] in order to connect to burp through USB. 

The first step is to configure proxy of your burp to listen on all interfaces (alternatively only on the WiFi interface). Then we can configure our iDevice to use our proxy in advanced wifi settings. Portswigger provides good tutorial on setting an iOS Device and Burp [22].

### Bypassing Certificate Pinning

Certificate Pinning is a practice used to tighten security of TLS connection. When an application is connecting to the server using TLS, it checks if the server's certificate is signed with trusted CA's private key. The verification is based on checking the signature with public key that is within device's key store. This in turn contains public keys of all trusted root CAs.

Certificate pinning means that our application will have server's certificate or hash of the certificate hardcoded into the source code. 
This protects against two main attack scenarios:

* Compromised CA issuing certificate for our domain to a third-party
* Phishing attacks that would add a third-party root CA to device's trust store

The simplest method is to use `SSL Kill Switch` (can be installed via Cydia store), which will hook on all high-level API calls and bypass certificate pinning. There are some cases, though, where certificate pinning is more tricky to bypass. Things to look for when you try to bypass certificate pinning are:

- following API calls: `NSURLSession`, `CFStream`, `AFNetworking`
- during static analysis, try to look for methods/strings containing words like 'pinning', 'X509', 'Certificate', etc.
- sometimes, more low-level verification can be done using e.g. openssl. There are tutorials [20] on how to bypass this. 
- some dual-stack applications written using Apache Cordova or Adobe Phonegap heavily use callbacks. You can look for the callback function called upon success and call it manually with Cycript
- sometimes the certificate resides as a file within application bundle. It might be sufficient to replace it with burp's certificate, but beware of certificate's SHA sum that might be hardcoded in the binary. In that case you must replace it too!

#### Recommendations

Certificate pinning is a good security practice and should be used for all applications handling sensitive information. 
EFF's Observatory<sup>[28]</sup> provides list of root and intermediate CAs that are by default trusted on major operating systems. Please also refer to a map of the 650-odd organizations that function as Certificate Authorities trusted (directly or indirectly) by Mozilla or Microsoft<sup>[29]</sup>. Use certificate pinning if you don't trust at least one of these CAs.

If you want to get more details on white-box testing and usual code patters, refer to iOS Application Security by David Thiel [21]. It contains description and code snippets of most-common techniques used to perform certificate pinning.

To get more information on testing transport security, please refer to section 'Testing Network Communication' 

### References

* [1] IPA Installer Console - http://cydia.saurik.com/package/com.autopear.installipa
* [2] Clutch - https://github.com/KJCracks/Clutch
* [3] Optool - https://github.com/alexzielenski/optool
* [4] Swizzler 2 - https://github.com/vtky/Swizzler2/wiki
* [5] iOS instrumentation without jailbreak - https://www.nccgroup.trust/au/about-us/newsroom-and-events/blogs/2016/october/ios-instrumentation-without-jailbreak/
* [6] Uncrackable Level 1 - https://github.com/OWASP/owasp-mstg/tree/master/OMTG-Files/02_Crackmes/02_iOS/UnCrackable_Level1
* [7] Maintaining Certificates - https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/MaintainingCertificates/MaintainingCertificates.html
* [8] Maintaining Provisioning Profiles - https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppDistributionGuide/MaintainingProfiles/MaintainingProfiles.html
* [9] Entitlements Troubleshooting - https://developer.apple.com/library/content/technotes/tn2415/_index.html
* [10] iOS-deploy - https://github.com/phonegap/ios-deploy
* [11] MacOS and iOS Internals, Volume III: Security & Insecurity - Johnathan Levin
* [12] Damn Vulnerable iOS Application - http://damnvulnerableiosapp.com/
* [13] Hopper Disassembler - https://www.hopperapp.com/
* [14] Introduction to iOS Application Security Testing - Slawomir Kosowski
* [15] The Mobile Application Hacker's Handbook -  Dominic Chell, Tyrone Erasmus, Shaun Colley
* [16] Cydia Substrate  - http://www.cydiasubstrate.com
* [17] Frida - http://frida.re
* [18] usbmuxd - https://github.com/libimobiledevice/usbmuxd
* [19] Jailbreak Detection Methods - https://www.trustwave.com/Resources/SpiderLabs-Blog/Jailbreak-Detection-Methods/
* [20] Bypassing OpenSSL Certificate Pinning -https://www.nccgroup.trust/us/about-us/newsroom-and-events/blog/2015/january/bypassing-openssl-certificate-pinning-in-ios-apps/ 
* [21] iOS Application Security - David Thiel
* [22] Configuring an iOS Device to Work With Burp - https://support.portswigger.net/customer/portal/articles/1841108-configuring-an-ios-device-to-work-with-burp
* [23] KeyChain-Dumper - https://github.com/ptoomey3/Keychain-Dumper/
* [24] iphonedevwiki - SSH over USB - http://iphonedevwiki.net/index.php/SSH_Over_USB
* [25] Can I Jailbreak? by IPSW Downloads - https://canijailbreak.com/
* [26] The iPhone Wiki - https://www.theiphonewiki.com/
* [27] The iPhone Wiki - https://www.theiphonewiki.com/wiki/Usbmux 
* [28] EFF's Observatory - https://www.eff.org/pl/observatory
* [29] Map of the 650-odd organizations that function as Certificate Authorities trusted (directly or indirectly) by Mozilla or Microsoft - https://www.eff.org/files/colour_map_of_CAs.pdf
* [30] IPSW Downloads - https://ipsw.me
