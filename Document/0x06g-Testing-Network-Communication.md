## Testing Network Communication in iOS Apps

Almost every every iOS app acts as a client to one or more remote services. As this network communcation usually takes place of the public Internet, and often over unstrusted networks such as public Wifi, classical, network based-attacks become a potential issue.

Most modern mobile apps use variants of http-based (web-)services, as these protocols are well-documented and supported. On iOS, the The <code>NSURLConnection</code> class provides convenience class methods to load URL requests asynchronously and synchronously.

### Testing App Transport Security

#### Overview

App Transport Security (ATS)<sup>[1]</sup> is a set of security checks that the operating system enforces when making connections with NSURLConnection <sup>[2]</sup>, NSURLSession and CFURL<sup>[3]</sup> to public hostnames. ATS is enabled by default for applications build on iOS SDK 9 and above.

ATS is enforced only when making connections to public hostnames. Therefore any connection made to an IP address, unqualified domain names or TLD of .local is  not protected with ATS.

The following is a summarised list of App Transport Security Requirements<sup>[1]</sup>:

- No HTTP connections are allowed
- The X.509 Certificate has a SHA256 fingerprint and must be signed with at least 2048-bit RSA key or a 256-bit Elliptic-Curve Cryptography (ECC) key.
- Transport Layer Security (TLS) version must be 1.2 or above and must support Perfect Forward Secrecy (PFS) through Elliptic Curve Diffie-Hellman Ephemeral (ECDHE) key exchange and AES-128 or AES-256 symmetric ciphers.

The cipher suit must be one of the following:

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

##### ATS Exceptions

ATS restrictions can be disabled by configuring exceptions in the Info.plist file under the `NSAppTransportSecurity` key. These exceptions can be applied to:
* allow insecure connections (HTTP),
* lower the minimum TLS version,
* disable PFS or
* allow connections to local domains

ATS exceptions can be applied globally or per domain basis. The application can globally disable ATS, but opt in for individual domains. The following listing from Apple Developer documentation shows the structure of the `NSAppTransportSecurity` dictionary<sup>[1]</sup>.

```
NSAppTransportSecurity : Dictionary {
    NSAllowsArbitraryLoads : Boolean
    NSAllowsArbitraryLoadsForMedia : Boolean
    NSAllowsArbitraryLoadsInWebContent : Boolean
    NSAllowsLocalNetworking : Boolean
    NSExceptionDomains : Dictionary {
        <domain-name-string> : Dictionary {
            NSIncludesSubdomains : Boolean
            NSExceptionAllowsInsecureHTTPLoads : Boolean
            NSExceptionMinimumTLSVersion : String
            NSExceptionRequiresForwardSecrecy : Boolean   // Default value is YES
            NSRequiresCertificateTransparency : Boolean
        }
    }
}
```
Source: Apple Developer Documentation<sup>[1]</sup>.

The following table summarises the global ATS exceptions. For more information about these exceptions, please refer to Table 2 in reference [1].

|  Key | Description |
| -----| ------------|
| `NSAllowsArbitraryLoads` | Disable ATS restrictions globally excepts for individual domains specified under `NSExceptionDomains` |
| `NSAllowsArbitraryLoadsInWebContent` | Disable ATS restrictions for all the connections made from web views |
| `NSAllowsLocalNetworking` | Allow connection to unqualified domain names and .local domains |
| `NSAllowsArbitraryLoadsForMedia` | Disable all ATS restrictions for media loaded through the AV Foundations framework |


The following table summarises the per-domain ATS exceptions. For more information about these exceptions, please refer to Table 3 in reference [1].

|  Key | Description |
| -----| ------------|
| `NSIncludesSubdomains` | Indicates whether ATS exceptions should apply to subdomains of the named domain |
| `NSExceptionAllowsInsecureHTTPLoads` | Allows HTTP connections to the named domain, but does not affect TLS requirements |
| `NSExceptionMinimumTLSVersion` | Allows connections to servers with TLS versions less than 1.2 |
| `NSExceptionRequiresForwardSecrecy` | Disable perfect forward secrecy (PFS) |


Starting from January 1 2017, Apple App Store review and requires justification if one of the following ATS exceptions are defined. However this decline is extended later by Apple stating “To give you additional time to prepare, this deadline has been extended and we will provide another update when a new deadline is confirmed”<sup>[5]</sup>

* `NSAllowsArbitraryLoads`
* `NSAllowsArbitraryLoadsForMedia`
* `NSAllowsArbitraryLoadsInWebContent`
* `NSExceptionAllowsInsecureHTTPLoads`
* `NSExceptionMinimumTLSVersion`

#### Static Analysis

