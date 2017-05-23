## Testing Authentication

### Verify that Users Are Properly Authenticated

#### Overview

Applications often have different sections with, on the one hand public and non-privileged information / actions, and on the other hand sensitive and privileged information / actions. Users can legitimately access the first ones without any restriction; however, in order to make sure sensitive and privileged information / actions are protected and accessible only to legitimate users, proper authentication has to take place.  

#### Static Analysis

When source code is available, first locate all sections with sensitive and privileged information / actions: they are the ones that need to be protected. Prior to accessing any item, the application must make sure the user is really who he pretends to and that he is allowed to access the section. Look for keywords in the targeted programming language that are used to authenticate a user or to retrieve and check an existing session token (for instance: KeyStore, SharedPreferences, ...).


#### Dynamic Analysis

The easiest way to check authentication on an App is to try to browse the app and access privileged sections. When this cannot be done manually, an automated crawler can be used (for instance, try to start an Activity that contains sensitive information with Drozer without providing authentication elements; for further information, please refer to the official Drozer guide available at https://labs.mwrinfosecurity.com/tools/drozer/). 

In case the app is exchanging information with a backend server, an intercepting proxy can be used to capture network traffic while being authenticated. Then, log out and try to replay requests while removing authentication information or not.
Further attacks methods can be found in the OWASP Testing Guide V4 concerning web-based applications (cf link in the Info section).

#### Remediation

For every section that needs to be protected, implement a mechanism that checks the session token of the user :
- if there is no session token, the user may not have authenticated before;
- if a token exists, make sure this token is valid and that it grants the user with sufficient privileges to allow the user to access the section.
If any of these two conditions raise an issue, reject the request and do not allow the user to start the Activity.

#### References

##### OWASP Mobile Top 10 2016

* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS

- 4.1: "If the app provides users with access to a remote service, an acceptable form of authentication such as username/password authentication is performed at the remote endpoint."

##### CWE

- CWE-287: Improper Authentication - https://cwe.mitre.org/data/definitions/287.html

##### Info

* OWASP Testing Guide V4 (web-based applications) - https://www.owasp.org/index.php/Testing_for_Bypassing_Authentication_Schema_(OTG-AUTHN-004)

##### Tools

* Drozer - https://labs.mwrinfosecurity.com/tools/drozer/


### Testing Session Management

#### Overview

All significant, if not privileged, actions must be done after a user is properly authenticated; the application will remember the user inside a "session". When improperly managed, sessions are subject to a variety of attacks where the session of a legitimate user may be abused, allowing the attacker to impersonate the user. As a consequence, data may be lost, confidentiality compromised or illegitimate actions performed.

Sessions must have a beginning and an end; it must be impossible for an attacker to forge a session token: instead, it must be ensured that a session can only be started by the system on the server side. Also, the duration of a session should be as short as possible, and the session must be properly terminated after a given amount of time or after the user has explicitely logged out. It must be impossible to reuse session tokens. 

As such, the scope of this test is to validate that sessions are securely managed and cannot be compromised by an attacker.

#### Static Analysis

When source code is available, the tester should look for the place where sessions are initiated, stored, exchanged, verified and canceled. This must be done whenever any access to privileged information or action takes place. For those matters, automated tools or custom scripts (in any language like Python or Perl) can be used to look for relevant keywords in the target language. Also, team members knowledgeable on the application structure may be involved to cover all necessary entry points or fasten the process.

#### Dynamic Analysis

A best practice is first to crawl the application, either manually or with an automated tool, the goal being to check if all parts of the application leading to privileged information of actions are protected and a valid session token is required or not. 

Then, the tester can use any intercepting proxy to capture network traffic between a client and the server and try to manipulate session tokens :
- create one from scratch;
- modify a valid one for an illegitimate one (for instance, add 1 to the valid token);
- delete a valid token to test if the targeted part of the application can be accessed;
- if network exchanges have not done over a secure connection, try to intercept one and reuse it;
- try to log out and re-log in and check if the token has changed or not;
- when changing privilege level, try to use the former one (hence with a lower authorization level) to access the privileged part of the application;
- try to use a token after logging out.

#### Remediation

In order to offer proper protection against the attacked mentioned earlier, session tokens must:
- always be created on the server side;
- not be predictable (use proper length and entropy);
- always be exchanged between the client and the server over secure connections (ex : https);
- be stored securely on the client side;
- be verified when a user is trying to access privileged parts of an application: a token must be valid, correspond to the proper level of authorization;
- be renewed when a user is asked to log in again to perform an operation requiring higher privileges;
- be terminated when a user logs out or after a given amount of time.

It is strongly advised to use built-in session token generators as they are usually more secure than custom tokens; such generators exist for most platforms and languages.

#### References

##### OWASP Mobile Top 10 2016

* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS

* 4.2: "The remote endpoint uses randomly generated access tokens to authenticate client requests without sending the user's credentials."

##### CWE

- CWE-613 - Insufficient Session Expiration https://cwe.mitre.org/data/definitions/613.html

##### Info

- OWASP Session Management Cheat Sheet: https://www.owasp.org/index.php/Session_Management_Cheat_Sheet

##### Tools

* Proxy tools like Zed Attack Proxy, Burp Suite, Fiddler.



### Testing the Logout Functionality

#### Overview

Session termination is an important part of the session lifecycle. Reducing the lifetime of the session tokens to a minimum decreases the likelihood of a successful session hijacking attack.
 
The scope for this test case is to validate that the application has a logout functionality and it effectively terminates the session on client and server side.

##### Static Analysis 

If server side code is available, it should be reviewed to validate that the session is being terminated as part of the logout functionality.
The check needed here will be different depending on the technology used. Here are different examples on how a session can be terminated in order to implement a proper logout on server side:
- Spring (Java) - http://docs.spring.io/spring-security/site/docs/current/apidocs/org/springframework/security/web/authentication/logout/SecurityContextLogoutHandler.html
- Ruby on Rails -  http://guides.rubyonrails.org/security.html
- PHP - http://php.net/manual/en/function.session-destroy.php
- JSF - http://jsfcentral.com/listings/A20158?link
- ASP.Net - https://msdn.microsoft.com/en-us/library/ms524798(v=vs.90).aspx
- Amazon AWS - http://docs.aws.amazon.com/appstream/latest/developerguide/rest-api-session-terminate.html

#### Dynamic Analysis

For a dynamic analysis of the application an interception proxy should be used. The following steps can be applied to check if the logout is implemented properly.  
1.  Log into the application.
2.  Do a couple of operations that require authentication inside the application.
3.  Perform a logout operation.
4.  Resend one of the operations detailed in step 2 using an interception proxy. For example, with Burp Repeater. The purpose of this is to send to the server a request with the token that has been invalidated in step 3.
 
If the session is correctly terminated on the server side, either an error message or redirect to the login page will be sent back to the client. On the other hand, if you have the same response you had in step 2, then, this session is still valid and has not been correctly terminated on the server side.
A detailed explanation with more test cases, can also be found in the OWASP Web Testing Guide (OTG-SESS-006)<sup>[1]</sup>.

#### Remediation 

One of the most common errors done when implementing a logout functionality is simply not destroying the session object on server side. This leads to a state where the session is still alive even though the user logs out of the application. The session remains alive, and if an attacker get’s in possession of a valid session he can still use it and a user cannot even protect himself by logging out or if there are no session timeout controls in place.
 
To mitigate it, the logout function on the server side must invalidate this session identifier immediately after logging out to prevent it to be reused by an attacker that could have intercepted it.
 
Related to this, it must be checked that after calling an operation with an expired token, the application does not generate another valid token. This could lead to another authentication bypass.
 
Many Apps do not automatically logout a user, because of customer convenience. The user logs in once, afterwards a token is generated on server side and stored within the applications internal storage and used for authentication when the application starts instead of asking again for user credentials. If the token expires a refresh token might be used (OAuth2) to transparently reinitiate the session for the user. There should still be a logout function available within the application and this should work according to best practices by also destroying the session on server side.

#### References

##### OWASP Mobile Top 10 2016
* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS
-- TODO [Update reference "VX.Y" below for "Testing the Logout Functionality"] --
- 4.3: "The remote endpoint terminates the existing session when the user logs out."

##### CWE

-- TODO [Add relevant CWE for "Testing the Logout Functionality"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

* [1] OTG-SESS-006 - https://www.owasp.org/index.php/Testing_for_logout_functionality
* [2] Session Management Cheat Sheet - https://www.owasp.org/index.php/Session_Management_Cheat_Sheet


### Testing the Password Policy

#### Overview

Password strength is a key concern when using passwords for authentication. Password policy defines requirements that end users should adhere to. Password length, password complexity and password topologies should properly be included in the Password Policy. A "strong" password policy makes it difficult or even infeasible for one to guess the password through either manual or automated means. 

A good password policy should defines following controls in order to avoid password guessing attacks or even brute-forcing. 

#####  Password Length
* Minimum length of the passwords should be enforced by the application.
* Maximum password length should not be set too low, as it will prevent users from creating passphrases. Typical maximum length is 128 characters.

##### Password Complexity
* Password must meet at least 3 out of the following 4 complexity rules
1. at least 1 uppercase character (A-Z)
2. at least 1 lowercase character (a-z)
3. at least 1 digit (0-9)
4. at least 1 special character (punctuation)
* at least 10 characters
* at most 128 characters
* not more than 2 identical characters in a row

##### Password Topologies
* Ban commonly used password topologies.
* Force multiple users to use different password topologies.
* Require a minimum topology change between old and new passwords.
-- TODO [Provide a general description of the issue "Testing the Password Policy".] --

#### Static Analysis

When testing a password policy, a well-defined rule set can be used to verify that source code not contain any previously identified technical or logical security flew. A exemplary rule set (source: VT Password<sup>[1]</sup>) is given below:
* AllowedCharacterRule - Does a password contain only a specific list of characters
* AlphabeticalSequenceRule - Does a password contain an alphabetical sequence
* CharacterCharacteristicRule - Does a password contain the desired mix of character types
* DictionaryRule - Does a password match a word in a dictionary
* DictionarySubstringRule - Does a password contain a word in a dictionary
* DigitCharacterRule - Does a password contain a digit
* HistoryRule - Does a password match a previous password, supports hashes
* IllegalCharacterRule - Does a password contain an illegal character
* LengthRule - Is a password of a certain length
* LowercaseCharacterRule - Does a password contain a lowercase character
* NonAlphanumericCharacterRule - Does a password contain a non-alphanumeric character
* NumericalSequenceRule - Does a password contain a numerical sequence
* RegexRule - Does a password match a regular expression
* RepeatCharacterRegexRule - Does a password contain a repeated character
* SequenceRule - Does a password contain a keyboard sequence
* SourceRule - Does a password match the password from another system or source
* QwertySequenceRule - Does a password contain a QWERTY keyboard sequence
* UppercaseCharacterRule - Does a password contain an uppercase character
* UsernameRule - Does a password contain a username
* WhitespaceRule - Does a password contain whitespace

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm remark "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>." ] --

-- TODO [Develop content on Testing the Password Policy with source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing the Password Policy" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

Issues related to Password Policy can easily be mitigated if application architecture is built with it from the beginning of the develpoment. Using regular expressions, developers could implement these policy settings. A list of regaular expressions which was discused in stackoverflow<sup>[2]</sup> is given below:
* ^                 # start-of-string
* (?=.*[0-9])       # a digit must occur at least once
* (?=.*[a-z])       # a lower case letter must occur at least once
* (?=.*[A-Z])       # an upper case letter must occur at least once
* (?=.*[@#$%^&+=])  # a special character must occur at least once
* (?=\S+$)          # no whitespace allowed in the entire string
* .{8,}             # anything, at least eight places though
* $                 # end-of-string

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing the Password Policy".] --

#### References

##### OWASP Mobile Top 10 2016
* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS
* 4.4: "A password policy exists and is enforced at the remote endpoint."

##### OWASP Testing Guide v4
* 4.5 - Authentication Testing - https://www.owasp.org/index.php/Testing_for_Weak_password_policy_(OTG-AUTHN-007)

##### CWE

-- TODO [Add relevant CWE for "Testing the Password Policy"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] VT Password - https://code.google.com/archive/p/vt-middleware/wikis/vtpassword.wiki
- [2] Stackoverflow - http://stackoverflow.com/questions/3802192/regexp-java-for-password-validation

##### Tools

-- TODO [Add relevant tools for "Testing the Password Policy"] --
* Enjarify - https://github.com/google/enjarify



### Testing Excessive Login Attempts

#### Overview

We all have heard about brute force attacks. That is one of the simplest attack types, as already many tools are available that work out of the box. It also doesn’t require a deep technical understanding of the target, as only a list of username and password combinations is sufficient to execute the attack. Once a valid combination of credentials is identified access to the application is possible and the account can be compromised.
 
To be protected against these kind of attacks, applications need to implement a control to block the access after a defined number of incorrect login attempts.
 
Depending on the application that you want to protect, the number of incorrect attempts allowed may vary. For example, in a banking application it should be around three to five attempts, but, in a public forum, it could be a higher number. Once this threshold is reached it also needs to be decided if the account gets locked permanently or temporarily. Locking the account temporarily is also called login throttling.
 
It is important to clarify that this control is at the server side, so the testing will be the same for iOS and Android applications.
Moreover, the test consists by entering the password incorrectly for the defined number of attempts to trigger the account lockout. At that point, the anti-brute force control should be activated and your logon should be rejected when the correct credentials are entered.

#### Static Analysis

It need to be checked that a validation method exists during logon that checks if the number of attempts for a username equals to the maximum number of attempts set. In that case, no logon should be granted once this threshold is meet.
After a correct attempt, there should also be a mechanism in place to set the error counter to zero.


#### Dynamic Analysis

For a dynamic analysis of the application an interception proxy should be used. The following steps can be applied to check if the lockout mechanism is implemented properly.  
1.  Log in incorrectly for a number of times to trigger the lockout control (generally 3 to 15 incorrect attempts)
2.  Once you have locked out the account, enter the correct logon details to verify if login is not possible anymore.
If this is correctly implemented logon should be denied when the right password is entered, as the credential has already been blocked.

#### Remediation

Lockout controls have to be implemented on server side to prevent brute force attacks. Further mitigation techniques are described by the OWASP in Blocking Brute Force Attacks<sup>[3]</sup>.
It is interesting to clarify that incorrect logon attempts should be cumulative and not linked to a session. If you implement a control to block the credential in your 3rd attempt in the same session, it can be easily bypassed by entering the details wrong two times and get a new session. This will then give another two free attempts.

#### References

##### OWASP Mobile Top 10 2016
* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS
* 4.5: "The remote endpoint implements an exponential back-off, or temporarily locks the user account, when incorrect authentication credentials are submitted an excessive number of times ."

##### CWE

-- TODO [Add relevant CWE for "Testing Excessive Login Attempts"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info
* [1] OTG-AUTHN-003 - https://www.owasp.org/index.php/Testing_for_Weak_lock_out_mechanism
* [2] Brute Force Attacks - https://www.owasp.org/index.php/Brute_force_attack
* [3] Blocking Brute Force Attacks - https://www.owasp.org/index.php/Blocking_Brute_Force_Attacks

##### Tools

* Burp Suite Professional - https://portswigger.net/burp/
* OWASP ZAP - https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project

### Testing Biometric Authentication

#### Overview

Android 6.0 introduced public APIs for authenticating users via fingerprint. Access to the fingerprint hardware is provided through the  <code>FingerprintManager</code> class <sup>[1]</sup>. An app can request fingerprint authentication instantiating a <code>FingerprintManager</code> object and calling its <code>authenticate()</code> method. The caller registers callback methods to handle possible outcomes of the authentication process (success, failure or error).

By using the fingerprint API in conjunction with the Android KeyGenerator class, apps can create a cryptographic key that must be "unlocked" with the user's fingerprint. This can be used to implement more convenient forms of user login. For example, to allow users access to a remote service, a symmetric key can be created and used to encrypt the user PIN or authentication token. By calling <code>setUserAuthenticationRequired(true)</code> when creating the key, it is ensured that the user must re-authenticate using their fingerprint to retrieve it. The encrypted authentication data itself can then be saved using regular storage (e.g. SharedPreferences).

Apart from this relatively reasonable method, fingerprint authentication can also be implemented in unsafe ways. For instance, developers might opt to assume successful authentication based solely on whether the <code>onAuthenticationSucceeded</code> callback <sup>3</sup> is called. This event however isn't proof that the user has performed biometric authentication - such a check can be easily patched or bypassed using instrumentation. Leveraging the Keystore is the only way to be reasonably sure that the user has actually entered their fingerprint (unless of course, the Keystore is compromised).

#### Static Analysis

Search for calls of <code>FingerprintManager.authenticate()</code>. The first parameter passed to this method should be a <code>CryptoObject</code> instance. <code>CryptoObject</code> is a wrapper class for the crypto objects supported by FingerprintManager <sup>[2]</sup>. If this parameter is set to <code>null</code>, the fingerprint auth is purely event-bound, which likely causes a security issue.

Trace back the creation of the key used to initialize the cipher wrapped in the CryptoObject. Verify that the key was created using the <code>KeyGenerator</code> class, and that <code>setUserAuthenticationRequired(true)</code> was called when creating the <code>KeyGenParameterSpec</code> object (see also the code samples below).

Verify the authentication logic. For the authentication to be successful, the remote endpoint **must** require the client to present the secret retrieved from the Keystore, or some value derived from the secret.

#### Dynamic Analysis

Patch the app or us runtime instrumentation to bypass fingerprint authentication on the client. For example, you could use Frida call the <code>onAuthenticationSucceeded</code> callback directly. Refer to the chapter "Tampering and Reverse Engineering on Android" for more information.

#### Remediation

Fingerprint authentication should be implemented allong the following lines:

Check whether fingerprint authentication is possible. The device must run Android 6.0 or higher (SDK 23+) and feature a fingerprint sensor. The user must have protected their logscreen and registered at least one fingerprint on the device. If any of those checks failed, the option for fingerprint authentication should not be offered.

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

To perform encryption or decryption, create a <code>Cipher</code> object and initialize it with the AES key. 

```java
	SecretKey keyspec = (SecretKey)keyStore.getKey(KEY_ALIAS, null);

    if (mode == Cipher.ENCRYPT_MODE) {
        cipher.init(mode, keyspec);
```

Note that the key cannot be used right away - it has to be authenticated through <code>FingerprintManager</code> first. This involves wrapping <code>Cipher</code> into a <code>FingerprintManager.CryptoObject</code> which is passed to <code>FingerprintManager.authenticate()</code>.

```java
	cryptoObject = new FingerprintManager.CryptoObject(cipher);
	FingerprintHandler helper = new FingerprintHandler(this);
	helper.startAuth(fingerprintManager, cryptoObject);
```

If authentication succeeds, the callback method <code>onAuthenticationSucceeded(FingerprintManager.AuthenticationResult result)</code> is called, and the authenticated CryptoObject can be retrieved from the authentication result. 

```java
public void authenticationSucceeded(FingerprintManager.AuthenticationResult result) {
	cipher = result.getCryptoObject().getCipher();

	(... do something with the authenticated cipher object ...)
}
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
- [4] Securing Your Android Appps with the Fingerprint API - https://www.sitepoint.com/securing-your-android-apps-with-the-fingerprint-api/#savingcredentials

##### Tools

N/A

### Testing the Session Timeout

#### Overview

Compared to web applications most mobile applications don’t have a session timeout mechanism that terminates the session after some period of inactivity and force the user to login again. For most mobile applications users need to enter the credentials once. After authenticating on server side an access token is stored on the device which is used to authenticate. If the token is about to expire the token will be renewed without entering the credentials again. Applications that handle sensitive data like patient data or critical functions like financial transactions should implement a session timeout as a security-in-depth measure that forces users to re-login after a defined period.
 
We will explain here how to check that this control is implemented correctly, both in the client and server side.

To test this, dynamic analysis is an efficient option, as it is easy to validate if this feature is working or not at runtime using an interception proxy. This is similar to test case "Testing the Logout Functionality", but we need to leave the application in idle for the period of time required to trigger the timeout function. Once this condition has been launched, we need to validate that the session is effectively terminated on client and server side.

#### Static Analysis

If server side code is available, it should be reviewed that the session timeout functionality is correctly configured and a timeout is triggered after a defined period of time.  
The check needed here will be different depending on the technology used. Here are different examples on how a session timeout can be configured:
- Spring (Java) - http://docs.spring.io/spring-session/docs/current/reference/html5/
- Ruby on Rails -  https://github.com/rails/rails/blob/318a20c140de57a7d5f820753c82258a3696c465/railties/lib/rails/application/configuration.rb#L130
- PHP - http://php.net/manual/en/session.configuration.php#ini.session.gc-maxlifetime
- ASP.Net - https://msdn.microsoft.com/en-GB/library/system.web.sessionstate.httpsessionstate.timeout(v=vs.110).aspx
- Amazon AWS - http://docs.aws.amazon.com/ElasticLoadBalancing/latest/DeveloperGuide/config-idle-timeout.html
 
Some applications also have an autologoff functionality in the client side. This is not a mandatory feature, but helps to improve to enforce a session timeout.  To implement this, the client side needs to control the timestamp when the screen has been displayed, and check continuously if the time elapsed is lower than the defined timeout. Once that time matches or excesses the timeout, the logoff method will be invoked, sending a signal to the server side to terminate the session and redirecting the customer to an informative screen.
For Android the following code might be used to implement it<sup>[3]</sup>:

```
public class TestActivity extends TimeoutActivity {
@Override protected void onTimeout() {
// logout
}
@Override protected long getTimeoutInSeconds() {
return 15 * 60; // 15 minutes
}
```

#### Dynamic Analysis

For a dynamic analysis of the application an interception proxy should be used. The following steps can be applied to check if the session timeout is implemented properly.  
-   Log into the application.
-   Do a couple of operations that require authentication inside the application.
-   Leave the application in idle until the session expires (for testing purposes, a reasonable timeout can be configured, and amended later in the final version)
 
Resend one of the operations executed in step 2 using an interception proxy. For example, with Burp Repeater. The purpose of this is to send to the server a request with the session ID that has been invalidated when the session has expired.
If session timeout has been correctly configured on the server side, either an error message or redirect to the login page will be sent back to the client. On the other hand, if you have the same response you had in step 2, then, this session is still valid, which means that the session timeout is not configured correctly.
More information can also be found in the OWASP Web Testing Guide (OTG-SESS-007)<sup>[1]</sup>.

#### Remediation

Most of the frameworks have a parameter to configure the session timeout. This parameter should be set accordingly to the best practices specified of the documentation of the framework. The best practice timeout setting may vary between 10 minutes to two hours, depending on the sensitivity of your application and the use case of it.
Regarding autologoff, the pseudocode of the implementation should be as follow:

Function autologoff<br>
    Get timestamp_start<br>
    While application_is_running<br>
        time=timestamp-timestamp_start<br>
        If time=logoff_condition<br>
            Call logoff<br>
        EndIf<br>
    EndWhile<br>
End<br>

#### References

##### OWASP Mobile Top 10 2016
* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS
* 4.7: "Sessions are terminated at the remote endpoint after a predefined period of inactivity."

##### CWE

-- TODO [Add relevant CWE for "Testing the Session Timeout"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

* [1] OWASP web application test guide https://www.owasp.org/index.php/Test_Session_Timeout_(OTG-SESS-007)
* [2] OWASP Session management cheatsheet https://www.owasp.org/index.php/Session_Management_Cheat_Sheet
* [3] Logout triggered by Client - https://github.com/zoltanersek/android-timeout-activity

##### Tools

-- TODO [Add relevant tools for "Testing the Session Timeout"] --
* Enjarify - https://github.com/google/enjarify



### Testing 2-Factor Authentication

#### Overview

https://authy.com/blog/security-of-sms-for-2fa-what-are-your-options/
-- TODO [Provide a general description of the issue "Testing 2-Factor Authentication".] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm remark on "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

-- TODO [Develop content on Testing 2-Factor Authentication with source code] --


#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing 2-Factor Authentication" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing 2-Factor Authentication".] --

#### References

##### OWASP Mobile Top 10 2016
* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS
* 4.8: "A second factor of authentication exists at the remote endpoint and the 2FA requirement is consistently enforced."

##### CWE

-- TODO [Add relevant CWE for "Testing 2-Factor Authentication"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add relevant tools for "Testing 2-Factor Authentication"] --
* Enjarify - https://github.com/google/enjarify

### Testing Step-up Authentication

#### Overview

-- TODO [Provide a general description of the issue "Testing Step-up Authentication".] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm remark on "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>." ] --

-- TODO [Develop content on Testing Step-up Authentication with source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing Step-up Authentication" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Step-up Authentication".] --

#### References

##### OWASP Mobile Top 10 2016
* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS
* 4.9: "Step-up authentication is required to enable actions that deal with sensitive data or transactions."

##### CWE

-- TODO [Add relevant CWE for "Testing Step-up Authentication"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add relevant tools for "Testing Step-up Authentication"] --
* Enjarify - https://github.com/google/enjarify

### Testing User Device Management

#### Overview

-- TODO [Provide a general description of the issue "Testing User Device Management".] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm remark on "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

--TODO [Develop content on Testing User Device Management with source code] --


#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing User Device Management" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing User Device Management".] --

#### References

##### OWASP Mobile Top 10 2016
* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS
* 4.10: "The app informs the user of all login activities with his or her account. Users are able view a list of devices used to access the account, and to block specific devices."

##### CWE

-- TODO [Add relevant CWE for "Testing User Device Management"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add relevant tools for "Testing User Device Management"] --
* Enjarify - https://github.com/google/enjarify
