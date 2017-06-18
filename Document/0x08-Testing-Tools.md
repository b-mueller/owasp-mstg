## Testing Tools
To perform security testing different tools are available in order to be able to manipulate requests and responses, decompile Apps, investigate the behavior of running Apps and other test cases and automate them.

### Mobile Application Security Testing Distributions
* Appie - https://manifestsecurity.com/appie - A portable software package for Android Pentesting and an awesome alternative to existing Virtual machines.
* Android Tamer - https://androidtamer.com/ - Android Tamer is a Virtual / Live Platform for Android Security professionals.
* AppUse - https://appsec-labs.com/AppUse/ - AppUse is a VM (Virtual Machinedeveloped by AppSec Labs.
* Androl4b - https://github.com/sh4hin/Androl4b - A Virtual Machine For Assessing Android applications, Reverse Engineering and Malware Analysis
* Mobisec - http://sourceforge.net/projects/mobisec/ - Mobile security testing live environment.
* Santoku - https://santoku-linux.com/ - Santoku is an OS and can be run outside a VM as a standalone operating system.
* Vezir Project - https://github.com/oguzhantopgul/Vezir-Project - Mobile Application Pentesting and Malware Analysis Environment.

### Static Source Code Analysis
* Checkmarx - https://www.checkmarx.com/technology/static-code-analysis-sca/ - Static Source Code Scanner that also scans source code for Android and iOS.
* Fortify - https://saas.hpe.com/en-us/software/fortify-on-demand/mobile-security - Static Source Code Scanner that also scans source code for Android and iOS.


### All-in-One Mobile Security Frameworks
* Mobile Security Framework - MobSF - https://github.com/ajinabraham/Mobile-Security-Framework-MobSF - Mobile Security Framework is an intelligent, all-in-one open source mobile application (Android/iOSautomated pen-testing framework capable of performing static and dynamic analysis.
* Needle - https://github.com/mwrlabs/needle - Needle is an open source, modular framework to streamline the process of conducting security assessments of iOS apps including Binary Analysis, Static Code Analysis, Runtime Manipulation using Cycript and Frida hooking, and so on.

### Tools for Android
#### Reverse Engineering and Static Analysis
* Androguard - https://github.com/androguard/androguard - Androguard is a python based tool, which can use to disassemble and  decompile android apps.
* Android Debug Bridge - adb - https://developer.android.com/studio/command-line/adb.html - Android Debug Bridge (adbis a versatile command line tool that lets you communicate with an emulator instance or connected Android device.
* APKInspector - https://github.com/honeynet/apkinspector/ - APKinspector is a powerful GUI tool for analysts to analyze the Android applications.
* APKTool - http://ibotpeaches.github.io/Apktool/ - A tool for reverse engineering 3rd party, closed, binary Android apps. It can decode resources to nearly original form and rebuild them after making some modifications.
* android-classyshark - https://github.com/google/android-classyshark - ClassyShark is a standalone binary inspection tool for Android developers.
* Sign - https://github.com/appium/sign - Sign.jar automatically signs an apk with the Android test certificate.
* Jadx - https://github.com/skylot/jadx - Dex to Java decompiler: Command line and GUI tools for produce Java source code from Android Dex and Apk files.
* Oat2dex - https://github.com/testwhat/SmaliEx - A tool for converting .oat file to .dex files.
* FindBugs - http://findbugs.sourceforge.net/ - Static Analysis tool for Java
* FindSecurityBugs - http://h3xstream.github.io/find-sec-bugs/ - FindSecurityBugs is a extension for FindBugs which include security rules for Java applications.
* Qark - https://github.com/linkedin/qark - This tool is designed to look for several security related Android application vulnerabilities, either in source code or packaged APKs.
* SUPER - https://github.com/SUPERAndroidAnalyzer/super - SUPER is a command-line application that can be used in Windows, MacOS X and Linux, that analyzes .apk files in search for vulnerabilities. It does this by decompressing APKs and applying a series of rules to detect those vulnerabilities.
* AndroBugs - https://github.com/AndroBugs/AndroBugs_Framework - AndroBugs Framework is an efficient Android vulnerability scanner that helps developers or hackers find potential security vulnerabilities in Android applications. No need to install on Windows.
* Simplify - https://github.com/CalebFenton/simplify - A tool for de-obfuscating android package into Classes.dex which can be use Dex2jar and JD-GUI to extract contents of dex file.
* ClassNameDeobfuscator - https://github.com/HamiltonianCycle/ClassNameDeobfuscator - Simple script to parse through the .smali files produced by apktool and extract the .source annotation lines.
* Android backup extractor - https://github.com/nelenkov/android-backup-extractor - Utility to extract and repack Android backups created with adb backup (ICS+). Largely based on BackupManagerService.java from AOSP.
* VisualCodeGrepper - https://sourceforge.net/projects/visualcodegrepp/ - Static Code Analysis Tool for several programming languages including Java

