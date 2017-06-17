## Testing Platform Interaction on Android

### Testing App Permissions

#### Overview

Android assigns every installed app with a distinct system identity (Linux user ID and group ID). Because each Android app operates in a process sandbox, apps must explicitly request access to resources and data outside their sandbox. They request this access by declaring the permissions they need to use certain system data and features. Depending on how sensitive or critical the data or feature is, Android system will grant the permission automatically or ask the user to approve the request.

Android permissions are classified in four different categories based on the protection level it offers.

* **Normal**: This permission gives apps access to isolated application-level features, with minimal risk to other apps, the user or the system. It is granted during the installation of the App. If no protection level is specified, normal is the default value. Example: `android.permission.INTERNET`
* **Dangerous**: This permission usually gives the app control over user data or control over the device that impacts the user. This type of permission may not be granted at installation time, leaving it to the user to decide whether the app should have the permission or not. Example: `android.permission.RECORD_AUDIO`
* **Signature**: This permission is granted only if the requesting app was signed with the same certificate as the app that declared the permission. If the signature matches, the permission is automatically granted. Example: `android.permission.ACCESS_MOCK_LOCATION`
* **SystemOrSignature**: Permission only granted to applications embedded in the system image or that were signed using the same certificate as the application that declared the permission. Example: `android.permission.ACCESS_DOWNLOAD_MANAGER`

A full list of all Android Permissions can be found in the developer documentation<sup>[1]</sup>.

**Custom Permissions**

Android allow apps to expose their services/components to other apps and custom permissions are required to restrict which app can access the exposed component. Custom permission can be defined in `AndroidManifest.xml`, by creating a permission tag with two mandatory attributes:
* `android:name` and
* `android:protectionLevel`.

It is crucial to create custom permission that adhere to the _Principle of Least Privilege_: permission should be defined explicitly for its purpose with meaningful and accurate label and description.

Below is an example of a custom permission called `START_MAIN_ACTIVITY` that is required when launching the `TEST_ACTIVITY` Activity.

The first code block defines the new permission which is self-explanatory. The label tag is a summary of the permission and description is a more detailed description of the summary. The protection level can be set based on the types of permission it is granting.
Once you have defined your permission, it can be enforced on the component by specifying it in the application’s manifest. In our example, the second block is the component that we are going to restrict with the permission we created. It can be enforced by adding the `android:permission` attributes.

```xml
<permission android:name="com.example.myapp.permission.START_MAIN_ACTIVITY"
        android:label="Start Activity in myapp"
        android:description="Allow the app to launch the activity of myapp app, any app you grant this permission will be able to launch main activity by myapp app."
        android:protectionLevel="normal" />

<activity android:name="TEST_ACTIVITY"
    android:permission="com.example.myapp.permission.START_MAIN_ACTIVITY">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER"/>
     </intent-filter>
</activity>
```

Now that the new permission `START_MAIN_ACTIVTY` is created, apps can request it using the `uses-permission` tag in the `AndroidManifest.xml` file. Any application can now launch the `TEST_ACTIVITY` if it is granted with the custom permission `START_MAIN_ACTIVITY`.

```xml
<uses-permission android:name=“com.example.myapp.permission.START_MAIN_ACTIVITY”/>
```

#### Static Analysis

**Android Permissions**

Permissions should be checked if they are really needed within the App. For example in order for an Activity to load a web page into a WebView the `INTERNET` permission in the Android Manifest file is needed.

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

It is always recommended to run through the permissions with the developer together to identify the intention of every permission set and remove those that are not needed.

Alternatively, Android Asset Packaging tool can be used to examine permissions.

```bash
$ aapt d permissions com.owasp.mstg.myapp
uses-permission: android.permission.WRITE_CONTACTS
uses-permission: android.permission.CHANGE_CONFIGURATION
uses-permission: android.permission.SYSTEM_ALERT_WINDOW
uses-permission: android.permission.INTERNAL_SYSTEM_WINDOW
```

**Custom Permissions**

Apart from enforcing custom permissions via application manifest file, it can also be enforced programmatically. This is not recommended as this can lead to permission leaking and perform an unauthorized operation. This can be verified by inspecting whether if all defined custom permissions were enforced in the android manifest file.

```java
int canProcess = checkCallingOrSelfPermission(“com.example.perm.READ_INCOMING_MSG”);
if (canProcess != PERMISSION_GRANTED)
throw new SecurityException();
```

#### Dynamic Analysis

Permissions of applications installed on a device can be retrieved using the Android security assessment framework Drozer. The following extract demonstrates how to examine the permissions used by an application, in addition to the the custom permissions defined by the app:

```bash
dz> run app.package.info  -a com.android.mms.service
Package: com.android.mms.service
  Application Label: MmsService
  Process Name: com.android.phone
  Version: 6.0.1
  Data Directory: /data/user/0/com.android.mms.service
  APK Path: /system/priv-app/MmsService/MmsService.apk
  UID: 1001
  GID: [2001, 3002, 3003, 3001]
  Shared Libraries: null
  Shared User ID: android.uid.phone
  Uses Permissions:
  - android.permission.RECEIVE_BOOT_COMPLETED
  - android.permission.READ_SMS
  - android.permission.WRITE_SMS
  - android.permission.BROADCAST_WAP_PUSH
  - android.permission.BIND_CARRIER_SERVICES
  - android.permission.BIND_CARRIER_MESSAGING_SERVICE
  - android.permission.INTERACT_ACROSS_USERS
  Defines Permissions:
  - None
```

When Android applications expose IPC components to other applications, they can define permissions to limit access to the component to certain applications. To communicate with a component protected by a `normal` or `dangerous` permission, Drozer can be rebuilt to contain the required permission:

```
$ drozer agent build  --permission android.permission.REQUIRED_PERMISSION
```

Note that this method cannot be used for `signature` level permissions, as Drozer would need to be signed by the same certificate as the target application.

#### Remediation

Only permissions that are needed within the app should be requested in the Android Manifest file and all other permissions should be removed.

Developers should take care to secure sensitive IPC components with the `signature` protection level, which will only allow applications signed with the same certificate to access the component.

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage - https://www.owasp.org/index.php/Mobile_Top_10_2016-M1-Improper_Platform_Usage

##### OWASP MASVS
* V6.1: "The app only requires the minimum set of permissions necessary."

##### CWE
* CWE-250 - Execution with Unnecessary Privileges

