## Cryptography for Mobile Apps

The following chapter translates the cryptography requirements of the MASVS into technical test cases. Test cases listed in this chapter are based upon generic cryptographic concepts and are not relying on a specific implementation on iOS or Android.
This chapter strives to provide recommendations for static testing methods where possible. However, dynamic testing methods are not generally applicable for the problems discussed below and, correspondingly, are not listed here.

#### Background on cryptography

The primary goal of cryptography is to provide confidentiality, data integrity, and authenticity, even in the face of an attack. Confidentiality is achieved through use of encryption, with the aim of ensuring secrecy of the contents. Data integrity deals with maintaining and ensuring consistency of data and detection of tampering/modification. Authenticity ensures that the data comes from a trusted source. Since this is a testing guide and not a cryptography textbook, the following paragraphs provide only a very limited outline of relevant techniques and their usages in the context of mobile applications.

* Encryption ensures data confidentiality by using special algorithms to convert the plaintext data into cipher text, which does not reveal any information about the original contents. The plaintext data can be restored from the cipher text through decryption. Two main forms of encryption are symmetric (or secret key) and asymmetric (or public key). In general, encryption operations do not protect integrity, but some symmetric encryption modes also feature that protection (see “Testing Sensitive Data Protection” section).
  - Symmetric-key encryption algorithms use the same key for both encryption and decryption. It is fast and suitable for bulk data processing. Since everybody who has access to the key is able to decrypt the encrypted content, they require careful key management.
  - Public-key (or asymmetric) encryption algorithms operate with two separate keys: the public key and the private key. The public key can be distributed freely, while the private key should not be shared with anyone. A message encrypted with the public key can only be decrypted with the private key. Since asymmetric encryption is several times slower than symmetric operations, it is typically only used to encrypt small amounts of data, such as symmetric keys for bulk encryption.
* Hash functions deterministically map arbitrary pieces of data into fixed-length values. It is typically easy to compute the hash, but difficult (or impossible) to determine the original input based on the hash. Cryptographic hash functions additionally guarantee that even small changes to the input data result in large changes to the resulting hash values. Cryptographic hash functions are used for integrity verification, but do not provide authenticity guarantees.
* Message Authentication Codes, or MACs, combine other cryptographic mechanism, such as symmetric encryption or hashes, with secret keys to provide both integrity and authenticity protection. However, in order to verify a MAC, multiple entities have to share the same secret key, and any of those entities will be able to generate a valid MAC. The most commonly used type of MAC, called HMAC, relies on hash as the underlying cryptographic primitive. As a rule, full name of an HMAC algorithm also includes the name of the underlying hash, e.g. - HMAC-SHA256.
* Signatures combine asymmetric cryptography (i.e. - using a public/private keypair) with hashing to provide integrity and authenticity by encrypting hash of the message with the private key. However, unlike MACs, signatures also provide non-repudiation property, as the private key should remain unique to the data signer.
* Key Derivation Functions, or KDFs, are often confused with password hashing functions. KDFs do have many useful properties for password hashing, but were created with different purposes in mind. In context of mobile applications, it is the password hashing functions that are typically meant for protecting stored passwords.

Two uses of cryptography are covered in other chapters:

* Secure communications. TLS (Transport Layer Security) uses most of the primitives named above, as well a number of others. It is covered in the “Testing Network Communication” chapter.
* Secure storage. Тhis chapter includes high-level considerations for using cryptography for secure data storage, and specific content for secure data storage capabilities will be found in OS-specific data storage chapters.

#### References
- [1] Password Hashing Competition - https://password-hashing.net/
-- TODO - list references to sources of algorithm definitions (RFCs, NIST SP, etc)


### Testing for Custom Implementations of Cryptography

#### Overview

The use of non-standard or custom built cryptographic algorithms is dangerous because a determined attacker may be able to break the algorithm and compromise data that has been protected. Implementing cryptographic functions is time consuming, difficult and very likely to fail. Instead well-known algorithms that were already proven to be secure should be used. All mature frameworks and libraries offer cryptographic functions that should also be used when implementing mobile apps.

#### Static Analysis

Carefully inspect all the cryptographic methods used within the source code, especially those which are directly applied to sensitive data. All cryptographic operations (see the list in the introduction section) should come from the standard providers (for standard APIs for Android and iOS, see cryptography chapters for the respective platforms). Any cryptographic invocations which do not invoke standard routines from known providers should be candidates for closer inspection. Pay close attention to seemingly standard but modified algorithms. Remember that encoding is not encryption! Any appearance of bit manipulation operators like XOR (exclusive OR) might be a good sign to start digging deeper.

