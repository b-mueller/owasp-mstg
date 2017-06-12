# General Testing Guide

-- TODO [This chapter is a partial mess. It needs cleanup, editing and rewriting. ] --

## Mobile App Taxonomy

The following section is a brief introduction to the 3 different types of mobile applications, namely the (1) Native App, (2) Hybrid App and (3) Web App. Before we dive into them, it is essential to first understand what a mobile app is.

### Mobile App

The term `mobile app` refers to applications (self-contained computer programs), designed to execute and enhance the functionality of a mobile device. In this guide we will focus on the mobile apps designed to run on Android and iOS operating systems, as cumulatively they take more than 99% of the market share<sup>[12]</sup>. Due to the expansion of these operating systems to other device types, like smart watches, TVs, cars, etc. a more general term `app` is more appropriate. Nevertheless, for historic reasons, both terms are used interchangeably to refer to an application that can run on some of these systems, regardless of the exact device type.

Today, mobile internet usage has surpassed desktop usage for the first time in history and mobile apps are the most widespread kind of applications<sup>[10]</sup>.

### Native App

Most operating systems, including Android and iOS, come with set of high-level APIs that can be used to develop applications specifically for that system. Such applications are called `native` for the system for which they have been developed. Usually, when discussing about `mobile app`, the assumption is that it is a `native app`, that is implemented in a particular programming language for either iOS (Objective-C or Swift) or Android (Java).

Native mobile apps provide fast performance and a high degree of reliability. They usually adhere to the design principles (e.g. Android Design Principles<sup>[13]</sup>), providing a more consistent UI, compared to `hybrid` and `web` apps. Due to their close integration with the operating system, native apps have access to almost every component of the device (camera, sensors, hardware backed key stores, etc.)

Please note that there is a little ambiguity when discussion `native` apps for Android. Namely, Android provides two sets of APIs to develop against, Android SDK and Android NDK. The SDK (or Software Development Kit) is a Java API and is the default API against which applications are built. The NDK (or Native Development Kit) is a C/C++ based API used for developing only parts of the application that require specific optimization, or can otherwise benefit from lower level API. Normally, you can only distribute apps build with the SDK, which potentially can have parts implemented against NDK. Therefore we say that Android `native **apps**` (build against SDK) can have `native **code**` (build against NDK).

Biggest downside of native apps is that they target only one specific platform. To build the same app for both Android and iOS, one needs to maintain two independent code bases.

### Web App

Mobile Web apps, or simply Web apps, are websites designed to look and feel like a native app. They run in a browser and are usually developed in HTML5. Normally, both Android and iOS allow for launcher icons to be created out of bookmarked Web apps, which simply run the default web browser and load the bookmarked app.

Web apps have limited integration with the components of the device and usually have a noticeable difference in performance. Since they typically target multiple platforms, their UI does not follow some of the design principles users are used to. Their biggest advantage is the price for supporting multiple platforms (only slight adaptation in the UI can server well most desktop and mobile operating systems), as well as their flexibility for delivering new content (as they are not delivered over an official application store, which sometimes take weeks to distribute through).

### Hybrid App

Hybrid apps attempt to fill the gap between native and web apps. Namely, hybrid apps are (distributed and executed as) native apps, that have majority of their content implemented on top of web technologies, running in an embedded web browser (web view). As such, hybrid apps inherit some of the pros and cons of both native and web apps.

A web-to-native abstraction layer enables access to device capabilities for hybrid apps that are not accessible to mobile web applications. Depending on the framework used for developing, one code base can result in multiple applications, targeting separate platforms, with a UI closely resembling that of the targeted platform. Nevertheless, usually significant effort is required to exactly match the look and feel of a native app.

Following is a non-exhaustive list of more popular frameworks for developing Hybrid Apps:

* Apache Cordova - https://cordova.apache.org/
* Framework 7 - http://framework7.io/
* Ionic - https://ionicframework.com/
* jQuery Mobile - https://jquerymobile.com/
* Native Script - https://www.nativescript.org/
* Onsen UI - https://onsen.io/
* React Native - http://www.reactnative.com/
* Sencha Touch - https://www.sencha.com/products/touch/

## Mobile App Security Testing

The context of mobile security testing is a conjunction of multiple different tier of components: **app**, **system**, **communication** and **back-end server**. These four high-level components will be the main attack surface for a mobile security test.   

* **App:**  Insecure data storage, poor resiliency against reverse engineering etc.
* **System:** Any system API to which sensitive info is sent. E.g. Tampering with the system HTTP client might give access to the whole communication, even when SSL with certificate pinning is used.
* **Communication:** Usage of insecure or unencrypted communication channel, missing SSL certificate pinning etc.
* **Back-end Servers:** Flawed authentication and session management, vulnerable server side functions etc.

-- TODO --

The following sections will show how to use the OWASP mobile application security checklist and testing guide during a security test.

### Preparation - Defining The Baseline

First of all, you need to decide what security level of the MASVS to test against. The security requirements should ideally have been decided at the beginning of the SDLC - but unfortunately we are not living in an ideal world. At the very least, it is a good idea to walk through the checklist, ideally with an IT security representative of the enterprise, the app stakeholders of the project and make a reasonable selection of Level 2 (L2) controls to cover during the test.

The controls in MASVS Level 1 (L1) are appropriate for all mobile apps - the rest depends on the threat model and risk assessment for the particular app. Discuss with the app stakeholders to understand what are the requirements that are applicable and which are the ones that should be deemed out of scope for the scope of testing, perhaps due to business decisions or company policies. Also consider whether some L2 requirements may be needed due to industry regulations or local laws - for example, 2-factor-authentation (2FA) may be obligatory for a financial app, as enforced by the respective country's central bank and/or financial regulatory authority.

