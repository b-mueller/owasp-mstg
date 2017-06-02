## Testing Cryptography

The following chapter translates the cryptography requirements of the MASVS into technical test cases. Test cases listed in this chapter are based upon generic cryptographic concepts and are not relying on a specific implementation on iOS or Android.

Proper design of a cryptographic system is a common pitfall for mobile application development. To achieve good security, a developer has to chose the right cryptographic directive (e.g., symmetric encryption), chose the right implementation for that directive (e.g., AES-GCM) and then configure that implementation correctly (e.g., key length, block modes, key management). While this chapter does not give an introduction into cryptography, its questions are designed to find common problems within the mentioned selection and implementation process.

Throughout this chapter, multiple basic cryptographic building blocks are used. The following gives a rough introduction into commonly referred concepts:

* Hashes are used to quickly calculate a fixed-length checksum based upon the original data. The same input data will produce the same output hash. Cryptographic hashes guarantee, that the generated hash will limit reasoning about the original data, that small changes within the original date will produce a completely different hash and that, given a hash, providing input data that leads to the same hash is not feasible. As no secret keys are used, an attacker can recalculate a new hash after data was modified.
* Encryption converts the original plain-text data into encrypted text and subsequently allows to reconstruct the original data form the encrypted text (also known as cipher text). Thus it provides data confidentiality.
* Symmetric Encryption utilizes a secret key. The data confidentiality of the encrypted data is solely dependent upon the confidentiality of the secret key. This implies, that the secret key should be secret and thus not be predictable.
* Asymmetric Encryption utilizes two keys: a public key that can be used to encrypt plain-text and a secret private key that can be used to reconstruct the original data from the plain-text.

### Testing for Custom Implementations of Cryptography

#### Overview

The use of non-standard or custom built cryptographic algorithms is dangerous because a determined attacker may be able to break the algorithm and compromise data that has been protected. Implementing cryptographic functions is time consuming, difficult and very likely to fail. Instead well-known algorithms that were already proven to be secure should be used. All mature frameworks and libraries offer cryptographic functions that should also be used when implementing mobile apps.

#### Static Analysis

Carefully inspect all the cryptographic methods used within the source code, especially those which are directly applied to sensitive data. Pay close attention to seemingly standard but modified algorithms. Remember that encoding is not encryption! Any appearance of bit shift operators like exclusive OR operations might be a good sign to start digging deeper.

#### Dynamic Analysis

The recommended approach is be to decompile the APK and inspect the resulting source code for usage of custom encryption schemes (see "Static Analysis").

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

### Testing for Insecure and/or Deprecated Cryptographic Algorithms

#### Overview

Many cryptographic algorithms and protocols should not be used because they have been shown to have significant weaknesses or are otherwise insufficient for modern security requirements. Previously thought secure algorithms may become insecure over time. It is therefore important to periodically check current best practices and adjust configurations accordingly.

#### Static Analysis

The source code should be checked that cryptographic algorithms are up to date and in-line with industry standards. This includes, but is not limited to outdated block ciphers (e.g. DES), stream ciphers (e.g. RC4), as well as hash functions (e.g. MD5) and broken random number generators like Dual_EC_DRBG. Please note, that an algorithm that was certified, e.g., by the NIST, can also become insecure over time. A certification does not replace periodic verification of an algorithm's soundness. All of these should be marked as insecure and should not be used and removed from the application code base.

Inspect the source code to identify the instances of cryptographic algorithms throughout the application, and look for known weak ones, such as:

* DES, 3DES<sup>[6]</sup>
* RC2
* RC4
* BLOWFISH<sup>[6]</sup>
* CRC32
* MD4
* MD5
* SHA1 and others.

Example initialization of DES algorithm, that is considered weak:
```Java
Cipher cipher = Cipher.getInstance("DES");
```

#### Dynamic Analysis

The recommended approach is be to decompile the APK and inspect the resulting source code for usage of custom encryption schemes (see "Static Analysis").

If you encounter locally stored data during the test, try to identify the used algorithm and verify them against a list of known insecure algorithms.

#### Remediation

Periodically ensure that the cryptography has not become obsolete. Some older algorithms, once thought to require years of computing time, can now be broken in days or hours. This includes MD4, MD5, SHA1, DES, and other algorithms that were once considered as strong. Examples of currently recommended algorithms<sup>[1] [2]</sup>:

