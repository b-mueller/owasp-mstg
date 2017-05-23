# Testing Process and Techniques

## Mobile App Security Testing Methodology

-- TODO [Describe Mobile Security Testing methodology] --

The context of mobile security testing is a conjunction of multiple different tier of components: **app**, **communication** and **back-end server**. These three high-level components will be the main attack surface for a mobile security test.   

* **App:**  Insecure data storage, poor resiliency against reverse engineering etc.
* **Communication:** Usage of insecure or unencrypted communication channel, missing SSL certificate pinning etc.
* **Back-end Servers:** Flawed authentication and session management, vulnerable server side functions etc.

### Different Types of Mobile Apps

The following section is a brief introduction to the 3 different types of mobile applications, namely the (1) Native App, (2) Hybrid App and (3) Web App. Before we dive into them, it is essential to first understand what is Mobile App.

#### Mobile App

In the past, people uses Personal Computers (PCs) to perform daily tasks at work and at leisure, such as creating a PowerPoint presentation slide or writing a report. Then, when computation power increases and web technologies become more popular, some of these capabilities that used to be only able to perform on PCs, they can be performed on the Web Browser. Today, a smart phone in one's pocket has more processor and RAM than a full-fledge PC back in those days! These mobile devices are capable to perform daily tasks and they has special processor designed for high performance and capabilities to support multitasking and high productivity daily tasks. As such, it has formed its own ecosystem where there are high demand for various types of mobile apps, be it designed for enhancing one's productivity, lifestyle or social connectivity. 

In short, mobile applications (hereby referred to as simply 'Mobile App'), are essentially self-contained programs that were designed to enhance the existing functionality of a smart phone. On Android, there is Play Store and on iOS, there is App Store -- they both have their own ecosystem which fulfills their own users' demand and supply. It plays a huge part in people's everyday life and allows them to be highly connected with the world and their friends. According to a survey conducted by BGR Media in late 2016, the mobile internet usage has surpassed desktop usage for the first time in history, and this can never happen without the countless Mobile Apps that make a mobile platform ecosystem attractive and full of enhanced functionalities <sup>[10]</sup>.

#### Native App 

Native App are basically mobile apps that were developed for use on a particular specific platform. A native mobile app is a smart phone application that is being coded in a particular programming language, for instance, Objective C or Swift for iOS and Java for Android operating systems. There are also other candidates of native mobile app, such as C# and XAML or JavaScript for Universal Windows Platform app (UWP) <sup>[11]</sup>. 

However, the MSTG will focus on Android and iOS platforms at the moment as based on a survey conducted in November 2016, these two mobile operating system takes up 86.8% and 12.5% of market share worldwide, respectively, which takes up over 99% of the entire market share of the mobile operating systems <sup>[12]</sup>.  

Native mobile apps provide fast performance and a high degree of reliability. They have better look and feel as well because most of time, they uses native buttons and user interface which are familiar to the user and looks good on the respective platform. In addition, they usually adhere to the design principles (e.g. Android Design Principles <sup>[13]</sup>), which are usually entirely neglected by the developers who design Hybrid Apps and Web Apps. 

Another feature of an Native mobile apps is their ability of having access to the components of a smart phone, such as its accelerometer, GPS, and camera. Moreover, users are able to use certain apps without having Internet connectivity. However, a Native App is expensive to develop because it require a developer with specific skillset and the resulted app can only run on one platform, forcing the company that creates the app to make duplicated versions of the same app that work on other platforms. More often than not, Android mobile app developers are not proficient in developing iOS apps and vice versa for iOS mobile app developers. 

Usually, when discussing about Mobile App, the assumption is always that it is a Native App. It is also worth noting that a Native App can only be "Native" to one type of mobile operating system: iOS, Android, UWP, etc. For companies that want to publish their Native Apps to multiple mobile operating system will need to develop and maintain a separate piece of software, with entirely different design and implementation, which could easily become complicated to manage, tedious to implement and expensive to maintain. This conveniently brings us to the next two types of Mobile Apps. 

#### Hybrid App

Hybrid Apps are similar to Native Apps, runs on a smart phone or tablet devices, and are written with web technologies, which consists of HTML5, CSS and JavaScript. Hybrid Apps run within a native container, and leverages on the device's browser engine (but not the browser, only the browser engine) to render the HTML content and process the JavaScript locally. A web-to-native abstraction layer enables access to device capabilities that are not accessible in Mobile Web applications, such as the accelerometer, camera and local storage.

