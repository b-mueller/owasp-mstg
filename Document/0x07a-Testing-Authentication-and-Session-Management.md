## Remote Authentication and Authorization

The following chapter outlines authentication and session management requirements of the MASVS into technical test cases. Test cases listed in this chapter are focused on server side and therefore are not relying on a specific implementation on iOS or Android.  

For all of the test cases below, it need to be investigated first what kind of authentication mechanism is used. There are different mechanisms available, to implement server side authentication, either:
* Cookie-Based Authentication using a session ID or
* Token-Based Authentication.

Cookie-Based Authentication is the traditional authentication mechanism used in web applications, which is stateful. In order to adopt to the different requirements of mobile apps, a shift to stateless authentication or Token-Based Authentication can be seen. A prominent example for this is JSON Web Token or JWT<sup>[1]</sup> which can be part of an OAuth2 authentication and authorization framework.

#### OAuth2

OAuth2 is an authorization framework used to authorize an application to use a user account on an HTTP service for a limited time and, at the same time, preventing the client applications from having knowledge of any user credentials.

OAuth2 defines 4 roles:

* Resource Owner: the user owning the account.
* Client: the application that wants to access the user's account using the access tokens.
* Resource Server: hosts the user accounts.
* Authorization Server: verifies the identity of the user and issues access tokens to the application.

Note: The API fulfills both the resource and authorization server roles. Therefore we will refer to both as the API.

<img src="Images/Chapters/0x07a/abstract-oauth2-flow.png" width="350px"/>

Here is a more detailed explanation of the steps in the diagram <sup>[1]</sup> <sup>[2]</sup>:

1. The application requests authorization to access service resources from the user.
2. If the user authorized the request, the application receives an authorization grant. The authorization grant might have different forms (explicit, implicit, etc).
3. The application requests an access token from the authorization server (API) by presenting authentication of its own identity, and the authorization grant.
4. If the application identity is authenticated and the authorization grant is valid, the authorization server (API) issues an access token to the application. The access token might have a companion refresh token. Authorization is complete.
5. The application requests the resource from the resource server (API) and presents the access token for authentication. The access token might be used on different ways (e.g., as a bearer token).
6. If the access token is valid, the resource server (API) serves the resource to the application.

These are some of the common best practices for OAuth2 on native apps:

User-agent:
- Use an external user-agent (the browser) instead of an embedded user-agent (e.g. WebView or internal client user interface) to prevent End-User Credentials Phishing (e.g. you do not want an app offering you a "Login with Facebook" to get your Facebook password). However, by using the browser, the app relies on the OS Keychain for server trust. This way it will not be possible to implement certificate pinning. A solution for this would be to restrict the embedded user-agent to only the relevant domain.
- The user should have a way to verify visual trust mechanisms (e.g., Transport Layer Security (TLS) confirmation, web site mechanisms).
- The client should validate the fully qualified domain name of the server to the public key presented by the server during connection establishment to prevent man-in-the-middle attacks.

Type of grant:
- Use code grant instead of implicit grant on native apps.
- When using code grant, implement PKCE (Proof Key for Code Exchange) to protect the code grant. Make sure that the server also implements it.
- The auth "code" should be short-lived and only used immediately after receiving it. Make sure that they only reside on transient memory and are not stored or logged.

Client secrets:
- No shared secret should be used as proof of the client's identity as this could lead to client impersonation ("client_id" already serves this purpose). If for some reason they do use client secrets, be sure that they are stored in secure local storage.

End-User credentials:
- The transmission of end-user credentials must be protected using transport-layer mechanisms such as TLS.

Tokens:
- Keep access tokens in transient memory.
- Access tokens must be securely transmitted via TLS.
- The scope and expiry time of access tokens should be reduced when end-to-end confidentiality cannot be guaranteed or when the token provides access to sensitive information or allows the execution of high risk actions.
- Remember that if the app uses access tokens as bearer tokens and no additional mechanism is used to identify the client, the attacker can access all resources associated with the token and its scope after stealing the tokens.
- Store refresh tokens in secure local storage as they are long-term credentials.

For additional best practices and detailed information please refer to the source documents <sup>[2]</sup> <sup>[3]</sup> <sup>[4]</sup>.

##### References
- [1] An Introduction into OAuth2 - https://www.digitalocean.com/community/tutorials/an-introduction-to-oauth-2
- [2] RFC6749: The OAuth 2.0 Authorization Framework (October 2012) - https://tools.ietf.org/html/rfc6749
- [3] draft_ietf-oauth-native-apps-12: OAuth 2.0 for Native Apps (June 2017) - https://tools.ietf.org/html/draft-ietf-oauth-native-apps-12
- [4] RFC6819: OAuth 2.0 Threat Model and Security Considerations (January 2013) - https://tools.ietf.org/html/rfc6819