If security requirements were already defined during the SDLC, even better! Ask for this information and document it on the front page of the Excel sheet ("dashboard"). More guidance on the verification levels and guidance on the certification can be found in the [MASVS](https://github.com/OWASP/owasp-masvs).

![Preparation](Images/Chapters/0x03/mstg-preparation.png)

All involved parties need to agree on the decisions made and on the scope in the checklist, as this will present the baseline for all security testing, regardless if done manually or automatically.

#### Identifying Sensitive Data

Classification of sensitive information can vary between different industries and countries. Therefore laws and regulations that are applicable to the app need to be known. This will become the basis of what sensitive information actually is in the context of the app.

Ideally the customer can share a data classification policy that is already considering all different requirements and clearly defines sensitive information. This will become then the baseline during testing. The data classification should be applicable to:

* Data at rest,
* Data in use and
* Data in transit

For example, regulations in Singapore for financial institutions has imposed a requirement to encrypt passwords and PINs explicitly, even though they are already transmitted via HTTPS. Even though this might not be a vulnerability from the point of view of a tester, it is mandatory to raise this finding as a compliance issue.

If no data classification policy is available, the following should be considered as sensitive information:

* User authentication information (credentials, PINs etc.),
* Personal Identifiable Information (PII) that can be abused for identity theft: Social security numbers, credit card numbers, bank account numbers, health information,
* Highly sensitive data that would lead to reputational harm and/or financial costs if compromised,
* Any data that must be protected by law or for compliance reasons.
* Finally any technical data, generated by the application or it's related systems, that is used to protect other data or the system, should also be considered as sensitive information (e.g. encryption keys).

Defining sensitive information before the test is important for almost all data storage test cases in Android and iOS, as otherwise the tester has no clear basis on what he might need to look for.

### Vulnerability Analysis

#### Static Analysis

When executing a static analysis, the source code of the mobile App(s) will be analyzed to ensure sufficient and correct implementation of security controls, specifically on crucial components such as cryptographic and data storage mechanisms. Due to the amount of code a tester will be confronted with, the ideal approach for static analysis should be a mixture of using tools that scan the code automatically and manual code review.

Through this approach you can get the best out of both worlds. You can get the so called "low hanging fruits" through the automatic scan, as the scanning engine and the (predefined) rules can easily pick up vulnerable patterns in the code. The manual code review can proficiently make a deep dive into the various code paths to check for logical errors and flaws in the mobile application's design and architecture where automated analysis tools are not able to identify it properly as they mostly do not understand the big picture.

#### Automatic Code Analysis

During an automatic static analysis, a tool will check the source code for compliance with a predefined set of rules or industry's best practices. It has been a standard development practice to use analytical methods to review and inspect the mobile application's source code to detect bugs and implementation errors.

The automatic static analysis tools will provide assistance with the manual code review and inspection process. The tool will typically display a list of findings or warnings and then flag all the instances which contains any forms of violations in terms of their programming standards. Automatic static tools come in different variations, some are only running when you can actually build the app, some just need to be feed with the source code and some are running as plugin in an Integrated Development Environments (IDE)<sup>[7] [8]</sup>. The latter one provides assistance within your IDE in improving the security mechanisms in the mobile application code through a programmer-assisted way to correct the issues found. Ideally these tools should be used during the development process, but can also be useful during a source code review.

Some static code analysis tools encapsulate deep knowledge of the underlying rules and semantics required to perform the specific type of analysis, but still require a professional to identify if it's a false positive or not.

It should be noted that automatic static analysis can produce a high number of false positives, if the tool is not configured properly to the target environment. Executing the scan only for certain vulnerability classes might be a good decision for the first scan to not get overwhelmed with the results.

In the role of a penetration testing engagement, the use of automatic code analysis tools can be very handy as it could quickly and easily provide a first-level analysis of source code, to identify the low hanging fruits before diving deeper into the more complicated functions, where it is essential to thoroughly assess the method of implementation in varying contexts.

A full list of tools for static analysis can be found in the chapter "Testing tools".

#### Manual Code Analysis

In manual code analysis, a human code reviewer will be looking through the source code of the mobile application, to identify security vulnerabilities. This can be as basic as from crawling the code by executing grep on key words within the source code repository to identify usages of potentially vulnerable code patterns, to the usage of an Integrated Development Environment (IDE). An IDE provides basic code review functionality and can be extend through different tools to assist in reviewing process.

During a manual code review, the code base will be scanned to look for key indicators wherein a possible security vulnerability might reside. This is also known as "Crawling Code"<sup>[9]</sup> and will be executed by looking for certain keywords used within functions and APIs. For example, cryptographic strings like DES, MD5 or Random, or even database related strings like executeStatement or executeQuery are key indicators which are of interest in the process of crawling code.

The main difference between a manual code review and the use of any automatic code analysis tools is that in manual code review, it is better at identifying vulnerabilities in the business logic, standards violations and design flaws, especially in the situations where the code is technically secure but logically flawed. In such scenarios, the code snippet will not be detected by any automatic code analysis tool as an issue.

A manual code review requires an expert human code reviewer who is proficient in both the language and the frameworks used in the mobile application. This is essential to have a deep understanding of the security implementation of the technologies used in the mobile application's source code. As a result it can be time consuming, slow and tedious for the reviewer; especially when mobile application source code has a large number of lines of code.

#### Dynamic Analysis

In a Dynamic Analysis approach, the focus is on testing and evaluation of an app by executing it in a real-time manner, under different stimuli. The main objective of a dynamic analysis is to find the security vulnerabilities or weak spots in a program while it is running. Dynamic analysis is conducted against the backend services and APIs of mobile applications, where its request and response patterns would be analysed.

Usually, dynamic analysis is performed to check whether there are sufficient security mechanisms being put in place to prevent disclosure of data in transit, authentication and authorization issues, data validation vulnerabilities (e.g. cross-site scripting, SQL injection, etc.) and server configuration errors.

##### Pros of Dynamic Analysis

* Does not require to have access to the source code
* Does not need to understand how the mobile application is supposed to behave
* Able to identify infrastructure, configuration and patch issues that Static Analysis approach tools will miss

##### Cons of Dynamic Analysis

* Limited scope of coverage because the mobile application must be footprinted to identify the specific test area
* No access to the actual instructions being executed, as the tool is exercising the mobile application and conducting pattern matching on the requests and responses

#### Runtime Analysis

-- TODO [Describe Runtime Analysis : goal, how it works, kind of issues that can be found] --

#### Traffic Analysis

Dynamic analysis of the traffic exchanged between client and server can be performed by launching a Man-in-the-middle (MITM) attack. This can be achieved by using an interception proxy like Burp Suite or OWASP ZAP for HTTP traffic.  

* Configuring an Android Device to work with Burp - https://support.portswigger.net/customer/portal/articles/1841101-configuring-an-android-device-to-work-with-burp
* Configuring an iOS Device to work with Burp - https://support.portswigger.net/customer/portal/articles/1841108-configuring-an-ios-device-to-work-with-burp

In case another (proprietary) protocol is used in a mobile app that is not HTTP, the following tools can be used to try to intercept or analyze the traffic:
* Mallory - https://github.com/intrepidusgroup/mallory
* Wireshark - https://www.wireshark.org/

#### Input Fuzzing

The process of fuzzing is to repeatedly feeding an application with various combinations of input value, with the goal of finding security vulnerabilities in the input-parsing code. There were instances when the application simply crashes, but also were also occations when it did not crash but behave in a manner which the developers did not expect them to be, which may potentially lead to exploitation by attackers.  

Fuzz testing, is a method for testing software input validation by feeding it intentionally malformed input. Below are the steps in performing the fuzzing:

* Identifying a target
* Generating malicious inputs
* Test case delivery
* Crash monitoring

Also refer to the OWASP Fuzzing guide - https://www.owasp.org/index.php/Fuzzing

Note: Fuzzing only detects software bugs. Classifying this issue as a security flaw requires further analysis by the researcher.

### Eliminating Common False Positives

-- [TODO] --

#### Cross-Site Scripting (XSS)

A typical reflected XSS attack is executed by sending a URL to the victim(s), which for example can contain a payload to connect to some exploitation framework like BeeF<sup>[2]</sup>. When clicking on it a reverse tunnel is established with the Beef server in order to attack the victim(s). As a WebView is only a slim browser, it is not possible for a user to insert a URL into a WebView of an app as no address bar is available. Also, clicking on a link will not open the URL in a WebView of an app, instead it will open directly within the default browser of the respective mobile device. Therefore, a typical reflected Cross-Site Scripting attack that targets a WebView in an app is not applicable and will not work.

If an attacker finds a stored Cross-Site Scripting vulnerability in an endpoint, or manages to get a Man-in-the-middle (MITM) position and injects JavaScript into the response, then the exploit will be sent back within the response. The attack will then be executed directly within the WebView. This can become dangerous in case:

* JavaScript is not deactivated in the WebView (see OMTG-ENV-005)
* File access is not deactivated in the WebView (see OMTG-ENV-006)
* The function addJavascriptInterface() is used (see OMTG-ENV-008)

As a summary, a reflected Cross-Site Scripting is no concern for a mobile App, but a stored Cross-Site Scripting or injected JavaScript through MITM can become a dangerous vulnerability if the WebView in used is configured insecurely.

#### Cross-Site Request Forgery (CSRF)

The same problem described with reflected XSS also applied to CSRF attacks. A typical CSRF attack is executed by sending a URL to the victim(s) that contains a state changing request like creation of a user account or triggering a financial transaction. As a WebView is only a slim browser it is not possible for a user to insert a URL into a WebView of an app and also clicking on a link will not open the URL in a WebView of an App. Instead it will open directly within the browser of Android. Therefore a typical CSRF attack that targets a WebView in an app is not applicable.

The basis for CSRF attacks, access to session cookies of all browser tabs and attaching them automatically if a request to a web page is executed is not applicable on mobile platforms. This is the default behaviour of full blown browsers. Every app has, due to the sandboxing mechanism, it's own web cache and stores it's own cookies, if WebViews are used. Therefore a CSRF attack against a mobile app is by design not possible as the session cookies are not shared with the Android browser.

Only if a user logs in by using the Android browser (instead of using the mobile App) a CSRF attack would be possible, as then the session cookies are accessible for the browser instance.

## Tampering and Reverse Engineering

In the context of mobile apps, reverse engineering is the process of analyzing the compiled app to extract knowledge about its inner workings. It is akin to reconstructing the original source code from the bytecode or binary code, even though this doesn't need to happen literally. The main goal in reverse engineering is *comprehending* the code.

*Tampering* is the process of making changes to a mobile app (either the compiled app, or the running process) or its environment to affect its behavior. For example, an app might refuse to run on your rooted test device, making it impossible to run some of your tests. In cases like that, you'll want to alter that particular behavior.

Reverse engineering and tampering techniques have long belonged to the realm of crackers, modders, malware analysts, and other more exotic professions. For "traditional" security testers and researchers, reverse engineering has been more of a complementary, nice-to-have-type skill that wasn't all that useful in 99% of day-to-day work. But the tides are turning: Mobile app black-box testing increasingly requires testers to disassemble compiled apps, apply patches, and tamper with binary code or even live processes. The fact that many mobile apps implement defenses against unwelcome tampering doesn't make things easier for us.

Mobile security testers should be able to understand basic reverse engineering concepts. It goes without saying that they should also know mobile devices and operating systems inside out: the processor architecture, executable format, programming language intricacies, and so forth.

Reverse engineering is an art, and describing every available facet of it would fill a whole library. The sheer range of techniques and possible specializations is mind-blowing: One can spend years working on a very specific, isolated sub-problem, such as automating malware analysis or developing novel de-obfuscation methods. Security testers are generalists: To be effective reverse engineers, they must be able filter through the vast amount of information to build a workable methodology.

There is no generic reverse engineering process that always works. That said, we'll describe commonly used methods and tools later on, and give examples for tackling the most common defenses.

### Why You Need It

Mobile security testing requires at least basic reverse engineering skills for several reasons:

**1. To enable black-box testing of mobile apps.** Modern apps often employ technical controls that will hinder your ability to perform dynamic analysis. SSL pinning and end-to-end (E2E) encryption sometimes prevent you from intercepting or manipulating traffic with a proxy. Root detection could prevent the app from running on a rooted device, preventing you from using advanced testing tools. In this cases, you must be able to deactivate these defenses.

**2. To enhance static analysis in black-box security testing.** In a black-box test, static analysis of the app bytecode or binary code is helpful for getting a better understanding of what the app is doing. It also enables you to identify certain flaws, such as credentials hardcoded inside the app.

**3. To assess resilience against reverse engineering.**  Apps that implement the software protection measures listed in MASVS-R should be resilient against reverse engineering to a certain degree. In this case, testing the reverse engineering defenses ("resiliency assessment") is part of the overall security test. In the resilience assessment, the tester assumes the role of the reverse engineer and attempts to bypass the defenses.

Before we dive into the world of mobile app reversing, we have some good news and some bad news to share. Let's start with the good news:

**Ultimately, the reverse engineer always wins.**

This is even more true in the mobile world, where the reverse engineer has a natural advantage: The way mobile apps are deployed and sandboxed is more restrictive by design, so it is simply not feasible to include the rootkit-like functionality often found in Windows software (e.g. DRM systems). At least on Android, you have a much higher degree of control over the mobile OS, giving you easy wins in many situations (assuming you know how to use that power). On iOS, you get less control - but defensive options are even more limited.

The bad news is that dealing with multi-threaded anti-debugging controls, cryptographic white-boxes, stealthy anti-tampering features and highly complex control flow transformations is not for the faint-hearted. The most effective software protection schemes are highly proprietary and won't be beaten using standard tweaks and tricks. Defeating them requires tedious manual analysis, coding, frustration, and - depending on your personality - sleepless nights and strained relationships.

It's easy to get overwhelmed by the sheer scope of it in the beginning. The best way to get started is to set up some basic tools (see the respective sections in the Android and iOS reversing chapters) and starting doing simple reversing tasks and crackmes. As you go, you'll need to learn about the assembler/bytecode language, the operating system in question, obfuscations you encounter, and so on. Start with simple tasks and gradually level up to more difficult ones.

In the following section we'll give a high level overview of the techniques most commonly used in mobile app security testing. In later chapters, we'll drill down into OS-specific details for both Android and iOS.

### Basic Tampering Techniques

#### Binary Patching

*Patching* means making changes to the compiled app - e.g. changing code in binary executable file(s), modifying Java bytecode, or tampering with resources. The same process is known as *modding* in the mobile game hacking scene. Patches can be applied in any number of ways, from decompiling, editing and re-assembling an app, to editing binary files in a hex editor - anything goes (this rule applies to all of reverse engineering). We'll give some detailed examples for useful patches in later chapters.

One thing to keep in mind is that modern mobile OSes strictly enforce code signing, so running modified apps is not as straightforward as it used to be in traditional Desktop environments. Yep, security experts had a much easier life in the 90s! Fortunately, this is not all that difficult to do if you work on your own device - it simply means that you need to re-sign the app, or disable the default code signature verification facilities to run modified code.

#### Code Injection

Code injection is a very powerful technique that allows you to explore and modify processes during runtime. The injection process can be implemented in various ways, but you'll get by without knowing all the details thanks to freely available, well-documented tools that automate it. These tools give you direct access to process memory and important structures such as live objects instantiated by the app, and come with many useful utility functions for resolving loaded libraries, hooking methods and native functions, and more. Tampering with process memory is more difficult to detect than patching files, making in the preferred method in the majority of cases.

Substrate, Frida and XPosed are the most widely used hooking and code injection frameworks in the mobile world. The three frameworks differ in design philosophy and implementation details: Substrate and Xposed focus on code injection and/or hooking, while Frida aims to be a full-blown "dynamic instrumentation framework" that incorporates both code injection and language bindings, as well as an injectable JavaScript VM and console.

However, you can also instrument apps with Substrate by using it to inject Cycript, the programming environment (a.k.a. "Cycript-to-JavaScript" compiler) authored by Saurik of Cydia fame. To complicate things even more, Frida's authors also created a fork of Cycript named "frida-cycript" that replaces Cycript's runtime with a Frida-based runtime called Mjølner<sup>[17]</sup>. This enables Cycript to run on all the platforms and architectures maintained by frida-core (if you are confused now don't worry, it's perfectly OK to be).

The release was accompanied by a blog post by Frida's developer Ole titled "Cycript on Steroids", which did not go that down that well with Saurik<sup>[18]</sup>.

We'll include some examples for all three frameworks. As your first pick, we recommend starting with Frida, as it is the most versatile of the three (for this reason we'll also include more Frida details and examples). Notably, Frida can inject a Javascript VM into a process on both Android and iOS, while Cycript injection with Substrate only works on iOS. Ultimately however, you can of course achieve many of the same end goals with either framework.

