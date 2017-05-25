## Testing Cryptography

The following chapter outlines cryptography requirements of the MASVS into technical test cases. Test cases listed in this chapter are focused on server side and therefore are not relying on a specific implementation on iOS or Android.

Proper cryptographic key management is a common pitfall when designing mobile applications.

### Testing for Insecure and/or Deprecated Cryptographic Algorithms

#### Overview

Choosing strong cryptographic algorithm alone is not enough. Often security of otherwise sound algorithms can be affected if misconfigured. Many previously strong algorithms and their configurations are now considered vulnerable or non-compliant with best practices. It is therefore important to periodically check current best practices and adjust configurations accordingly.  

Many cryptographic algorithms and protocols should not be used because they have been shown to have significant weaknesses or are otherwise insufficient for modern security requirements.

#### Static Analysis

The following list shows different checks to validate the usage of cryptographic algorithms in source code:

* Cryptographic algorithms are up to date and in-line with industry standards. This includes, but is not limited to outdated block ciphers (e.g. DES), stream ciphers (e.g. RC4), as well as hash functions (e.g. MD5) and broken random number generators like Dual_EC_DRBG (even if they are NIST certified). All of these should be marked as insecure and should not be used and removed from the app and server code base.
* Key lengths are in-line with industry standards and provide protection for sufficient amount of time. An online comparison of different key lengths and protection they provide taking into account Moore's law is available online<sup>[3]</sup>.
* Cryptographic parameters are well defined within reasonable range. This includes, but is not limited to: cryptographic salt, which should be at least the same length as hash function output, reasonable choice of password derivation function and iteration count (e.g. PBKDF2, scrypt or bcrypt), IVs being random and unique, fit-for-purpose block encryption modes (e.g. ECB should not be used, except specific cases), key management being done properly (e.g. 3DES should have three independent keys) and so on.

Inspect the source code to identify the instances of cryptographic algorithms throughout the application, and look for known weak ones, such as:

* DES
* RC2
* RC4
* BLOWFISH
* CRC32
* MD4
* MD5
* SHA1 and others.

See "Remediation" section for a basic list of recommended algorithms.

Example initialization of DES algorithm, that is considered weak:
```Java
Cipher cipher = Cipher.getInstance("DES");
```

##### Block cipher encryption modes
ECB (Electronic Codebook) encryption mode should not be used, as it is basically a raw cipher. A message is divided into blocks of fixed size and each block is encrypted separately<sup>[6]</sup>.

![Electronic Codebook (ECB mode encryption)](Images/Chapters/0x07c/ECB.png)

The problem with this encryption method is that any resident properties of the plaintext might well show up in the cipher text, just possibly not as clearly. That's what blocks and key schedules are supposed to protect against, but analyzing the patterns you may be able to deduce properties that you otherwise thought were hidden.

![Difference of encryption modes](Images/Chapters/0x07c/EncryptionMode.png)

#### Dynamic Analysis

-- TODO [Give examples of Dynamic Testing for "Testing for Insecure and/or Deprecated Cryptographic Algorithms"] --

#### Remediation

Periodically ensure that the cryptography has not become obsolete. Some older algorithms, once thought to require years of computing time, can now be broken in days or hours. This includes MD4, MD5, SHA1, DES, and other algorithms that were once considered as strong. Examples of currently recommended algorithms<sup>[1] [2]</sup>:

* Confidentiality: AES-256
* Integrity: SHA-256, SHA-384, SHA-512
* Digital signature: RSA (3072 bits and higher), ECDSA with NIST P-384
* Key establishment: RSA (3072 bits and higher), DH (3072 bits or higher), ECDH with NIST P-384

#### References

##### OWASP Mobile Top 10
* M6 - Broken Cryptography

##### OWASP MASVS
- V3.3: "The app uses cryptographic primitives that are appropriate for the particular use-case, configured with parameters that adhere to industry best practices"
- V3.4: "The app does not use cryptographic protocols or algorithms that are widely considered depreciated for security purposes"

##### CWE
* CWE-326: Inadequate Encryption Strength
* CWE-327: Use of a Broken or Risky Cryptographic Algorithm

##### Info
- [1] Commercial National Security Algorithm Suite and Quantum Computing FAQ - https://cryptome.org/2016/01/CNSA-Suite-and-Quantum-Computing-FAQ.pdf
- [2] NIST Special Publication 800-57 - http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-57pt1r4.pdf
- [3] Security "Crypto" provider deprecated in Android N -  https://android-developers.googleblog.com/2016/06/security-crypto-provider-deprecated-in.html
- [4] NIST recommendations (2016) - https://www.keylength.com/en/4/
- [5] BSI recommendations (2017) - https://www.keylength.com/en/8/
- [6] Electronic Codebook (ECB) - https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Electronic_Codebook_.28ECB.29