#### Dynamic and Runtime Analysis
* Cydia Substrate - http://www.cydiasubstrate.com/ - Cydia Substrate for Android enables developers to make changes to existing software with Substrate extensions that are injected in to the target process's memory.
* Xposed Framework - http://forum.xda-developers.com/xposed/xposed-installer-versions-changelog-t2714053 - Xposed framework enables you to modify the system or application aspect and behavior at runtime, without modifying any Android application package(APKor re-flashing.
* logcat-color - https://github.com/marshall/logcat-color - A colorful and highly configurable alternative to the adb logcat command from the Android SDK.
* Inspeckage - https://github.com/ac-pm/Inspeckage - Inspeckage is a tool developed to offer dynamic analysis of Android applications. By applying hooks to functions of the Android API, Inspeckage will help you understand what an Android application is doing at runtime.
* Frida - http://www.frida.re/ - The toolkit works using a client-server model and lets you inject in to running processes not just on Android, but also on iOS, Windows and Mac.
* Diff-GUI - https://github.com/antojoseph/diff-gui - A Web framework to start instrumenting with the avaliable modules, hooking on native, inject JavaScript using Frida.
* AndBug - https://github.com/swdunlop/AndBug-  AndBug is a debugger targeting the Android platform's Dalvik virtual machine intended for reverse engineers and developers.
* Cydia Substrate: Introspy-Android - https://github.com/iSECPartners/Introspy-Android - Blackbox tool to help understand what an Android application is doing at runtime and assist in the identification of potential security issues.
* Drozer - https://www.mwrinfosecurity.com/products/drozer/ - Drozer allows you to search for security vulnerabilities in apps and devices by assuming the role of an app and interacting with the Dalvik VM, other apps' IPC endpoints and the underlying OS.
* VirtualHook - https://github.com/rk700/VirtualHook - VirtualHook is a hooking tool for applications on Android ART(>=5.0). It's based on VirtualApp and therefore does not require root permission to inject hooks.

#### Bypassing Root Detection and SSL Pinning
* Xposed Module: Just Trust Me - https://github.com/Fuzion24/JustTrustMe - Xposed Module to bypass SSL certificate pinning.
* Xposed Module: SSLUnpinning - https://github.com/ac-pm/SSLUnpinning_Xposed - Android Xposed Module to bypass SSL certificate validation (Certificate Pinning).
* Cydia Substrate Module: Android SSL Trust Killer - https://github.com/iSECPartners/Android-SSL-TrustKiller - Blackbox tool to bypass SSL certificate pinning for most applications running on a device.
* Cydia Substrate Module: RootCoak Plus - https://github.com/devadvance/rootcloakplus - Patch root checking for commonly known indications of root.
* Android-ssl-bypass - https://github.com/iSECPartners/android-ssl-bypass - an Android debugging tool that can be used for bypassing SSL, even when certificate pinning is implemented, as well as other debugging tasks. The tool runs as an interactive console.


### Tools for iOS
#### Access Filesystem on iDevice
* FileZilla - https://filezilla-project.org/download.php?show_all=1 -  It supports FTP, SFTP, and FTPS (FTP over SSL/TLS).
* Cyberduck - https://cyberduck.io - Libre FTP, SFTP, WebDAV, S3, Azure & OpenStack Swift browser for Mac and Windows.
* itunnel - https://code.google.com/p/iphonetunnel-usbmuxconnectbyport/downloads/list -  Use to forward SSH via USB.
* iFunbox - http://www.i-funbox.com - The File and App Management Tool for iPhone, iPad & iPod Touch.