### Static and Dynamic Binary Analysis

Reverse engineering is the process of reconstructing the semantics of the original source code from a compiled program. In other words, you take the program apart, run it, simulate parts of it, and do other unspeakable things to it, in order to understand what it is doing and how.

#### Using Disassemblers and Decompilers

Disassemblers and decompilers allow you to translate an app binary code or byte-code back into a more or less understandable format. In the case of native binaries, you'll usually obtain assembler code matching the architecture which the app was compiled for. Android Java apps can be disassembled to Smali, which is an assembler language for the dex format used by dalvik, Android's Java VM. The Smali assembly is also quite easily decompiled back to Java code.

A wide range of tools and frameworks is available: from expensive but convenient GUI tools, to open source disassembling engines and reverse engineering frameworks. Advanced usage instructions for any of these tools often easily fill a book on their own. The best way to get started though is simply picking a tool that fits your needs and budget and buying a well-reviewed user guide along with it. We'll list some of the most popular tools in the OS-specific "Reverse Engineering and Yampering" chapters.

#### Debugging and Tracing

In the traditional sense, debugging is the process of identifying and isolating problems in a program as part of the software development lifecycle. The very same tools used for debugging are of great value to reverse engineers even when identifying bugs is not the primary goal. Debuggers enable suspending a program at any point during runtime, inspect the internal state of the process, and even modify the content of registers and memory. These abilities make it *much* easier to figure out what a program is actually doing.