#### Remediation

Do not develop custom cryptographic algorithms, as it is likely they are prone to attacks that are already well-understood by cryptographers. Select a well-vetted algorithm that is currently considered to be strong by experts in the field, and use well-tested implementations.

#### References

##### OWASP Mobile Top 10 2016
- M6 - Broken Cryptography

##### OWASP MASVS
- V3.2: "The app uses proven implementations of cryptographic primitives"

##### CWE
- CWE-327: Use of a Broken or Risky Cryptographic Algorithm

##### Info
- [1] Supported Ciphers in KeyStore - https://developer.android.com/training/articles/keystore.html#SupportedCiphers


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
* MD4
* MD5
* SHA1 and others.

On Android (via Java Cryptography APIs), selecting an algorithm is done by requesting an instance of the `Cipher` (or other primitive) by passing a string containing the algorithm name. For example, `Cipher cipher = Cipher.getInstance("DES");`. On iOS, algorithms are typically selected using predefined constants defined in CommonCryptor.h, e.g., `kCCAlgorithmDES`. Thus, searching the source code for the presence of these algorithm names would indicate that they are used. Note that since the constants on iOS are numeric, an additional check needs to be performed to check whether the algorithm values sent to CCCrypt function map to one of the deprecated/insecure algorithms.

Other uses of cryptography require careful adherence to best practices:
* For encryption, use a strong, modern cipher with the appropriate, secure mode and a strong key. Examples:
    * 256-bit key AES in GCM mode (provides both encryption and integrity verification.)
    * 4096-bit RSA with OAEP padding.
    * 224/256-bit elliptic curve cryptography.
* Do not use known weak algorithms. For example:
    * AES in ECB mode is not considered secure, because it leaks information about the structure of the original data.
    * Several other AES modes can be weak.
* RSA with 768-bit and weaker keys can be broken. Older PKCS#1 padding leaks information.
* Rely on secure hardware, if available, for storing encryption keys, performing cryptographic operations, etc.

#### Remediation

Periodically ensure that the cryptography has not become obsolete. Some older algorithms, once thought to require years of computing time, can now be broken in days or hours. This includes MD4, MD5, SHA1, DES, and other algorithms that were once considered as strong. Examples of currently recommended algorithms<sup>[1], [2]</sup>:

* Confidentiality: AES-GCM-256 or ChaCha20-Poly1305
* Integrity: SHA-256, SHA-384, SHA-512, Blake2
* Digital signature: RSA (3072 bits and higher), ECDSA with NIST P-384
* Key establishment: RSA (3072 bits and higher), DH (3072 bits or higher), ECDH with NIST P-384

#### References

##### OWASP Mobile Top 10
- M6 - Broken Cryptography

##### OWASP MASVS
- V3.3: "The app uses cryptographic primitives that are appropriate for the particular use-case, configured with parameters that adhere to industry best practices"
- V3.4: "The app does not use cryptographic protocols or algorithms that are widely considered depreciated for security purposes"

##### CWE
- CWE-326: Inadequate Encryption Strength
- CWE-327: Use of a Broken or Risky Cryptographic Algorithm

##### Info
- [1] Commercial National Security Algorithm Suite and Quantum Computing FAQ - https://cryptome.org/2016/01/CNSA-Suite-and-Quantum-Computing-FAQ.pdf
- [2] NIST Special Publication 800-57 - http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-57pt1r4.pdf
- [4] NIST recommendations (2016) - https://www.keylength.com/en/4/
- [5] BSI recommendations (2017) - https://www.keylength.com/en/8/
- [6] Sweet32 attack -- https://sweet32.info/

##### Tools
- QARK - https://github.com/linkedin/qark
- Mobile Security Framework - https://github.com/ajinabraham/Mobile-Security-Framework-MobSF


### Testing for Insecure Cryptographic Algorithm Configuration and Misuse

#### Overview

Choosing strong cryptographic algorithm alone is not enough. Often security of otherwise sound algorithms can be affected through their configuration. Most prominent for cryptographic algorithms is the selection of their used key length.

#### Static Analysis

Through source code analysis the following non-exhausting configuration options should be checked:

* cryptographic salt, which should be at least the same length as hash function output
* * reasonable choice of iteration counts when using password derivation functions
* IVs being random and unique
* fit-for-purpose block encryption modes
* key management being done properly

#### Remediation

Periodically ensure that used key length fulfill accepted industry standards<sup>[6]</sup>.

#### References

##### OWASP Mobile Top 10
- M6 - Broken Cryptography