##### Info
* [1] Android Permissions - https://developer.android.com/guide/topics/permissions/requesting.html
* [2] Custom Permissions - https://developer.android.com/guide/topics/permissions/defining.html
* [3] An In-Depth Introduction to the Android Permission Model - https://www.owasp.org/images/c/ca/ASDC12-An_InDepth_Introduction_to_the_Android_Permissions_Modeland_How_to_Secure_MultiComponent_Applications.pdf
* [4] Android Permissions - https://developer.android.com/reference/android/Manifest.permission.html#ACCESS_LOCATION_EXTRA_COMMANDS

##### Tools
* AAPT - http://elinux.org/Android_aapt
* Drozer - https://github.com/mwrlabs/drozer


### Testing Input Validation and Sanitization

#### Overview

Android apps can expose functionality to:
* other apps via IPC mechanisms like Intents, Binders, Android Shared Memory (ASHMEM) or BroadcastReceivers,
* through custom URL schemes (which are part of Intents) and
* the user via the user interface.

All input that is coming from these different sources cannot be trusted and need to be validated and/or sanitized. Validation ensures that only data is processed that the app is expecting. If validation is not enforced any input can be sent to the app, which might allow an attacker or malicious app to exploit vulnerable functionalities within the app.

#### Static Analysis

The source code should be checked if any functionality of the app is exposed, through:
* Custom URL schemes: check also the test case "Testing Custom URL Schemes"
* IPC Mechanisms (Intents, Binders, Android Shared Memory (ASHMEM) or BroadcastReceivers): check also the test case "Testing Whether Sensitive Data Is Exposed via IPC Mechanisms"
* User interface

An example for a vulnerable IPC mechanisms is listed below.

_ContentProviders_ can be used to access database information, while services can be probed to see if they return data. If data is not validated properly the content provider might be prone to SQL injection when others apps are interacting with it. See the following vulnerable implementation of a _ContentProvider_:

```xml
<provider
    android:name=".OMTG_CODING_003_SQL_Injection_Content_Provider_Implementation"
    android:authorities="sg.vp.owasp_mobile.provider.College">
</provider>
```

The `AndroidManifest.xml` above defines a content provider that is exported and therefore available for all other apps. . In the `OMTG_CODING_003_SQL_Injection_Content_Provider_Implementation.java` class the `query` function need to be inspected to detect if any sensitive information is leaked:

```java
@Override
public Cursor query(Uri uri, String[] projection, String selection,String[] selectionArgs, String sortOrder) {
    SQLiteQueryBuilder qb = new SQLiteQueryBuilder();
    qb.setTables(STUDENTS_TABLE_NAME);

    switch (uriMatcher.match(uri)) {
        case STUDENTS:
            qb.setProjectionMap(STUDENTS_PROJECTION_MAP);
            break;

        case STUDENT_ID:
            // SQL Injection when providing an ID
            qb.appendWhere( _ID + "=" + uri.getPathSegments().get(1));
            Log.e("appendWhere",uri.getPathSegments().get(1).toString());
            break;

        default:
            throw new IllegalArgumentException("Unknown URI " + uri);
    }

    if (sortOrder == null || sortOrder == ""){
        /**
         * By default sort on student names
         */
        sortOrder = NAME;
    }
    Cursor c = qb.query(db,	projection,	selection, selectionArgs,null, null, sortOrder);

    /**
     * register to watch a content URI for changes
     */
    c.setNotificationUri(getContext().getContentResolver(), uri);
    return c;
}
```

The query statement would return all credentials when accessing `content://sg.vp.owasp_mobile.provider.College/students`. Prepared statements<sup>[4]</sup> need to be used to avoid the SQL injection, but ideally also input validation should be applied<sup>[3]</sup>.

#### Dynamic Analysis

The tester should test manually the input fields with strings like "' OR 1=1--'" if for example a local SQL injection vulnerability can be identified.

When being on a rooted device the command content can be used to query the data from a Content Provider. The following command is querying the vulnerable function described above.

```
content query --uri content://sg.vp.owasp_mobile.provider.College/students
```

The SQL injection can be exploited by using the following command. Instead of getting the record for Bob all data can be retrieved.

```
content query --uri content://sg.vp.owasp_mobile.provider.College/students --where "name='Bob') OR 1=1--''"
```

Even if the risk is only locally on the device itself, it is possible for malicious Apps to exploit this functionality through SQL injection. Also tools like Drozer can be used to automate such attacks to check for SQL Injection or Path Traversal, as described in section 3.5.4 of the Drozer User Guide<sup>[5]</sup>.

#### Remediation

All functions in the app that process data that is coming from external and through the UI should be validated.
* For input coming from the user interface Android Saripaar v2<sup>[1]</sup> can be used.
* For input coming from IPC or URL schemes a validation function should be created. For example like the following that is checking if the value is alphanumeric<sup>[2]</sup>.

```java
public boolean isAlphaNumeric(String s){
    String pattern= "^[a-zA-Z0-9]*$";
    return s.matches(pattern);
}
```

Alternatively to validation functions type conversion by using `Integer.parseInt()` should be considered for numbers. The OWASP Input Validation Cheat Sheet contains more information about this topic<sup>[3]</sup>

#### References

##### OWASP Mobile Top 10 2016
* M7 - Poor Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
* V6.2: "All inputs from external sources and the user are validated and if necessary sanitized. This includes data received via the UI, IPC mechanisms such as intents, custom URLs, and network sources."

##### CWE
* CWE-20 - Improper Input Validation

##### Info
* [1] Android Saripaar v2 - https://github.com/ragunathjawahar/android-saripaar
* [2] Input Validation - https://stackoverflow.com/questions/11241690/regex-for-checking-if-a-string-is-strictly-alphanumeric
* [3] OWASP Input Validation Cheat Sheet - https://www.owasp.org/index.php/Input_Validation_Cheat_Sheet
* [4] OWASP SQL Injection Cheat Sheet - https://www.owasp.org/index.php/SQL_Injection_Prevention_Cheat_Sheet
* [5] Drozer User Guide - https://labs.mwrinfosecurity.com/assets/BlogFiles/mwri-drozer-user-guide-2015-03-23.pdf

##### Tools
* Drozer


### Testing Custom URL Schemes

#### Overview

Both Android and iOS allow inter-app communication through the use of custom URL schemes. These custom URLs allow other applications to perform specific actions within the application hosting the custom URL scheme. Much like a standard web URL that might start with `https://`, custom URIs can begin with any scheme prefix and usually define an action to take within the application and parameters for that action.

