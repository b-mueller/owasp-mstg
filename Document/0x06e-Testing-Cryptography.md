## Testing Cryptography in iOS Apps

### Testing for Hardcoded Cryptographic Keys

#### Overview

-- TODO [Note: The content originally found in this test case was moved to 0x07c - Testing cryptography. This test case should pertain only to finding hardcoded keys on iOS (how are they typically used and stored,... )] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Verifying Cryptographic Key Management" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Verifying Cryptographic Key Management".] --

#### References

##### OWASP Mobile Top 10 2016
* M5 - Insufficient Cryptography - https://www.owasp.org/index.php/Mobile_Top_10_2016-M5-Insufficient_Cryptography

##### OWASP MASVS
* V3.1: "The app does not rely on symmetric cryptography with hardcoded keys as a sole method of encryption."
* V3.5: "The app doesn't re-use the same cryptographic key for multiple purposes."

##### CWE
* CWE-320: Key Management Errors
* CWE-321: Use of Hard-coded Cryptographic Key

##### Info
- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add links to relevant tools] --

### Verifying the Configuration of Cryptographic Standard Algorithms

#### Overview

Apple provides libraries with implementations of most commonly used cryptographic algorithms. A good point of reference is Apple's  Cryptographic Services Guide <sup>[1]</sup>. It contains broad documentation on how to use standard libraries to initialize and use cryptographic primitives, which is also useful when performing source code analysis.
For dynamic testing, more useful is native C API, for instance CommonCryptor, that is most frequently used when performing cryptographic operations. Source code is partially available at the Apple open source repository<sup>[2]</sup>.

#### Static Analysis

The main goal of static analysis is to ensure the following:

* Cryptographic algorithms are up to date and in-line with industry standards. This includes, but is not limited to outdated block ciphers (e.g. DES), stream ciphers (e.g. RC4), as well as hash functions (e.g. MD5) and broken random number generators like Dual_EC_DRBG (even if they are NIST certified). All of these should be marked as insecure and should not be used and removed from the application and server.
* Key lengths are in-line with industry standards and provide protection for sufficient amount of time. An online comparison of different key lengths and protection they provide taking into account Moore's law is available online<sup>[3]</sup>.
* Cryptographic parameters are well defined within reasonable range. This includes, but is not limited to: cryptographic salt, which should be at least the same length as hash function output, reasonable choice of password derivation function and iteration count (e.g. PBKDF2, scrypt or bcrypt), IVs being random and unique, fit-for-purpose block encryption modes (e.g. ECB should not be used, except specific cases), key management being done properly (e.g. 3DES should have three independent keys) and so on.

If the app is using standard cryptographic implementations provided by Apple, the easiest way is to decompile the application and check for calls to functions from `CommonCryptor`, such as `CCCrypt`, `CCCryptorCreate`, etc. The source code<sup>[4]</sup> contains signatures of all functions.
For instance, `CCCryptorCreate` has following signature:
```
CCCryptorStatus CCCryptorCreate(
	CCOperation op,             /* kCCEncrypt, etc. */
	CCAlgorithm alg,            /* kCCAlgorithmDES, etc. */
	CCOptions options,          /* kCCOptionPKCS7Padding, etc. */
	const void *key,            /* raw key material */
	size_t keyLength,
	const void *iv,             /* optional initialization vector */
	CCCryptorRef *cryptorRef);  /* RETURNED */
```

You can then compare all the `enum` types to understand which algorithm, padding and key material is being used. Pay attention to the keying material, if it's coming directly from a password (which is bad), or if it's coming from Key Generation Function (e.g. PBKDF2).
Obviously, there are other non-standard libraries that your application might be using (for instance `openssl`), so you should check for these too.

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Verifying the Configuration of Cryptographic Standard Algorithms" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Verifying the Configuration of Cryptographic Standard Algorithms".] --

#### References

##### OWASP Mobile Top 10 2016
* M5 - Insufficient Cryptography - https://www.owasp.org/index.php/Mobile_Top_10_2016-M5-Insufficient_Cryptography

