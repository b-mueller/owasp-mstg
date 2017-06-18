## Testing Local Authentication in Android Apps

Most of the authentication and session management requirements of the MASVS refer to architectural and server-side issues that can be verified independent of the specific implementation on iOS or Android. In the MSTG, we therefore discuss these test cases in a platform-independent way (see the appendix "Testing Authentication and Session Management on the Endpoint"). There's however also cases where local authentication mechanisms are used - e.g. to locally "unlock" the app and/or provide an easy means for users to resume an existing session. These cases are discussed here.

### Testing Biometric Authentication

#### Overview

Android 6.0 introduced public APIs for authenticating users via fingerprint. Access to the fingerprint hardware is provided through the <code>FingerprintManager</code> class <sup>[1]</sup>. An app can request fingerprint authentication by instantiating a <code>FingerprintManager</code> object and calling its <code>authenticate()</code> method. The caller registers callback methods to handle possible outcomes of the authentication process (success, failure or error).

By using the fingerprint API in conjunction with the Android KeyGenerator class, apps can create a cryptographic key that must be "unlocked" with the user's fingerprint. This can be used to implement more convenient forms of user login. For example, to allow users access to a remote service, a symmetric key can be created and used to encrypt the user PIN or authentication token. By calling <code>setUserAuthenticationRequired(true)</code> when creating the key, it is ensured that the user must re-authenticate using their fingerprint to retrieve it. The encrypted authentication data itself can then be saved using regular storage (e.g. SharedPreferences).

Apart from this relatively reasonable method, fingerprint authentication can also be implemented in unsafe ways. For instance, developers might opt to assume successful authentication based solely on whether the <code>onAuthenticationSucceeded</code> callback <sup>[3]</sup> is called or when the Samsung Pass SDK is used for instance. This event however isn't proof that the user has performed biometric authentication - such a check can be easily patched or bypassed using instrumentation. Leveraging the Keystore is the only way to be reasonably sure that the user has actually entered their fingerprint.

Unless, of course, the Keystore is compromised. Which has been the case as reported in [5] and mostly explained in [6]. There are a few known CVEs registered for instance: CVE-2016-2431, CVE-2016-2432, CVE-2015-6639, CVE-2015-6647. Therefore one should always check the security patch-level:

```java
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd", 	Locale.getDefault());
	sdf.parse(Build.VERSION.SECURITY_PATCH).after(sdf.parse("2016-05-01"));
```


#### Static Analysis

First make sure that the actual Android SDK is used for fingerprint evaluation and not any vendor specific SDKs, such as Samsung Pass as it is inherently flawed.

Search for calls of <code>FingerprintManager.authenticate()</code>. The first parameter passed to this method should be a <code>CryptoObject</code> instance. <code>CryptoObject</code> is a wrapper class for the crypto objects supported by FingerprintManager <sup>[2]</sup>. If this parameter is set to <code>null</code>, the fingerprint auth is purely event-bound, which likely causes a security issue.

Trace back the creation of the key used to initialize the cipher wrapped in the CryptoObject. Verify that the key was created using the <code>KeyGenerator</code> class, and that <code>setUserAuthenticationRequired(true)</code> was called when creating the <code>KeyGenParameterSpec</code> object (see also the code samples below).

Verify the authentication logic. For the authentication to be successful, the remote endpoint **must** require the client to present the secret retrieved from the Keystore, or some value derived from the secret.


#### Dynamic Analysis

Patch the app or use runtime instrumentation to bypass fingerprint authentication on the client. For example, you could use Frida call the <code>onAuthenticationSucceeded</code> callback directly. Refer to the chapter "Tampering and Reverse Engineering on Android" for more information.

#### Remediation

Fingerprint authentication should be implemented along the following lines:

Check whether fingerprint authentication is possible. The device must run Android 6.0 or higher (SDK 23+) and feature a fingerprint sensor. There are a two pre-requisites that you need to check:

- The user must have protected their lockscreen

```java
	 KeyguardManager keyguardManager = (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);
	 keyguardManager.isKeyguardSecure();
```
- Fingerprinthardware must be available:

```java
	 FingerprintManager fingerprintManager = (FingerprintManager)
                    context.getSystemService(Context.FINGERPRINT_SERVICE);
    fingerprintManager.isHardwareDetected();                
```