Companies usually build hybrid apps as wrappers for an existing web page, as an attempt to gain presence within the app store of the respective mobile operating systems, without spending significant effort for developing a different app. Hybrid apps are also popular because they allow cross platform development and thus significantly reduce development costs. The way it is able to support cross platform development is through the usage of the same HTML code components which is then being reused on different mobile operating systems. 

For example, the HTML, CSS and JavaScript code that is rendered by the browser engine on an Android mobile device could also be rendered in the same way on an iOS mobile device. They will look the same but they may not look native. It is not difficult to visually differentiate between the User Interface (UI) of a Native App and a Hybrid App.   

The following is a non-exhaustive list of the more popular frameworks for developing Hybrid Apps:

* Apache Cordova - https://cordova.apache.org/
* Framework 7 - http://framework7.io/ 
* Ionic - https://ionicframework.com/
* jQuery Mobile - https://jquerymobile.com/
* Native Script - https://www.nativescript.org/
* Onsen UI - https://onsen.io/
* React Native - http://www.reactnative.com/
* Sencha Touch - https://www.sencha.com/products/touch/

#### Web App

Web App, more commonly known as the Mobile Web App, are simply websites that were designed to look and feel like a native mobile app, but not implemented as such. Web App are run on a browser (unlike Hybrid App which run on browser engine, Web App run on browser) and are usually developed in HTML5. 

Firstly, users will access the Web App on browser via a specific URL, where the look and feel is almost, quite identical to a native mobile app. To perform the installation of the app, a simple bookmark shortcut will be created on the Home screen of the device. 

Web App was very popular when HTML5 was first released and people noticed its capability to achieve a look and feel which is very similar to a native app. Today, as the usage of native apps has increased significantly, it become obvious in differentiating between a Web App and a Native App, even for non-tech savvy personnel. 

### Testing Process

The following sections will show how to use the OWASP mobile application security checklist and testing guide during a security test.

#### Preparation - Defining The Baseline

First of all, you need to decide what security level of the MASVS to test against. The security requirements should ideally have been decided at the beginning of the SDLC - but unfortunately we are not living in an ideal world. At the very least, it is a good idea to walk through the checklist, ideally with an IT security representative of the enterprise, the app stakeholders of the project and make a reasonable selection of Level 2 (L2) controls to cover during the test.

The controls in MASVS Level 1 (L1) are appropriate for all mobile apps - the rest depends on the threat model and risk assessment for the particular app. Discuss with the app stakeholders to understand what are the requirements that are applicable and which are the ones that should be deemed out of scope for the scope of testing, perhaps due to business decisions or company policies. Also consider whether some L2 requirements may be needed due to industry regulations or local laws - for example, 2-factor-authentation (2FA) may be obligatory for a financial app, as enforced by the respective country's central bank and/or financial regulatory authority.

