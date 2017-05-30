## Testing Cryptography

The following chapter outlines cryptography requirements of the MASVS into technical test cases. Test cases listed in this chapter are focused on server side and therefore are not relying on a specific implementation on iOS or Android.

Proper cryptographic key management is a common pitfall when designing mobile applications.

Cryptographic systems are comprised of different building blocks. It is important to use the building blocks in their intended manner (in addition to using the current secure building blocks as well as secure configuration).

Typically encountered building blocks are:

* Hashes are used to quickly calculate a fixed-length checksum based upon the original data. The same input data will produce the same output hash. Cryptographic hashes guarantee, that the generated hash will limit reasoning about the original data, that small changes within the original date will produce a completely different hash and that it is hard that, given a hash, to provide for original data that leads to a pre-determined hash. As no secret keys are used, an attacker can recalculate a new hash after data was modified.
* Encryption converts the original plain-text data into encrypted text and subsequently allows to reconstruct the original data form the encrypted text (also known as cipher text). Thus it provides data confidenciality. Please note that, encryption does not provide data integrity, i.e., if an attacker modifies the cipher text and a user decrypts the modified cipher text, the resulting plain-text will be garbage (but the decryption operation itself will perform successfully).
* Symmetric Encryption utilizes a secret key. The data confidenciality of the encrypted data is solely dependent upon the confidenciality of the secret key.
* Asymmetric Encryption uses two keys: a pbulic key that can be used to encrypt plain-text and a secret private key that can be used to reconstruct the original data from the plain-text.

### Testing for Insecure and/or Deprecated Cryptographic Algorithms

#### Overview

Many cryptographic algorithms and protocols should not be used because they have been shown to have significant weaknesses or are otherwise insufficient for modern security requirements. Previously thought secure algorithms may become insecure over time. It is therefore important to periodically check current best practices and adjust configurations accordingly.  

#### Static Analysis

The following list shows different checks to validate the usage of cryptographic algorithms in source code:

* Cryptographic algorithms are up to date and in-line with industry standards. This includes, but is not limited to outdated block ciphers (e.g. DES), stream ciphers (e.g. RC4), as well as hash functions (e.g. MD5) and broken random number generators like Dual_EC_DRBG (even if they are NIST certified). All of these should be marked as insecure and should not be used and removed from the app and server code base.
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
- [4] NIST recommendations (2016) - https://www.keylength.com/en/4/
- [5] BSI recommendations (2017) - https://www.keylength.com/en/8/

##### Tools
* QARK - https://github.com/linkedin/qark
* Mobile Security Framework - https://github.com/ajinabraham/Mobile-Security-Framework-MobSF

 


### Testing for Insecure Cryptographic Algorihm Configuration

#### Overview

Choosing strong cryptographic algorithm alone is not enough. Often security of otherwise sound algorithms can be affected if misconfigured.

#### Static Analysis

The following list shows different checks to validate the usage of cryptographic algorithms in source code:

* Key lengths are in-line with industry standards and provide protection for sufficient amount of time. An online comparison of different key lengths and protection they provide taking into account Moore's law is available online<sup>[3]</sup>.
* Cryptographic parameters are well defined within reasonable range. This includes, but is not limited to: cryptographic salt, which should be at least the same length as hash function output, reasonable choice of password derivation function and iteration count (e.g. PBKDF2, scrypt or bcrypt), IVs being random and unique, fit-for-purpose block encryption modes (e.g. ECB should not be used, except specific cases), key management being done properly (e.g. 3DES should have three independent keys) and so on.

#### Dynamic Analysis

-- TODO [Give examples of Dynamic Testing for "Testing for Insecure and/or Deprecated Cryptographic Algorithms"] --

#### Remediation

Periodically ensure that used key length fulfill accepted industry standards.

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

##### Tools
* QARK - https://github.com/linkedin/qark
* Mobile Security Framework - https://github.com/ajinabraham/Mobile-Security-Framework-MobSF



### Testing for Custom Implementations of Cryptography

#### Overview

The use of a non-standard and custom build algorithm for cryptographic functionalities is dangerous because a determined attacker may be able to break the algorithm and compromise data that has been protected. Implementing cryptographic functions is time consuming, difficult and likely to fail. Instead well-known algorithms that were already proven to be secure should be used. All mature frameworks and libraries offer cryptographic functions that should also be used when implementing mobile apps.

#### Static Analysis