##### OWASP MASVS
* V3.3: "The app uses cryptographic primitives that are appropriate for the particular use-case, configured with parameters that adhere to industry best practices."
* V3.4: "The app does not use cryptographic protocols or algorithms that are widely considered depreciated for security purposes."

##### CWE
-- TODO [Add relevant CWE for "Verifying the Configuration of Cryptographic Standard Algorithms"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

* [1] Apple Cryptographic Services Guide - https://developer.apple.com/library/content/documentation/Security/Conceptual/cryptoservices/GeneralPurposeCrypto/GeneralPurposeCrypto.html
* [2] Apple Open Source - https://opensource.apple.com
* [3] Keylength comparison - https://www.keylength.com/
* [4] CommonCryptoer.h - https://opensource.apple.com/source/CommonCrypto/CommonCrypto-36064/CommonCrypto/CommonCryptor.h

##### Tools

-- TODO [Add links to relevant tools for "Verifying the Configuration of Cryptographic Standard Algorithms"] --
* Enjarify - https://github.com/google/enjarify



### Testing Random Number Generation

#### Overview

To test for the security implementation of the random number generation, it is essential to understand what is it about. In essence, the concept of Random number generation is to perform the generation of a sequence of numbers or symbols that cannot be reasonably predicted better than by a random chance, usually through a Random Number Generator (RNG).

#### Static Analysis

In static analysis where we have the source code of the application, it is important to understand how it works and identify the code snippet that perform the function; in this case, the random number generation. In iOS, Apple has provided developers with the Randomisation Services application programming interface (API) that generates cryptographically secure random numbers<sup>[1]</sup>.

The Randomisation Services API uses the `SecRandomCopyBytes` function to perform the numbers generation. It is reliably random because it is a wrapper function for `/dev/random` device file, which provides cryptographically secure pseudorandom value from 0 to 255 and perform concatenation<sup>[2]</sup>. 

The following is the `SecRandomCopyBytes` function API in Swift<sup>[3]</sup>:
```
func SecRandomCopyBytes(_ rnd: SecRandomRef?, 
                      _ count: Int, 
                      _ bytes: UnsafeMutablePointer<UInt8>) -> Int32
```

The following is the `SecRandomCopyBytes` function API in Objective-C<sup>[4]</sup>:
```
int SecRandomCopyBytes(SecRandomRef rnd, size_t count, uint8_t *bytes);
```

The following is an example of its usage:
```
int result = SecRandomCopyBytes(kSecRandomDefault, 16, randomBytes);
```

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing Random Number Generation" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

-- TODO [Can probably write about generating multiple values via the random number generation and compare them to analyse the entropy] --

#### Remediation

The recommended remediation to fix this issue is to always use the Randomisation Services API for any random number generation purposes. 
Avoid implementing custom cryptography algorithms and standards. Also, only supply cryptographically strong random numbers to cryptographic functions. 

#### References

##### OWASP Mobile Top 10 2016
* M5 - Insufficient Cryptography - https://www.owasp.org/index.php/Mobile_Top_10_2016-M5-Insufficient_Cryptography

##### OWASP MASVS
* V3.6: "All random values are generated using a sufficiently secure random number generator."

##### CWE
- CWE-337 - Predictable Seed in PRNG
- CWE-338 - Use of Cryptographically Weak Pseudo-Random Number Generator (PRNG)

##### Info
- [1] Randomization Services - https://developer.apple.com/reference/security/randomization_services
- [2] Generating Random Numbers - https://developer.apple.com/library/content/documentation/Security/Conceptual/cryptoservices/RandomNumberGenerationAPIs/RandomNumberGenerationAPIs.html
- [3] SecRandomCopyBytes (Swift) - https://developer.apple.com/reference/security/1399291-secrandomcopybytes
- [4] SecRandomCopyBytes (Objective-C) - https://developer.apple.com/reference/security/1399291-secrandomcopybytes?language=objc

##### Tools
-- TODO [Add links to relavant tools for "Testing Random Number Generation"] --
* Enjarify - https://github.com/google/enjarify