##### Tools
* QARK - https://github.com/linkedin/qark
* Mobile Security Framework - https://github.com/ajinabraham/Mobile-Security-Framework-MobSF



### Testing for Custom Implementations of Cryptography

-- [TODO - needs more review / editing ] --

#### Overview

The use of a non-standard and custom build algorithm for cryptographic functionalities is dangerous because a determined attacker may be able to break the algorithm and compromise data that has been protected. Implementing cryptographic functions is time consuming, difficult and likely to fail. Instead well-known algorithms that were already proven to be secure should be used. All mature frameworks and libraries offer cryptographic functions that should also be used when implementing mobile apps.

#### Static Analysis

Carefully inspect all the cryptographic methods used within the source code, especially those which are directly applied to sensitive data. Pay close attention to seemingly standard but modified algorithms. Remember that encoding is not encryption! Any appearance of bit shift operators like exclusive OR operations might be a good sign to start digging deeper.

-- [TODO - The below content was merged from the old iOS 'Verifying Cryptographic Key Management' section. This section needs some review and editing] --

During static analysis, it is important understand how cryptographic algorithms used by the particular target app. Let us divide applications into three main categories:

1. An application is a pure online application, where authentication, authorization is done online with application server and no information is stored locally.
2. An application is mainly an offline application, where authentication and authorization is done purely locally. Application information is stored also locally.
3. An application is a mixture of the first two, i.e. it supports both: online and offline authentication, some information may be stored locally and some or all actions that are performed online may be performed offline.
   * A good example of such an app, may be point of sale (POS), where seller may sell products. The app requires connection to the internet, so that it can communicate with backend and update information on products that were sold, cash amount, etc. However, there might be a business requirement that this app must also work in offline mode and would synchronize all information once it connects back to the internet. This will be a mixed app type, i.e. online and offline.

The following checks would be performed in the last two app categories:

* Ensure that no keys/passwords are hardcoded and stored within the source code. Pay special attention to any 'administrative' or backdoor accounts enabled in the source code. Storing fixed salt within application or password hashes may cause problems too.
* Ensure that no obfuscated keys or passwords are in the source code. Obfuscation is easily bypassed by dynamic instrumentation and in principle does not differ from hardcoded keys.
* If the application is using two-way SSL (i.e. there is both server and client certificate validated) check if:
   * the password to the client certificate is not stored locally, it should be in the Keychain
   * the client certificate is not shared among all installations (e.g. hardcoded in the app)

A proper way would be to generate the client certificate upon user registration/first login and then store it in the Keychain.

* Ensure that the keys/passwords/logins are not stored in application data. This can be included in the iTunes backup and increase attack surface. Keychain is the only appropriate place to store credentials of any type (password, certificate, etc.).
* Ensure that keychain entries have appropriate protection class. The most rigorous being `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` which translates to: entry unlocked only if passcode on the device is set and device is unlocked; the entry is not exportable in backups or by any other means.

The following checks would be performed in the offline application:

* if the app relies on an additional encrypted container stored in app data, ensure how the encryption key is used;
   * if key wrapping scheme is used, ensure that the master secret is initialized for each user, or container is re-encrypted with new key;
   * check how password change is handled and specifically, if you can use master secret or previous password to decrypt the container.

#### Dynamic Analysis

The recommended approach is be to decompile the APK and inspect the algorithm to see if custom encryption schemes is really the case (see "Static Analysis").

#### Remediation

Do not develop custom cryptographic algorithms, as it is likely they are prone to attacks that are already well-understood by cryptographers.

When there is a need to store sensitive data, use strong, up-to-date cryptographic algorithms. Select a well-vetted algorithm that is currently considered to be strong by experts in the field, and use well-tested implementations. The KeyStore is suitable for storing sensitive information locally and a list of strong ciphers offered by it can be found in the Android documentation<sup>[1]</sup>.

#### References

##### OWASP Mobile Top 10 2016
* M6 - Broken Cryptography

##### OWASP MASVS
- V3.2: "The app uses proven implementations of cryptographic primitives"

##### CWE
* CWE-327: Use of a Broken or Risky Cryptographic Algorithm

##### Info
[1] Supported Ciphers in KeyStore - https://developer.android.com/training/articles/keystore.html#SupportedCiphers