As a contrived example, consider: `sms://compose/to=your.boss@company.com&message=I%20QUIT!&sendImmediately=true`. When a victim clicks such a link on a web page in their mobile browser, the vulnerable SMS application will send the SMS message with the maliciously crafted content. This could lead to:
* financial loss for the victims if messages are sent to premium services,
* disclosing the phone number if messages are sent to predefined addresses that collect phone numbers or
* rigging votes for talent shows.

Once a URL scheme is defined, multiple apps can register for any available scheme. For any application, each of these custom URL schemes needs to be enumerated, and the actions they perform need to be tested.

#### Static Analysis

Investigate if custom URL schemes are defined. This can be done in the AndroidManifest file inside of an intent-filter element<sup>[1]</sup>.

```xml
<activity android:name=".MyUriActivity">
  <intent-filter>
      <action android:name="android.intent.action.VIEW" />
      <category android:name="android.intent.category.DEFAULT" />
      <category android:name="android.intent.category.BROWSABLE" />
      <data android:scheme="myapp" android:host="path" />
  </intent-filter>
</activity>

```
The example above is specifying a new URL scheme called `myapp://`. The category `browsable` will allow to open the URI within a browser.

Data can then be transmitted trough this new scheme, by using for example the following URI:  `myapp://path/to/what/i/want?keyOne=valueOne&keyTwo=valueTwo`. Code like the following can be used to retrieve the data:

```
Intent intent = getIntent();
if (Intent.ACTION_VIEW.equals(intent.getAction())) {
  Uri uri = intent.getData();
  String valueOne = uri.getQueryParameter("keyOne");
  String valueTwo = uri.getQueryParameter("keyTwo");
}
```


#### Dynamic Analysis

To enumerate URL schemes within an application that can be called by a web browser, the Drozer module `scanner.activity.browsable` should be used:

```
dz> run scanner.activity.browsable -a com.google.android.apps.messaging
Package: com.google.android.apps.messaging
  Invocable URIs:
    sms://
    mms://
  Classes:
    com.google.android.apps.messaging.ui.conversation.LaunchConversationActivity
```

Custom URL schemes can be called using the Drozer module `app.activity.start`:

```
dz> run app.activity.start  --action android.intent.action.VIEW --data-uri "sms://0123456789"
```