### Verifying that Users Are Properly Authenticated

#### Overview

Applications often have different areas with, on the one hand public and non-privileged information and functions, and on the other hand sensitive and privileged information and functions. Users can legitimately access the first ones without any restriction; however, in order to make sure sensitive and privileged information and functions are protected and accessible only to legitimate users, proper authentication has to be in place.  

Authentication always need to be handled in the server side code and should never rely on client-side controls. Client-side controls can be used to improve the user workflow and only allow specific actions, but there always need to be the server-side counterpart that defines what a user is allowed to access.

In case Token-Based authentication with JWT is used, please also look at the test case "Testing JSON Web Token (JWT)".

#### Static Analysis

When server-side source code is available, first identify which authentication mechanism (Token or Cookie based) is used and enforced on server side. Afterwards locate all endpoints with sensitive and privileged information and functions: they are the ones that need to be protected. Prior to accessing any item, the application must make sure the user is really who he pretends to and that he is allowed to access the endpoint. Look for keywords in the server source code that are used to authenticate a user or to retrieve and check an existing session.

Authentication mechanisms shouldn't be implemented from scratch, instead they should be build on top of frameworks that offer this functionality. The framework used on the server side should be identified and the usage of the available authentication APIs/functions should be verified if they are used accordingly to best practices. Widely used frameworks on server side are for example:

- Spring (Java) - https://projects.spring.io/spring-security/
- Struts (Java) - https://struts.apache.org/docs/security.html
- Laravel (PHP) - https://laravel.com/docs/5.4/authentication
- Ruby on Rails -  http://guides.rubyonrails.org/security.html

#### Dynamic Analysis

To verify authentication, first all privileged endpoints a user can access within an app should be explored. For all requests sent to an endpoint, an interception proxy can be used to capture network traffic while being authenticated. Then, try to replay requests while removing the authentication information. If the endpoint is still sending back the requested data, that should only be available for authenticated users, authentication checks are not implemented properly on the endpoint.

Further attacks methods can be found in the OWASP Testing Guide V4 (OTG-AUTHN-004)<sup>[3]</sup> and also the OWASP Testing Guide<sup>[2]</sup> should be consulted for more authentication test cases.

#### Remediation

For every endpoint that needs to be protected, implement a mechanism that checks the session ID or token of the user:
- if there is no session ID or token, the user may not have been authenticated before;
- if a session ID or token exists, make sure that it is valid and that it grants the user with sufficient privileges to allow the user to access the endpoint.

If any of these two conditions raise an issue, reject the request and do not allow the user to access the endpoint.

#### References

##### OWASP Mobile Top 10 2016

* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS

- 4.1: "If the app provides users with access to a remote service, an acceptable form of authentication such as username/password authentication is performed at the remote endpoint."

##### CWE

- CWE-287: Improper Authentication

##### Info

* [1] OWASP JWT Cheat Sheet for Java: https://www.owasp.org/index.php/JSON_Web_Token_(JWT)_Cheat_Sheet_for_Java
* [2] OWASP Testing Guide V4 (Testing for Session Management) - https://www.owasp.org/index.php/Testing_for_Session_Management
* [3] OWASP Testing Guide V4 (OTG-AUTHN-004) - https://www.owasp.org/index.php/Testing_for_Bypassing_Authentication_Schema_(OTG-AUTHN-004)


### Testing Session Management

#### Overview

All significant, if not privileged, actions must be done after a user is properly authenticated; the application will remember the user inside a session. When improperly managed, sessions are subject to a variety of attacks where the session of a legitimate user may be abused, allowing the attacker to impersonate the user. As a consequence, data may be lost, confidentiality compromised or illegitimate actions performed.

Sessions must have a beginning and an end. It must be impossible for an attacker to forge a session ID: instead, it must be ensured that a session can only be started by the system on the server side. Also, the duration of a session should be as short as possible, and the session must be properly terminated after a given amount of time or after the user has explicitly logged out. It must be impossible to reuse session ID.

As such, the scope of this test is to validate that sessions are securely managed and cannot be compromised by an attacker.

#### Static Analysis

When server source code is available, the tester should look for the place where sessions are initiated, stored, exchanged, verified and terminated. This must be done whenever any access to privileged information or action takes place. For those matters, automated tools or manual search can be used to look for relevant keywords in the target programming language. Sample frameworks on server side are:

