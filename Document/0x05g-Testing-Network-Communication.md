## Testing Network Communication in Android Apps

### Testing Endpoint Identify Verification

#### Overview

Using TLS for transporting sensitive information over the network is essential from security point of view. However, implementing a mechanism of encrypted communication between mobile application and backend API is not a trivial task. Developers often decides for easier, but less secure (e.g. accepting any certificate) solutions to ease a development process what often is not fixed after going on production<sup>[1]</sup>, exposing at the same time an application to man-in-the-middle attacks<sup>[2]</sup>.

#### Static Analysis

The static analysis approach is to decompile an application, if the source code was not provided. There are 2 main issues related with validating TLS connection that should be verified in the code:
* the first one is verification if a certificate comes from a trusted source and
* the second one is to check whether the endpoint server presents the right certificate<sup>[3]</sup>.

Simply look in the code for TrustManager and HostnameVerifier usage. You can find insecure usage examples in the sections below.

Such checks of improper certificate verification, may be done automatically, using a tool called MalloDroid<sup>[4]</sup>. It simply decompiles an application and warns you if it finds something suspicious. To run it, simply type this command:

```bash
$ ./mallodroid.py -f ExampleApp.apk -d ./outputDir
```

Now, you should be warned if any suspicious code was found by MalloDroid and in `./outputDir` you will find decompiled application for further manual analysis.

##### Verifying the Server Certificate

A mechanism responsible for verifying conditions to establish a trusted connection in Android is called "TrustManager". Conditions to be checked at this point, are the following:

* Is the certificate signed by a "trusted" CA?
* Is the certificate expired?
* Is the certificate self-signed?

You should look in the code if there are control checks of aforementioned conditions. For example, the following code will accept any certificate:

```java
TrustManager[] trustAllCerts = new TrustManager[] {
    new X509TrustManager() {
        @Override
        public X509Certificate[] getAcceptedIssuers() {
            return new java.security.cert.X509Certificate[] {};
        }

        @Override
        public void checkClientTrusted(X509Certificate[] chain, String authType)
            throws CertificateException {
        }

        @Override
        public void checkServerTrusted(X509Certificate[] chain, String authType)
            throws CertificateException {
        }
    }
};

// SSLContext context
context.init(null, trustAllCerts, new SecureRandom());
```

##### Hostname verification

Another security fault in TLS implementation is lack of hostname verification. A development environment usually uses some internal addresses instead of valid domain names, so developers often disable hostname verification (or force an application to allow any hostname) and simply forget to change it when their application goes to production. The following code is responsible for disabling hostname verification:

```java
final static HostnameVerifier NO_VERIFY = new HostnameVerifier() {
    public boolean verify(String hostname, SSLSession session) {
        return true;
    }
};
```

It's also possible to accept any hostname using a built-in `HostnameVerifier`:

```
HostnameVerifier NO_VERIFY = org.apache.http.conn.ssl.SSLSocketFactory
                             .ALLOW_ALL_HOSTNAME_VERIFIER;
```

Ensure that your application verifies a hostname before setting trusted connection.


#### Dynamic Analysis

A dynamic analysis approach will require usage of intercept proxy. To test improper certificate verification, you should go through following control checks:

 1) Self-signed certificate

  In Burp go to `Proxy -> Options` tab, go to `Proxy Listeners` section, highlight your listener and click `Edit`. Then go to `Certificate` tab and check `Use a self-signed certificate` and click `Ok`. Now, run your application. If you are able to see HTTPS traffic, then it means your application is accepting self-signed certificates.

 2) Accepting invalid certificate

  In Burp go to `Proxy -> Options` tab, go to `Proxy Listeners` section, highlight your listener and click `Edit`. Then go to `Certificate` tab, check `Generate a CA-signed certificate with a specific hostname` and type a hostname of a backend server. Now, run your application. If you are able to see HTTPS traffic, then it means your application is accepting any certificate.

 3) Accepting wrong hostname.

  In Burp go to `Proxy -> Options` tab, go to `Proxy Listeners` section, highlight your listener and click `Edit`. Then go to `Certificate` tab, check `Generate a CA-signed certificate with a specific hostname` and type in an invalid hostname, e.g. example.org. Now, run your application. If you are able to see HTTPS traffic, then it means your application is accepting any hostname.

> **Note**, if you are interested in further MITM analysis or you face any problems with configuration of your intercept proxy, you may consider using Tapioca<sup>[6]</sup>. It's a CERT preconfigured VM appliance<sup>[7]</sup> for performing MITM analysis of software. All you have to do is deploy a tested application on emulator and start capturing traffic<sup>[8]</sup>.

#### Remediation

Ensure, that the hostname and certificate is verified correctly. Examples and common pitfalls can be found in the official Android documentation<sup>[3]</sup>.


#### References

#### OWASP Mobile Top 10 2016
* M3 - Insecure Communication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M3-Insecure_Communication

##### OWASP MASVS
* V5.3: "The app verifies the X.509 certificate of the remote endpoint when the secure channel is established. Only certificates signed by a valid CA are accepted."