When calling a defined schema (myapp://someaction/?var0=str&var1=string), it might be used to send data to the app as in the example below.

```Java
Intent intent = getIntent();
if (Intent.ACTION_VIEW.equals(intent.getAction())) {
  Uri uri = intent.getData();
  String valueOne = uri.getQueryParameter("var0");
  String valueTwo = uri.getQueryParameter("var1");
}
```

Defining your own URL scheme and using it can become a risk in this case, if data is sent to it from an external party and processed in the app.

#### Remediation

URL schemes can be used for deeplinking, which is a widespread and convenient methodology for launching a native mobile app via a link<sup>[3]</sup> and doesn't represent a risk by itself.

Nevertheless data coming in through URL schemes which is processed by the app should be validated, as described in the test case "Testing Input Validation and Sanitization".

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage - https://www.owasp.org/index.php/Mobile_Top_10_2016-M1-Improper_Platform_Usage

##### OWASP MASVS
* V6.3: "The app does not export sensitive functionality via custom URL schemes, unless these mechanisms are properly protected."

##### CWE
N/A

##### Info
- [1] Custom URL scheme - https://developer.android.com/guide/components/intents-filters.html#DataTest
- [2] Intent.toUI() - https://developer.android.com/reference/android/content/Intent.html#toUri%28int%29
- [3] Mobile Deeplinking - http://mobiledeeplinking.org

##### Tools
* Drozer - https://github.com/mwrlabs/drozer



### Testing For Sensitive Functionality Exposure Through IPC

#### Overview

During development of a mobile application, traditional techniques for IPC might be applied like usage of shared files or network sockets. As mobile application platforms implement their own system functionality for IPC, these mechanisms should be applied as they are much more mature than traditional techniques. Using IPC mechanisms with no security in mind may cause the application to leak or expose sensitive data.

The following is a list of Android IPC Mechanisms that may expose sensitive data:
* Binders<sup>[1]</sup>
* Services<sup>[2]</sup>
  * Bound Services<sup>[9]</sup>
  * AIDL<sup>[10]</sup>
* Intents<sup>[3]</sup>
* Content Providers<sup>[4]</sup>

#### Static Analysis

We start by looking at the AndroidManifest, where all activities, services and content providers included in the source code must be declared (otherwise the system will not recognize them and they will not run). However, broadcast receivers can be either declared in the manifest or created dynamically. You will want to identify elements such as:

* `<intent-filter>`<sup>[5]</sup>
* `<service>`<sup>[6]</sup>
* `<provider>`<sup>[7]</sup>
* `<receiver>`<sup>[8]</sup>

Making an activity, service or content provided as "exported" means that it can be accessed by other apps. There are two common ways to set a component as exported. The obvious one is to set the export tag to true `android:exported="true"`.
The second way is to define an `<intent-filter>` within the component element (`<activity>`, `<service>`, `<receiver>`). When doing this, the export tag is automatically set to "true".

Apart from that, remember that using the permission tag (`android:permission`) will also limit the exposure of a component to other applications.

For more information about the content providers, please refer to the test case "Testing Whether Stored Sensitive Data Is Exposed via IPC Mechanisms" in chapter "Testing Data Storage".

Once you identify a list of IPC mechanisms, review the source code in order to detect if they leak any sensitive data when used. For example, content providers can be used to access database information, while services can be probed to see if they return data. Also broadcast receivers can leak sensitive information if probed or sniffed.

In the following we will use two example apps and give examples on how to identify vulnerable IPC components:
- "Sieve" <sup>[12]</sup>
- "Android Insecure Bank" <sup>[13]</sup>

##### Activities

##### Inspect the AndroidManifest
In the "Sieve" app we can find three exported activities idendified by `<activity>`:
```xml
<activity android:excludeFromRecents="true" android:label="@string/app_name" android:launchMode="singleTask" android:name=".MainLoginActivity" android:windowSoftInputMode="adjustResize|stateVisible">
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
</activity>
<activity android:clearTaskOnLaunch="true" android:excludeFromRecents="true" android:exported="true" android:finishOnTaskLaunch="true" android:label="@string/title_activity_file_select" android:name=".FileSelectActivity"/>
<activity android:clearTaskOnLaunch="true" android:excludeFromRecents="true" android:exported="true" android:finishOnTaskLaunch="true" android:label="@string/title_activity_pwlist" android:name=".PWList"/>

```

##### Inspect the source code
By inspecting the `PWList.java` activity we see that it offers options to list all keys, add, delete, etc. If we invoke it directly we will be able to bypass the LoginActivity. More on this can be found below in the dynamic analysis.

##### Services

##### Inspect the AndroidManifest
In the "Sieve" app we can find two exported services identified by `<service>`:
```xml
<service android:exported="true" android:name=".AuthService" android:process=":remote"/>
<service android:exported="true" android:name=".CryptoService" android:process=":remote"/>
```

##### Inspect the source code
Check the source code for the class `android.app.Service`:

By reversing the target application, we can see the service `AuthService` provides functionality to change the password and PIN protecting the target app.

```
   public void handleMessage(Message msg) {
            AuthService.this.responseHandler = msg.replyTo;
            Bundle returnBundle = msg.obj;
            int responseCode;
            int returnVal;
            switch (msg.what) {
                ...
                case AuthService.MSG_SET /*6345*/:
                    if (msg.arg1 == AuthService.TYPE_KEY) /*7452*/ {
                        responseCode = 42;
                        if (AuthService.this.setKey(returnBundle.getString("com.mwr.example.sieve.PASSWORD"))) {
                            returnVal = 0;
                        } else {
                            returnVal = 1;
                        }
                    } else if (msg.arg1 == AuthService.TYPE_PIN) {
                        responseCode = 41;
                        if (AuthService.this.setPin(returnBundle.getString("com.mwr.example.sieve.PIN"))) {
                            returnVal = 0;
                        } else {
                            returnVal = 1;
                        }
                    } else {
                        sendUnrecognisedMessage();
                        return;
                    }
```

##### Broadcast Receivers

##### Inspect the AndroidManifest
In "Android Insecure Bank" app we can find a broadcast receiver in the manifest identified by `<receiver>`:
```xml
<receiver android:exported="true" android:name="com.android.insecurebankv2.MyBroadCastReceiver">
    <intent-filter>
        <action android:name="theBroadcast"/>
    </intent-filter>
</receiver>
```

##### Inspect the source code
Search in the source code for strings like `sendBroadcast`, `sendOrderedBroadcast`, `sendStickyBroadcast` and verify that the application doesn't send any sensitive data.

In order to know more about what the receiver is intended to do we have to go deeper in our static analysis and search for usages of the class `android.content.BroadcastReceiver` and the `Context.registerReceiver()` method used to dynamically create receivers.

In the extract below taken from the source code of the target application, we can see that the broadcast receiver triggers a SMS message to be sent containing the decrypted password of the user.

```
public class MyBroadCastReceiver extends BroadcastReceiver {
  String usernameBase64ByteString;
  public static final String MYPREFS = "mySharedPreferences";

  @Override
  public void onReceive(Context context, Intent intent) {
    // TODO Auto-generated method stub

        String phn = intent.getStringExtra("phonenumber");
        String newpass = intent.getStringExtra("newpass");

    if (phn != null) {
      try {
                SharedPreferences settings = context.getSharedPreferences(MYPREFS, Context.MODE_WORLD_READABLE);
                final String username = settings.getString("EncryptedUsername", null);
                byte[] usernameBase64Byte = Base64.decode(username, Base64.DEFAULT);
                usernameBase64ByteString = new String(usernameBase64Byte, "UTF-8");
                final String password = settings.getString("superSecurePassword", null);
                CryptoClass crypt = new CryptoClass();
                String decryptedPassword = crypt.aesDeccryptedString(password);
                String textPhoneno = phn.toString();
                String textMessage = "Updated Password from: "+decryptedPassword+" to: "+newpass;
                SmsManager smsManager = SmsManager.getDefault();
                System.out.println("For the changepassword - phonenumber: "+textPhoneno+" password is: "+textMessage);
smsManager.sendTextMessage(textPhoneno, null, textMessage, null, null);
```

#### Dynamic Analysis

IPC components can be enumerated using Drozer. To list all exported IPC components, the module `app.package.attacksurface` should be used:

```
dz> run app.package.attacksurface com.mwr.example.sieve
Attack Surface:
  3 activities exported
  0 broadcast receivers exported
  2 content providers exported
  2 services exported
    is debuggable
```

##### Activities

To list activities exported by an application the module `app.activity.info` should be used. Specify the target package with `-a` or leave blank to target all apps on the device:

```
dz> run app.activity.info -a com.mwr.example.sieve
Package: com.mwr.example.sieve
  com.mwr.example.sieve.FileSelectActivity
    Permission: null
  com.mwr.example.sieve.MainLoginActivity
    Permission: null
  com.mwr.example.sieve.PWList
    Permission: null  
```

By enumerating activities in the vulnerable password manager "Sieve"<sup>[1]</sup>, the activity `com.mwr.example.sieve.PWList` is found to be exported with no required permissions. It is possible to use the module `app.activity.start` to launch this activity.

```
dz> run app.activity.start --component com.mwr.example.sieve com.mwr.example.sieve.PWList
```

Since the activity was called directly, the login form protecting the password manager was bypassed, and the data contained within the password manager could be accessed.

##### Services

Services can be enumerated using the Drozer module `app.service.info`:

```
dz> run app.service.info -a com.mwr.example.sieve
Package: com.mwr.example.sieve
  com.mwr.example.sieve.AuthService
    Permission: null
  com.mwr.example.sieve.CryptoService
    Permission: null
```

To communicate with a service, static analysis must first be used to identify the required inputs.

Since this service is exported, it is possible to use the module `app.service.send` to communicate with the service and change the password stored in the target application:

```
dz> run app.service.send com.mwr.example.sieve com.mwr.example.sieve.AuthService --msg  6345 7452 1 --extra string com.mwr.example.sieve.PASSWORD "abcdabcdabcdabcd" --bundle-as-obj
Got a reply from com.mwr.example.sieve/com.mwr.example.sieve.AuthService:
  what: 4
  arg1: 42
  arg2: 0
  Empty
```

##### Broadcast Receivers

Broadcasts can be enumerated using the Drozer module `app.broadcast.info`, the target package should be specified using the `-a` parameter:

```
dz> run app.broadcast.info -a com.android.insecurebankv2
Package: com.android.insecurebankv2
  com.android.insecurebankv2.MyBroadCastReceiver
    Permission: null
```

In the example app "Android Insecure Bank", we can see that one broadcast receiver is exported, not requiring any permissions, indicating that we can formulate an intent to trigger the broadcast receiver. When testing broadcast receivers, static analysis must also be used to understand the functionality of the broadcast receiver as we did before.

Using the Drozer module `app.broadcast.send`, it is possible to formulate an intent to trigger the broadcast and send the password to a phone number within our control:

```
dz>  run app.broadcast.send --action theBroadcast --extra string phonenumber 07123456789 --extra string newpass 12345
```

This generates the following SMS:

```
Updated Password from: SecretPassword@ to: 12345
```

###### Sniffing Intents

If an Android application broadcasts intents without setting a required permission or specifying the destination package, the intents are susceptible to monitoring by any application on the device.

To register a broadcast receiver to sniff intents, the Drozer module `app.broadcast.sniff` should be used, specifying the action to monitor with the `--action` parameter:

```
dz> run app.broadcast.sniff  --action theBroadcast
[*] Broadcast receiver registered to sniff matching intents
[*] Output is updated once a second. Press Control+C to exit.

Action: theBroadcast
Raw: Intent { act=theBroadcast flg=0x10 (has extras) }
Extra: phonenumber=07123456789 (java.lang.String)
Extra: newpass=12345 (java.lang.String)
```

#### Remediation

If not strictly required, be sure that your IPC component element does not have the `android:exported="true"` value in the `AndroidManifest.xml` file nor an `<intent-filter>`, to prevent all other apps on Android from being able to interact with it.

If an Intent is only broadcast/received in the same application, `LocalBroadcastManager` can be used so that, by design, other apps cannot receive the broadcast message. This reduces the risk of leaking sensitive information. `LocalBroadcastManager.sendBroadcast().
BroadcastReceivers` should make use of the `android:permission` attribute, as otherwise any other application can invoke them. `Context.sendBroadcast(intent, receiverPermission);` can be used to specify permissions a receiver needs to be able to read the broadcast<sup>[11]</sup>.
You can also set an explicit application package name that limits the components this Intent will resolve to. If left to the default value of null, all components in all applications will considered. If non-null, the Intent can only match the components in the given application package.

If your IPC is intended to be accessible to other applications, you can apply a security policy by using the `<permission>` element and set a proper `android:protectionLevel`. When using `android:permission` in a service declaration, other applications will need to declare a corresponding `<uses-permission>` element in their own manifest to be able to start, stop, or bind to the service.

#### References

##### OWASP Mobile Top 10 2016
* M1 - Improper Platform Usage - https://www.owasp.org/index.php/Mobile_Top_10_2016-M1-Improper_Platform_Usage

##### OWASP MASVS
- V6.4: "The app does not export sensitive functionality through IPC facilities, unless these mechanisms are properly protected."

##### CWE
-- TODO [Add links and titles for CWE related to the "Testing For Sensitive Functionality Exposure Through IPC" topic] --

##### Info
- [1] IPCBinder - https://developer.android.com/reference/android/os/Binder.html
- [2] IPCServices - https://developer.android.com/guide/components/services.html
- [3] IPCIntent - https://developer.android.com/reference/android/content/Intent.html
- [4] IPCContentProviders - https://developer.android.com/reference/android/content/ContentProvider.html
- [5] IntentFilterElement - https://developer.android.com/guide/topics/manifest/intent-filter-element.html
- [6] ServiceElement - https://developer.android.com/guide/topics/manifest/service-element.html
- [7] ProviderElement - https://developer.android.com/guide/topics/manifest/provider-element.html
- [8] ReceiverElement - https://developer.android.com/guide/topics/manifest/receiver-element.html
- [9] BoundServices - https://developer.android.com/guide/components/bound-services.html
- [10] AIDL - https://developer.android.com/guide/components/aidl.html
- [11] SendBroadcast - https://developer.android.com/reference/android/content/Context.html#sendBroadcast(android.content.Intent)
- [12] Sieve: Vulnerable Password Manager - https://github.com/mwrlabs/drozer/releases/download/2.3.4/sieve.apk
- [13] Android Insecure Bank V2 - https://github.com/dineshshetty/Android-InsecureBankv2

##### Tools
* Drozer - https://github.com/mwrlabs/drozer


### Testing JavaScript Execution in WebViews

#### Overview

In Web applications, JavaScript can be injected in many ways by leveraging reflected, stored or DOM based Cross-Site Scripting (XSS). Mobile Apps are executed in a sandboxed environment and when implemented natively do not possess this attack vector. Nevertheless, WebViews can be part of a native App to allow viewing of web pages. Every App has it's own cache for WebViews and doesn't share it with the native Browser or other Apps. WebViews in Android are using the WebKit rendering engine to display web pages but are stripped down to a minimum of functions, as for example no address bar is available. If the WebView is implemented too lax and allows the usage of JavaScript it can be used to to attack the App and gain access to it's data.

#### Static Analysis

The source code need to be checked for usage and implementations of the WebView class. To create and use a WebView, an instance of the class WebView need to be created.

```Java
WebView webview = new WebView(this);
setContentView(webview);
webview.loadUrl("http://slashdot.org/");
```

Different settings can be applied to the WebView of which one is able to activate and deactivate JavaScript. By default JavaScript is disabled in a WebView, so it need to be explicitly enabled. Look for the method `setJavaScriptEnabled` to check if JavaScript is activated.

```Java
webview.getSettings().setJavaScriptEnabled(true);
```

This allows the WebView to interpret JavaScript and execute it's command.

#### Dynamic Analysis

A Dynamic Analysis depends on different surrounding conditions, as there are different possibilities to inject JavaScript into a WebView of an App:
* Stored Cross-Site Scripting (XSS) vulnerability in an endpoint, where the exploit will be sent to the WebView of the Mobile App when navigating to the vulnerable function.
* Man-in-the-middle (MITM) position by an attacker where he is able to tamper the response by injecting JavaScript.
* Malware tampering local files that are loaded by the WebView.

In order to address these attack vectors, the outcome of the following checks should be verified:
* All functions offered by the endpoint need to be free of stored XSS<sup>[4]</sup>.
* The HTTPS communication need to be implemented according to best practices to avoid MITM attacks. This means:
  * whole communication is encrypted via TLS (see test case "Testing for Unencrypted Sensitive Data on the Network"),
  * the certificate is checked properly (see test case "Testing Endpoint Identify Verification") and/or
  * the certificate is even pinned (see "Testing Custom Certificate Stores and SSL Pinning")
* Only files within the App data directory should be rendered in a WebView (see test case "Testing for Local File Inclusion in WebViews").

#### Remediation

JavaScript is disabled by default in a WebView and if not needed shouldn't be enabled. This reduces the attack surface and potential threats to the App. If JavaScript is needed it should be ensured:
* that the communication relies consistently on HTTPS to protect the HTML and JavaScript from tampering while in transit.
* that JavaScript and HTML is only loaded locally from within the App data directory or from trusted web servers.

The cache of the WebView should also be cleared in order to remove all JavaScript and locally stored data, by using `clearCache()`<sup>[2]</sup> when closing the App.

Devices running platforms older than Android 4.4 (API level 19) use a version of Webkit that has a number of security issues. As a workaround, if your app is running on these devices, it must confirm that WebView objects display only trusted content<sup>[3]</sup>.

#### References

##### OWASP Mobile Top 10 2016
* M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V6.5: "JavaScript is disabled in WebViews unless explicitly required."

##### CWE
- CWE-79 - Improper Neutralization of Input During Web Page Generation https://cwe.mitre.org/data/definitions/79.html

##### Info
- [1] setJavaScriptEnabled in WebViews  - https://developer.android.com/reference/android/webkit/WebSettings.html#setJavaScriptEnabled(boolean)
- [2] clearCache() in WebViews - https://developer.android.com/reference/android/webkit/WebView.html#clearCache(boolean)
- [3] WebView Best Practices - https://developer.android.com/training/articles/security-tips.html#WebView
- [4] Stored Cross-Site Scripting - https://www.owasp.org/index.php/Testing_for_Stored_Cross_site_scripting_(OTG-INPVAL-002)


### Testing WebView Protocol Handlers

#### Overview

Several schemas are available by default in an URI on Android and can be triggered within a WebView<sup>[3]</sup>, e.g:

* http(s):
* file:
* tel:

When using them in a link the App can be triggered for example to access a local file when using `file:///storage/emulated/0/private.xml`. This can be exploited by an attacker if he is able to inject JavaScript into the WebView to access local resources via the file schema.

#### Static Analysis

The following methods are available for WebViews to control access to different resources<sup>[4]</sup>:

* `setAllowContentAccess()`: Content URL access allows WebView to load content from a content provider installed in the system. The default is enabled.
* `setAllowFileAccess()`: Enables or disables file access within WebView. File access is enabled by default.
* `setAllowFileAccessFromFileURLs()`: Sets whether JavaScript running in the context of a file scheme URL should be allowed to access content from other file scheme URLs. The default value is true for API level _ICE_CREAM_SANDWICH_MR1_ and below, and false for API level _JELLY_BEAN_ and above.
* `setAllowUniversalAccessFromFileURLs()`: Sets whether JavaScript running in the context of a file scheme URL should be allowed to access content from any origin. The default value is true for API level ICE_CREAM_SANDWICH_MR1 and below, and false for API level JELLY_BEAN and above.

If one or all of the methods above can be identified and they are activated it should be verified if it is really needed for the App to work properly.

#### Dynamic Analysis

While using the app look for ways to trigger phone calls or accessing files from the file system to identify usage of protocol handlers.

#### Remediation

Set the following best practices in order to deactivate protocol handlers, if applicable<sup>[2]</sup>:

```java
//Should an attacker somehow find themselves in a position to inject script into a WebView, then they could exploit the opportunity to access local resources. This can be somewhat prevented by disabling local file system access. It is enabled by default. The Android WebSettings class can be used to disable local file system access via the public method setAllowFileAccess.
webView.getSettings().setAllowFileAccess(false);

webView.getSettings().setAllowFileAccessFromFileURLs(false);

webView.getSettings().setAllowUniversalAccessFromFileURLs(false);

webView.getSettings().setAllowContentAccess(false);
```

Access to files in the file system can be enabled and disabled for a WebView with `setAllowFileAccess()`. File access is enabled by default and should be deactivated if not needed. Note that this enables or disables file system access only. Assets and resources are still accessible using `file:///android_asset` and `file:///android_res`<sup>[1]</sup>.

#### References

##### OWASP Mobile Top 10 2016
* M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V6.6: "WebViews are configured to allow only the minimum set of protocol handlers required (ideally, only https is supported). Potentially dangerous handlers, such as file, tel and app-id, are disabled."

##### CWE
N/A

##### Info
- [1] File Access in WebView - https://developer.android.com/reference/android/webkit/WebSettings.html#setAllowFileAccess%28boolean%29
- [2] WebView best practices - https://github.com/nowsecure/secure-mobile-development/blob/master/en/android/webview-best-practices.md#remediation
- [3] Intent List - https://developer.android.com/guide/appendix/g-app-intents.html
- [4] WebView Settings - https://developer.android.com/reference/android/webkit/WebSettings.html



### Testing for Local File Inclusion in WebViews

#### Overview

WebViews can load content remotely, but can also load it locally from the app data directory or external storage. If the content is loaded locally it should not be possible by the user to influence the filename or path where the file is loaded from or should be able to edit the loaded file.

#### Static Analysis

Check the source code for the usage of WebViews. If a WebView instance can be identified check if local files are loaded through the method `loadURL()`<sup>[1]</sup>.

```Java
WebView webview = new WebView(this);
webView.loadUrl("file:///android_asset/filename.html");
```

It needs to be verified where the HTML file is loaded from. For example if it's loaded from the external storage the file is read and writable by everybody and considered a bad practice.

```java
webview.loadUrl("file:///" +
Environment.getExternalStorageDirectory().getPath() +
"filename.html");
```

The URL specified in `loadURL()` should be checked, if any dynamic parameters are used that can be manipulated, which may lead to local file inclusion.

#### Dynamic Analysis

This test case should be verified through static analysis.

#### Remediation

Create a white-list that defines the web pages and it's protocols (HTTP or HTTPS) that are allowed to be loaded locally and remotely. Loading web pages from the external storage should be avoided as they are read and writable for all users in Android. Instead they should be placed in the assets directory of the App.

Create checksums of the local HTML/JavaScript files and check it during start up of the App. Minify JavaScript files in order to make it harder to read them.

#### References

##### OWASP Mobile Top 10 2016
* M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V6.7: "The app does not load user-supplied local resources into WebViews."

##### CWE
N/A

##### Info
- [1] loadURL() in WebView - https://developer.android.com/reference/android/webkit/WebView.html#loadUrl(java.lang.String)



### Testing Whether Java Objects Are Exposed Through WebViews

#### Overview

Android offers two different ways that enables JavaScript executed in a WebView to call and use native functions within an Android App:

* `shouldOverrideUrlLoading()`<sup>[4]</sup>
* `addJavascriptInterface()`<sup>[5]</sup>

**shouldOverrideUrlLoading**

This method gives the host application a chance to take over the control when a new URL is about to be loaded in the current WebView.  The method `shouldOverrideUrlLoading()` is available with two different method signatures:

* `boolean shouldOverrideUrlLoading` (WebView view, String url)
  * This method was deprecated in API level 24.
* `boolean shouldOverrideUrlLoading` (WebView view, WebResourceRequest request)
  * This method was added in API level 24

**addJavascriptInterface**

The `addJavascriptInterface()` method allows to expose Java Objects to WebViews. When using this method in an Android App it is possible for JavaScript code in a WebView to invoke native methods of the Android App.

Before Android 4.2 JELLY_BEAN (API Level 17) a vulnerability was discovered in the implementation of `addJavascriptInterface()`, by using reflection that leads to remote code execution when injecting malicious JavaScript in a WebView<sup>[2]</sup>.

With API Level 17 this vulnerability was fixed and the access granted to methods of a Java Object for JavaScript was changed. When using `addJavascriptInterface()`, methods of a Java Object are only accessible for JavaScript when the annotation `@JavascriptInterface` is explicitly added. Before API Level 17 all methods of the Java Object were accessible by default.

An App that is targeting an Android version before Android 4.2 is still vulnerable to the identified flaw in `addJavascriptInterface()` and should only be used with extreme care. Therefore several best practices should be applied in case this method is needed.


#### Static Analysis

**shouldOverrideUrlLoading**

It needs to be verified if and how the method `shouldOverrideUrlLoading()` is used and if it's possible for an attacker to inject malicious JavaScript.

The following example illustrates how the method can be used.

```Java
@Override
public boolean shouldOverrideUrlLoading (WebView view, WebResourceRequest request) {
    URL url = new URL(request.getUrl().toString());
    // execute functions according to values in URL
  }
}
```

If an attacker has access to the JavaScript code, for example through stored XSS or MITM, he can directly trigger native functions if the exposed Java methods are implemented in an insecure way.

```javascript
window.location = http://example.com/method?parameter=value
```

**addJavascriptInterface**

It need to be verified if and how the method `addJavascriptInterface()` is used and if it's possible for an attacker to inject malicious JavaScript.

The following example shows how `addJavascriptInterface` is used in a WebView to bridge a Java Object to JavaScript:

```Java
WebView webview = new WebView(this);
WebSettings webSettings = webview.getSettings();
webSettings.setJavaScriptEnabled(true);

MSTG_ENV_008_JS_Interface jsInterface = new MSTG_ENV_008_JS_Interface(this);

myWebView.addJavascriptInterface(jsInterface, "Android");
myWebView.loadURL("http://example.com/file.html");
setContentView(myWebView);
```

In Android API level 17 and above, a special annotation is used to explicitly allow the access from JavaScript to a Java method.


```Java
public class MSTG_ENV_008_JS_Interface {

        Context mContext;

        /** Instantiate the interface and set the context */
        MSTG_ENV_005_JS_Interface(Context c) {
            mContext = c;
        }

        @JavascriptInterface
        public String returnString () {
            return "Secret String";
        }

        /** Show a toast from the web page */
        @JavascriptInterface
        public void showToast(String toast) {
            Toast.makeText(mContext, toast, Toast.LENGTH_SHORT).show();
        }
}
```

If the annotation `@JavascriptInterface` is used, this method can be called from JavaScript. If the App is targeting API level < 17, all methods of the Java Object are exposed to JavaScript and can be called.

In JavaScript the method `returnString()` can now be called and the return value can be stored in the parameter `result`.

```Javascript
var result = window.Android.returnString();
```

If an attacker has access to the JavaScript code, for example through stored XSS or MITM, he can directly call the exposed Java methods in order to exploit them.

#### Dynamic Analysis

The dynamic analysis of the app can determine what HTML or JavaScript files are loaded and if known vulnerabilities are present. The procedure to exploit the vulnerability is to produce a JavaScript payload and then inject it into the file that the app is requesting for. The injection could be done either though MITM attack, or by modifying directly the file in case it is stored on the external storage.
The whole process could be done through Drozer that using weasel (MWR's advanced exploitation payload) is able to install a full agent, injecting a limited agent into a running process, or connecting a reverse shell to act as a Remote Access Tool (RAT).

A full description of the attack can be found in the blog article by MWR<sup>[2]</sup>.

#### Remediation

If `shouldOverrideUrlLoading()` is needed, it should be verified how the input is processed and if it's possible to execute native functions through malicious JavaScript.

If `addJavascriptInterface()` is needed, only JavaScript provided with the APK should be allowed to call it but no JavaScript loaded from remote endpoints.

Moreover pay attention if you imported library, e.g. for advertising, because they con uses the methods mentioned before and bring the vulnerabilities in your app.

Another compliant solution is to define the API level to 17 (JELLY_BEAN_MR1) and above in the manifest file of the App. For these API levels, only public methods that are annotated with `JavascriptInterface` can be accessed from JavaScript<sup>[1]</sup>.

```xml
<uses-sdk android:minSdkVersion="17" />
...

</manifest>
```

#### References

##### OWASP Mobile Top 10 2016
* M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
- V6.8: "If Java objects are exposed in a WebView, verify that the WebView only renders JavaScript contained within the app package."

##### CWE
* CWE-502 - Deserialization of Untrusted Data

##### Info
- [1] DRD13 addJavascriptInterface()  - https://www.securecoding.cert.org/confluence/pages/viewpage.action?pageId=129859614
- [2] WebView addJavascriptInterface Remote Code Execution - https://labs.mwrinfosecurity.com/blog/webview-addjavascriptinterface-remote-code-execution/
- [3] Method shouldOverrideUrlLoading() - https://developer.android.com/reference/android/webkit/WebViewClient.html#shouldOverrideUrlLoading(android.webkit.WebView,%20java.lang.String)
- [4] Method addJavascriptInterface() - https://developer.android.com/reference/android/webkit/WebView.html#addJavascriptInterface(java.lang.Object, java.lang.String)



### Testing Object persistance

#### Overview

There are various ways to persistn an object within Android:

##### Object Serialization

An object and its data can be represented as a sequence of bytes. In Java, this is possible using object serialization <sup>[1]</sup>. Serialization is not secure by default and is just a binary format or representation that can be used to store data locally as .ser file. It is possible to sign and encrypt serialized data but, if the source code is available, this is always reversible.  

##### Json

There are various ways to serialize the contents of an object to JSON. Android comes with the `JSONObject` and `JSONArray` classes. Next there is a wide veriaty of libraries which can be used, such as: GSON<sup>[2]</sup>, Jackson<sup>[3]</sup> and others. They mostly differ in whether they use reflection to compose the object, whether they support annotations and the amount of memory they use. Note that almost all the json representations are String based and therefore immutable. This means that any secret stored in json will be harder to remove from memory.
The JSON itself can be stored somewhere (E.g. (NoSQL) database or a file). You just need to make sure that any JSON that contains secrets has been appropriately protected (e.g. encrypted/HMACed). See the storage chapter for more details.

##### ORM

Object-Relational Mapping (ORM) is used to store the contents of an object directly into a database. Libraries like OrmLite<sup>[4]</sup>, SugarORM<sup>[5]</sup>, GreenDAO<sup>[6]</sup> and ActiveAndroid<sup>[7]</sup> use a SQLite database to store the data in. Realm <sup>[8]</sup>, another library, uses its own database to store the contents of a class.
The amount of protection that ORM can provide mostly relies on whether the database is encrypted. See the storage chapter for more details.

##### Parcelable
`Parcelable` is an interface for classes whose instances can be written to and restored from a `Parcel` <sup>[9][10][11]</sup>. A parcel is often used to pack a class as part of a `Bundle` content for an `Intent`.

#### Static Analysis

Search the source code for the following keywords:

- `import java.io.Serializable`
- `implements Serializable`

Check if serialized data is stored temporarily or permanently within the app's data directory or external storage and if it contains sensitive data.

**https://www.securecoding.cert.org/confluence/display/java/SER04-J.+Do+not+allow+serialization+and+deserialization+to+bypass+the+security+manager**


#### Dynamic Analysis

-- TODO [Create content for dynamic analysis of "Testing Object (De-)Serialization" ] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Object (De-)Serialization".] --

#### References

##### OWASP Mobile Top 10 2016
* M7 - Client Code Quality - https://www.owasp.org/index.php/Mobile_Top_10_2016-M7-Poor_Code_Quality

##### OWASP MASVS
* V6.9: "Object serialization, if any, is implemented using safe serialization APIs."

##### CWE
N/A

##### Info
- [1] Serializable - https://developer.android.com/reference/java/io/Serializable.html
- [2] Google Gson - https://github.com/google/gson
- [3] Jackson core - https://github.com/FasterXML/jackson-core
- [4] ORM Lite - http://ormlite.com/
- [5] Sugar ORM - http://satyan.github.io/sugar/
- [6] GreenDAO - http://greenrobot.org/greendao/
- [7] ActiveAndroid - http://www.activeandroid.com/
- [8] Realm Java - https://realm.io/docs/java/latest/
- [9] Parcelable - https://developer.android.com/reference/android/os/Parcelable.html
- [10] Parcel - https://developer.android.com/reference/android/os/Parcel.html
- [11] Parcelable.Creator - https://developer.android.com/reference/android/os/Parcelable.Creator.html

### Testing Root Detection

#### Overview

Checking the integrity of the environment where the app is running is getting more and more common on the Android platform. Due to the usage of rooted devices several fundamental security mechanisms of Android are deactivated or can easily be bypassed by any app. Apps that process sensitive information or have built in largely intellectual property (IP), like gaming apps, might want to avoid to run on a rooted phone to protect data or their IP.

Keep in mind that root detection is not protecting an app from attackers, but can slow down an attacker dramatically and higher the bar for successful local attacks. Root detection should be considered as part of a broad security-in-depth strategy, to be more resilient against attackers and make analysis harder.

#### Static Analysis

Root detection can either be implemented by leveraging existing root detection libraries, such as `Rootbeer`<sup>[1]</sup>, or by implementing manually checks.

Check the source code for the string `rootbeer` and also the `gradle` file, if a dependency is defined for Rootbeer:

```java
dependencies {
    compile 'com.scottyab:rootbeer-lib:0.0.4'
}
```

If this library is used, code like the following might be used for root detection.

```java
        RootBeer rootBeer = new RootBeer(context);
        if(rootBeer.isRooted()){
            //we found indication of root
        }else{
            //we didn't find indication of root
        }
```

If the root detection is implemented from scratch, the following should be checked to identify functions that contain the root detection logic. The following checks are the most common ones for root detection:
* Checking for settings/files that are available on a rooted device, like verifying the BUILD properties for test-keys in the parameter `android.os.build.tags`.
* Checking permissions of certain directories that should be read-only on a non-rooted device, but are read/write on a rooted device.
* Checking for installed Apps that allow or support rooting of a device, like verifying the presence of _Superuser.apk_.
* Checking available commands, like is it possible to execute `su` and being root afterwards.


#### Dynamic Analysis

A debug build with deactivated root detection should be provided in a white box test to be able to apply all test cases to the app.

In case of a black box test, an implemented root detection can be challenging if for example the app is immediately terminated because of a rooted phone. Ideally, a rooted phone is used for black box testing and might also be needed to disable SSL Pinning. To deactivate SSL Pinning and allow the usage of an interception proxy, the root detection needs to be defeated first in that case. Identifying the implemented root detection logic without source code in a dynamic scan can be fairly hard.

By using the Xposed module `RootCloak` it is possible to run apps that detect root without disabling root. Nevertheless, if a root detection mechanism is used within the app that is not covered in RootCloak, this mechanism needs to be identified and added to RootCloak in order to disable it.

Other options are dynamically patching the app with Friday or repackaging the app. This can be as easy as deleting the function in the smali code and repackage it, but can become difficult if several different checks are part of the root detection mechanism. Dynamically patching the app can also become difficult if countermeasures are implemented that prevent runtime manipulation/tampering.

Otherwise it should be switched to a non-rooted device in order to use the testing time wisely and to execute all other test cases that can be applied on a non-rooted setup. This is of course only possible if the SSL Pinning can be deactivated for example in smali and repackaging the app.

#### Remediation

To implement root detection within an Android app, libraries can be used like `RootBeer`<sup>[1]</sup>. The root detection should either trigger a warning to the user after start, to remind him that the device is rooted and that the user can only proceed on his own risk. Alternatively, the app can terminate itself in case a rooted environment is detected. This decision is depending on the business requirements and the risk appetite of the stakeholders.

#### References

##### OWASP Mobile Top 10 2016
* M8 - Code Tampering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M8-Code_Tampering
* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

- V6.10: "The app detects whether it is being executed on a rooted or jailbroken device. Depending on the business requirement, users are warned, or the app is terminated if the device is rooted or jailbroken."

##### CWE
N/A

##### Info
- [1] RootBeer - https://github.com/scottyab/rootbeer

##### Tools

* RootCloak - http://repo.xposed.info/module/com.devadvance.rootcloak2