- Spring (Java) - http://docs.spring.io/spring-security/site/docs/current/reference/htmlsingle/#ns-session-mgmt
- PHP - http://php.net/manual/en/book.session.php
- Ruby on Rails -  http://guides.rubyonrails.org/security.html

#### Dynamic Analysis

A best practice is to crawl the application first, either manually or with an automated tool. The goal is to check if all parts of the application leading to privileged information or actions are protected and a valid session ID is required or not.

Then, you can use the crawled requests within any intercepting proxy to try to manipulate session IDs:
- by modifying them into illegitimate ones (for instance, add 1 to the valid session ID or delete parts of it).
- by deleting a valid one in the request to test if the information and/or function of the application can still be accessed.
- by trying to log out and re-log in again to check if the session ID has changed or not.
- when changing privilege level (step-up authentication). Try to use the former one (hence with a lower authorization level) to access the privileged part of the application.
- by trying to re-use a session ID after logging out.

Also the OWASP Testing Guide<sup>[1]</sup> should be consulted for more session management test cases.

#### Remediation

In order to offer proper protection against the attacks mentioned earlier, session IDs must:
- always be created on the server side,
- not be predictable (use proper length and entropy),
- always be exchanged over secure connections (e.g. HTTPS),
- be stored securely within the mobile app,
- be verified when a user is trying to access privileged parts of an application (a session ID must be valid and correspond to the proper level of authorization),
- be renewed when a user is asked to log in again to perform an operation requiring higher privileges and
- be terminated on server side and deleted within the mobile app when a user logs out or after a specified timeout.

It is strongly advised to use session ID generators that are build-in within the framework used, as they are more secure than building a custom one. Such generators exist for most frameworks and languages.

#### References

##### OWASP Mobile Top 10 2016

* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS

* 4.2: "The remote endpoint uses randomly generated session identifiers, if classical server side session management is used, to authenticate client requests without sending the user's credentials."

##### CWE

- CWE-613: Insufficient Session Expiration

##### Info

[1] OWASP Testing Guide V4 (Testing for Session Management) - https://www.owasp.org/index.php/Testing_for_Session_Management

##### Tools

* OWASP ZAP (Zed Attack Proxy)
* Burp Suite



### Testing JSON Web Token (JWT)

#### Overview

JSON Web Token (JWT) ensures the integrity of information within a JSON object between two parties and is defined in RFC 7519<sup>[1]</sup>. A cryptographic signature is created for the data within the token. This only allows the server to create and modify tokens and enables a stateless authentication. The server doesn't need to remember any session or any other authentication information, as everything is contained within JWT.