Carefully inspect all the cryptographic methods used within the source code, especially those which are directly applied to sensitive data. Pay close attention to seemingly standard but modified algorithms. Remember that encoding is not encryption! Any appearance of bit shift operators like exclusive OR operations might be a good sign to start digging deeper.

#### Dynamic Analysis

The recommended approach is be to decompile the APK and inspect the algorithm to see if custom encryption schemes is really the case (see "Static Analysis").

#### Remediation

Do not develop custom cryptographic algorithms, as it is likely they are prone to attacks that are already well-understood by cryptographers. Select a well-vetted algorithm that is currently considered to be strong by experts in the field, and use well-tested implementations.

#### References

##### OWASP Mobile Top 10 2016
* M6 - Broken Cryptography

##### OWASP MASVS
- V3.2: "The app uses proven implementations of cryptographic primitives"

##### CWE
* CWE-327: Use of a Broken or Risky Cryptographic Algorithm

##### Info
[1] Supported Ciphers in KeyStore - https://developer.android.com/training/articles/keystore.html#SupportedCiphers




### Testing for Usage of ECB Mode

#### Overview

-- TODO: write Introduction --

ECB (Electronic Codebook) encryption mode should not be used, as it is basically a raw cipher. A message is divided into blocks of fixed size and each block is encrypted separately<sup>[6]</sup>.

![Electronic Codebook (ECB mode encryption)](Images/Chapters/0x07c/ECB.png)

The problem with this encryption method is that any resident properties of the plaintext might well show up in the cipher text, just possibly not as clearly. That's what blocks and key schedules are supposed to protect against, but analyzing the patterns you may be able to deduce properties that you otherwise thought were hidden.

![Difference of encryption modes](Images/Chapters/0x07c/EncryptionMode.png)

#### Static Analysis

The following list shows different checks to validate the usage of cryptographic algorithms in source code:

-- TODO --

See "Remediation" section for a basic list of recommended algorithms.

#### Dynamic Analysis

-- TODO [Give examples of Dynamic Testing for "Testing for Insecure and/or Deprecated Cryptographic Algorithms"] --

#### Remediation

-- TODO --

Periodically ensure that the cryptography has not become obsolete. Some older algorithms, once thought to require years of computing time, can now be broken in days or hours. This includes MD4, MD5, SHA1, DES, and other algorithms that were once considered as strong. Examples of currently recommended algorithms<sup>[1] [2]</sup>:

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
- [6] Electronic Codebook (ECB) - https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Electronic_Codebook_.28ECB.29

##### Tools
* QARK - https://github.com/linkedin/qark
* Mobile Security Framework - https://github.com/ajinabraham/Mobile-Security-Framework-MobSF



### Testing if anything but a KDF (key-derivation function) is used for storing passwords

#### Overview

-- TODO: write Introduction --

* move text from generic description to this section
* describe hashes vs key-derivation-function
*
* Key Derivation Functions (KDFs): normal hashes are optimized for speed, e.g., optimized to verify large media in short time. For password storage this property is not desirable as it implies that an attacker can crack retrieved password hashes (using rainbow tables or through brute-force attacks) in a short time. A solution this are Key-Derivation Functions (KDFs) that have a configurable calculation time. While this imposes a larger performance overhead this is neglectable during normal operation but prevents brute-force attacks.

#### Static Analysis

-- TODO --

* check source code for used algorithm

#### Dynamic Analysis

-- TODO [Give examples of Dynamic Testing for "Testing for Insecure and/or Deprecated Cryptographic Algorithms"] --

* check extracted hashes with ocl hashcat

#### Remediation

-- TODO --

* use bcrypt/scrypt

#### References

##### OWASP Mobile Top 10

-- TODO --

##### OWASP MASVS

-- TODO --

##### CWE

-- TODO --

##### Info

-- TODO --

* link to oclhashcat performance values

##### Tools

-- TODO --

* link to ocl hashcat



### Test if user-supplied credentials are not directly used as key material

#### Overview

-- TODO: write Introduction --

* sometimes a password is directly used as key for cryptographic functions
* sometimes it is even filled with spaces to achieve the cryptographic' algorithm's requirements

#### Static Analysis

-- TODO --

* check source code for used algorithm

#### Dynamic Analysis

-- TODO [Give examples of Dynamic Testing for "Testing for Insecure and/or Deprecated Cryptographic Algorithms"] --

* check extracted hashes with ocl hashcat

#### Remediation

-- TODO --

* use password as input data for a secure hashing function
* this improves the keyspace of the selected cryptographic function

#### References