If the source code is available, open then `Info.plist` file in the application bundle directory using a text editor and look for any exceptions that the application developer has configured. This file should be examined taking the applications context into consideration. 

The following listing is an example of an exception configured to disable ATS restrictions globally. 

```
	<key>NSAppTransportSecurity</key>
	<dict>
		<key>NSAllowsArbitraryLoads</key>
		<true/>
	</dict>
```

If the source code is not available, then the `Info.plist` file should be either can be obtained from a jailbroken device or by extracting the application IPA file.

Since IPA files are ZIP archives, they can be extracted using any zip utility.

```
$ unzip app-name.ipa
```

`Info.plist` file can be found in the `Payload/BundleName.app/` directory of the extract. It’s a binary encoded file and has to be converted to a human readable format for the analysis. 

`plutil`<sup>[6]</sup> is a tool that’s designed for this purpose. It comes natively with Mac OS 10.2 and above versions.

The following command shows how to convert the Info.plist file into XML format.
```
$ plutil -convert xml1 Info.plist
```

Once the file is converted to a human readable format, the exceptions can analysed. The application may have ATS exceptions defined to allow it’s normal functionality. For an example, the Firefox iOS application has ATS disabled globally. This exception is acceptable because otherwise the application would not be able to connect to any HTTP web sites or website that do not have the ATS requirements.


#### Dynamic Analysis

--TODO

#### Remediation
* ATS should always be activated and only be deactivated under certain circumstances.
* If the application connects to a defined number of domains that the application owner controls, then configure the servers to support the ATS requirements and opt-in for the ATS requirements within the app. In the following example, `example.com` is owned by the applicaiton owner and ATS is enabled for that domain.
```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>example.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <true/>
        </dict>
    </dict>
</dict>
```

* If connections to 3rd party domains are made (that are not under control of the app owner) it should be evaluated what ATS settings are not supported by the 3rd party domain and deactivated.
* If the application opens third party web sites in web views, then from iOS 10 onwards NSAllowsArbitraryLoadsInWebContent can be used to disable ATS restrictions for the content loaded in web views 

#### References

— TODO —

##### OWASP Mobile Top 10 2016

* M3 - Insufficient Transport Layer Protection - https://www.owasp.org/index.php/Mobile_Top_10_2014-M3

##### OWASP MASVS

* V5.1: "Data is encrypted on the network using TLS. The secure channel is used consistently throughout the app."
* V5.2: "The TLS settings are in line with current best practices, or as close as possible if the mobile operating system does not support the recommended standards."

##### CWE

— TODO —

##### Info

* [1] Information Property List Key Reference: Cocoa Keys - https://developer.apple.com/library/content/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html
* [2] API Reference NSURLConnection - https://developer.apple.com/reference/foundation/nsurlconnection
* [3] API Reference NSURLSession - https://developer.apple.com/reference/foundation/urlsession
* [4] API Reference CFURL - https://developer.apple.com/reference/corefoundation/cfurl-rd7
* [5] Apple Developer Portal Announcement - Supporting App Transport Security - https://developer.apple.com/news/?id=12212016b
* [6] OS X Man Pages - Plutil - https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man1/plutil.1.html

##### Tools

— TODO —

### Testing Endpoint Identity Verification

#### Overview

-- TODO [Provide a general description of the issue "Testing Endpoint Identity Verification".]

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Add content on "Testing Endpoint Identity Verification" with source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing Endpoint Identity Verification" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Endpoint Identity Verification".] --

#### References

#### OWASP Mobile Top 10 2016

* M3 - Insecure Communication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M3-Insecure_Communication

##### OWASP MASVS

* V5.3: "The app verifies the X.509 certificate of the remote endpoint when the secure channel is established. Only certificates signed by a valid CA are accepted."

##### CWE

* CWE-296 - Improper Following of a Certificate's Chain of Trust - https://cwe.mitre.org/data/definitions/296.html
* CWE-297 - Improper Validation of Certificate with Host Mismatch - https://cwe.mitre.org/data/definitions/297.html
* CWE-298 - Improper Validation of Certificate Expiration - https://cwe.mitre.org/data/definitions/298.html

##### Info

- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add relevant tools for "Testing Endpoint Identity Verification"] --


### Testing Custom Certificate Stores and SSL Pinning

#### Overview

Certificate pinning allows to hard-code in the client the certificate that is known to be used by the server. This technique is used to reduce the threat of a rogue CA and CA compromise. Pinning the server’s certificate take the CA out of games. Mobile applications that implement certificate pinning only can connect to a limited numbers of servers, as a small list of trusted CAs or server certificates are hard-coded in the application.

#### Static Analysis

