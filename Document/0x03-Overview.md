# Introduction to the Mobile Security Testing Guide

Technological revolutions can happen quickly. Less than a decade ago, smartphones were clunky devices with little keyboards - expensive playthings for tech-savvy business users. Today, smartphones are an essential part of our lives. We've come to rely on them for information, navigation and communication, and they are ubiquitous both in business and in our social lives.

Apps running on those devices store our personal information, pictures, recordings, notes, account data, business information, location and much more. They act as clients that connect us to services we use on a daily basis, and as communications hubs that processes each and every message we exchange with others. Compromise a person's smartphone and you get unfiltered access to that person's life. When we consider that mobile devices are more readily lost or stolen and mobile malware is on the rise, the need for data protection becomes even more apparent.

Every new technology introduces new security risks, and mobile computing is no different. Even though modern mobile operating systems like iOS and Android are arguably more secure by design compared to traditional Desktop operating systems, there's still a lot of things that can go wrong when security is not considered during the mobile app development process. Data storage, inter-app communication, proper usage of cryptographic APIs and secure network communication are only some of the aspects that require careful consideration.

## Mobile Application Threats

Security concerns in the mobile app space differ from traditional desktop software in some important ways. Firstly, while not many people opt to carry a desktop tower around in their pocket, doing this with a mobile device is decidedly more common. As a consequence, mobile devices are more readily lost and stolen, so adversaries are more likely to get physical access to a device and access any of the data stored. Also leaving a device unattended, which allows adversaries temporary physical access (Evil-Maid attack) can already lead to full compromise of the device or steal data without the owner noticing it.

From the view of a mobile app, this means that extra care has to be taken when storing user data, such as using appropriate key storage APIs and taking advantage of hardware-backed security features when available. Here however we encounter another problem: Much depends on the device and operating system the app is running on, as well as its configuration. Is the keychain locked with a passcode? What if the device doesn't offer hardware-backed secure storage, as is the case with some Android devices? Can and should the app even verify this, or is it the responsibility of the user?

Data stored on mobile devices also differ from the data stored on desktops and laptops. While both are used to access personal information, it is much more likely to find copies of these information on a mobile device. Further, due to the various connectivity options and their portability, mobile devices are used as keys for electronic door locks, replacement for payment cards, etc.

Finally, mobile devices regularly connect to a variety of networks, including public WiFi networks shared with other (possibly malicious) clients. This creates great opportunities for network-based attacks, from simple packet sniffing to creating a rogue access point and going SSL man-in-the-middle (or even old-school stuff like routing protocol injection - those baddies use whatever works).

## OWASP Mobile Top 10 2016
The OWASP Mobile Top 10 is the equivalent counterpart of the OWASP Top Ten Project, but is specifically designed to focus on the mobile application security. Most of the time, folks in the information security industry discuss about the "OWASP Top Ten" project but in fact, they are only referring to the web application security.

In this guide, we bring to your attention about its equivalent counterpart, the OWASP Mobile Top 10 2016, which is essentially an awareness document for mobile application security.

The OWASP Mobile Top 10 represents a broad consensus about what are the most critical mobile application security flaws identified in the actual mobile applications, derived as per the raw data obtained from various different vendors and consultants in the information security industry.

The following are the OWASP Mobile Top 10:

* M1 - Improper Platform Usage<sup>[1]</sup>
  * Misuse of a mobile platform feature or failure to use platform security controls adequately
  * Scope of coverage includes Android intents, platform permissions, misuse of TouchID, the Keychain, or some other security control that is part of the mobile operating system
  * Some examples includes the violation of published guidelines, violation of convention or common practice, and any unintentional misuse
* M2 - Insecure Data Storage<sup>[2]</sup>
  * Insufficient protection mechanisms towards user or app data stored locally in the mobile devices
  * Scope of coverage includes an adversary that has attained a lost or stolen mobile device, malware or a repackaged app acting on the adversary's behalf that executes on the mobile device
  * Data insecurely stored includes files such as SQLite databases, log files, XML files and cookies
* M3 - Insecure Communication<sup>[3]</sup>
  * Insufficient protection mechanisms towards user or app data transmitted over the mobile device's carrier network or the internet
  * Scope of coverage includes an adversary that shares the same Local Area Network (LAN), network devices or malware; and whether defensive mechanisms such as Certificate Pinning has been implemented in the mobile app   
* M4 - Insecure Authentication<sup>[4]</sup>
  * Lack of proper authentication methods and controls
  * Scope of coverage includes the exploitation of authentication vulnerabilities like weak password policy
* M5 - Insufficient Cryptography<sup>[5]</sup>
  * Usage of inadequately strong cryptographic standards, or poor cryptography implementation and usages
  * Scope of coverage includes the cracking of improperly encrypted data through physical access or mobile malware acting on an adversary's behalf