An example of an encoded JSON Web Token can be found below<sup>[5]</sup>.

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9.TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ
```

JWTs are Base-64 encoded and are divided into three parts:

* **Header** Algorithm and Token Type (eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9):
```JSON
{"alg":"HS256","typ":"JWT"}
```
* **Claims** Data  (eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiYWRtaW4iOnRydWV9):
```JSON
{"sub":"1234567890","name":"John Doe","admin":true}
```
* **JSON Web Signature (JWS)** (TJVA95OrM7E2cBab30RMHrHDcEfxjoYZgeFONFh7HgQ):
```JSON
HMACSHA256(
  base64UrlEncode(header) + "." +
  base64UrlEncode(payload),
  secret
)
```

For mobile apps it's more and more used to authenticate both the message sender and receiver by using JWT. JWT implementations are available for all major programming languages, like PHP<sup>[2]</sup> or Java Spring<sup>[3]</sup>.

#### Static Analysis

Identify the JWT library that is used on server and client side. Check if there are any known vulnerabilities available for the JWT libraries in use.

The following best practices should be checked in the JWT libraries<sup>[7]</sup>:
* Verify the signature or HMAC on server-side at all times for all incoming requests containing a token.
* Verify where the private signing key or secret key for HMAC is located and stored. The key should always reside on the server side and never shared with the client. It should only be available for the issuer and verifier.
* Verify if encryption is used to encrypt the data embedded into JWT.
* Verify if replay attacks are addressed by using `jti` (JWT ID) claim, which provides a unique identifier for JWT.


#### Dynamic Analysis

Several known vulnerabilities in JWT should be checked while executing a dynamic analysis:
* Hashing algorithm `none`<sup>[6]</sup>:
  * Modify the `alg` attribute in the token header and delete `HS256` and set it to `none` and use an empty signature (e.g. signature = ""). Use this token and replay it in a request. Some libraries treat tokens signed with the none algorithm as a valid token with a verified signature. This would allow an attacker to create their own "signed" tokens.
* Usage of asymmetric algorithms<sup>[6]</sup>:
  *  JWT offers several asymmetric algorithms as RSA or ECDSA. In this case the private key will be used to sign the tokens and the verification will be done through the public key. If a server is expecting a token signed with an asymmetric algorithm as RSA, but actually receives a token signed with HMAC, it will think the public key is actually an HMAC secret key. The public key can now be misused as HMAC secret key in order to sign the tokens.
* Token Storage on client side:
  * When using a mobile app that uses JWT it should be verified where the token is stored locally on the device<sup>[5]</sup>.
* Cracking the signing key:
  * Creating a signature of the token is done through a private key on server side. Once a JWT is obtained there are several tools available that can try to brute force the secret key offline<sup>[8]</sup>. See the tools section for details.
* Information Disclosure:
  * Decode the Base-64 encoded JWT and check what kind of data is transmitted within it and if it's encrypted or not.

Please also follow the test cases in the OWASP JWT Cheat Sheet<sup>[4]</sup> and check the implementation of the logout as described in "Testing the Logout Functionality".

#### Remediation

The following best practices should be considered, when implementing JWT:

* The latest version available of the JWT libraries in use should be implemented, to avoid known vulnerabilities.
* Make sure that tokens with a different signature type are guaranteed to be rejected.
* Store the JWT on the mobile phone using a secure mechanism, like KeyChain on iOS or KeyStore on Android.
* The private signing key or secret key for HMAC should only be available on server side.
* If replay attacks are a risk for the app, `jti` (JWT ID) claim should be implemented.
* Ideally the content of JWT should be encrypted in order to ensure the confidentially of the information contained within it. There might be description of roles, usernames or other sensitive information available that should be protected. An example implementation in Java can be found in the OWASP JWT Cheat Sheet<sup>[4]</sup>
* Clarify if copying a token to another device should or should not make an attacker able to continue authenticated. Check the device binding test case, if this should be enforced.

#### References

##### OWASP Mobile Top 10 2016

* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS

* 4.3: "The remote endpoint uses server side signed tokens, if stateless authentication is used, to authenticate client requests without sending the user's credentials."

##### CWE

* CWE-287: Improper Authentication

##### Info

* [1] RFC 7519 JSON Web Token (JWT) - https://tools.ietf.org/html/rfc7519
* [2] PHP JWT - https://github.com/firebase/php-jwt
* [3] Java Spring with JWT - http://projects.spring.io/spring-security-oauth/docs/oauth2.html
* [4] OWASP JWT Cheat Sheet - https://www.owasp.org/index.php/JSON_Web_Token_(JWT)_Cheat_Sheet_for_Java
* [5] Sample of JWT Token - https://jwt.io/#debugger
* [6] Critical Vulnerabilities in JSON Web Token - https://auth0.com/blog/critical-vulnerabilities-in-json-web-token-libraries/
* [7] JWT the right way - https://stormpath.com/blog/jwt-the-right-way
* [8] Attacking JWT Authentication - https://www.sjoerdlangkemper.nl/2016/09/28/attacking-jwt-authentication/

##### Tools
* jwtbrute - https://github.com/jmaxxz/jwtbrute
* crackjwt - https://github.com/Sjord/jwtcrack/blob/master/crackjwt.py
* John the ripper - https://github.com/magnumripper/JohnTheRipper



### Testing the Logout Functionality

#### Overview

Reducing the lifetime of session identifiers and tokens to a minimum decreases the likelihood of a successful account hijacking attack. The scope for this test case is to validate that the application has a logout functionality and it effectively terminates the session on client and server side or invalidates a stateless token.

One of the most common errors done when implementing a logout functionality is simply not destroying the session object or invalidating the token on server side. This leads to a state where the session or token is still alive even though the user logs out of the application. If an attacker get’s in possession of valid authentication information he can continue using it and hijack a user account.

##### Static Analysis 

If server side code is available, it should be reviewed that the session is being terminated or token invalidated as part of the logout functionality. The check needed here will be different depending on the technology used. Here are different examples on how a session can be terminated in order to implement a proper logout on server side:
- Spring (Java) -  http://docs.spring.io/spring-security/site/docs/current/apidocs/org/springframework/security/web/authentication/logout/SecurityContextLogoutHandler.html
- Ruby on Rails -  http://guides.rubyonrails.org/security.html
- PHP - http://php.net/manual/en/function.session-destroy.php

For stateless authentication the access token and refresh token (if used) should be deleted from the mobile device and the refresh token should be invalidated on server side<sup>[1]</sup>.

#### Dynamic Analysis

For a dynamic analysis of the application an interception proxy should be used. The following steps can be applied to check if the logout is implemented properly.  
1.  Log into the application.
2.  Do a couple of operations that require authentication inside the application.
3.  Perform a logout operation.
4.  Resend one of the operations detailed in step 2 using an interception proxy. For example, with Burp Repeater. The purpose of this is to send to the server a request with the session ID or token that has been invalidated in step 3.
 
If the logout is correctly implemented on the server side, either an error message or redirect to the login page will be sent back to the client. On the other hand, if you have the same response you had in step 2, then the token or session ID is still valid and has not been correctly terminated on the server side.
A detailed explanation with more test cases, can also be found in the OWASP Web Testing Guide (OTG-SESS-006)<sup>[2]</sup>.

#### Remediation 

The logout function on the server side must invalidate the session identifier or token immediately after logging out to prevent it to be reused by an attacker that could have intercepted it<sup>[3]</sup>.

Many mobile apps do not automatically logout a user, because of customer convenience by implementing stateless authentication. There should still be a logout function available within the application and this should work accordingly to best practices by also destroying the access and refresh token on client and server side. Otherwise this could lead to another authentication bypass in case the refresh token is not invalidated.

#### References

##### OWASP Mobile Top 10 2016
* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS

* 4.4: "The remote endpoint terminates the existing session or server side signed tokens when the user logs out."

##### CWE

* CWE-613: Insufficient Session Expiration

##### Info

* [1] JWT token blacklisting - https://auth0.com/blog/blacklist-json-web-token-api-keys/
* [2] OTG-SESS-006 - https://www.owasp.org/index.php/Testing_for_logout_functionality
* [3] Session Management Cheat Sheet - https://www.owasp.org/index.php/Session_Management_Cheat_Sheet



### Testing the Password Policy

#### Overview

Password strength is a key concern when using passwords for authentication. Password policy defines requirements that end users should adhere to. Password length, password complexity and password topologies should properly be included in the password policy. A "strong" password policy makes it difficult or even infeasible for one to guess the password through either manual or automated means.


#### Static Analysis

Regular Expressions are often used to validate passwords. The password verification check against a defined password policy need to be reviewed if it rejects passwords that violate the password policy.

Passwords can be set when registering accounts, changing the password or when resetting the password in a forgot password process. All of the available functions in the application that are able to change or set a password need to be identified in the source code. They should all be using the same password verification check, that is aligned with the password policy.

Here are different examples on how a validation can be implemented server-side:

* Spring (Java) -  https://docs.spring.io/spring/docs/current/javadoc-api/org/springframework/validation/Validator.html
* Ruby on Rails -  http://guides.rubyonrails.org/active_record_validations.html
* PHP - http://php.net/manual/en/filter.filters.validate.php

If a framework is used that offers the possibility to create and enforce a password policy for all users of the application, the configuration should be checked.

#### Dynamic Analysis

All available functions that allow a user to set a password need to be verified, if passwords can be used that violate the password policy specifications. This can be:

- Self-registration function for new users that allows to specify a password,
- Forgot Password function that allows a user to set a new password or
- Change Password function that allows a logged in user to set a new password.

An interception proxy should be used, to bypass client passwords checks within the app in order to be able verify the password policy implemented on server side. More information about testing methods can be found in the OWASP Testing Guide (OTG-AUTHN-007)<sup>[1]</sup>


#### Remediation

A good password policy should define the following requirements<sup>[2]</sup> in order to avoid password brute-forcing:

**Password Length**
* Minimum length of the passwords should be enforced, at least 10 characters.
* Maximum password length should not be set too low, as it will prevent users from creating passphrases. Typical maximum length is 128 characters.

**Password Complexity**
* Password must meet at least 3 out of the following 4 complexity rules
1. at least 1 uppercase character (A-Z)
2. at least 1 lowercase character (a-z)
3. at least 1 digit (0-9)
4. at least 1 special character (punctuation)

For further details check the OWASP Authentication Cheat Sheet<sup>[2]</sup>. A common library that can be used for estimating password strength is zxcvbn<sup>[3]</sup>, which is available for many programming languages.


#### References

##### OWASP Mobile Top 10 2016
- M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS
- 4.5: "A password policy exists and is enforced at the remote endpoint."

##### CWE
- CWE-521: Weak Password Requirements

##### Info
- [1] OWASP Testing Guide (OTG-AUTHN-007) - https://www.owasp.org/index.php/Testing_for_Weak_password_policy_(OTG-AUTHN-007)
- [2] OWASP Authentication Cheat Sheet - https://www.owasp.org/index.php/Authentication_Cheat_Sheet#Implement_Proper_Password_Strength_Controls
- [3] zxcvbn - https://github.com/dropbox/zxcvbn


### Testing Excessive Login Attempts

#### Overview

We all have heard about brute force attacks. This is one of the simplest attack types, as already many tools are available that work out of the box. It also doesn’t require a deep technical understanding of the target, as only a list of username and password combinations is sufficient to execute the attack. Once a valid combination of credentials is identified access to the application is possible and the account can be taken over.
 
To be protected against these kind of attacks, applications need to implement a control to block the access after a defined number of incorrect login attempts.
 
Depending on the application that you want to protect, the number of incorrect attempts allowed may vary. For example, in a banking application it should be around three to five attempts, but, in a app that doesn't handle sensitive information it could be a higher number. Once this threshold is reached it also needs to be decided if the account gets locked permanently or temporarily. Locking the account temporarily is also called login throttling.
 
The test consists by entering the password incorrectly for the defined number of attempts to trigger the account lockout. At that point, the anti-brute force control should be activated and your logon should be rejected when the correct credentials are entered.

#### Static Analysis

It need to be checked that a validation method exists during logon that checks if the number of attempts for a username equals to the maximum number of attempts set. In that case, no logon should be granted once this threshold is meet. After a correct attempt, there should also be a mechanism in place to set the error counter to zero.


#### Dynamic Analysis

For a dynamic analysis of the application an interception proxy should be used. The following steps can be applied to check if the lockout mechanism is implemented properly.  
1.  Log in incorrectly for a number of times to trigger the lockout control (generally 3 to 15 incorrect attempts). This can be automated by using Burp Intruder<sup>[5]</sup>.
2.  Once you have locked out the account, enter the correct logon details to verify if login is not possible anymore.
If this is correctly implemented logon should be denied when the right password is entered, as the account has already been blocked.

#### Remediation

Lockout controls have to be implemented on server side to prevent brute force attacks. Further mitigation techniques are described by OWASP in Blocking Brute Force Attacks<sup>[3]</sup>.
It is interesting to clarify that incorrect login attempts should be cumulative and not linked to a session. If you implement a control to block the credential in your 3rd attempt in the same session, it can be easily bypassed by entering the details wrong two times and get a new session. This will then give another two free attempts.

Alternatives to locking accounts are enforcing 2-Factor-Authentication (2FA) for all accounts or the usage of CAPTCHAS. See also Credential Cracking OAT-007 in the OWASP Automated Thread Handbook<sup>[4]</sup>.

#### References

##### OWASP Mobile Top 10 2016
* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS
* 4.6: "The remote endpoint implements an exponential back-off, or temporarily locks the user account, when incorrect authentication credentials are submitted an excessive number of times ."

##### CWE

- CWE-307: Improper Restriction of Excessive Authentication Attempts

##### Info
* [1] OTG-AUTHN-003 - https://www.owasp.org/index.php/Testing_for_Weak_lock_out_mechanism
* [2] Brute Force Attacks - https://www.owasp.org/index.php/Brute_force_attack
* [3] Blocking Brute Force Attacks - https://www.owasp.org/index.php/Blocking_Brute_Force_Attacks
* [4] OWASP Automated Threats to Web Applications - https://www.owasp.org/index.php/OWASP_Automated_Threats_to_Web_Applications
* [5] Burp Intruder - https://portswigger.net/burp/help/intruder.html

##### Tools
* Burp Suite Professional - https://portswigger.net/burp/
* OWASP ZAP - https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project



### Testing the Session Timeout

#### Overview

Compared to web applications most mobile applications don’t have a visible timeout mechanism that terminates the session ID or token after some period of inactivity and force the user to login again. For most mobile applications users need to enter the credentials once and use a stateless authentication mechanism. Mobile apps that handle sensitive data like patient data or critical functions like financial transactions should implement a timeout as a security-in-depth measure that forces users to re-login after a defined period of time.
 
We will explain here how to check that this control is implemented correctly, both in the client and server side.

#### Static Analysis

If server side code is available, it should be reviewed that the session timeout or token invalidation functionality is correctly configured and a timeout is triggered after a defined period of time.  
The check needed here will be different depending on the technology used. Here are different examples on how a session timeout can be configured:
* Spring (Java) - http://docs.spring.io/spring-session/docs/current/reference/html5/
* Ruby on Rails - http://guides.rubyonrails.org/security.html#session-expiry
* PHP - http://php.net/manual/en/session.configuration.php#ini.session.gc-maxlifetime
* ASP.Net - https://msdn.microsoft.com/en-GB/library/system.web.sessionstate.httpsessionstate.timeout(v=vs.110).aspx

In case of stateless authentication, once a token is signed, it is valid forever unless the signing key is changed or expiration explicitly set. One could use "exp" expiration claim<sup>[3]</sup> to define the expiration time on or after which the JWT must not be accepted for processing.
Speaking of tokens for stateless authentication, one should differentiate types of tokens, such as access tokens and refresh tokens<sup>[4]</sup>. Access tokens are used for accessing protected resources and should be short-lived. Refresh tokens are primarily used to obtain renewed access tokens. They are rather long-lived but should expire too, as otherwise their leakage would expose the system for unauthorized use.

The exact values for token expiration depend on the application requirements and capacity. Sample code for JWT token refreshments is presented below:
```
 app.post('/refresh_token', function (req, res) {
  // verify the existing token
  var profile = jwt.verify(req.body.token, secret);

  // if more than 14 days old, force login
  if (profile.original_iat - new Date() > 14) { // iat == issued at
    return res.send(401); // re-logging
  }

  // check if the user still exists or if authorization hasn't been revoked
  if (!valid) return res.send(401); // re-logging

  // issue a new token
  var refreshed_token = jwt.sign(profile, secret, { expiresInMinutes: 60*5 });
  res.json({ token: refreshed_token });
});
```

#### Dynamic Analysis

Dynamic analysis is an efficient option, as it is easy to validate if the session timeout is working or not at runtime using an interception proxy. This is similar to test case "Testing the Logout Functionality", but we need to leave the application in idle for the period of time required to trigger the timeout function. Once this condition has been launched, we need to validate that the session is effectively terminated on client and server side.

The following steps can be applied to check if the session timeout is implemented properly.  
1. Log into the application.
2. Do a couple of operations that require authentication inside the application.
3. Leave the application in idle until the session expires (for testing purposes, a reasonable timeout can be configured, and amended later in the final version)
 
Resend one of the operations executed in step 2 using an interception proxy, for example with Burp Repeater. The purpose of this is to send to the server a request with the session ID that has been invalidated when the session has expired.
If session timeout has been correctly configured on the server side, either an error message or redirect to the login page will be sent back to the client. On the other hand, if you have the same response you had in step 2, then, this session is still valid, which means that the session timeout is not configured correctly.
More information can also be found in the OWASP Web Testing Guide (OTG-SESS-007)<sup>[1]</sup>.

#### Remediation

Most of the frameworks have a parameter to configure the session timeout. This parameter should be set accordingly to the best practices specified of the documentation of the framework. The best practice timeout setting may vary between 10 minutes to two hours, depending on the sensitivity of your application and the use case of it.

#### References

##### OWASP Mobile Top 10 2016
* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS
* 4.8: "Sessions and server side signed tokens are terminated at the remote endpoint after a predefined period of inactivity."

##### CWE
- CWE-613: Insufficient Session Expiration

##### Info
* [1] OWASP Web Application Test Guide (OTG-SESS-007) - https://www.owasp.org/index.php/Test_Session_Timeout_(OTG-SESS-007)
* [2] OWASP Session management cheatsheet - https://www.owasp.org/index.php/Session_Management_Cheat_Sheet
* [3] RFC 7519 - https://tools.ietf.org/html/rfc7519#section-4.1.4
* [4] Refresh tokens & access tokens - https://auth0.com/blog/refresh-tokens-what-are-they-and-when-to-use-them/


### Testing 2-Factor Authentication and Step-up Authentication

#### Overview

Two-factor authentication (2FA) is becoming a standard when logging into mobile apps. Typically the first factor might be credentials (username/password), followed by a second factor which could be an One Time Password (OTP) sent via SMS. The key aspect of 2FA is to use two different factors out of the following categories:
* Something you have: this can be a physical object like a hardware token, a digital object like X.509 certificates (in enterprise environments) or generation of software tokens on the mobile phone itself.
* Something you know: this can be a secret only known to the user like a password.
* Something you are: this can be biometric characteristics that identify the users like TouchID.

Applications that offer access to sensitive data or critical functions, might require users additionally to re-authenticate with a stronger authentication mechanism. For example, after logging in via biometric authentication (e.g. TouchID) into a banking app, a user might need to do a so called "Step-up Authentication" again through OTP in order to execute a bank transfer.

A key advantage of step-up authentication is improved usability for the user. A user is asked to authenticate with the additional factor only when necessary.


#### Static Analysis

When server-side source code is available, first identify how a second factor or step-up authentication is used and enforced. Afterwards locate all endpoints with sensitive and privileged information and functions: they are the ones that need to be protected. Prior to accessing any item, the application must make sure the user has already passed 2FA or the step-up authentication and that he is allowed to access the endpoint.

2FA or step-up authentication shouldn't be implemented from scratch, instead they should be build on top of available libraries that offer this functionality. The libraries used on the server side should be identified and the usage of the available APIs/functions should be verified if they are used accordingly to best practices.

For example server side libraries like GoogleAuth<sup>[2]</sup> can be used. Such libraries rely on a widely accepted mechanism of implementing an additional factor by using Time-Based One-Time Password Algorithms (TOTP). TOTP is a cryptographic algorithm that computes a OTP from a shared secret key between the client and server and the current time. The created OTPs are only valid for a short amount of time, usually 30 to 60 seconds.

Instead of using libraries in the server side code, also available cloud solutions can be used like for example:

- Google Authenticator<sup>[2]</sup>
- Microsoft Authenticator<sup>[3]</sup>
- Authy<sup>[4]</sup>

Regardless if the implementation is done within the server side or by using a cloud provider, the TOTP app need to be started and will display the OTP that need to be keyed in into the app that is waiting to authenticate the user.

For local biometric authentication as an additional factor, please verify the test case "Testing Biometric Authentication".

#### Dynamic Analysis

First, all privileged endpoints a user can only access with step-up authentication or 2FA within an app should be explored. For all of these requests sent to an endpoint, an interception proxy can be used to capture network traffic. Then, try to replay requests with a token or session information that hasn't been elevated yet via 2FA or step-up authentication. If the endpoint is still sending back the requested data, that should only be available after 2FA or step-up authentication, authentication checks are not implemented properly on the endpoint.

The recorded requests should also be replayed without providing any authentication information, in order to check for a complete bypass of authentication mechanisms.

Another attack is related to the case "Testing Excessive Login Attempts" - given that many OTPs are just numeric values, if the accounts are not locked after N unsuccessful attempts on this stage, an attacker can bypass second factor by simply bruterorcing the values within the range at the lifespan of the OTP. For 6-digit values and 30-second time step there's more than 90% probability to find a match within 72 hours.

#### Remediation

The implementation of a second or multiple factors should be strictly enforced on server-side for all critical operations. If cloud solutions are in place, they should be implemented accordingly to best practices.

Step-up authentication should be optional for the majority of user scenarios and only enforced for critical functions or when accessing sensitive data.

Account lockouts for the second factor should be implemented the same way as for non-2FA cases (see "Testing Excessive Login Attempts" and [5]).

Regardless of 2FA or step-up authentication, additionally it should be supplemented with passive contextual authentication<sup>[1]</sup>, which can be:

* Geolocation
* IP address
* Time of day

Ideally the user's context is compared to previously recorded data to identify anomalies that might indicate account abuse or potential fraud. This is all happening transparent for the user, but can become a powerful control in order to stop attackers.

An additional control to ensure that an authorized user is using the app on an authorized device is to verify if device binding controls are in place. Please check also "Testing Device Binding" for iOS and Android.

#### References

##### OWASP Mobile Top 10 2016
* M4 - Insecure Authentication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M4-Insecure_Authentication

##### OWASP MASVS

* 4.9: "A second factor of authentication exists at the remote endpoint and the 2FA requirement is consistently enforced."
* 4.10: "Step-up authentication is required to enable actions that deal with sensitive data or transactions."

##### CWE
- CWE-287: Improper Authentication
- CWE-308: Use of Single-factor Authentication

##### Info

* [1] Best Practices for Step-up Multi-factor Authentication  - http://www.mtechpro.com/2016/newsletter/may/Ping_Identity_best-practices-stepup-mfa-3001.pdf
* [2] Google Authenticator - https://support.google.com/accounts/answer/1066447?hl=en
* [3] Microsoft Authenticator - https://docs.microsoft.com/en-us/azure/multi-factor-authentication/end-user/microsoft-authenticator-app-how-to
* [4] Authy - https://authy.com/
* [5] https://www.owasp.org/index.php/Blocking_Brute_Force_Attacks


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
* 4.11: "The app informs the user of all login activities with his or her account. Users are able view a list of devices used to access the account, and to block specific devices."

##### CWE

-- TODO [Add relevant CWE for "Testing User Device Management"] --
- CWE-312: Cleartext Storage of Sensitive Information

##### Info

- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add relevant tools for "Testing User Device Management"] --
* Enjarify - https://github.com/google/enjarify