The code presented below shows how it is possible to check if the certificate provided by the server reflects the certificate hard-coded  in the application. The method below implements the connection authentication tells the delegate that the connection will send a request for an authentication challenge.

The delegate must implement connection:canAuthenticateAgainstProtectionSpace: and connection: forAuthenticationChallenge. Within connection: forAuthenticationChallenge, the delegate must call SecTrustEvaluate to perform customary X509 checks. Below a snippet who implements a check of the certificate.  

```Objective-C
(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
  SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
  SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, 0);
  NSData *remoteCertificateData = CFBridgingRelease(SecCertificateCopyData(certificate));
  NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"MyLocalCertificate" ofType:@"cer"];
  NSData *localCertData = [NSData dataWithContentsOfFile:cerPath];
  The control below can verify if the certificate received by the server is matching the one pinned in the client.
  if ([remoteCertificateData isEqualToData:localCertData]) {
  NSURLCredential *credential = [NSURLCredential credentialForTrust:serverTrust];
  [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}
else {
  [[challenge sender] cancelAuthenticationChallenge:challenge];
}
```

#### Dynamic Analysis

##### Server certificate validation

We start our analysis by testing the application's behaviour while establishing secure connection. Our test approach is to gradually relax security of SSL handshake negotiation and check which security mechanisms are enabled.

1. Having burp set up as a proxy in wifi settings, make sure that there is no certificate added to trust store (Settings -> General -> Profiles) and that tools like SSL Kill Switch are deactivated. Launch your application and check if you can see the traffic in Burp. Any failures will be reported under 'Alerts' tabl. If you can see the traffic, it means that there is no certificate validation performed at all! This effectively means that an active attacker can silently do MiTM against your application. If however, you can't see any traffic and you have an information about SSL handshake failure, follow the next point.
2. Now, install Burp certificate, as explained in [Basic Security Testing section](./0x06b-Basic-Security-Testing.md). If the handshake is successful and you can see the traffic in Burp, it means that certificate is validated against device's trust store, but the pinning is not performed. The risk is less significant than in previous scenario, as two main attack scenarios at this point are misbehaving CAs and phishing attacks, as discussed in [Basic Security Testing section](./0x06b-Basic-Security-Testing.md).
3. If executing instructions from previous step doesn't lead to traffic being proxied through burp, it means that certificate is actually pinned and all security measures are in place. However, you still need to bypass the pinning in order to test the application. Please refer to [Basic Security Testing section](./0x06b-Basic-Security-Testing.md) for more information on this.

##### Client certificate validation

Some applications use two-way SSL handshake, meaning that application verifies server's certificate and server verifies client's certificate. You can notice this if there is an error in Burp 'Alerts' tab indicating that client failed to negotiate connection.

There is a couple of things worth noting:

1. client certificate contains private key that will be used in key exchange
2. usually certificate would also need a password to use (decrypt) it
3. certificate itself can be stored in the binary itself, data directory or the keychain

Most common and improper way of doing two-way handshake is to store client certificate within the application bundle and hardcode the password. This obviously does not bring much security, because all clients will share the same certificate.

Second way of storing the certificate (and possibly password) is to use the keychain. Upon first login, the application should download personal certificate and store it securely in the keychain.

Sometimes application have one certificate that is hardcoded and used for first login and then personal certificate is downloaded. In this case, check if it's possible to still use the 'generic' certificate to connect to the server.

Once you have extracted the certificate from the application (e.g. using Cycript or Frida), add it as client certificate in Burp, and you will be able to intercept the traffic.

#### Remediation

As a best practice, the certificate should be pinned. This can be done in several ways, where most common include:

1. Including server's certificate in the application bundle and performing verification on each connection. This requires an update mechanisms whenever the certificate on the server is updated
2. Limiting certificate issuer to e.g. one entity and bundling the root CA's public key into the application. In this way we limit the attack surface and have a valid certificate.
3. Owning and managing your own PKI. The application would contain the root CA's public key. This avoids updating the application every time you change the certificate on the server, due to e.g. expiration. Note that using your own CA would cause the certificate to be self-singed.

#### References

##### OWASP Mobile Top 10 2016

* M3 - Insecure Communication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M3-Insecure_Communication

##### OWASP MASVS

* V5.4 "The app either uses its own certificate store, or pins the endpoint certificate or public key, and subsequently does not establish connections with endpoints that offer a different certificate or key, even if signed by a trusted CA."

##### CWE

* CWE-295 - Improper Certificate Validation

##### Info

* [1] Setting Burp Suite as a proxy for iOS Devices : https://support.portswigger.net/customer/portal/articles/1841108-configuring-an-ios-device-to-work-with-burp
* [2] OWASP - Certificate Pinning for iOS : https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#iOS