- At least one finger should be registered:
```java
	fingerprintManager.hasEnrolledFingerprints();
```

- The application should have permission to ask for the users fingerprint:
```java
	context.checkSelfPermission(Manifest.permission.USE_FINGERPRINT) == PermissionResult.PERMISSION_GRANTED;
```

If any of those checks failed, the option for fingerprint authentication should not be offered.

When setting up fingerprint authentication, create a new AES key using the <code>KeyGenerator</code> class. Add <code>setUserAuthenticationRequired(true)</code> in <code>KeyGenParameterSpec.Builder</code>.

```java
	generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, KEYSTORE);

	generator.init(new KeyGenParameterSpec.Builder (KEY_ALIAS,
	      KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
	      .setBlockModes(KeyProperties.BLOCK_MODE_CBC)
	      .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_PKCS7)
	      .setUserAuthenticationRequired(true)
	      .build()
	);

	generator.generateKey();
```
Please note, that since Android 7 you can use the `setInvalidatedByBiometricEnrollment(boolean value)` as a method of the builder. If you set this to true, then the fingerprint will not be invalidated when new fingerprints are enrolled. Even though this might provide user-convenience, it opens op a problem area when possible attackers are somehow able to social-engineer their fingerprint in.

To perform encryption or decryption, create a <code>Cipher</code> object and initialize it with the AES key.

```java
	SecretKey keyspec = (SecretKey)keyStore.getKey(KEY_ALIAS, null);

    if (mode == Cipher.ENCRYPT_MODE) {
        cipher.init(mode, keyspec);
```

Note that the key cannot be used right away - it has to be authenticated through the <code>FingerprintManager</code> first. This involves wrapping <code>Cipher</code> into a <code>FingerprintManager.CryptoObject</code> which is passed to <code>FingerprintManager.authenticate()</code>.

```java
	cryptoObject = new FingerprintManager.CryptoObject(cipher);
	fingerprintManager.authenticate(cryptoObject, new CancellationSignal(), 0, this, null);
```

If authentication succeeds, the callback method <code>onAuthenticationSucceeded(FingerprintManager.AuthenticationResult result)</code> is called, and the authenticated CryptoObject can be retrieved from the authentication result.

```java
public void authenticationSucceeded(FingerprintManager.AuthenticationResult result) {
	cipher = result.getCryptoObject().getCipher();

	(... do something with the authenticated cipher object ...)
}
```

Please bare in mind that the keys might not be always in secure hardware, for that you can do the following to validate the posture of the key:

```java
SecretKeyFactory factory = SecretKeyFactory.getInstance(getEncryptionKey().getAlgorithm(), ANDROID_KEYSTORE);
                KeyInfo secetkeyInfo = (KeyInfo) factory.getKeySpec(yourencryptionkeyhere, KeyInfo.class);
secetkeyInfo.isInsideSecureHardware()
```
Please note that, on some systems, you can make sure that the biometric authentication policy itself is hardware enforced as well. This is checked by:

```java
	keyInfo.isUserAuthenticationRequirementEnforcedBySecureHardware();
```

For a full example, see the blog article by Deivi Taka <sup>[4]</sup>.


#### References

##### OWASP Mobile Top 10 2016

* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS

* 4.6: "Biometric authentication, if any, is not event-bound (i.e. using an API that simply returns "true" or "false"). Instead, it is based on unlocking the keychain/keystore."

##### CWE

- CWE-287 - Improper Authentication
- CWE-604 - Use of Client-Side Authentication

##### Info

- [1] FingerprintManager - https://developer.android.com/reference/android/hardware/fingerprint/FingerprintManager.html
- [2] FingerprintManager.CryptoObject - https://developer.android.com/reference/android/hardware/fingerprint/FingerprintManager.CryptoObject.html
- [3] https://developer.android.com/reference/android/security/keystore/KeyGenParameterSpec.Builder.html#setUserAuthenticationRequired(boolean)
- [4] Securing Your Android Apps with the Fingerprint API - https://www.sitepoint.com/securing-your-android-apps-with-the-fingerprint-api/#savingcredentials
- [5] Android Security Bulletins - https://source.android.com/security/bulletin/
- [6] Extracting Qualcomm's KeyMaster Keys - Breaking Android Full Disk Encryption - http://bits-please.blogspot.co.uk/2016/06/extracting-qualcomms-keymaster-keys.html
