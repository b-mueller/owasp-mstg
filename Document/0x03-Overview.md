# Introduction to the OWASP Mobile Security Testing Guide

The OWASP Mobile Security Testing Guide (MSTG) is an extension of the OWASP Testing Project specifically focusing on the security testing of Android and iOS devices.

The goal of this project is to help people understand the what, why, when, where, and how of testing applications on Android and iOS devices. The project delivers a complete suite of test cases designed to address the OWASP Mobile Top 10, the Mobile App Security Checklist and the Mobile Application Security Verification Standard (MASVS).

## Why Does the World Need a Mobile Application Security Testing Guide?

Every new technology introduces new security risks, and mobile computing is no different. Even though modern mobile operating systems like iOS and Android are arguably more secure by design compared to traditional Desktop operating systems, there's still a lot of things that can go wrong when security is not considered during the mobile app development process. Data storage, inter-app communication, proper usage of cryptographic APIs and secure network communication are only some of the aspects that require careful consideration.

Security concerns in the mobile app space differ from traditional desktop software in some important ways. Firstly, while not many people opt to carry a desktop tower around in their pocket, doing this with a mobile device is decidedly more common. As a consequence, mobile devices are more readily lost and stolen, so adversaries are more likely to get physical access to a device and access any of the data stored. Also leaving a device unattended, which allows adversaries temporary physical access (Evil-Maid attack) can already lead to full compromise of the device or steal data without the owner noticing it.

## Key Areas in Mobile AppSec

Many mobile app pentesters have a background in network and web app penetration testing, and a lot of their knowledge is useful in mobile app testing. Practically every mobile app talks to some kind of backend service, and those services are prone to the same kinds of attacks we all know and love. On the mobile app side however, there is only little attack surface for injection attacks and similar attacks. Here, the main focus shifts to data protection both on the device itself and on the network. The following are some of the key areas in mobile app security.

### Local Data Storage

From the view of a mobile app, this extra care has to be taken when storing user data, such as using appropriate key storage APIs and taking advantage of hardware-backed security features when available. Here however we encounter another problem: Much depends on the device and operating system the app is running on, as well as its configuration. Is the keychain locked with a passcode? What if the device doesn't offer hardware-backed secure storage, as is the case with some Android devices? Can and should the app even verify this, or is it the responsibility of the user?

Data stored on mobile devices also differ from the data stored on desktops and laptops. While both are used to access personal information, it is much more likely to find copies of these information on a mobile device. Further, due to the various connectivity options and their portability, mobile devices are used as keys for electronic door locks, replacement for payment cards, etc.

The protection of sensitive data, such as user credentials and private information, is a key focus in mobile security. Firstly, sensitive data can be unintentionally exposed to other apps running on the same device if operating system mechanisms like IPC are used improperly. Data may also unintentionally leak to cloud storage, backups, or the keyboard cache. Additionally, mobile devices can be lost or stolen more easily compared to other types of devices, so an adversary gaining physical access is a more likely scenario.

### Communication with Trusted Endpoints

Mobile devices regularly connect to a variety of networks, including public WiFi networks shared with other (possibly malicious) clients. This creates great opportunities for network-based attacks, from simple packet sniffing to creating a rogue access point and going SSL man-in-the-middle (or even old-school stuff like routing protocol injection - those baddies use whatever works).

It is crucial to maintain confidentiality and integrity of information exchanged between the mobile app and remote service endpoints. At the very least, a mobile app must set up a secure, encrypted channel for network communication using the TLS protocol with appropriate settings. Level 2 lists additional defense-in-depth measure such as SSL pinning.

### Authentication and Session Management

In most cases, user login to a remote service is an integral part of the overall mobile app architecture. Even though most of the logic happens at the endpoint, MASVS defines some basic requirements regarding how user accounts and sessions are managed. The requirements can be easily verified without access to the source code of the service endpoint.

### Interaction with the Mobile Platform

-- [TODO] --

### Code Quality and Exploit Mitigation

-- [TODO] --

### Anti-Tampering and Anti-Reversing

-- [TODO] --

## The OWASP Mobile AppSec Verification Standard, Checklist and Testing Guide

This guide belongs to a set of three closely related mobile application security documents. All three documents map to the same basic set of security requirements. Depending on the context, they can be used stand-alone or in combination to achieve different objectives:

* The **Mobile Application Security Verification Standard (MASVS):** A standard that defines a mobile app security model and lists generic security requirements for mobile apps. It can be used by architects, developers, testers, security professionals, and consumers to define what a secure mobile application is.
* The **Mobile Security Testing Guide (MSTG):** A manual for testing the security of mobile apps. It provides verification instructions for the requirements defined in the MASVS along with operating-system-specific best practices (currently for Android and iOS). The MSTG helps ensure completeness and consistency of mobile app security testing. It is also useful as a standalone learning resource and reference guide for mobile application security testers.
* The **Mobile App Security Checklist:** A checklist for tracking compliance against the MASVS during practical assessments. The list conveniently links to the MSTG test case for each requirement, making mobile penetration app testing a breeze.

![Document Overview](Images/Chapters/0x03/owasp-mobile-overview.jpg)

For example, the MASVS requirements could be used in the planning and architecture design stages, while the checklist and testing guide may serve as a baseline for manual security testing or as a template for automated security tests during of after development. In the next chapter, we'll describe how the checklist and guide can be practically applied during a mobile application penetration test.

## Organization of the Mobile Security Testing Guide

All requirements specified in the MASVS are described in technical detail in the testing guide. The main sections of the MSTG are explained briefly in this chapter.

The guide is organized as follows:

- In the Testing Processes and Techniques Section, we present the mobile app security testing methodology, vulnerability analysis techniques, security testing in the SDLC, and vulnerability analysis techniques.

- The Android Testing Guide covers the everything specific to the Android platform, including security basics, security test cases, and reverse engineering and tampering techniques and preventions.

- The iOS Testing Guide Testing Guide covers everything specific to iOS, including an overview of the iOS OS, security testing, reverse engineering and anti-reversing.

- The appendix presents technical test cases that apply independent of mobile OS, such as authentication and session management, network communications and cryptography. We also include a methodology for assessing software protection schemes.
