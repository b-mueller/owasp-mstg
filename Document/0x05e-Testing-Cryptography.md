## Testing Cryptography in Android Apps

### Verifying the Configuration of Cryptographic Standard Algorithms

#### Overview

A general rule in app development is that one should never attempt to invent their own cryptography. In mobile apps in particular, any form of crypto should be implemented using existing, robust implementations. In 99% of cases, this simply means using the data storage APIs and cryptographic libraries that come with the mobile OS.

Android developers don't need to bother much with the intricate details of cryptography most of the time. However, even when using standard algorithms can be affected if misconfigured. 

#### Static Analysis

-- TODO [Describe Static Analysis on Verifying the Configuration of Cryptographic Standard Algorithms : how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Clarify the purpose of "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

-- TODO [Develop Static Analysis with source code of "Verifying the Configuration of Cryptographic Standard Algorithms"] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Verifying the Configuration of Cryptographic Standard Algorithms" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- REVIEW --
Use cryptographic algorithm configurations that are currently considered strong, such those from NIST<sup>1</sup> and BSI<sup>2</sup> recommendations.


#### References

##### OWASP Mobile Top 10

* M6 - Broken Cryptography

##### OWASP MASVS

-- REVIEW --
- V3.3: "The app uses cryptographic primitives that are appropriate for the particular use-case, configured with parameters that adhere to industry best practices"

##### CWE

-- REVIEW --
* CWE-326: Inadequate Encryption Strength


##### Info

-- REVIEW --
- [1] NIST recommendations (2016) - https://www.keylength.com/en/4/
- [2] BSI recommendations (2017) - https://www.keylength.com/en/8/

##### Tools

-- TODO [Add relevant tools for "Verifying the Configuration of Cryptographic Standard Algorithms"] --
* Enjarify - https://github.com/google/enjarify


### Testing Random Number Generation

#### Overview

When software generates predictable values in a context requiring unpredictability, it may be possible for an attacker to guess the next value that will be generated, and use this guess to impersonate another user or access sensitive information.

#### Static Analysis

Identify all the instances of random number generators and look for either custom or known insecure java.util.Random class. This class produces an identical sequence of numbers for each given seed value; consequently, the sequence of numbers is predictable.
The following sample source code shows weak random number generation:

```Java
import java.util.Random;
// ...

Random number = new Random(123L);
//...
for (int i = 0; i < 20; i++) {
  // Generate another random integer in the range [0, 20]
  int n = number.nextInt(21);
  System.out.println(n);
}
```

#### Dynamic Analysis

Once an attacker is knowing what type of weak pseudo-random number generator (PRNG) is used, it can be trivial to write proof-of-concept to generate the next random value based on previously observed ones, as it was done for Java Random<sup>[1]</sup>. In case of very weak custom random generators it may be possible to observe the pattern statistically. Although the recommended approach would anyway be to decompile the APK and inspect the algorithm (see Static Analysis).

#### Remediation

Use a well-vetted algorithm that is currently considered to be strong by experts in the field, and select well-tested implementations with adequate length seeds. Prefer the no-argument constructor of SecureRandom that uses the system-specified seed value to generate a 128-byte-long random number<sup>[2]</sup>.
In general, if a PRNG is not advertised as being cryptographically secure (e.g. java.util.Random), then it is probably a statistical PRNG and should not be used in security-sensitive contexts.
Pseudo-random number generators can produce predictable numbers if the generator is known and the seed can be guessed<sup>[3]</sup>. A 128-bit seed is a good starting point for producing a "random enough" number.

The following sample source code shows the generation of a secure random number:

```Java
import java.security.SecureRandom;
import java.security.NoSuchAlgorithmException;
// ...

public static void main (String args[]) {
  SecureRandom number = new SecureRandom();
  // Generate 20 integers 0..20
  for (int i = 0; i < 20; i++) {
    System.out.println(number.nextInt(21));
  }
}
```

#### References

##### OWASP MASVS
- V3.6: "All random values are generated using a sufficiently secure random number generator"

##### OWASP Mobile Top 10 2016
* M6 - Broken Cryptography

##### CWE
* CWE-330: Use of Insufficiently Random Values

##### Info
[1] Predicting the next Math.random() in Java - http://franklinta.com/2014/08/31/predicting-the-next-math-random-in-java/
[2] Generation of Strong Random Numbers - https://www.securecoding.cert.org/confluence/display/java/MSC02-J.+Generate+strong+random+numbers
[3] Proper seeding of SecureRandom - https://www.securecoding.cert.org/confluence/display/java/MSC63-J.+Ensure+that+SecureRandom+is+properly+seeded

##### Tools
* QARK - https://github.com/linkedin/qark