* M6 - Insecure Authorisation<sup>[6]</sup>
  * Lack of proper roles and permissions validation and access rights controls
  * Scope of coverage includes the exploitation of the authorization vulnerabilities like insecure direct object references
* M7 - Poor Code Quality<sup>[7]</sup>
  * Insufficient consistency in coding patterns and lack of proper user data input validations and method calls
  * Scope of coverage includes any plausible endpoints that can pass untrusted inputs to method calls made within the mobile app's code, resulting in potential exploitation via malware or phishing scams
* M8 - Code Tampering<sup>[8]</sup>
  * Lack of runtime checks function that perform app code integrity checks  
  * Scope of coverage includes exploitation through code modification via malicious forms of the apps hosted in third-party app stores. Malicious attacker may also trick the user into installing the app via phishing attacks
* M9 - Reverse Engineering<sup>[9]</sup>
  * Missing obfuscation methods
  * Scope of coverage includes downloading the mobile app from an app store and analyze it within their own local environment using a suite of different tools to identify potential attack vectors
* M10 - Extraneous Functionality<sup>[10]</sup>
  * Lack of logs and endpoints verification prior to publishing the production builds
  * Scope of coverage includes the identification of hidden or extraneous functionality in the backend system or the mobile app itself, and then exploit it directly from their own systems without any involvement by end-users

To read more about the category of vulnerabilities and procedures to prevent them from compromising your mobile application, please refer to the OWASP Mobile Top 2016 Project Page<sup>11</sup>.

## The OWASP Mobile AppSec Verification Standard, Checklist and Testing Guide

This guide belongs to a set of three closely related mobile application security documents. All three documents map to the same basic set of security requirements. Depending on the context, they can be used stand-alone or in combination to achieve different objectives:

* The **Mobile Application Security Verification Standard (MASVS):** A standard that defines a mobile app security model and lists generic security requirements for mobile apps. It can be used by architects, developers, testers, security professionals, and consumers to define what a secure mobile application is.
* The **Mobile Security Testing Guide (MSTG):** A manual for testing the security of mobile apps. It provides verification instructions for the requirements defined in the MASVS along with operating-system-specific best practices (currently for Android and iOS). The MSTG helps ensure completeness and consistency of mobile app security testing. It is also useful as a standalone learning resource and reference guide for mobile application security testers.
* The **Mobile App Security Checklist:** A checklist for tracking compliance against the MASVS during practical assessments. The list conveniently links to the MSTG test case for each requirement, making mobile penetration app testing a breeze.

![Document Overview](Images/Chapters/0x03/owasp-mobile-overview.jpg)

For example, the MASVS requirements could be used in the planning and architecture design stages, while the checklist and testing guide may serve as a baseline for manual security testing or as a template for automated security tests during of after development. In the next chapter, we'll describe how the checklist and guide can be practically applied during a mobile application penetration test.

## Organization of the Mobile Security Testing Guide

All requirements specified in the MASVS are described in technical detail in the testing guide. The main sections of the MSTG are explained briefly in this chapter.

### Testing Process and Techniques

This section explains the checklist and how to use it during project security evaluation. The different analysis techniques used for the test cases are explained like static and dynamic analysis on source code, but also on binaries. An introduction into tampering and reverse engineering is also part of this section.

### Android Testing Guide

-- TODO
The Android chapter of the testing guide contains all technical procedures to verify the requirements of the MASVS on the Android platform.

### iOS Testing Guide

-- TODO
The iOS chapter of the testing guide contains all technical procedures to verify the requirements of the MASVS on the iOS platform.

### Reverse Engineering and Tampering

-- TODO

### Testing Tools

There are various tool that can be used to conduct an effective mobile security test and like any tool of choice it all depends on the matter of preference and budget. An extensive list of tools can be found in "Testing Tools" chapter at the end of this document.

-- TODO [Describe the organization of the current guide] --

## References

* [1] M1 - Improper Platform Usage - https://www.owasp.org/index.php/Mobile_Top_10_2016-M1-Improper_Platform_Usage
* [2] M2 - Insecure Data Storage - https://www.owasp.org/index.php/Mobile_Top_10_2016-M2-Insecure_Data_Storage
* [3] M3 - Insecure Communication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M3-Insecure_Communication
* [4] M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication
* [5] M5 - Insufficient Cryptography - https://www.owasp.org/index.php/Mobile_Top_10_2016-M5-Insufficient_Cryptography
* [6] M6 - Insecure Authorization - https://www.owasp.org/index.php/Mobile_Top_10_2016-M6-Insecure_Authorization
* [7] M7 - Poor Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality
* [8] M8 - Code Tampering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M8-Code_Tampering
* [9] M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering
* [10] M10 - Extraneous Functionality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M10-Extraneous_Functionality
* [11] OWASP Mobile Top 2016 Project Page - https://www.owasp.org/index.php/Mobile_Top_10_2016-Top_10