If security requirements were already defined during the SDLC, even better! Ask for this information and document it on the front page of the Excel sheet ("dashboard"). More guidance on the verification levels and guidance on the certification can be found in the [MASVS](https://github.com/OWASP/owasp-masvs).

![Preparation](Images/Chapters/0x03/mstg-preparation.png)

All involved parties need to agree on the decisions made and on the scope in the checklist, as this will present the baseline for all security testing, regardless if done manually or automatically.

#### Mobile App Security Testing

During a manual test, one can simply walk-through the applicable requirements down the checklist, one-by-one. For a detailed testing procedures, simply click on the link provided in the "Testing Procedure" column. These links will bring you to the respective chapter in the OWASP Mobile Security Testing Guide (MSTG), where detailed steps and examples are listed for reference and guidance purposes.

Also important is to note that the OWASP Mobile Security Testing Guide (MSTG) is still "Work In Progress" and being updated even as you are reading this paragraph, therefore, some test cases may not have been written yet or may be in a draft status. (Ideally, if you discover any missing content, you could contribute it yourself).

![The checklist. Requirements marked with "L1" should always be verified. Choose either "Pass" or "Fail" in the "Status" column. The links in the "Testing Procedure" column lead to the OWASP Mobile Security Testing Guide.](Images/Chapters/0x03/mstg-test-cases.png)

The status column can have one of the following three different values, that need to be filled out:

* **Pass:** Requirement is applicable to mobile app and implemented according to best practices.
* **Fail:** Requirement is applicable to mobile app but not fulfilled.
* **N/A:** Requirement is not applicable to mobile app.

#### Reverse Engineering Resiliency Testing

*Resiliency testing* is a new concept introduced in the OWASP MASVS and MSTG. This kind of testing can be used if the app implements defenses against specific client-side threats.. As we know, such protection is never 100% effective. The goal in resiliency testing is to identify glaring holes in the protection scheme and verify that the expectations as to its effectiveness are met. The assessment methodology is described in detail in the appendix "Assessing Anti-Reversing Schemes".

#### Reporting

The checklist itself can be used as a report as it list's down in detail what test cases have been included and verified in the tests and ideally also shows evidence in case a test fails. Also the first page should then be filled out, to include all the meta information needed for a report.

#### The Management Summary

A spider chart is generated on the fly according to the results of the requirements for both supported platforms (Android and iOS) in the "Management Summary" tab. You can use this in your report to point out areas that need improvement, and visualize progress over time.

![Management Summary - Spider Chart](Images/Chapters/0x03/mstg-spiderchart.png)

The spider chart visualizes the ratio of passed and failed requirements in each domain. As can be seen above all requirements in "V3: Cryptography Verification Requirements" were set to "pass", resulting in a value of 1.00. Requirements that are set to N/A are not included in this chart.

A more detailed overview can also be found in the "Management Summary" tab. This table gives an overview according to the eight domains and breaks down the requirements according to it's status (Passed, Failed or N/A). The percentage column is the ratio from passed to failed requirements and is the input for the spider chart described above.

![Management Summary - Detailed Overview](Images/Chapters/0x03/mstg-detailed-summary.png)


## Vulnerability Analysis Techniques

### Static Analysis

When executing a static analysis, the source code of the mobile App(s) will be analyzed to ensure sufficient and correct implementation of security controls, specifically on crucial components such as cryptographic and data storage mechanisms. Due to the amount of code a tester will be confronted with the ideal approach for static analysis should be a mixture of using tools that scan the code automatically and manual code review.

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

### Dynamic Analysis

In a Dynamic Analysis approach, the focus is on testing and evaluation of an app by executing it in a real-time manner, under different stimuli. The main objective of a dynamic analysis is to find the security vulnerabilities or weak spots in a program while it is running. Dynamic analysis is conducted against the backend services and APIs of mobile applications, where its request and response patterns would be analysed.

Usually, dynamic analysis is performed to check whether there are sufficient security mechanisms being put in place to prevent disclosure of data in transit, authentication and authorization issues, data validation vulnerabilities (e.g. cross-site scripting, SQL injection, etc.) and server configuration errors.

-- ToDo

#### Pros of Dynamic Analysis

* Does not require to have access to the source code
* Does not need to understand how the mobile application is supposed to behave
* Able to identify infrastructure, configuration and patch issues that Static Analysis approach tools will miss

#### Cons of Dynamic Analysis

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

-- TODO [Write a better description, or remove this] --

Fuzz testing, is a method for testing software input validation by feeding it intentionally malformed input.
Steps in fuzzing
* Identifying a target
* Generating malicious inputs
* Test case delivery
* Crash monitoring

Also refer to the OWASP Fuzzing guide - https://www.owasp.org/index.php/Fuzzing

Note: Fuzzing only detects software bugs. Classifying this issue as a security flaw requires further analysis by the researcher.

### Vulnerability Analysis Considerations

#### Eliminating False Positives

##### Cross-Site Scripting (XSS)

A typical reflected XSS attack is executed by sending a URL to the victim(s), which for example can contain a payload to connect to some exploitation framework like BeeF [2]. When clicking on it a reverse tunnel is established with the Beef server in order to attack the victim(s). As a WebView is only a slim browser, it is not possible for a user to insert a URL into a WebView of an app as no address bar is available. Also, clicking on a link will not open the URL in a WebView of an app, instead it will open directly within the default browser of the respective mobile device. Therefore, a typical reflected Cross-Site Scripting attack that targets a WebView in an app is not applicable and will not work.

If an attacker finds a stored Cross-Site Scripting vulnerability in an endpoint, or manages to get a Man-in-the-middle (MITM) position and injects JavaScript into the response, then the exploit will be sent back within the response. The attack will then be executed directly within the WebView. This can become dangerous in case:

* JavaScript is not deactivated in the WebView (see OMTG-ENV-005)
* File access is not deactivated in the WebView (see OMTG-ENV-006)
* The function addJavascriptInterface() is used (see OMTG-ENV-008)

As a summary, a reflected Cross-Site Scripting is no concern for a mobile App, but a stored Cross-Site Scripting or injected JavaScript through MITM can become a dangerous vulnerability if the WebView in used is configured insecurely.

##### Cross-Site Request Forgery (CSRF)

The same problem described with reflected XSS also applied to CSRF attacks. A typical CSRF attack is executed by sending a URL to the victim(s) that contains a state changing request like creation of a user account or triggering a financial transaction. As a WebView is only a slim browser it is not possible for a user to insert a URL into a WebView of an app and also clicking on a link will not open the URL in a WebView of an App. Instead it will open directly within the browser of Android. Therefore a typical CSRF attack that targets a WebView in an app is not applicable.

The basis for CSRF attacks, access to session cookies of all browser tabs and attaching them automatically if a request to a web page is executed is not applicable on mobile platforms. This is the default behaviour of full blown browsers. Every app has, due to the sandboxing mechanism, it's own web cache and stores it's own cookies, if WebViews are used. Therefore a CSRF attack against a mobile app is by design not possible as the session cookies are not shared with the Android browser.

Only if a user logs in by using the Android browser (instead of using the mobile App) a CSRF attack would be possible, as then the session cookies are accessible for the browser instance.

## Classification of data

Classification of sensitive information can vary between different industries and countries. Therefore laws and regulations that are applicable to the app need to be known. This will become the basis of what sensitive information actually is in the context of the app.

Ideally the customer can share a data classification policy that is already considering all different requirements and clearly defines sensitive information. This will become then the baseline during testing. The data classification should be applicable to:
* data in transit and
* data at rest

For example, regulations in Singapore for financial institutions has imposed a requirement to encrypt passwords and PINs explicitly, even though they are already transmitted via HTTPS. Even though this might not be a vulnerability from the point of view of a tester, it is mandatory to raise this finding as a compliance issue.

If no data classification policy is available, the following should be considered as sensitive information:
* User authentication information (credentials, PINs etc.),
* Personal Identifiable Information (PII) that can be abused for identity theft: Social security numbers, credit card numbers, bank account numbers, health information,
* Highly sensitive data that would lead to reputational harm and/or financial costs if compromised,
* Any data that must be protected by law or for compliance reasons.

Defining sensitive information before the test is important for almost all data storage test cases in Android and iOS, as otherwise the tester has no clear basis on what he might need to look for.

## Tampering and Reverse Engineering

In the context of mobile apps, *reverse engineering* is the process of analyzing the compiled app to extract knowledge about its inner workings. It is akin to reconstructing the original source code from the bytecode or binary code, even though this doesn't need to happen literally. The main goal in reverse engineering is *comprehending* the code.

*Tampering* is the process of making changes to a mobile app (either the compiled app, or the running process) or its environment to affect its behavior. For example, an app might refuse to run on your rooted test device, making it impossible to run some of your tests. In cases like that, you'll want to alter that particular behavior.

Reverse engineering and tampering techniques have long belonged to the realm of crackers, modders, malware analysts, and other more exotic professions. For "traditional" security testers and researchers, reverse engineering has been more of a complementary, nice-to-have-type skill that wasn't all that useful in 99% of day-to-day work. But the tides are turning: Mobile app black-box testing increasingly requires testers to disassemble compiled apps, apply patches, and tamper with binary code or even live processes. The fact that many mobile apps implement defenses against unwelcome tampering doesn't make things easier for us.

Mobile security testers should be able to understand basic reverse engineering concepts. It goes without saying that they should also know mobile devices and operating systems inside out: the processor architecture, executable format, programming language intricacies, and so forth.

Reverse engineering is an art, and describing every available facet of it would fill a whole library. The sheer range of techniques and possible specializations is mind-blowing: One can spend years working on a very specific, isolated sub-problem, such as automating malware analysis or developing novel de-obfuscation methods. Security testers are generalists: To be effective reverse engineers, they must be able filter through the vast amount of information to build a workable methodology.

There is no generic reverse engineering process that always works. That said, we'll describe commonly used methods and tools later on, and give examples for tackling the most common defenses.

### Why You Need It

Mobile security testing requires at least basic reverse engineering skills for several reasons:

**1. To enable black-box testing of mobile apps.** Modern apps often employ technical controls that will hinder your ability to perform dynamic analysis. SSL pinning and end-to-end (E2E) encryption sometimes prevent you from intercepting or manipulating traffic with a proxy. Root detection could prevent the app from running on a rooted device, preventing you from using advanced testing tools. In this cases, you must be able to deactivate these defenses.

**2. To enhance static analysis in black-box security testing.** In a black-box test, static analysis of the app bytecode or binary code is helpful for getting a better understanding of what the app is doing. It also enables you to identify certain flaws, such as credentials hardcoded inside the app.

**3. To assess resiliency against reverse engineering.**  Apps that implement the software protection measures listed in MASVS-R should be resilient against reverse engineering to a certain degree. In this case, testing the reverse engineering defenses ("resiliency assessment") is part of the overall security test. In the resiliency assessment, the tester assumes the role of the reverse engineer and attempts to bypass the defenses.

In this guide, we'll cover basic tampering techniques such as patching and hooking, as well as common tools and processes for reverse engineering (and comprehending) mobile apps without access to the original source code. Reverse engineering is an immensely complex topic however - covering every possible aspect would easily fill several books. Links and pointers to useful resources are included in the "references" section at the end of each chapter.

### Before You Start

Before you dive into the world of mobile app reversing, we have some good news and some bad news to share. Let's start with the good news:

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

However, you can also instrument apps with Substrate by using it to inject Cycript, the programming environment (a.k.a. "Cycript-to-JavaScript" compiler) authored by Saurik of Cydia fame. To complicate things even more, Frida's authors also created a fork of Cycript named "frida-cycript" (https://github.com/nowsecure/frida-cycript) that replaces Cycript's runtime with a Frida-based runtime called Mjølner. This enables Cycript to run on all the platforms and architectures maintained by frida-core (if you are confused now don't worry, it's perfectly OK to be). 

The release was accompanied by a blog post by Frida's developer Ole titled "Cycript on Steroids", which did not go that down that well with Saurik - https://www.reddit.com/r/ReverseEngineering/comments/50uweq/cycript_on_steroids_pumping_up_portability_and/.

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

Even though most professional GUI-based disassemblers feature scripting facilities and extensibility, they sometimes simply not well-suited to solving a particular problem. Reverse engineering frameworks allow you perform and automate any kind of reversing task without the dependence for heavy-weight GUI, while also allowing for increased flexibility. Notably, most reversing frameworks are open source and/or available for free. Popular frameworks with support for mobile architectures include Radare2 <sup>[4]</sup> and Angr <sup>[5]</sup>.

##### Example: Program Analysis using Symbolic / Concolic Execution

In the late 2000s, symbolic-execution based testing has gained popularity as a means of identifying security vulnerabilities. Symbolic "execution" actually refers to the process of representing possible paths through a program as formulas in first-order logic, whereby variables are represented by symbolic values, which are actually entire ranges of values. Satisfiability Modulo Theories (SMT) solvers are used to check satisfiability of those formulas and provide a solution, including concrete values for the variables needed to reach a certain point of execution on the path corresponding to the solved formula.

Typically, this approach is used in combination with other techniques such as dynamic execution (hence the name concolic stems from *conc*rete and symb*olic*), in order to tone down the path explosion problem specific to classical symbolic execution. This together with improved SMT solvers and current hardware speeds, allow concolic execution to explore paths in medium size software modules (i.e. in the order of 10s KLOC). However, it also comes in handy for supporting de-obfuscation tasks, such as simplifying control flow graphs. For example, Jonathan Salwan and Romain Thomas have shown how to reverse engineer VM-based software protections using Dynamic Symbolic Execution (i.e., using a mix of actual execution traces, simulation and symbolic execution) <sup>[6]</sup>.

In the Android section, you'll find a walkthrough for cracking a simple license check in an Android application using symbolic execution.

#### Domain-Specific De-Obfuscation Attacks

-- TODO [Describe de-obfucscation of virtual machines and whiteboxes] --

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
* [11] Universal Windows Platform (UWP) app - https://docs.microsoft.com/en-us/windows/uwp/get-started/whats-a-uwp
* [12] Worldwide Smartphone OS Market Share - http://www.idc.com/promo/smartphone-market-share/os 
* [13] Android Design Principles - https://developer.android.com/design/get-started/principles.html

