## Testing Network Communication

The following chapter outlines network communication requirements of the MASVS into technical test cases. Test cases listed in this chapter are focused on server side and therefore are not relying on a specific implementation on iOS or Android.  

### Testing for Unencrypted Sensitive Data on the Network

#### Overview

A functionality of most mobile applications requires sending or receiving information from services on the Internet. This reveals another surface of attacks aimed at data on the way. It's possible for an attacker to sniff or even modify (MiTM attacks) an unencrypted information if he controls any part of network infrastructure (e.g. an WiFi Access Point)<sup>[1]</sup>. For this reason, developers should make a general rule, that any confidential data cannot be sent in a cleartext<sup>[2]</sup>.

#### Static Analysis

Identify all external endpoints (backend APIs, third-party web services), which communicate with tested application and ensure that all those communication channels are encrypted.

#### Dynamic Analysis

The recommended approach is to intercept all network traffic coming to or from tested application and check if it is encrypted. A network traffic can be intercepted using one of the following approaches:

* Capture all network traffic, using Tcpdump. You can begin live capturing via command:
```
adb shell "tcpdump -s 0 -w - | nc -l -p 1234"
adb forward tcp:1234 tcp:1234
```

Then you can display captured traffic in a human-readable way, using Wireshark
```
nc localhost 1234 | sudo wireshark -k -S -i –
```

* Capture all network traffic using interception proxy, like OWASP ZAP<sup>[3]</sup> or Burp Suite<sup>[4]</sup> and observe whether all requests are using HTTPS instead of HTTP.

> Please note, that some applications may not work with proxies like Burp or ZAP (because of customized HTTP/HTTPS implementation, or Certificate Pinning). In such case you may use a VPN server to forward all traffic to your Burp/ZAP proxy. You can easily do this, using Vproxy.

It is important to capture all traffic (TCP and UDP), so you should run all possible functions of tested application after starting interception. This should include a process of patching application, because sending a patch to application via HTTP may allow an attacker to install any application on victim's device (MiTM attacks).

#### Remediation

Ensure that sensitive information is being sent via secure channels, using HTTPS<sup>[5]</sup>, or SSLSocket<sup>[6]</sup> for socket-level communication using TLS.

Please be aware that `SSLSocket` **does not** verify hostname. The hostname verification should be done by using `getDefaultHostnameVerifier()` with expected hostname. Consult documentation<sup>[7]</sup> for an example of correct usage.

Some applications may use localhost address, or binding to INADDR_ANY for handling sensitive IPC, what is bad from security perspective, as this interface is accessible for other applications installed on a device. For such purpose developers should consider using secure Android IPC mechanism<sup>[8]</sup>.

#### References

##### OWASP Mobile Top 10 2016
* M3 - Insecure Communication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M3-Insecure_Communication

##### OWASP MASVS
* V5.1: "Sensitive data is encrypted on the network using TLS. The secure channel is used consistently throughout the app."

##### CWE
* CWE-319 - Cleartext Transmission of Sensitive Information

##### Info
* [1] https://cwe.mitre.org/data/definitions/319.html
* [2] https://developer.android.com/training/articles/security-tips.html#Networking
* [3] https://security.secure.force.com/security/tools/webapp/zapandroidsetup
* [4] https://support.portswigger.net/customer/portal/articles/1841101-configuring-an-android-device-to-work-with-burp
* [5] https://developer.android.com/reference/javax/net/ssl/HttpsURLConnection.html
* [6] https://developer.android.com/reference/javax/net/ssl/SSLSocket.html
* [7] https://developer.android.com/training/articles/security-ssl.html#WarningsSslSocket
* [8] https://developer.android.com/reference/android/app/Service.html

##### Tools
* Tcpdump - http://www.androidtcpdump.com/
* Wireshark - https://www.wireshark.org/
* OWASP ZAP - https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project
* Burp Suite - https://portswigger.net/burp/
* Vproxy - https://github.com/B4rD4k/Vproxy

### Verifying the TLS Settings

#### Overview

Many mobile applications consume remote services over the HTTP protocol. HTTPS is HTTP over SSL/TLS. Other encrypted channels are less common. Thus, it is important to ensure that TLS configuration is done properly. SSL is the older name of the TLS protocol and should no longer be used, since SSLv3 is considered vulnerable. TLS v1.2 and v1.3 are the most modern and most secure versions, but many services still include configurations for TLS v1.0 and v1.1, to ensure compatibility with the older clients. This is especially true for browsers that can connect to arbitrary servers and for servers that expect connections from arbitrary clients.

In the situation where both the client and the server are controlled by the same organization and are used for the purpose of only communicating with each other, higher levels of security can be achieved by more strict configurations<sup>[1]</sup>.

If a mobile application connects to a specific server for a specific part of its functionality, the networking stack for that client can be tuned to ensure highest levels of security possible given the server configuration. Additionally, the mobile application may have to use a weaker configuration due to the lack of support in the underlying operating system.

For example, the popular Android networking library okhttp uses the following list as the preferred set of cipher suites, but these are only available on Android 7.0 and later:

* `TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256`
* `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`
* `TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384`
* `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384`
* `TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256`
* `TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256`

To support earlier versions of Android, it adds a few ciphers that are not considered as secure:

* `TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA`
* `TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA`
* `TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA`
* `TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA`
* `TLS_RSA_WITH_AES_128_GCM_SHA256`
* `TLS_RSA_WITH_AES_256_GCM_SHA384`
* `TLS_RSA_WITH_AES_128_CBC_SHA`
* `TLS_RSA_WITH_AES_256_CBC_SHA`
* `TLS_RSA_WITH_3DES_EDE_CBC_SHA`