##### OWASP MASVS
- V3.3: "The app uses cryptographic primitives that are appropriate for the particular use-case, configured with parameters that adhere to industry best practices"
- V3.4: "The app does not use cryptographic protocols or algorithms that are widely considered depreciated for security purposes"

##### CWE
- CWE-326: Inadequate Encryption Strength
- CWE-327: Use of a Broken or Risky Cryptographic Algorithm

##### Info
- [1] Commercial National Security Algorithm Suite and Quantum Computing FAQ - https://cryptome.org/2016/01/CNSA-Suite-and-Quantum-Computing-FAQ.pdf
- [2] NIST Special Publication 800-57 - http://nvlpubs.nist.gov/nistpubs/SpecialPublications/NIST.SP.800-57pt1r4.pdf
- [3] Security "Crypto" provider deprecated in Android N -  https://android-developers.googleblog.com/2016/06/security-crypto-provider-deprecated-in.html
- [4] NIST recommendations (2016) - https://www.keylength.com/en/4/
- [5] BSI recommendations (2017) - https://www.keylength.com/en/8/
- [6] ENISA Algorithms, key size and parameters report 2014 - https://www.enisa.europa.eu/publications/algorithms-key-size-and-parameters-report-2014

##### Tools
- QARK - https://github.com/linkedin/qark
- Mobile Security Framework - https://github.com/ajinabraham/Mobile-Security-Framework-MobSF
- hashcat - https://hashcat.net/hashcat/
- hashID - https://pypi.python.org/pypi/hashID


### Testing for Hardcoded Cryptographic Keys

#### Overview

The security of symmetric encryption and keyed hashes (MACs) is highly dependent upon the secrecy of the used secret key. If the secret key is disclosed, the security gained by encryption/MACing is rendered naught.
This mandates, that the secret key is protected and should not be stored together with the encrypted data.

#### Static Analysis

The following checks would be performed against the used source code:

* Ensure that no keys/passwords are hard coded and stored within the source code. Pay special attention to any 'administrative' or backdoor accounts enabled in the source code. Storing fixed salt within application or password hashes may cause problems too.
* Ensure that no obfuscated keys or passwords are in the source code. Obfuscation is easily bypassed by dynamic instrumentation and in principle does not differ from hard coded keys.
* If the application is using two-way SSL (i.e. there is both server and client certificate validated) check if:
    * the password to the client certificate is not stored locally, it should be in the Keychain
    * the client certificate is not shared among all installations (e.g. hard coded in the app)
* if the app relies on an additional encrypted container stored in app data, ensure how the encryption key is used;
    * if key wrapping scheme is used, ensure that the master secret is initialized for each user, or container is re-encrypted with new key;
    * check how password change is handled and specifically, if you can use master secret or previous password to decrypt the container.

Mobile operating systems provide a specially protected storage area for secret keys, commonly named key stores or key chains. Those storage areas will not be part of normal backup routines and might even be protected by hardware means. The application should use this special storage locations/mechanisms for all secret keys.

#### Remediation
-- TODO --

#### References

##### OWASP Mobile Top 10

- M6 - Broken Cryptography

##### OWASP MASVS

- V3.1: "The app does not rely on symmetric cryptography with hardcoded keys as a sole method of encryption."

##### CWE

- CWE-321 - Use of Hard-coded Cryptographic Key

##### Info

- [1] iOS: Managing Keys, Certificates, and Passwords - https://developer.apple.com/library/content/documentation/Security/Conceptual/cryptoservices/KeyManagementAPIs/KeyManagementAPIs.html
- [2] Android: The Android Keystore System - https://developer.android.com/training/articles/keystore.html
- [3] Android: Hardware-backed Keystore - https://source.android.com/security/keystore/

##### Tools

-- TODO --


### Testing Key Generation Techniques

#### Overview

Cryptographic algorithms -- such as symmetric encryption or MACs -- expect a secret input of a given size, e.g. 128 or 256 bit. A naive implementation might use the use-supplied password directly as an input key. There are a couple of problems with this approach:

* If the password is smaller than the key, then not the full key-space is used (the rest is padded, sometimes even with spaces)
* A user-supplied password will realistically consist mostly of displayable and pronounceable characters. So instead of the full entropy, i.e. 28 when using ASCII, only a small subset is used (approx. 26).
* If two users select the same password an attacker can match the encrypted files. This opens up the possibility of rainbow table attacks.

#### Static Analysis

Use the source code to verify that no password is directly passed into an encryption function.

#### Remediation

Pass the user-supplied password into a salted hash function or KDF; use its result as key for the cryptographic function.

#### References

Pass the user-supplied password into a salted hash function or KDF; use its result as key for the cryptographic function.