When talking about debugging, we usually mean interactive debugging sessions in which a debugger is attached to the running process. In contrast, *tracing* refers to passive logging of information about the app's execution, such as API calls. This can be done in a number of ways, including debugging APIs, function hooks, or Kernel tracing facilities. Again, we'll cover many of these techniques in the OS-specific "Reverse Engineering and Yampering" chapters.

### Advanced Techniques

For more complicated tasks, such as de-obfuscating heavily obfuscated binaries, you won't get far without automating certain parts of the analysis. For example, understanding and simplifying a complex control flow graph manually in the disassembler would take you years (and most likely drive you mad, way before you're done). Instead, you can augment your workflow with custom made scripts or tools. Fortunately, modern disassemblers come with scripting and extension APIs, and many useful extensions are available for popular ones. Additionally, open-source disassembling engines and binary analysis frameworks exist to make your life easier.

Like always in hacking, the anything-goes-rule applies: Simply use whatever brings you closer to your goal most efficiently. Every binary is different, and every reverse engineer has their own style. Often, the best way to get to the goal is to combine different approaches, such as emulator-based tracing and symbolic execution, to fit the task at hand. To get started, pick a good disassembler and/or reverse engineering framework and start using them to get comfortable with their particular features and extension APIs. Ultimately, the best way to get better is getting hands-on experience.

