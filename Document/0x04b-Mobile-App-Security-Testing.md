## Mobile App Security Testing

Mobile app security testing involves, unsurprisingly, evaluating the security of mobile apps using technical analysis methods. Often (but not necessarily) this is done in the context of a larger security assessment that also encompasses the overall client-server architecture, as well as server-side APIs used by the mobile app. 

You'll find that various terms such as "Mobile App Penetration Testing", "Mobile App Security Review", and others are used in the security industry. All of those terms refer to roughly the same thing. Throughout the guide, we'll simply use "mobile app security testing" as an umbrella term. There's a few key points to consider:

- As far as mobile apps are concerned, there isn't really a difference between white-box and black-box testing. You always have access to the compiled app, and once you learn reading bytecode and binary code (or using a decompiler), having the compiled app is pretty much the same as having the source code.

The following sections will show how to use the OWASP mobile application security checklist and testing guide during a security test. It is split into four sections:

* **Preparation** - defining the scope of security testing, such as which security controls are applicable, what goals the development team/organization have for the testing, and what counts as sensitive data in the context of the test. 
* **Intelligence Gathering** - involves analysing the **environmental** and **architectural** context of the app, to gain a general contextual understanding of the app.
* **Threat Modelling** - consumes information gathered during the earlier phases to determine what threats are the most likely, or the most serious, and therefore which should receive the most attention from a security tester. Produces test cases that may be used during test execution.
* **Vulnerability Analysis** - identifies vulnerabilities using the previously created test cases, including static, dynamic and forensic methodologies.

----------

### Preparation