Similarly, the iOS ATS (App Transport Security) configuration requires one of the following ciphers:

* `TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384`
* `TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256`
* `TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384`
* `TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA`
* `TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256`
* `TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA`
* `TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384`
* `TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256`
* `TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384`
* `TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256`
* `TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA`


#### Static Analysis

This is platform/language/library specific.

#### Dynamic Analysis

After identifying all servers communicating with your application (e.g. using Tcpdump, or Burp Suite) you should verify if they allow the usage of weak ciphers, protocols or keys. It can be done, using different tools:

* testssl.sh: via following command:

The GitHub repo of testssl.sh offers also a compiled openssl version for download that supports **all cipher suites and protocols including SSLv2**.

```
$ OPENSSL=./bin/openssl.Linux.x86_64 bash ./testssl.sh yoursite.com
```

The tool will also help identifying potential misconfiguration or vulnerabilities by highlighting them in red.

If you want to store the report preserving color and format use `aha`:

```
$ OPENSSL=./bin/openssl.Linux.x86_64 bash ./testssl.sh yoursite.com | aha > output.html
```

This will give you a HTML document that will match CLI output.

* sslyze: via following command:

```
sslyze --regular www.example.com:443
```
* O-Saft (OWASP SSL Advanced Forensic Tool): can be run in GUI mode via command:

```
o-saft.tcl
```
or via command. There are multiple options<sup>[2]</sup>, but the most general one, verifying certificate, ciphers and SSL connection is the following:

```
perl o-saft.pl +check www.example.com:443
```

#### Remediation

Any vulnerability or misconfiguration should be solved either by patching or reconfiguring the server. To properly configure transport layer protection for network communication, please follow the OWASP Transport Layer Protection cheat sheet<sup>[3]</sup> and Qualys TLS best practices<sup>[4]</sup>.

#### References

##### OWASP Mobile Top 10 2016
* M3 - Insecure Communication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M3-Insecure_Communication

##### OWASP MASVS
* V5.2: "The TLS settings are in line with current best practices, or as close as possible if the mobile operating system does not support the recommended standards."

##### CWE
* CWE-327 - Use of a Broken or Risky Cryptographic Algorithm - https://cwe.mitre.org/data/definitions/327.html

##### Info
* [1] Testing for Weak SSL/TLS Ciphers - https://www.owasp.org/index.php/Testing_for_Weak_SSL/TLS_Ciphers,_Insufficient_Transport_Layer_Protection_(OTG-CRYPST-001)
* [2] O-Saft various tests - https://www.owasp.org/index.php/O-Saft/Documentation#COMMANDS
* [3] Transport Layer Protection Cheat Sheet - https://www.owasp.org/index.php/Transport_Layer_Protection_Cheat_Sheet
* [4] Qualys SSL/TLS Deployment Best Practices - https://dev.ssllabs.com/projects/best-practices/
* [5] okhttp `okhttp.ConnectionSpec` class, `APPROVED_CIPHER_SUITES` array - https://github.com/square/okhttp/
* [6] Requirements for Connecting Using ATS, App Transport Security - https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW57


##### Tools
* testssl.sh- https://testssl.sh
* sslyze - https://github.com/nabla-c0d3/sslyze
* O-Saft - https://www.owasp.org/index.php/O-Saft

### Verifying that Critical Operations Use Secure Communication Channels

#### Overview

For sensitive applications, like banking apps, OWASP MASVS introduces "Defense in Depth" verification level<sup>[1]</sup>. Critical operations (e.g. user enrollment, or account recovery) of such sensitive applications are the most attractive targets from attacker's perspective. This creates a need of implementing advanced security controls for such operations, like adding additional channels (e.g. SMS and e-mail) to confirm user's action. Additional channels may reduce a risk of many attacking scenarios (mainly phishing), but only when they are out of any security faults.

#### Static Analysis

Review the code and identify those parts of a code which refers to critical operations. Verify if it uses additional channels to perform such operation. Examples of additional verification channels are following:

* token (e.g. RSA token, yubikey)
* push notification (e.g. Google Prompt)
* SMS
* email
* data from another website you had to visit/scan
* data from a physical letter or physical entry point (e.g.: data you receive only after signing a document at the office of a bank)

#### Dynamic Analysis

Identify all critical operations implemented in tested application (e.g. user enrollment, or account recovery, money transfer etc.). Ensure that each of critical operations, requires at least one additional channel (e.g. SMS, e-mail, token etc.). Verify if usage of such channel can be bypassed (e.g. turning off SMS confirmation without using any other channel).

#### Remediation

Ensure that critical operations require at least one additional channel to confirm user's action. Each channel must not be bypassed to execute a critical operation. If you are going to implement additional factor to verify user's identity, you may consider usage of Infobip 2FA library<sup>[2]</sup>, one-time passcodes via Google Authenticator<sup>[3]</sup>.

#### References

##### OWASP Mobile Top 10 2016
* M3 - Insecure Communication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M3-Insecure_Communication

##### OWASP MASVS
* V5.5 "The app doesn't rely on a single insecure communication channel (email or SMS) for critical operations, such as enrollments and account recovery."

##### CWE
* CWE-956 - Software Fault Patterns (SFPs) within the Channel Attack cluster

##### Info
* [1] The Mobile Application Security Verification Standard - https://github.com/OWASP/owasp-masvs/blob/master/Document/0x03-Using_the_MASVS.md
* [2] Infobip 2FA library - https://2-fa.github.io/libraries/android-library.html
* [3] Google Authenticator for Android - https://github.com/google/google-authenticator-android