* Confidentiality: AES-GCM-256 or ChaCha20-Poly1305
* Integrity: SHA-256, SHA-384, SHA-512, Blake2
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
- [6] Sweet32 attack -- https://sweet32.info/

##### Tools
* QARK - https://github.com/linkedin/qark
* Mobile Security Framework - https://github.com/ajinabraham/Mobile-Security-Framework-MobSF

 


### Testing for Insecure Cryptographic Algorithm Configuration

#### Overview

Choosing strong cryptographic algorithm alone is not enough. Often security of otherwise sound algorithms can be affected through their configuration. Most prominent for cryptographic algorithms is the selection of their used key length.

#### Static Analysis

Through source code analysis the following non-exhausting configuration options should be checked:

* cryptographic salt, which should be at least the same length as hash function output
* * reasonable choice of iteration counts when using password derivation functions
* IVs being random and unique
* fit-for-purpose block encryption modes
* key management being done properly

#### Dynamic Analysis

If hashes were extracted during the analysis, and they have been configured in an insecure manner, a brute-force password cracking tool, e.g. hashcat, can be used to extract the original plain-text passwords from the encrypted hashes. Hashcat's wiki contains examples of cracking speeds for different algorithms, this can be utilized to estimate the effort that an attacker would have to recover plain-text passwords.

To utilize brute-force tools, the used hash algorithm (e.g., MD5 or SHA1) must be known. If this knowledge is not gathered during the Testing, tools like hashID can be used to automatically identify hash algorithms.

#### Remediation

Periodically ensure that used key length fulfill accepted industry standards<sup>[6]</sup>.

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
- [6] ENISA Algorithms, key size and parameters report 2014 - https://www.enisa.europa.eu/publications/algorithms-key-size-and-parameters-report-2014

##### Tools
* QARK - https://github.com/linkedin/qark
* Mobile Security Framework - https://github.com/ajinabraham/Mobile-Security-Framework-MobSF
* hashcat - https://hashcat.net/hashcat/
* hashID - https://pypi.python.org/pypi/hashID

### Testing for Usage of ECB Mode

#### Overview

As the name implies, block-based encryption is performed upon discrete input blocks, e.g., 128 bit blocks when using AES. If the plain-text is larger than the block-size, it is internally split up into blocks of the given input size and encryption is performed upon each block. The so called block mode defines, if the result of one encrypted block has any impact upon subsequently encrypted blocks.

The ECB (Electronic Codebook) encryption mode should not be used, as it is basically divides the input into blocks of fixed size and each block is encrypted separately<sup>[6]</sup>. For example, if an image is encrypted utilizing the ECB block mode, then the input image is split up into multiple smaller blocks. Each block might represent a small area of the original image. Each of which is encrypted using the same secret input key. If input blocks are similar, e.g., each input block is just a white background, the resulting encrypted output block will also be the same. While each block of the resulting encrypted image is encrypted, the overall structure of the image will still be recognizable within the resulting encrypted image.

![Electronic Codebook (ECB mode encryption)](Images/Chapters/0x07c/ECB.png)

![Difference of encryption modes](Images/Chapters/0x07c/EncryptionMode.png)

#### Static Analysis

Use the source code to verify the used blcok mode. Especially check for ECB mode, e.g.:

```
Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
```

#### Dynamic Analysis

Test encrypted data for reoccuring patterns -- thse can be an indication of ECB mode being used.

#### Remediation

Use an established block mode that provides a feedback mechanism for subsequent blocks, e.g. Counter Mode (CTR). For storing encrypted data it is often advisable to use a block mode that additionally protects the integrity of the stored data, e.g. Galois/Counter Mode (GCM). The latter has the additional benefit that the algorithm is mandatory for each TLSv1.2 implementation -- thus being available on all modern plattforms.

Consult the NIST guidelines on block mode selection<sup>[1]</sup>.

#### References

##### OWASP Mobile Top 10
* M6 - Broken Cryptography

##### OWASP MASVS
- V3.3: "The app uses cryptographic primitives that are appropriate for the particular use-case, configured with parameters that adhere to industry best practices"

##### CWE
* CWE-326: Inadequate Encryption Strength
* CWE-327: Use of a Broken or Risky Cryptographic Algorithm

##### Info