##### OWASP Mobile Top 10

-- TODO --

##### OWASP MASVS

-- TODO --

##### CWE

-- TODO --

##### Info

-- TODO --

* link to oclhashcat performance values

##### Tools

-- TODO --

* link to ocl hashcat


### Test if sensitive data is integrity protected

#### Overview

-- TODO: write Introduction --


* MACs (Message Authentication Codes, also known as keyed hashes) combine hashes with a secret key. The MAC can only be calculated or verified if the secret key is known. In contrast to hashes this means, that an attacker cannot easily calculate a MAC after the original data was modified.
* Digital Signatures are a public key-based scheme where, instead of a single secret key, a combination of a secret private key and a a public key is sued. The signature is created utilizing the secret key and can be verified utilizing the public key. Similar to MACs, an attacker cannot easily create a new signature. In contrast to MACs, signatures allow verification without needed to disclose the secret key. Why is not everyone using Signatures instead of MACs? Mostly for performance reasons.

* maybe mention the whole mac-then-encrypt vs encrypt-then-mac problems
*
#### Static Analysis

-- TODO --

* check source code for used algorithm

#### Dynamic Analysis

-- TODO --


#### Remediation

-- TODO --

* use integrity-preserving encryption
* use AEAD based encryption for data storage (provides confidenciality as well as integrity protection)
* use digital signatures

#### References

##### OWASP Mobile Top 10

-- TODO --

##### OWASP MASVS

-- TODO --

##### CWE

-- TODO --

##### Info

-- TODO --

##### Tools

-- TODO --


### Test if encryption provides data integrity protection

#### Overview

-- TODO: write Introduction --

* encryption only protects data confidenciality, not integrity
* e.g., bit-flip attacks are possible

#### Static Analysis

-- TODO --

* check source code for used algorithm

#### Dynamic Analysis

-- TODO [Give examples of Dynamic Testing for "Testing for Insecure and/or Deprecated Cryptographic Algorithms"] --

#### Remediation

-- TODO --

* use integrity-preserving encryption
* maybe mention the whole mac-then-encrypt vs encrypt-then-mac problems
* use AEAD based encryption for data storage (provides confidenciality as well as integrity protection)

#### References

##### OWASP Mobile Top 10

-- TODO --

##### OWASP MASVS

-- TODO --

##### CWE

-- TODO --

##### Info

-- TODO --

##### Tools

-- TODO --




### if symmetric encryption or MACs are used, test for hard coded secret keys

#### Overview

-- TODO: write Introduction --

The following checks would be performed in the last two app categories:

* Ensure that no keys/passwords are hardcoded and stored within the source code. Pay special attention to any 'administrative' or backdoor accounts enabled in the source code. Storing fixed salt within application or password hashes may cause problems too.
* Ensure that no obfuscated keys or passwords are in the source code. Obfuscation is easily bypassed by dynamic instrumentation and in principle does not differ from hardcoded keys.
* If the application is using two-way SSL (i.e. there is both server and client certificate validated) check if:
   * the password to the client certificate is not stored locally, it should be in the Keychain
   * the client certificate is not shared among all installations (e.g. hardcoded in the app)


The following checks would be performed in the offline application:

* if the app relies on an additional encrypted container stored in app data, ensure how the encryption key is used;
   * if key wrapping scheme is used, ensure that the master secret is initialized for each user, or container is re-encrypted with new key;
   * check how password change is handled and specifically, if you can use master secret or previous password to decrypt the container.


#### Static Analysis

-- TODO --

* check source code for used key strings
* check property files for used keys
* check files for used keys

A proper way would be to generate the client certificate upon user registration/first login and then store it in the Keychain.

* Ensure that the keys/passwords/logins are not stored in application data. This can be included in the iTunes backup and increase attack surface. Keychain is the only appropriate place to store credentials of any type (password, certificate, etc.).
* Ensure that keychain entries have appropriate protection class. The most rigorous being `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly` which translates to: entry unlocked only if passcode on the device is set and device is unlocked; the entry is not exportable in backups or by any other means.
*
#### Dynamic Analysis

-- TODO [Give examples of Dynamic Testing for "Testing for Insecure and/or Deprecated Cryptographic Algorithms"] --

* reverse engineer source code, then do the same

#### Remediation

-- TODO --

#### References

##### OWASP Mobile Top 10

-- TODO --

##### OWASP MASVS

-- TODO --

##### CWE

-- TODO --

##### Info

-- TODO --

##### Tools

-- TODO --