##### CWE
* CWE-296 - Improper Following of a Certificate's Chain of Trust - https://cwe.mitre.org/data/definitions/296.html
* CWE-297 - Improper Validation of Certificate with Host Mismatch - https://cwe.mitre.org/data/definitions/297.html
* CWE-298 - Improper Validation of Certificate Expiration - https://cwe.mitre.org/data/definitions/298.html

#### Info
* [1] Hunting Down Broken SSL in Android Apps -  https://www.owasp.org/images/7/77/Hunting_Down_Broken_SSL_in_Android_Apps_-_Sascha_Fahl%2BMarian_Harbach%2BMathew_Smith.pdf
* [2] CWE-295 - https://cwe.mitre.org/data/definitions/295.html
* [3] Android Official Documentation SSL - https://developer.android.com/training/articles/security-ssl.html
* [4] MalloDroid - https://github.com/sfahl/mallodroid
* [5] Configuring an Android device to work with Burp -  https://support.portswigger.net/customer/portal/articles/1841101-configuring-an-android-device-to-work-with-burp
* [6] Announcing CERT Tapioca for MITM Analysis - https://insights.sei.cmu.edu/cert/2014/08/-announcing-cert-tapioca-for-mitm-analysis.html
* [7] Downloading the CERT Tapioca Virtual Machine - http://www.cert.org/download/mitm/CERT_Tapioca.ova
* [8] Finding Android SSL vulnerabilites with CERT Tapioca - https://insights.sei.cmu.edu/cert/2014/09/-finding-android-ssl-vulnerabilities-with-cert-tapioca.html


### Testing Custom Certificate Stores and SSL Pinning

#### Overview

Certificate pinning allows to hard-code the certificate or parts of it into the app that is known to be used by the server. This technique is used to reduce the threat of a rogue CA and CA compromise. Pinning the server’s certificate takes the CA out of the game. Mobile apps that implement certificate pinning only can connect to a limited numbers of servers, as a small list of trusted CAs or server certificates are hard-coded in the application.

#### Static Analysis

The process to implement the SSL pinning involves three main steps outlined below:

1. Obtain a certificate for the desired host
1. Make sure the certificate is in .bks format
1. Pin the certificate to an instance of the default Apache Httpclient.

To analyze the correct implementation of SSL pinning the HTTP client should:

1. Load the Keystore:

```java
InputStream in = resources.openRawResource(certificateRawResource);
keyStore = KeyStore.getInstance("BKS");
keyStore.load(resourceStream, password);
```

Once the Keystore is loaded we can use the TrustManager that trusts the CAs in our KeyStore :

```java
String tmfAlgorithm = TrustManagerFactory.getDefaultAlgorithm();
TrustManagerFactory tmf = TrustManagerFactory.getInstance(tmfAlgorithm);
tmf.init(keyStore);
Create an SSLContext that uses the TrustManager
// SSLContext context = SSLContext.getInstance("TLS");
sslContext.init(null, tmf.getTrustManagers(), null);
```

The specific implementation in the app might be different, as it might be pinning against only the public key of the certificate, the whole certificate or a whole certificate chain. 

Applications that use third-party networking libraries may utilize the certificate pinning functionality in those libraries. For example, okhttp<sup>[3]</sup> can be set up with the `CertificatePinner` as follows:

```java
OkHttpClient client = new OkHttpClient.Builder()
        .certificatePinner(new CertificatePinner.Builder()
            .add("bignerdranch.com", "sha256/UwQAapahrjCOjYI3oLUx5AQxPBR02Jz6/E2pt0IeLXA=")
            .build())
        .build();
```

#### Dynamic Analysis

Dynamic analysis can be performed by launching a MITM attack using your preferred interception proxy<sup>[1]</sup>. This will allow to monitor the traffic exchanged between client (mobile application) and the backend server. If the Proxy is unable to intercept the HTTP requests and responses, the SSL pinning is correctly implemented.

#### Remediation

The SSL pinning process should be implemented as described on the static analysis section. For further information please check the OWASP certificate pinning guide [2].

#### References

##### OWASP Mobile Top 10 2016
* M3 - Insecure Communication - https://www.owasp.org/index.php/Mobile_Top_10_2016-M3-Insecure_Communication

##### OWASP MASVS
* V5.4 "The app either uses its own certificate store, or pins the endpoint certificate or public key, and subsequently does not establish connections with endpoints that offer a different certificate or key, even if signed by a trusted CA."

##### CWE
* CWE-295 - Improper Certificate Validation

##### Info

* [1] Setting Burp Suite as a proxy for Android Devices -  https://support.portswigger.net/customer/portal/articles/1841101-configuring-an-android-device-to-work-with-burp)
* [2] OWASP Certificate Pinning for Android - https://www.owasp.org/index.php/Certificate_and_Public_Key_Pinning#Android
* [3] okhttp library - https://github.com/square/okhttp/wiki/HTTPS