- [1] NIST Modes Development, Proposed Modes - http://csrc.nist.gov/groups/ST/toolkit/BCM/modes_development.html
- [6] Electronic Codebook (ECB) - https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Electronic_Codebook_.28ECB.29

##### Tools
* QARK - https://github.com/linkedin/qark
* Mobile Security Framework - https://github.com/ajinabraham/Mobile-Security-Framework-MobSF



### Testing if anything but a KDF (key-derivation function) is used for storing passwords

#### Overview

Normal hashes are optimized for speed, e.g., optimized to verify large media in short time. For password storage this property is not desirable as it implies that an attacker can crack retrieved password hashes (using rainbow tables or through brute-force attacks) in a short time. For example, when the insecure MD5 hash has been used, an attacker with access to eight high-level graphics cards can test 200.3 Giga-Hashes per Second<sup>[1]</sup>.

A solution this are Key-Derivation Functions (KDFs) that have a configurable calculation time. While this imposes a larger performance overhead this is negligible during normal operation but prevents brute-force attacks. Recently developed key derivation functions such as Argon2 or scrypt have been hardened against GPU-based password cracking.

#### Static Analysis

-- TODO --

* check source code for used algorithm

#### Dynamic Analysis

If hashes were extracted and they have been configured in an insecure manner, a brute-force password cracking tool, e.g. hashcat, can be used to extract the original plain-text passwords from the encrypted hashes. Hashcat's wiki contains examples of cracking speeds for different algorithms, this can be utilized to estimate the effort that an attacker would have to recover plain-text passwords.

To utilize brute-force tools, the used hash algorithm (e.g., MD5 or SHA1) must be known. If this knowledge is not gathered during the Testing, tools like hashID can be used to automatically identify hash algorithms.

#### Remediation

Use an established key derivation function such as PBKDF2 (RFC 2898<sup>[5]</sup>), Argon2<sup>[4]</sup>, bcrypt<sup>[3]</sup> or scrypt (RFC 7914<sup>[2]</sup>).

#### References

##### OWASP Mobile Top 10

* M6 - Broken Cryptography

##### OWASP MASVS

- V3.3: "The app uses cryptographic primitives that are appropriate for the particular use-case, configured with parameters that adhere to industry best practices"
- V3.4: "The app does not use cryptographic protocols or algorithms that are widely considered depreciated for security purposes"

##### CWE

-- TODO --

##### Info

[1] 8x Nvidia GTX 1080 Hashcat Benchmarks -- https://gist.github.com/epixoip/a83d38f412b4737e99bbef804a270c40
[2] The scrypt Password-Based Key Derivation Function -- https://tools.ietf.org/html/rfc7914
[3] A Future-Adaptable Password Scheme -- https://www.usenix.org/legacy/events/usenix99/provos/provos_html/node1.html
[4] https://github.com/p-h-c/phc-winner-argon2
[5] PKCS #5: Password-Based Cryptographic Specification Version 2.0 -- https://tools.ietf.org/html/rfc2898

##### Tools

* hashcat - https://hashcat.net/hashcat/
* hashID - https://pypi.python.org/pypi/hashID



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

* M6 - Broken Cryptography

##### OWASP MASVS

- V3.3: "The app uses cryptographic primitives that are appropriate for the particular use-case, configured with parameters that adhere to industry best practices"

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
* use AEAD based encryption for data storage (provides confidentiality as well as integrity protection)
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

 Please note that, encryption does not provide data integrity, i.e., if an attacker modifies the cipher text and a user decrypts the modified cipher text, the resulting plain-text will be garbage (but the decryption operation itself will perform successfully).

* encryption only protects data confidentiality, not integrity
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
* use AEAD based encryption for data storage (provides confidentiality as well as integrity protection)

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

* Ensure that no keys/passwords are hard coded and stored within the source code. Pay special attention to any 'administrative' or backdoor accounts enabled in the source code. Storing fixed salt within application or password hashes may cause problems too.
* Ensure that no obfuscated keys or passwords are in the source code. Obfuscation is easily bypassed by dynamic instrumentation and in principle does not differ from hard coded keys.
* If the application is using two-way SSL (i.e. there is both server and client certificate validated) check if:
   * the password to the client certificate is not stored locally, it should be in the Keychain
   * the client certificate is not shared among all installations (e.g. hard coded in the app)


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