#### Dynamic Binary Instrumentation

Another useful method for dealing with native binaries is dynamic binary instrumentations (DBI). Instrumentation frameworks such as Valgrind and PIN support fine-grained instruction-level tracing of single processes. This is achieved by inserting dynamically generated code at runtime. Valgrind compiles fine on Android, and pre-built binaries are available for download.

The Valgrind README contains specific compilation instructions for Android - http://valgrind.org/docs/manual/dist.readme-android.html

#### Emulation-based Dynamic Analysis

Running an app in the emulator gives you powerful ways to monitor and manipulate its environment. For some reverse engineering tasks, especially those that require low-level instruction tracing, emulation is the best (or only) choice. Unfortunately, this type of analysis is only viable for Android, as no emulator for iOS exists (the iOS simulator is not an emulator, and apps compiled for an iOS device don't run on it). We'll provide an overview of popular emulation-based analysis frameworks for Android in the "Tampering and Reverse Engineering on Android" chapter.

#### Custom Tooling using Reverse Engineering Frameworks

Even though most professional GUI-based disassemblers feature scripting facilities and extensibility, they sometimes simply not well-suited to solving a particular problem. Reverse engineering frameworks allow you perform and automate any kind of reversing task without the dependence for heavy-weight GUI, while also allowing for increased flexibility. Notably, most reversing frameworks are open source and/or available for free. Popular frameworks with support for mobile architectures include Radare2<sup>[4]</sup> and Angr <sup>[5]</sup>.

##### Example: Program Analysis using Symbolic / Concolic Execution

In the late 2000s, symbolic-execution based testing has gained popularity as a means of identifying security vulnerabilities. Symbolic "execution" actually refers to the process of representing possible paths through a program as formulas in first-order logic, whereby variables are represented by symbolic values, which are actually entire ranges of values. Satisfiability Modulo Theories (SMT) solvers are used to check satisfiability of those formulas and provide a solution, including concrete values for the variables needed to reach a certain point of execution on the path corresponding to the solved formula.

Typically, this approach is used in combination with other techniques such as dynamic execution (hence the name concolic stems from *conc*rete and symb*olic*), in order to tone down the path explosion problem specific to classical symbolic execution. This together with improved SMT solvers and current hardware speeds, allow concolic execution to explore paths in medium size software modules (i.e. in the order of 10s KLOC). However, it also comes in handy for supporting de-obfuscation tasks, such as simplifying control flow graphs. For example, Jonathan Salwan and Romain Thomas have shown how to reverse engineer VM-based software protections using Dynamic Symbolic Execution (i.e., using a mix of actual execution traces, simulation and symbolic execution)<sup>[6]</sup>.

In the Android section, you'll find a walkthrough for cracking a simple license check in an Android application using symbolic execution.

## Security Testing in the Software Development Lifecycle

The history of software development is not that old after all, and it is easy to see that, rapidly, teams have stopped developing programs without any framework: we have all experienced the fact that, as the number of lines of code grows, a minimal set of rules are needed in order to keep work under control, meet deadlines, quality and budgets.

In the past, the most widely adopted methodologies were from the "Waterfall" family: development was done from a starting point to a final one, going through several steps, each of them happening one after the other in a predefined sequence. In case something was wrong during a given phase and something had to be changed in a former phase, it was possible to go only one step backward. This was a serious drawback of Waterfall methodologies. Even if they have strong positive points (bring structure, clarify where to put effort, clear and easy to understand, ...), they also have negative ones (creation of silos, slow, specialized teams, ...).

As time was passing and software development was maturing, also competition was getting stronger and stronger, and a need to react faster to market changes while creating software products with smaller budgets rose. The idea of having fewer structure with smaller teams collaborating together, breaking silos through the organization from marketing to production, became popular. The "Agile" concept was born (well known examples of Agile implementations are Scrum, XP and RAD), which was enabling more autonomous teams to work together in a faster manner.

Originally, security was not part of software development. It was seen as an afterthought, and was performed by Operation teams at the network level: those teams had to find ways to compensate for poor security in software programs! However, while this was possible when software programs were located inside a perimeter, the concept became obsolete as new ways to consume software emerged with Web and Mobile technologies. Nowadays, security has to be baked **inside** software as it is often very hard in this new paradigm to compensate for existing vulnerabilities.

The way to incorporate security during software development is to put in place a Secure SDLC (Software Development Life Cycle). A Secure SDLC does not depend on any methodology nor on any language, and it is possible to incorporate one in Waterfall or Agile: no excuse not to use one! This chapter will focus on Agile and Secure SDLC, in particular in the DevOps world. The reader will find below details on state-of-the-art ways to develop and deliver secure software in a fast-paced and collaborative manner that promotes autonomy and automation.

### Agile and DevOps

#### DevOps

DevOps refers to practices that focus on a close collaboration between all stakeholders involved in delivering software. DevOps is the logical evolution of Agile in that it enables software to be released to users as rapidly as possible. Besides the collaboration aspect, to a large extent, this is facilitated through heavy automation of the build, test and release process of software and infrastructure changes. This automation is embodied in the deployment pipeline.

##### -- Todo [Add deployment pipeline overview and description specific for mobile apps.] --

The term DevOps might be mistaken for only expressing collaboration between development and operations teams, however, as Gene Kim, a DevOps thought leader, puts it: “At first blush, it seems as though the problems are just between dev and ops," he says, "but test is in there, and you have information security objectives, and the need to protect systems and data. These are top-level concerns of management, and they have become part of the DevOps picture."

In other words, when you hear "DevOps" today, you should probably be thinking DevOpsQATestInfoSec.”<sup>[16]</sup>

Security is just as important for the business success as the overall quality, performance and usability of an application. As development cycles are shortened and deployment frequencies increased it is elementary to ensure that quality and security is built in from the very beginning.

From the human aspect, this is achieved by creating cross functional teams that work together on achieving business outcomes. This section is going to focus on the interaction with and integration of security into the development life cycle, from the inception of requirements, all the way until the value of the change is made available to users.

### General Considerations

* Release time for Apple store
* What are black listed, and how to avoid it
* Common gotchas: Ensure that the app is always fully removed and re-installed. Otherwise there might be issues that are hard to reproduce

### SDLC Overview

#### General description of SDLC

Whatever the development methodology that is being used, a SDLC always follows the same process:

* Perform a risk assessment of the application and it's components to identify their risk profile. This risk profile typically depends on the risk appetite of the organization and the regulatory requirements for the application in scope. The risk assessment is additionally influenced by other factors such as whether the application is accessible from the internet, or what kind of data is processed and stored. A data classification policy determines which data is considered sensitive and prescribes how this data has to be secured.
* At the beginning of a project or a development cycle, at the same time when functional requirements are gathered, **Security Requirements** are listed and clarified. As use cases are built, **Abuse Cases** are added. Also, **Security Risks** are analysed, the same way other risks of the project (financial, marketing, industrial, ...) are handled. Teams (including development teams) may be trained on security if needed (Secure Coding, ...);
* For mobile applications the OWASP MASVS [todo: link to the other guide] can be leveraged to determine the security requirements based on the risk assessment that was conducted in this initial step. It is common, especially for agile projects, to iteratively review the set of requirements based on newly added features and new classes of data that is handled by the application.
* Then, as architecture and design are ongoing, a foundational artefact must be performed: **Threat Modeling**. Based on the threat model, the **Security Architecture** is defined (both for software and hardware aspects). **Secure Coding rules** are established and the list of **Security tools** that will be used is created. Also, the strategy for **Security testing** is clarified;
* All security requirements and design considerations should be stored in the Application Life cycle Management System (ALM), which is typically known as issue tracker, that the development/ops team already uses to ensure that security requirements are tightly integrated into the development workflow. The security requirements should ideally also contain the relevant source code snippets for the used programming language, to ensure that developers can quickly reference them. Another strategy for secure coding guidelines is to create a dedicated repository under versioning control, that only contains these ode snippets, which has many benefits over the traditional apporach of storing these guidelines in word documents or PDFs.
* The next step is to develop software, including **Code Reviews** (usually with peers), **Static Analysis** with automated tools and **Unit Tests** dedicated to security;
* Then comes the long-awaited moment to perform tests on the release candidate: **Penetration Testing** ("Pentests"), using both manual and automated techniques;
* And finally, after software has been **Accredited** by all stakeholders, it can be transitioned to Operation teams and safely put in Production.

The picture below shows all the phases with the different artefacts:
-- TODO [Add a picture of a SDLC diagram that clarifies the description above] --

Based on the risks of the project, some artefacts may be simplified (or even skipped) while others may be added (formal intermediary approvals, documentation of certain points, ...). **Always keep in mind a SDLC is meant to bring risk reduction to software development and is a framework that helps put in place controls that will reduce those risks to an acceptable level. ** While this is a generic description of SDLC, always tailor this framework to the needs of your projects.

#### Diving into phases and artefacts

Now, let's have a closer look at the five phases listed above and let's clarify their main purposes, what is done while they take place and who performs them:

* **Initiation** phase: this is the first phase of a project, when requirements are gathered from the field and defined for the project. They should include both functional (e.g. what features will be created for the end user) and security (e.g. what security features will need to be implemented to allow end users to trust the software product) requirements. In this phase, all activities that need to happen before technical work starts and all others that can be anticipated will take place. This is also the moment when Proof of Concepts may be done and when the project viability is confirmed. Typically, teams close to business functions such as marketing (marketing people, or product owners, ...), management and finance are involved.
* **Architecture and Design** phase: after the project has been confirmed, the technical team will start working on early technical activities that will enable coding teams to be productive. In this matter, risks are analysed and relevant countermeasures identified and clarified. The architecture and coding approach as well as testing strategies and the appropriate tools are confirmed, and the different environnements (e.g. DEV, QA, SIT, UAT, PROD) are created and put in place. This phase is pivotal as its main goal is to go from a non-technical definition of needs to the point where technical teams are ready to give birth to code that will make up the software product. Typically, Architects, Designers, QA teams, Testers and AppSec experts are involved.
* **Coding** phase: this is the moment when code is produced and efforts become visible. This may be seen as the most important phase; however, one must keep in mind that all activities happening before and after the current phase are meant to support code creation and make sure it reaches proper standards for quality and security while meeting deadlines and budgets. In this phase, development teams work in the defined environnement to implement requirements following previously defined guidelines. The main people who are involved are developers.
* **Testing** phase: this is the phase when produced software is tested. As testing can take many forms (see detailed section on Security Testing in the SDLC below), testing activities may be performed during coding (the obvious goal being to discover issues as soon as possible). Depending on organizations, the project risk profile and techniques used, testing teams may be independent from coding teams. The main people involved during this phase are Testers. Test cases should exist that map tightly to the established security requirements and that are ideally presented in a way that allows codification and subsequently automated verification.
* **Release** phase: at this point of time, code has been created and tested. Its security level has been assessed; often, metrics are produced to support evidence that code meets the expected level of security. However, it now has to be transitioned to the Customer, e.g. it has to be accepted by stakeholders (Management, Marketing, ...) as able to create value on the market and be of economical interest to Customers; next to that, it will be made available to the market. It is not enough to produce secure software, but it now has to be safely transitioned to Production environnements, which in turn must be secured (both in the short term and in the long term); documentation for Operation teams may be created. In this phase, stakeholders (Management, Marketing, ...) are first involved, as well as technical teams (Testing, Operations, Quality, ...).

Even if the previous description seems to be "Waterfall-like", it also applies to Agile methodologies: the same logic is used, but in a more iterative manner. Some activities may be done only once (for instance project initiation), however smaller parts of similar activities will happen regularly all along the project (like bringing new requirements into light and clarifying them into user stories). In the same manner, testing will not happen only once at the end of a project, but, on each iteration, tests will focus on the amount of code that was produced in the iteration. This in-cycle testing is preferred over the out-of-cycle approach, because the longer it takes for developers to receive feedback, the more time it will take them to make the context switch.

### Security Testing in the SDLC

#### Overview

A well-known statement in software development (and many other fields as well) is that the sooner tests take place, the easier and more cost-effective it is to fix a defect. The same applies to defects related to cyber security: identifying (and fixing) vulnerabilities early in the development life cycle gives better results when it comes to produce secure software. In some ways, Quality Testing and Security Testing may share common aspects as both are meant to raise customer satisfaction.

Testing can be performed in many forms during the life cycle: using automated tools like Static Analysis, writing Unit Tests as code is being created, running Penetration Tests (either manually or with the help of scanning tools) after software has been developed. However, an emphasis should always be put on planning and preparing these efforts early in the Secure SDLC: a Test Plan should be initiated and developed at the beginning of the project, listing and clarifying the kind of tests that will be executed, their scope, how and when they will take place and with what budget. Also, abuse cases should be written early in the project (ideally at the same time when use cases are created) to provide guidance to test teams all along development. Finally, an artefact that should always be considered is Threat Modeling, which allow teams to focus on the right components in the architecture with the proper tests and proper coverage to ensure that the security controls have been implemented correctly.

The following diagram provides an overview of the way to perform test in the SDLC:

-- TODO [Add diagram to summarize the above paragraph and clarify the way test should be performed (planned, executed and reviewed)] --

#### Detailed Description

As stated before, several kinds of tests can be made along the SDLC. According to the risk profile of the targeted software, several kind of tests can be performed:

* **Analysis**: by nature, static analysis is about analysing source code without running it. The goal of this artefact is twofold: make sure the Secure Coding rules the team has agreed on are correctly implemented when writing code, and finding vulnerabilities. Often, specialized software tools are used to automate this task, as hundreds and thousands of lines of code may need to be analysed. However, the drawback is that tools can only find what they have been told to look for and, today, are not as successful as human beings. This is the reason why sometimes Static Analysis is performed by humans (in addition to tools or not): it may take more time for humans, but they have a more creative way to detect vulnerabilities. Examples of tools for Static Analysis are given in another section.
* **Unit Tests**: unit tests make up the family of tests that are the closest to source code (e.g. they are focused on a single unit) as they are performed along with code. According to the methodology in use, they can be created either before code is developed (known as Test Driven Development (TDD)) or right after. Whatever the case, the end goal is to verify that produced code is behaving as expected, but also that proper controls are put in place to prevent abuse cases (input filtering / validation, whitelisting, ...) and cannot be circumvented. Unit Tests are used to detect issues early in the development life cycle in order to fix them as quickly and effectively as possible. They are different from other forms of tests, like Integration / Verification / Validation tests, and may not be used to detect the same kind of issue. Often, Unit Tests are aided with tools; a few of them are listed in another section.
* **Penetration Testing**: this is the "king" of security tests, the one that is the most famous and often performed. However, one must keep in mind that they happen late in the development life cycle and that they cannot find every kind of flaw. They are too often constrained by available resources (time, money, expertise, ...), and as such should be complemented by other kind of tests. The current guide is about pentesting, and the reader will find a lot of useful information to conduct added-value tests and find even more vulnerabilities. Pentesting techniques include vulnerability scanning and fuzzing; however, Penetration Tests can be much more multi-facetted than these two examples. Useful tools are listed in another section.

A clear difference shall be made between quality testing and security testing: while quality testing is about making sure an explicitely planned feature has been implemented in the proper way, security testing is about making sure that:

* existing features cannot be used in a malicious way
* no new feature has unvoluntarily been introduced that could endanger the system or its users.

As a consequence, performing one type of tests is not enough to pretend having covered both types and that the produced software is both usable and secure. The same care should be given to both types of tests as they are of the same importance and that final users now put a strong emphasis both on quality (e.g. the fact features that are brought to them perform the way they expect them to) and security (e.g. that they can trust the software vendor that their money will not be stolen or their private life will remain private).

#### Defining a Test Strategy

The purpose of a test strategy is to define which tests will be performed all along the SDLC and how often. Its goal is twofold: make sure security objectives are met by the final software product, which are generally expressed by customers/legal/marketing/corporate teams, while being cost-effective. The test strategy is generally created at the beginning of a project, after risks have been clarified (Initiation phase) but before code production (Coding phase) starts. It generally takes place during the Architecture and Design phase. It takes inputs from activities such as Risk Management, Threat Modeling, Security Engineering, etc.

-- TODO [Add diagram (in the form of a workflow) showing inputs of a Test Strategy, and outputs (test cases, ...)] --

A Test Strategy does not always need to be formally written: it may be described through Stories (in Agile projects), quickly written in the form of checklists, or test cases could be written in a given tool; however, it definitely needs to be shared, as it may be defined by the Architecture team, but will have to be implemented by other teams such as Development, Testing, QA. Moreover, it needs to be agreed upon by all technical teams as it should not place unacceptable burdens on any of them.

Ideally, a Test Strategy addresses topics such as:

* Objectives to be met and description of risks to be put under control.
* How these objectives will be met and risks reduced to an acceptable level: which tests will be mandatory, who will perform them, how, when, and at which frequency.
* Acceptance criteria of the current project.

In order to follow its effectiveness and progress, metrics should be defined, updated all along the project and periodically communicated. An entire book could be written on the relevant metrics to choose; the best that can be said is that they depend on risk profiles, projects and organizations. However, some examples of metrics include:

* The number of stories related to security controls that are implemented,
* Code coverage for unit tests on security controls and sensitive features,
* The number of security bugs found by static analysis tools upon each build,
* The trend of the backlog for security bugs (may be sorted by criticality).

These are only suggestions, and other metrics may be even more relevant in your case. Metrics are really powerful tools to get a project under control, provided they give a clear view and in a timely manner to project managers on what is happening and what needs to be improved to reach targets.

### Team management

-- TODO [Develop content on Team Management in SDLC] --

* explain the importance of Separation of Duties (developers VS testers, ...)
* internal VS sub-contracted pentests

### Security Testing in DevOps Environments

#### Overview

As the frequency of deployments to production increases, and DevOps high-performers deploy to production many times a day, it is elementary to automated as many of the security verification tasks as possible. The best approach to facilitate that is by integrating security into the deployment pipeline. A deployment pipeline is a combination of continuous integration and continous delivery practices, which have been created to facilitate rapid development and receive almost instantaneous feedback upon every commit. More details on the deployment pipeline are provided in the section below.

#### The Deployment Pipeline

Depending on the maturity of the organisation, or development team, the deployment pipeline can be very sophisticated. In it's simplest form, the deployment pipeline consists of a commit phase. The commit phase commonly runs simple compiler checks, the unit tests suite, as well as creates a deployable artefact of the application which is called release candidate. A release candidate is the latest version of changes that has been checked into the trunk of the versioning control system and will be evaluated by the deployment pipeline to verify if it is in-line with the established standards to be potentially deployed to production.

The commit phase is designed to provide instant feedback to developers and as such is run on every commit to the trunk. Because of that, certain time constraints exists. Typically, the commit phase should run within 5 minutes, but in any case, shouldn't take longer than 10 minutes to complete. This time constraint is quite challenging in the security context, as many of the currently existing tools can't run in that short amount of time<sup>[14][15]</sup>.

Todo: Automating security tools in Jenkins,...

### References

* [1] OWASP Mobile Application Security Verification Standard - https://www.owasp.org/images/f/f2/OWASP_Mobile_AppSec_Verification_Standard_v0.9.2.pdf
* [2] The Importance of Manual Secure Code Review - https://www.mitre.org/capabilities/cybersecurity/overview/cybersecurity-blog/the-importance-of-manual-secure-code-review
* [3] OWASP Code Review Introduction - https://www.owasp.org/index.php/Code_Review_Introduction
* [4] Radare2 - https://github.com/radare/radare2
* [5] Angr - http://angr.io
* [6] https://triton.quarkslab.com/files/csaw2016-sos-rthomas-jsalwan.pdf
* [7] HP DevInspect - https://saas.hpe.com/en-us/software/agile-secure-code-development
* [8] Codiscope SecureAssist - https://codiscope.com/products/secureassist/
* [9] Crawling Code - https://www.owasp.org/index.php/Crawling_Code
* [10] Mobile internet usage surpasses desktop usage for the first time in history - http://bgr.com/2016/11/02/internet-usage-desktop-vs-mobile
* [12] Worldwide Smartphone OS Market Share - http://www.idc.com/promo/smartphone-market-share/os
* [13] Android Design Principles - https://developer.android.com/design/get-started/principles.html
* [14] Official (ISC)2 Guide to the CSSLP (ISC2 Press), Mano Paul - https://www.amazon.com/Official-Guide-CSSLP-Second-Press/dp/1466571276/
* [15] Software Security: Building Security In (Addison-Wesley Professional), Gary McGraw - https://www.amazon.com/Software-Security-Building-Gary-McGraw/dp/0321356705/
* [16] The evolution of DevOps: Gene Kim on getting to continuous delivery - https://techbeacon.com/evolution-devops-new-thinking-gene-kim
* [17] Cycript fork powered by Frida - https://github.com/nowsecure/frida-cycript
* [18] Cycript on steroids: Pumping up portability and performance with Frida - https://www.reddit.com/r/ReverseEngineering/comments/50uweq/cycript_on_steroids_pumping_up_portability_and/