Before conducting a test, an agreement must be reached as to what security level of the [MASVS](https://github.com/OWASP/owasp-masvs) to test against. The security requirements should ideally have been decided at the beginning of the SDLC, but this may not always be the case. In addition, different organizations have different security needs, and different amounts of resources to invest in test activity. While the controls in MASVS Level 1 (L1) are applicable to all mobile apps, it is a good idea to walk through the entire checklist of L1 and Level 2 (L2) MASVS controls with technical and business stakeholders to agree an appropriate level of test coverage.

Organizations/applications may have different regulatory and legal obligations in certain territories. Even if an app does not handle sensitive data, it may be important to consider whether some L2 requirements may be relevant due to industry regulations or local laws. For example, 2-factor-authentation (2FA) may be obligatory for a financial app, as enforced by the respective country's central bank and/or financial regulatory authority.

Security goals/controls defined earlier in the SDLC may also be reviewed during the stakeholder discussion. Some controls may conform to MASVS controls, but others may be specific to the organization or application. 

![Preparation](Images/Chapters/0x03/mstg-preparation.png)

All involved parties need to agree on the decisions made and on the scope in the checklist, as this will define the baseline for all security testing, regardless if done manually or automatically.

#### Identifying Sensitive Data

Classification of sensitive information can vary between different industries and countries. Beyond legal and civic obligations, organizations may take a more restrictive view of what counts as sensitive data, and may have a data classification policy that clearly defines what counts as sensitive information. 

There are three general states in which data may be accessible:

* **At rest** - when the data is sitting in a file or data store
* **In use** - when an application has load the data into its address space
* **In transit** - when data has been sent between consuming process - e.g. during IPC.

The degree of scrutiny to apply to each state may depend on the criticality of the data, and likelihood of access. For example, because the likelihood of malicious actors gaining physical access to mobile devices is greater, data held in application memory may be more at risk of being accessed via core dumps than that on a web-server.

If no data classification policy is available, the following kinds of information are generally considered to be sensitive:

* User authentication information (credentials, PINs etc.).
* Personal Identifiable Information (PII) that can be abused for identity theft: Social security numbers, credit card numbers, bank account numbers, health information.
* Highly sensitive data that would lead to reputational harm and/or financial costs if compromised.
* Any data that must be protected by law or for compliance reasons.
* Finally any technical data, generated by the application or it's related systems, that is used to protect other data or the system, should also be considered as sensitive information (e.g. encryption keys).

It may be impossible to detect leakage of sensitive data without a firm definition of what counts as such, so such a definition must be agreed upon in advance of testing.

----------

### Intelligence Gathering

Intelligence gathering involves the collection of information about the architecture of the app, the business use cases it serves, and the context in which it operates. Such information may be broadly divided into `environmental` and `architectural`.

#### Environmental information

Environmental information concerns understanding:

* **The goals the organization has for the app** - what the app is supposed to do shapes the ways users are likely to interact with it, and may make some surfaces more likely to be targeted than others by attackers.   
* **the industry in which they operate** - specific industries may have differing risk profiles, and may be more or less exposed to particular attack vectors.
* **stakeholders and investors** - understanding who is interested in or responsible for the app.
* **internal processes, workflows and organizational structures** - organization-specific internal processes and workflows may create opportunities for [business logic exploits](https://www.owasp.org/index.php/Testing_for_business_logic)

#### Architectural information

Architectural information concerns understanding:

* **App:** - how the app accesses data and manages it in-process, how it communicates with other resources, manages user sessions, and whether it detects and reacts to running on jailbroken or rooted phones.
* **Operating System:** - what operating systems and versions does the app run on (e.g. is it restricted to only newer Android or iOS, and do we need to be concerned about vulnerabilities in earlier OS versions), is it expected to run on devices with [MDM](https://en.wikipedia.org/wiki/Mobile_device_management) controls, and what OS vulnerabilities might be relevant to the app
* **Network:** - are secure transport protocols used (e.g. TLS), is network traffic encryption secured with strong keys and cryptographic algorithms (e.g. SHA-2), is certificate pinning used to verify the client, etc.
* **Remote Services:** - what remote services does the app consume? If they were compromised, could the client by compromised? 

----------

### Threat Modelling

Threat modelling involves using the results of the information gathering phase to determine what threats are likely or severe, producing test cases that may be executed at later stages. Threat modelling should be a key part of the general SDLC, ideally performed throughout development, rather than just before a penetration test.

General threat modelling guidelines [have been defined by OWASP](https://www.owasp.org/index.php/Application_Threat_Modeling), and these are usually applicable to mobile apps.

<!-- are there any threat modelling techniques specially applicable to mobile apps? -->

----------

### Vulnerability Analysis

#### Static Analysis

When executing static analysis, the source code of the mobile app(s) will be analysed to ensure sufficient and correct implementation of security controls, focusing on crucial components such as cryptographic and data storage mechanisms. Due to the amount of code a tester may be confronted with, the ideal approach for static analysis should be a mixture of using tools that scan the code automatically and manual code review.

Through this approach you can get the best out of both worlds. You can get the so called "low hanging fruits" through the automatic scan, as the scanning engine and its (predefined) rules can detect many common vulnerabilities in the code. A manual code review can explore the code base with specific business and usage contexts in mind, providing enhanced relevance and coverage.

#### Automatic Code Analysis

During automatic static analysis, a tool will check the source code for compliance with a predefined set of rules or industry best practices. It is a standard development practice to use analytical methods to review and inspect the mobile application's source code to detect bugs and implementation errors.

The automatic static analysis tools will provide assistance with the manual code review and inspection process. The tool will typically display a list of findings or warnings and then flag all detected violations. Automatic static tools come in different varieties - some only run against built code, some just need to be fed with the source code and some run as live-analysis plugins in an Integrated Development Environments (IDE)<sup>[7] [8]</sup>. Ideally these tools should be used during the development process, but can also be useful during a source code review.

Some static code analysis tools encapsulate a deep knowledge of the underlying rules and semantics required to perform the specific type of analysis, but still require a professional to identify whether a reported violation is a false positive or not.

It should be noted that automatic static analysis can produce a high number of false positives, particularly if the tool is not configured properly for the target environment. Initially executing the scan for only a limited class of vulnerabilities might be a good decision - to avoid getting overwhelmed by the volume of results.

A full list of tools for static analysis can be found in the chapter "Testing tools".

#### Manual Code Analysis

In manual code analysis, a human code reviewer will look through the source code of the mobile application, to identify security vulnerabilities. This can be as basic as grepping the for key words within the source code repository to identify usages of potentially vulnerable code patterns, or as sophisticated as live-analysis using an IDE plugin. An IDE provides basic code review functionality and can be extended through different tools to assist in the reviewing process.

During a manual code review, the code base will be scanned to look for key indicators of security vulnerabilities. This is also known as "Crawling Code"<sup>[9]</sup> and will be executed by looking for certain keywords used within functions and APIs. For example, cryptographic strings like DES, MD5 or Random, or even database related strings like executeStatement or executeQuery are key indicators which may be of interest.

The main difference between a manual code review and the use of an automatic code analysis tool is that manual code review is better at identifying vulnerabilities in the business logic, standards violations and design flaws, especially in situations where the code is technically secure but logically flawed. Such scenarios are unlikely to be detected by any automatic code analysis tool.

A manual code review requires an expert human code reviewer who is proficient in both the language and the frameworks used in the mobile application. It is essential to have a deep understanding of the security implementation of the technologies used in the mobile application's source code. As a result it can be time consuming, slow and tedious for the reviewer; especially for large codebases with many dependencies.

#### Dynamic Analysis

In Dynamic Analysis the focus is on testing and evaluating an app by executing it in real-time, in differing situations. The main objective of dynamic analysis is to find security vulnerabilities or weak spots in a program while it is running. Dynamic analysis should also be conducted against the backend services and APIs of mobile applications, where its request and response patterns can be analysed.

Usually, dynamic analysis is performed to check whether there are sufficient security mechanisms in place to prevent disclosure of data in transit, authentication and authorization issues, data validation vulnerabilities (e.g. cross-site scripting, SQL injection, etc.) and server configuration errors.

##### Pros of Dynamic Analysis

* Does not require access to the source code
* Does not need an understanding of how the mobile application is supposed to behave
* Able to identify infrastructure, configuration and patch issues that Static Analysis tools may miss

##### Cons of Dynamic Analysis

* Limited scope of coverage because the mobile application must be footprinted to identify the specific test area
* No access to the actual instructions being executed, as the tool exercises the mobile application and conducts pattern matching on requests and responses

#### Runtime Analysis

-- TODO [Describe Runtime Analysis : goal, how it works, kind of issues that can be found] --

#### Traffic Analysis

Dynamic analysis of the traffic exchanged between client and server can be performed by launching a Man-in-the-middle (MITM) attack. This can be achieved by using an interception proxy like Burp Suite or OWASP ZAP for HTTP traffic.  

* Configuring an Android Device to work with Burp - https://support.portswigger.net/customer/portal/articles/1841101-configuring-an-android-device-to-work-with-burp
* Configuring an iOS Device to work with Burp - https://support.portswigger.net/customer/portal/articles/1841108-configuring-an-ios-device-to-work-with-burp

In case another (proprietary) protocol is used in a mobile app that is not HTTP, the following tools can be used to try to intercept or analyse the traffic:
* Mallory - https://github.com/intrepidusgroup/mallory
* Wireshark - https://www.wireshark.org/

##### Input Fuzzing

The process of fuzzing is to repeatedly feeding an application with various combinations of input value, with the goal of finding security vulnerabilities in the input-parsing code. There were instances when the application simply crashes, but also were also occasions when it did not crash but behave in a manner which the developers did not expect them to be, which may potentially lead to exploitation by attackers.  

Fuzz testing, is a method for testing software input validation by feeding it intentionally malformed input. Below are the steps in performing the fuzzing:

* Identifying a target
* Generating malicious inputs
* Test case delivery
* Crash monitoring

Also refer to the OWASP Fuzzing guide - https://www.owasp.org/index.php/Fuzzing

Note: Fuzzing only detects software bugs. Classifying this issue as a security flaw requires further analysis by the researcher.

##### Eliminating Common False Positives

* **Protocol adherence** - for data to be handled at all by an application, it may need to adhere relatively closely to a given protocol (e.g. HTTP) or format (e.g. file headers). The greater the adherence to the structure of a given protocol or format, the more likely it is that meaningful errors will be detected in a short time frame. However, it comes at the cost of decreasing the test surface, potentially missing low level bugs in the protocol or format.

* **[Fuzz Vectors](https://www.owasp.org/index.php/OWASP_Testing_Guide_Appendix_C:_Fuzz_Vectors)** - fuzz vectors may be used to provide a list of known risky values likely to cause undefined or dangerous behaviour in an app. Using such a list focuses tests more closely on likely problems, reducing the number of false positives and decreasing the test execution time.å


#### Cross-Site Scripting (XSS)

A typical reflected XSS attack is executed by sending a URL to the victim(s), which for example can contain a payload to connect to some exploitation framework like BeeF<sup>[2]</sup>. When clicking on it a reverse tunnel is established with the Beef server in order to attack the victim(s). As a WebView is only a slim browser, it is not possible for a user to insert a URL into a WebView of an app as no address bar is available. Also, clicking on a link will not open the URL in a WebView of an app, instead it will open directly within the default browser of the respective mobile device. Therefore, a typical reflected Cross-Site Scripting attack that targets a WebView in an app is not applicable and will not work.

If an attacker finds a stored Cross-Site Scripting vulnerability in an endpoint, or manages to get a Man-in-the-middle (MITM) position and injects JavaScript into the response, then the exploit will be sent back within the response. The attack will then be executed directly within the WebView. This can become dangerous in case:

* JavaScript is not deactivated in the WebView (see OMTG-ENV-005)
* File access is not deactivated in the WebView (see OMTG-ENV-006)
* The function addJavascriptInterface() is used (see OMTG-ENV-008)

In summary, a reflected Cross-Site Scripting is no concern for a mobile App, but a stored Cross-Site Scripting vulnerability or MITM injected JavaScript can become a dangerous vulnerability if the WebView if configured insecurely.

#### Cross-Site Request Forgery (CSRF)

The same problems with reflected XSS also applied to CSRF attacks. A typical CSRF attack is executed by sending a URL to the victim(s) that contains a state changing request like creation of a user account or triggering a financial transaction. Just as with XSS, it is not possible for a user to insert a URL into a WebView of an app. Therefore a typical CSRF attack that targets a WebView in an app is not applicable.

The basis for CSRF attacks, access to session cookies of all browser tabs and attaching them automatically if a request to a web page is executed is not applicable on mobile platforms. This is the default behaviour of full blown browsers. Every app has, due to the sandboxing mechanism, it's own web cache and stores it's own cookies, if WebViews are used. Therefore a CSRF attack against a mobile app is by design not possible as the session cookies are not shared with the Android browser.

Only if a user logs in by using the Android browser (instead of using the mobile App) a CSRF attack would be possible, as then the session cookies are accessible for the browser instance.
## Mobile App Security Testing

Mobile app testing involves evaluating the security of four different attack surfaces: the **app**, the **operating system**, any **remote services** consumed by the app, and the **network** used to communicate with them.  

Examples of vulnerabilities in these surfaces include:

* **App:**  Insecure data storage, poor resiliency against reverse engineering etc.
* **Operating System:** Any native API to which sensitive info is sent. E.g. Tampering with the system HTTP client might give access to the all SSL/TLS traffic from and to the phone, even when SSL with certificate pinning is used.…mobile app is by design not possible as the session cookies are not shared with the Android browser.

Only if a user logs in by using the Android browser (instead of using the mobile App) a CSRF attack would be possible, as then the session cookies are accessible for the browser instance.