#### References

##### OWASP Mobile Top 10

- M6 - Broken Cryptography

##### OWASP MASVS

- V3.3: "The app uses cryptographic primitives that are appropriate for the particular use-case, configured with parameters that adhere to industry best practices"

##### CWE

-- TODO --

##### Info

- Wikipedia -- https://en.wikipedia.org/wiki/Key_stretching

##### Tools

- hashcat - https://hashcat.net/hashcat/
- hashID - https://pypi.python.org/pypi/hashID


### Testing Sensitive Data Protection

#### Overview

The attack surface of an application is defined as the sum of all potential input paths. An often forgotten attack vector are files stored on insecure locations, e.g., cloud storage or local file storage.

All data that is stored on potential insecure locations should be integrity protected, i.e., an attacker should not be able to change their content without the application detecting the change prior to the data being used.

Most countermeasures work by calculating a checksum for the stored data, and then by comparing the checksum with the retrieved data prior to the data's import. If the checksum/hash is stored with the data on the insecure location, typical hash algorithms will not be sufficient. As they do not possess a secret key, an attacker that is able to change the stored data, can easily recalculate the hash and store the newly calculated hash.

#### Static Analysis

-- TODO --

check source code for used algorithm

#### Remediation

Two typical cryptographic counter-measures for integrity protection are:

* MACs (Message Authentication Codes, also known as keyed hashes) combine hashes with a secret key. The MAC can only be calculated or verified if the secret key is known. In contrast to hashes this means, that an attacker cannot easily calculate a MAC after the original data was modified. This is well suited, if the application can store the secret key within its own storage and no other party needs to verify the authenticity of the data.
* Digital Signatures are a public key-based scheme where, instead of a single secret key, a combination of a secret private key and a public key is used. The signature is created utilizing the secret key and can be verified utilizing the public key. Similar to MACs, an attacker cannot easily create a new signature. In contrast to MACs, signatures allow verification without needed to disclose the secret key. Why is not everyone using Signatures instead of MACs? Mostly for performance reasons.

Another possibility is the usage of encryption using AEAD schemes (see "Test if encryption provides data integrity protection")

#### References

##### OWASP Mobile Top 10

- M6 - Broken Cryptography

##### OWASP MASVS

- V3.3: "The app uses cryptographic primitives that are appropriate for the particular use-case, configured with parameters that adhere to industry best practices"

##### CWE

-- TODO --

##### Info

-- TODO --

##### Tools

-- TODO --


### Testing for Stored Passwords

#### Overview

Normal hashes are optimized for speed, e.g., optimized to verify large media in short time. For password storage this property is not desirable as it implies that an attacker can crack retrieved password hashes (using rainbow tables or through brute-force attacks) in a short time. For example, when the insecure MD5 hash has been used, an attacker with access to eight high-level graphics cards can test 200.3 Giga-Hashes per Second<sup>[1]</sup>.
A solution to this are Key-Derivation Functions (KDFs) that have a configurable calculation time. While this imposes a larger performance overhead this is negligible during normal operation but prevents brute-force attacks. Recently developed key derivation functions such as Argon2 or scrypt have been hardened against GPU-based password cracking.

#### Static Analysis

Use the source code to determine how the hash is calculated.

#### Remediation

Use an established key derivation function such as PBKDF2 (RFC 2898<sup>[5]</sup>), Argon2<sup>[4]</sup>, bcrypt<sup>[3]</sup> or scrypt (RFC 7914<sup>[2]</sup>).

#### References

##### OWASP Mobile Top 10

- M6 - Broken Cryptography

##### OWASP MASVS

- V3.3: "The app uses cryptographic primitives that are appropriate for the particular use-case, configured with parameters that adhere to industry best practices"
- V3.4: "The app does not use cryptographic protocols or algorithms that are widely considered depreciated for security purposes"

##### CWE

-- TODO --

##### Info

- [1] 8x Nvidia GTX 1080 Hashcat Benchmarks -- https://gist.github.com/epixoip/a83d38f412b4737e99bbef804a270c40
- [2] The scrypt Password-Based Key Derivation Function -- https://tools.ietf.org/html/rfc7914
- [3] A Future-Adaptable Password Scheme -- https://www.usenix.org/legacy/events/usenix99/provos/provos_html/node1.html
- [4] https://github.com/p-h-c/phc-winner-argon2
- [5] PKCS #5: Password-Based Cryptographic Specification Version 2.0 -- https://tools.ietf.org/html/rfc2898

##### Tools

- hashcat - https://hashcat.net/hashcat/
- hashID - https://pypi.python.org/pypi/hashID