#### Reverse Engineering and Static Analysis
* otool - http://www.unix.com/man-page/osx/1/otool/ - The otool command displays specified parts of object files or libraries.
* Clutch - http://cydia.radare.org/- Decrypted the application and dump specified bundleID into binary or .ipa file.
* Dumpdecrypted] (https://github.com/stefanesser/dumpdecrypted - Dumps decrypted mach-o files from encrypted iPhone applications from memory to disk. This tool is necessary for security researchers to be able to look under the hood of encryption.
* class-dump - http://stevenygard.com/projects/class-dump/ - A command-line utility for examining the Objective-C runtime information stored in Mach-O files.
* Weak Classdump] (https://github.com/limneos/weak_classdump - A Cycript script that generates a header file for the class passed to the function. Most useful when you cannot classdump or dumpdecrypted , when binaries are encrypted etc.
* IDA Pro - https://www.hex-rays.com/products/ida/index.shtml - IDA is a Windows, Linux or Mac OS X hosted multi-processor disassembler and debugger that offers so many features it is hard to describe them all.
* HopperApp - http://hopperapp.com/ - Hopper is a reverse engineering tool for OS X and Linux, that lets you disassemble, decompile and debug your 32/64bits Intel Mac, Linux, Windows and iOS executables.
* Radare2 - http://www.radare.org/ - Radare2 is a unix-like reverse engineering framework and command line tools.
* iRET - https://www.veracode.com/iret-ios-reverse-engineering-toolkit - The iOS Reverse Engineering Toolkit is a toolkit designed to automate many of the common tasks associated with iOS penetration testing.
* Agnitio - https://sourceforge.net/projects/agnitiotool/ - Tool for static scanning of Objective-C, C# and Java source code.

#### Dynamic and Runtime Analysis
* cycript - http://www.cycript.org - Cycript allows developers to explore and modify running applications on either iOS or Mac OS X using a hybrid of Objective-C++ and JavaScript syntax through an interactive console that features syntax highlighting and tab completion.
* iNalyzer - https://appsec-labs.com/cydia/ - AppSec Labs iNalyzer is a framework for manipulating iOS applications, tampering with parameters and method.
* idb - https://github.com/dmayer/idb - idb is a tool to simplify some common tasks for iOS pentesting and research.
* snoop-it - http://cydia.radare.org/ - A tool to assist security assessments and dynamic analysis of iOS Apps.
* Introspy-iOS - https://github.com/iSECPartners/Introspy-iOS - Blackbox tool to help understand what an iOS application is doing at runtime and assist in the identification of potential security issues.
* gdb - http://cydia.radare.org/ - A tool to perform runtime analysis of IOS applications.
* keychaindumper - http://cydia.radare.org/ - A tool to check which keychain items are available to an attacker once an iOS device has been jailbroken.
* BinaryCookieReader - http://securitylearn.net/wp-content/uploads/tools/iOS/BinaryCookieReader.py - A tool to dump all the cookies from the binary Cookies.binarycookies file.
* Burp Suite Mobile Assistant - https://portswigger.net/burp/help/mobile_testing_using_mobile_assistant.html - A tool to bypass certificate pinning and is able to inject into apps.

#### Bypassing Root Detection and SSL Pinning
* SSL Kill Switch 2 - https://github.com/nabla-c0d3/ssl-kill-switch2 - Blackbox tool to disable SSL certificate validation - including certificate pinning - within iOS and OS X Apps.
* iOS TrustMe - https://github.com/intrepidusgroup/trustme - Disable certificate trust checks on iOS devices.
* Xcon - http://apt.modmyi.com - A tool for bypassing Jailbreak detection.
* tsProtector - http://cydia.saurik.com/package/kr.typostudio.tsprotector8/ - Another tool for bypassing Jailbreak detection.

### Tools for Network Interception and Monitoring
* Tcpdump - http://www.androidtcpdump.com - A command line packet capture utility.
* Wireshark - https://www.wireshark.org/download.html - An open-source packet analyzer.
* Canape - http://www.contextis.com/services/research/canape/ - A network testing tool for arbitrary protocols.
* Mallory - https://intrepidusgroup.com/insight/mallory/ - A Man in The Middle Tool (MiTM) that is used to monitor and manipulate traffic on mobile devices and applications.

### Interception Proxies
* Burp Suite - https://portswigger.net/burp/download.html - Burp Suite is an integrated platform for performing security testing of applications.
* OWASP ZAP - https://github.com/zaproxy/zaproxy - The OWASP Zed Attack Proxy (ZAPis a free security tools which can help you automatically find security vulnerabilities in your web applications and web services.
* Fiddler - http://www.telerik.com/fiddler - Fiddler is an HTTP debugging proxy server application which can captures HTTP and HTTPS traffic and logs it for the user to review. Fiddler can also be used to modify HTTP traffic for troubleshooting purposes as it is being sent or received.
* Charles Proxy - http://www.charlesproxy.com - HTTP proxy / HTTP monitor / Reverse Proxy that enables a developer to view all of the HTTP and SSL / HTTPS traffic between their machine and the Internet.


### IDEs
* IntelliJ - https://www.jetbrains.com/idea/download/ - IntelliJ IDEA is a Java integrated development environment (IDEfor developing computer software.
* Eclipse - https://eclipse.org/ - Eclipse is an integrated development environment (IDEused in computer programming, and is the most widely used Java IDE.
