## Testing Network Communication

The following chapter outlines network communication requirements of the MASVS into technical test cases. Test cases listed in this chapter are focused on server side and therefore are not relying on a specific implementation on iOS or Android.  

### Verifying the TLS Settings

#### Overview

Using encryption is essential when you are sending confidential data. However, encryption can defend your privacy, only if it uses enough strong cryptography. To reach this goal SSL-based services should not offer the possibility to choose weak cipher suite. A cipher suite is specified by an encryption protocol (e.g. DES, RC4, AES), the encryption key length (e.g. 40, 56, or 128 bits), and a hash algorithm (e.g. SHA, MD5) used for integrity checking. To ensure, that your encryption cannot be easily defeated, you should verify your TLS configuration that it does not use any weak cipher/protocol/key [1].

#### Static Analysis

Static analysis is not applicable for this test case.

#### Dynamic Analysis

After identifying all servers communicating with your application (e.g. using Tcpdump, or Burp Suite) you should verify if they allow the usage of weak ciphers, protocols or keys. It can be done, using different tools:

* testssl.sh: via following command:

The Github repo of testssl.sh offers also a compiled openssl version for download that supports **all ciphersuites and protocols including SSLv2**.

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
or via command. There are multiple options, which can be specified here [2], but the most general one, verifying certificate, ciphers and SSL connection is the following:

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

##### Tools
* testssl.sh- https://testssl.sh
* sslyze - https://github.com/nabla-c0d3/sslyze
* O-Saft - https://www.owasp.org/index.php/O-Saft
