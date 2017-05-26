## Testing Anti-Reversing Defenses on Android

### Testing Root Detection

#### Overview

In the context of anti-reversing, the goal of root detection is to make it a bit more difficult to run the app on a rooted device, which in turn impedes some tools and techniques reverse engineers like to use. As with most other defenses, root detection is not highly effective on its own, but having some root checks sprinkled throughout the app can improve the effectiveness of the overall anti-tampering scheme.

On Android, we define the term "root detection" a bit more broadly to include detection of custom ROMs, i.e. verifying whether the device is a stock Android build or a custom build.

##### Common Root Detection Methods

In the following section, we list some of the root detection methods you'll commonly encounter. You'll find some of those checks implemented in the Crackme examples that accompany the OWASP Mobile Testing Guide <sup>[1]</sup>.

###### SafetyNet

SafetyNet is an Android API that creates a profile of the device using software and hardware information. This profile is then compared against a list of white-listed device models that have passed Android compatibility testing. Google recommends using the feature as "an additional in-depth defense signal as part of an anti-abuse system" <sup>[2]</sup>.

What exactly SafetyNet does under the hood is not well documented, and may change at any time: When you call this API, the service downloads a binary package containing the device vaidation code from Google, which is then dynamically executed using reflection. An analysis by John Kozyrakis showed that the checks performed by SafetyNet also attempt to detect whether the device is rooted, although it is unclear how exactly this is determined <sup>[3]</sup>.

To use the API, an app may the SafetyNetApi.attest() method with returns a JWS message with the *Attestation Result*, and then check the following fields:

- ctsProfileMatch: Of "true", the device profile matches one of Google's listed devices that have passed  Android compatibility testing.
- basicIntegrity: The device running the app likely wasn't tampered with.

The attestation result looks as follows.

~~~
{
  "nonce": "R2Rra24fVm5xa2Mg",
  "timestampMs": 9860437986543,
  "apkPackageName": "com.package.name.of.requesting.app",
  "apkCertificateDigestSha256": ["base64 encoded, SHA-256 hash of the
                                  certificate used to sign requesting app"],
  "apkDigestSha256": "base64 encoded, SHA-256 hash of the app's APK",
  "ctsProfileMatch": true,
  "basicIntegrity": true,
}
~~~

###### Programmatic Detection

**File existence checks**

Perhaps the most widely used method is checking for files typically found on rooted devices, such as package files of common rooting apps and associated files and directories, such as:

~~~
/system/app/Superuser.apk
/system/etc/init.d/99SuperSUDaemon
/dev/com.koushikdutta.superuser.daemon/
/system/xbin/daemonsu

~~~

Detection code also often looks for binaries that are usually installed once a device is rooted. Examples include checking for the presence of busybox or attempting to open the *su* binary at different locations:

~~~
/system/xbin/busybox

/sbin/su
/system/bin/su
/system/xbin/su
/data/local/su
/data/local/xbin/su
~~~

Alternatively, checking whether *su* is in PATH also works:

~~~java
    public static boolean checkRoot(){
        for(String pathDir : System.getenv("PATH").split(":")){
            if(new File(pathDir, "su").exists()) {
                return true;
            }
        }
        return false;
    }
~~~

File checks can be easily implemented in both Java and native code. The following JNI example uses the <code>stat</code> system call to retrieve information about a file (example code adapted from rootinspector <sup>[9]</sup>), and returns <code>1</code> if the file exists.

```c
jboolean Java_com_example_statfile(JNIEnv * env, jobject this, jstring filepath) {
  jboolean fileExists = 0;
  jboolean isCopy;
  const char * path = (*env)->GetStringUTFChars(env, filepath, &isCopy);
  struct stat fileattrib;
  if (stat(path, &fileattrib) < 0) {
    __android_log_print(ANDROID_LOG_DEBUG, DEBUG_TAG, "NATIVE: stat error: [%s]", strerror(errno));
  } else
  {
    __android_log_print(ANDROID_LOG_DEBUG, DEBUG_TAG, "NATIVE: stat success, access perms: [%d]", fileattrib.st_mode);
    return 1;
  }

  return 0;
}
```

**Executing su and other commands**

Another way of determining whether <code>su</code> exists is attempting to execute it through <code>Runtime.getRuntime.exec()</code>. This will throw an IOException if <code>su</code> is not in PATH. The same method can be used to check for other programs often found on rooted devices, such as busybox or the symbolic links that typically point to it.

**Checking running processes**

Supersu - by far the most popular rooting tool - runs an authentication daemon named <code>daemonsu</code>, so the presence of this process is another sign of a rooted device. Running processes can be enumerated through <code>ActivityManager.getRunningAppProcesses()</code> and <code>manager.getRunningServices()</code> APIs, the <code>ps</code> command, or walking through the <code>/proc</code> directory. As an example, this is implemented the following way in rootinspector <sup>[9]</sup>:

```java
    public boolean checkRunningProcesses() {

      boolean returnValue = false;

      // Get currently running application processes
      List<RunningServiceInfo> list = manager.getRunningServices(300);

      if(list != null){
        String tempName;
        for(int i=0;i<list.size();++i){
          tempName = list.get(i).process;

          if(tempName.contains("supersu") || tempName.contains("superuser")){
            returnValue = true;
          }
        }
      }
      return returnValue;
    }
```

**Checking installed app packages**

The Android package manager can be used to obtain a list of installed packages. The following package names belong to popular rooting tools:

~~~
com.thirdparty.superuser
eu.chainfire.supersu
com.noshufou.android.su
com.koushikdutta.superuser
com.zachspong.temprootremovejb
com.ramdroid.appquarantine
~~~

**Checking for writable partitions and system directories**

Unusual permissions on system directories can indicate a customized or rooted device. While under normal circumstances, the system and data directories are always mounted as read-only, you'll sometimes find them mounted as read-write when the device is rooted. This can be tested for by checking whether these filesystems have been mounted with the "rw" flag, or attempting to create a file in these directories

**Checking for custom Android builds**

Besides checking whether the device is rooted, it is also helpful to check for signs of test builds and custom ROMs. One method of doing this is checking whether the BUILD tag contains test-keys, which normally indicates a custom Android image <sup>[5]</sup>. This can be checked as follows <sup>[6]</sup>:

~~~
private boolean isTestKeyBuild()
{
String str = Build.TAGS;
if ((str != null) && (str.contains("test-keys")));
for (int i = 1; ; i = 0)
  return i;
}
~~~

Missing Google Over-The-Air (OTA) certificates are another sign of a custom ROM, as on stock Android builds, OTA updates use Google's public certificates <sup>[4]</sup>.

##### Bypassing Root Detection

Run execution traces using JDB, DDMS, strace and/or Kernel modules to find out what the app is doing - you'll usually see all kinds of suspect interactions with the operating system, such as opening *su* for reading or obtaining a list of processes. These interactions are surefire signs of root detection. Identify and deactivate the root detection mechanisms one-by-one. If you're performing a black-box resiliency assessment, disabling the root detection mechanisms is your first step.

You can use a number of techniques to bypass these checks, most of which were introduced in the "Reverse Engineering and Tampering" chapter:

1. Renaming binaries. For example, in some cases simply renaming the "su" binary to something else is enough to defeat root detection (try not to break your enviroment though!).
2. Unmounting /proc to prevent reading of process lists etc. Sometimes, proc being unavailable is enough to bypass such checks.
2. Using Frida or Xposed to hook APIs on the Java and native layers. By doing this, you can hide files and processes, hide the actual content of files, or return all kinds of bogus values the app requests;
3. Hooking low-level APIs using Kernel modules.
4. Patching the app to remove the checks.

#### Effectiveness Assessment

Check for the presence of root detection mechanisms and apply the following criteria:

- Multiple detection methods are scattered throughout the app (as opposed to putting everything into a single method);
- The root detection mechanisms operate on multiple API layers (Java APIs, native library functions, Assembler / system calls);
- The mechanisms show some level of originality (vs. copy/paste from StackOverflow or other sources);

Develop bypass methods for the root detection mechanisms and answer the following questions:

- Is it possible to easily bypass the mechanisms using standard tools such as RootCloak?
- Is some amount of static/dynamic analysis necessary to handle the root detection?
- Did you need to write custom code?
- How long did it take you to successfully bypass it?
- What is your subjective assessment of difficulty?

Also note how well the root detection mechanisms are integrated within the overall protection scheme. For example, the detection functions should obfuscated and protected from tampering.

#### Remediation

If root detection is missing or too easily bypassed, make suggestions in line with the effectiveness criteria listed above. This may include adding more detection mechansims, or better integrating existing mechanisms with other defenses.

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

- V8.3: "The app implements two or more functionally independent methods of root detection and responds to the presence of a rooted device either by alerting the user or terminating the app."

##### CWE

N/A

##### Info

- [1] OWASP Mobile Crackmes - https://github.com/OWASP/owasp-mstg/blob/master/OMTG-Files/02_Crackmes/List_of_Crackmes.md
- [2] SafetyNet Documentation - https://developers.google.com/android/reference/com/google/android/gms/safetynet/SafetyNet
- [3] SafetyNet: Google's tamper detection for Android - https://koz.io/inside-safetynet/
- [4] NetSPI Blog - Android Root Detection Techniques - https://blog.netspi.com/android-root-detection-techniques/
- [5] InfoSec Institute - http://resources.infosecinstitute.com/android-hacking-security-part-8-root-detection-evasion/
- [6] Android – Detect Root Access from inside an app - https://www.joeyconway.com/blog/2014/03/29/android-detect-root-access-from-inside-an-app/

##### Tools

- [7] rootbeer - https://github.com/scottyab/rootbeer
- [8] RootCloak - http://repo.xposed.info/module/com.devadvance.rootcloak2
- [9] rootinspector - https://github.com/devadvance/rootinspector/

### Testing Anti-Debugging

#### Overview

Debugging is a highly effective way of analyzing the runtime behaviour of an app. It allows the reverse engineer to step through the code, stop execution of the app at arbitrary point, inspect the state of variables, read and modify memory, and a lot more.

As mentioned in the "Reverse Engineering and Tampering" chapter, we have to deal with two different debugging protocols on Android: One could debug on the Java level using JDWP, or on the native layer using a ptrace-based debugger. Consequently, a good anti-debugging scheme needs to implement defenses against both debugger types.

Anti-debugging features can be preventive or reactive. As the name implies, preventive anti-debugging tricks prevent the debugger from attaching in the first place, while reactive tricks attempt to detect whether a debugger is present and react to it in some way (e.g. terminating the app, or triggering some kind of hidden behaviour). The "more-is-better" rule applies: To maximize effectiveness, defenders combine multiple methods of prevention and detection that operate on different API layers and are distributed throughout the app.

##### Sample Anti-JDWP-Debugging Methods

In the chapter "Reverse Engineering and Tampering", we talked about JDWP, the protocol used for communication between the debugger and the Java virtual machine. We also showed that it easily possible to enable debugging for any app by either patching its Manifest file, or enabling debugging for all apps by changing the ro.debuggable system property. Let's look at a few things developers do to detect and/or disable JDWP debuggers.

###### Checking Debuggable Flag in ApplicationInfo

We have encountered the <code>android:debuggable</code> attribute a few times already. This flag in the app Manifest determines whether the JDWP thread is started for the app. Its value can be determined programmatically using the app's ApplicationInfo object. If the flag is set, this is an indication that the Manifest has been tampered with to enable debugging.

```java
    public static boolean isDebuggable(Context context){

        return ((context.getApplicationContext().getApplicationInfo().flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0);

    }
```
###### isDebuggerConnected

The Android Debug system class offers a static method for checking whether a debugger is currently connected. The method simply returns a boolean value.

```
    public static boolean detectDebugger() {
        return Debug.isDebuggerConnected();
    }
```

The same API can be called from native code by accessing the DvmGlobals global structure.

```
JNIEXPORT jboolean JNICALL Java_com_test_debugging_DebuggerConnectedJNI(JNIenv * env, jobject obj) {
    if (gDvm.debuggerConnect || gDvm.debuggerAlive)
        return JNI_TRUE;
    return JNI_FALSE;
}
```

###### Timer Checks

The <code>Debug.threadCpuTimeNanos</code> indicates the amount of time that the current thread has spent executing code. As debugging slows down execution of the process, The difference in execution time can be used to make an educated guess on whether a debugger is attached [2].

```
static boolean detect_threadCpuTimeNanos(){
  long start = Debug.threadCpuTimeNanos();

  for(int i=0; i<1000000; ++i)
    continue;

  long stop = Debug.threadCpuTimeNanos();

  if(stop - start < 10000000) {
    return false;
  }
  else {
    return true;
  }
```

###### Messing With JDWP-related Data Structures

In Dalvik, the global virtual machine state is accessible through the DvmGlobals structure. The global variable gDvm holds a pointer to this structure. DvmGlobals contains various variables and pointers important for JDWP debugging that can be tampered with.

```c
struct DvmGlobals {
    /*
     * Some options that could be worth tampering with :)
     */

    bool        jdwpAllowed;        // debugging allowed for this process?
    bool        jdwpConfigured;     // has debugging info been provided?
    JdwpTransportType jdwpTransport;
    bool        jdwpServer;
    char*       jdwpHost;
    int         jdwpPort;
    bool        jdwpSuspend;

    Thread*     threadList;

    bool        nativeDebuggerActive;
    bool        debuggerConnected;      /* debugger or DDMS is connected */
    bool        debuggerActive;         /* debugger is making requests */
    JdwpState*  jdwpState;

};
```

For example, setting the gDvm.methDalvikDdmcServer_dispatch function pointer to NULL crashed the JDWP thread<sup>[2]</sup>:

```c
JNIEXPORT jboolean JNICALL Java_poc_c_crashOnInit ( JNIEnv* env , jobject ) {
  gDvm.methDalvikDdmcServer_dispatch = NULL;
}
```

Debugging can be disabled using similar techniques in ART, even though the gDvm variable is not available. The ART runtime exports some of the vtables of JDWP-related classes as global symbols (in C++, vtables are tables that hold pointers to class methods). This includes the vtables of the classes include JdwpSocketState and JdwpAdbState - these two handle JDWP connections via network sockets and ADB, respectively. The behaviour of the debugging runtime can be manipulatedB ny overwriting the method pointers in those vtables.

One possible way of doing this is overwriting the address of "jdwpAdbState::ProcessIncoming()" with the address of "JdwpAdbState::Shutdown()". This will cause the debugger to disconnect immediately [3].

```c
#include <jni.h>
#include <string>
#include <android/log.h>
#include <dlfcn.h>
#include <sys/mman.h>
#include <jdwp/jdwp.h>

#define log(FMT, ...) __android_log_print(ANDROID_LOG_VERBOSE, "JDWPFun", FMT, ##__VA_ARGS__)

// Vtable structure. Just to make messing around with it more intuitive

struct VT_JdwpAdbState {
    unsigned long x;
    unsigned long y;
    void * JdwpSocketState_destructor;
    void * _JdwpSocketState_destructor;
    void * Accept;
    void * showmanyc;
    void * ShutDown;
    void * ProcessIncoming;
};

extern "C"

JNIEXPORT void JNICALL Java_sg_vantagepoint_jdwptest_MainActivity_JDWPfun(
        JNIEnv *env,
        jobject /* this */) {

    void* lib = dlopen("libart.so", RTLD_NOW);

    if (lib == NULL) {
        log("Error loading libart.so");
        dlerror();
    }else{

        struct VT_JdwpAdbState *vtable = ( struct VT_JdwpAdbState *)dlsym(lib, "_ZTVN3art4JDWP12JdwpAdbStateE");

        if (vtable == 0) {
            log("Couldn't resolve symbol '_ZTVN3art4JDWP12JdwpAdbStateE'.\n");
        }else {

            log("Vtable for JdwpAdbState at: %08x\n", vtable);

            // Let the fun begin!

            unsigned long pagesize = sysconf(_SC_PAGE_SIZE);
            unsigned long page = (unsigned long)vtable & ~(pagesize-1);

            mprotect((void *)page, pagesize, PROT_READ | PROT_WRITE);

            vtable->ProcessIncoming = vtable->ShutDown;

            // Reset permissions & flush cache

            mprotect((void *)page, pagesize, PROT_READ);

        }
    }
}
```

##### Sample Anti-Native-Debugging Methods

Most Anti-JDWP tricks (safe for maybe timer-based checks) won't catch classical, ptrace-based debuggers, so separate defenses are needed to defend against this type of debugging. Many "traditional" Linux anti-debugging tricks are employed here.

###### Checking TracerPid

When the <code>ptrace</code> system call is used to attach to a process, the "TracerPid" field in the status file of the debugged process shows the PID of the attaching process. The default value of "TracerPid" is "0" (no other process attached). Consequently, finding anything else than "0" in that field is a sign of debugging or other ptrace-shenanigans.

The following implementation is taken from Tim Strazzere's Anti-Emulator project [3].

```
    public static boolean hasTracerPid() throws IOException {
        BufferedReader reader = null;
        try {
            reader = new BufferedReader(new InputStreamReader(new FileInputStream("/proc/self/status")), 1000);
            String line;

            while ((line = reader.readLine()) != null) {
                if (line.length() > tracerpid.length()) {
                    if (line.substring(0, tracerpid.length()).equalsIgnoreCase(tracerpid)) {
                        if (Integer.decode(line.substring(tracerpid.length() + 1).trim()) > 0) {
                            return true;
                        }
                        break;
                    }
                }
            }

        } catch (Exception exception) {
            exception.printStackTrace();
        } finally {
            reader.close();
        }
        return false;
    }
```

**Ptrace variations***

On Linux, the <code>ptrace()</code> system call is used to observe and control the execution of another process (the "tracee"), and examine and change the tracee's memory and registers [5]. It is the primary means of implementing breakpoint debugging and system call tracing. Many anti-debugging tricks make use of <code>ptrace</code> in one way or another, often exploiting the fact that only one debugger can attach to a process at any one time.

As a simple example, one could prevent debugging of a process by forking a child process and attaching it to the parent as a debugger, using code along the following lines:

```
void fork_and_attach()
{
  int pid = fork();

  if (pid == 0)
    {
      int ppid = getppid();

      if (ptrace(PTRACE_ATTACH, ppid, NULL, NULL) == 0)
        {
          waitpid(ppid, NULL, 0);

          /* Continue the parent process */
          ptrace(PTRACE_CONT, NULL, NULL);
        }
    }
}
```

With the child attached, any further attempts to attach to the parent would fail. We can verify this by compiling the code into a JNI function and packing it into an app we run on the device.

```bash
root@android:/ # ps | grep -i anti
u0_a151   18190 201   1535844 54908 ffffffff b6e0f124 S sg.vantagepoint.antidebug
u0_a151   18224 18190 1495180 35824 c019a3ac b6e0ee5c S sg.vantagepoint.antidebug
```

Attempting to attach to the parent process with gdbserver now fails with an error.

```bash
root@android:/ # ./gdbserver --attach localhost:12345 18190
warning: process 18190 is already traced by process 18224
Cannot attach to lwp 18190: Operation not permitted (1)
Exiting
```

This is however easily bypassed by killing the child and "freeing" the parent from being traced. In practice, you'll therefore usually find more elaborate schemes that involve multiple processes and threads, as well as some form of monitoring to impede tampering. Common methods include:

- Forking multiple processes that trace one another;
- Keeping track of running processes to make sure the children stay alive;
- Monitoring values in the /proc filesystem, such as TracerPID in /proc/pid/status.

Let's look at a simple improvement we can make to the above method. After the initial <code>fork()</code>, we launch an extra thread in the parent that continually monitors the status of the child. Depending on whether the app has been built in debug or release mode (according to the <code>android:debuggable</code> flag in the Manifest), the child process is expected to behave in one of the following ways:

1. In release mode, the call to ptrace fails and the child crashes immediately with a segmentation fault (exit code 11).
2. In debug mode, the call to ptrace works and the child is expected to run indefinitely. As a consequence, a call to waitpid(child_pid) should never return - if it does, something is fishy and we kill the whole process group.

The complete code implementing this as a JNI function is below:

```c
#include <jni.h>
#include <string>
#include <unistd.h>
#include <sys/ptrace.h>
#include <sys/wait.h>

static int child_pid;

void *monitor_pid(void *) {

    int status;

    waitpid(child_pid, &status, 0);

    /* Child status should never change. */

    _exit(0); // Commit seppuku

}

void anti_debug() {

    child_pid = fork();

    if (child_pid == 0)
    {
        int ppid = getppid();
        int status;

        if (ptrace(PTRACE_ATTACH, ppid, NULL, NULL) == 0)
        {
            waitpid(ppid, &status, 0);

            ptrace(PTRACE_CONT, ppid, NULL, NULL);

            while (waitpid(ppid, &status, 0)) {

                if (WIFSTOPPED(status)) {
                    ptrace(PTRACE_CONT, ppid, NULL, NULL);
                } else {
                    // Process has exited
                    _exit(0);
                }
            }
        }

    } else {
        pthread_t t;

        /* Start the monitoring thread */

        pthread_create(&t, NULL, monitor_pid, (void *)NULL);
    }
}
extern "C"

JNIEXPORT void JNICALL
Java_sg_vantagepoint_antidebug_MainActivity_antidebug(
        JNIEnv *env,
        jobject /* this */) {

        anti_debug();
}
```

Again, we pack this into an Android app to see if it works. Just as before, two processes show up when running the debug build of the app.

```bash
root@android:/ # ps | grep -i anti-debug
u0_a152   20267 201   1552508 56796 ffffffff b6e0f124 S sg.vantagepoint.anti-debug
u0_a152   20301 20267 1495192 33980 c019a3ac b6e0ee5c S sg.vantagepoint.anti-debug
```

However, if we now terminate the child process, the parent exits as well:

```bash
root@android:/ # kill -9 20301
130|root@hammerhead:/ # cd /data/local/tmp                                     
root@android:/ # ./gdbserver --attach localhost:12345 20267   
gdbserver: unable to open /proc file '/proc/20267/status'
Cannot attach to lwp 20267: No such file or directory (2)
Exiting
```

To bypass this, it's necessary to modify the behavior of the app slightly (the easiest is to patch the call to _exit with NOPs, or hooking the function _exit in libc.so). At this point, we have entered the proverbial "arms race": It is always possible to implement more inticate forms of this defense, and there's always some ways to bypass it.

##### Bypassing Debugger Detection

As usual, there is no generic way of bypassing anti-debugging: It depends on the particular mechanism(s) used to prevent or detect debugging, as well as other defenses in the overall protection scheme. For example, if there are no integrity checks, or you have already deactivated them, patching the app might be the easiest way. In other cases, using a hooking framework or kernel modules might be preferable.

1. Patching out the anti-debugging functionality. Disable the unwanted behaviour by simply overwriting it with NOP instructions. Note that more complex patches might be required if the anti-debugging mechanism is well thought-out.
2. Using Frida or Xposed to hook APIs on the Java and native layers. Manipulate the return values of functions such as isDebuggable and isDebuggerConnected to hide the debugger.
3. Change the environment. Android is an open enviroment. If nothing else works, you can modify the operating system to subvert the assumptions the developers made when designing the anti-debugging tricks.

###### Example: UnCrackable App for Android Level 2

-- TODO [Bypassing Debugger Detection - Solve UnCrackable Level 2] --

When dealing with obfuscated apps, you'll often find that developers purposely "hide away" data and functionality in native libraries. You'll find an example for this in level 2 of the "UnCrackable App'.

At first glance, the code looks similar to the prior challenge. A class called "CodeCheck" is responsible for verifying the code entered by the user. The actual check appears to happen in the method "bar()", which is declared as a *native* method.

```java
package sg.vantagepoint.uncrackable2;

public class CodeCheck {
    public CodeCheck() {
        super();
    }

    public boolean a(String arg2) {
        return this.bar(arg2.getBytes());
    }

    private native boolean bar(byte[] arg1) {
    }
}

    static {
        System.loadLibrary("foo");
    }
```


-- TODO [Add a generic bypass script using Frida (?)] --

```python
#v0.1
 
import frida
import sys
 
session = frida.get_remote_device().attach("com.example.targetapp")
 
script = session.create_script("""
 
var funcPtr = Module.findExportByName("libdvm.so", "_Z25dvmDbgIsDebuggerConnectedv");
Interceptor.replace(funcPtr, new NativeCallback(function (pathPtr, flags) {
    return 0;
}, 'int', []));
""") 

def on_message(message, data):
    print(message)
 
script.on('message', on_message)
script.load()
sys.stdin.read()
```

#### Effectiveness Assessment

Check for the presence of anti-debugging mechanisms and apply the following criteria:

- Attaching JDB and ptrace based debuggers either fails, or causes the app to terminate or malfunction
- Multiple detection methods are scattered throughout the app (as opposed to putting everything into a single method or function);
- The anti-debugging defenses operate on multiple API layers (Java, native library functions, Assembler / system calls);
- The mechanisms show some level of originality (vs. copy/paste from StackOverflow or other sources);

Work on bypassing the anti-debugging defenses and answer the following questions:

- Can the mechanisms be bypassed using trivial methods (e.g. hooking a single API function)?
- How difficult is it to identify the anti-debugging code using static and dynamic analysis?
- Did you need to write custom code to disable the defenses? How much time did you need to invest?
- What is your subjective assessment of difficulty?

Consider how the anti-debugging mechansims fit into the overall protection scheme. For example, anti-debugging defenses should obfuscated and protected from tampering.

Note that some anti-debugging implementations respond in a stealthy way so that changes in behaviour are not immediately apparent. For example, a soft token app might not visibly respond when a debugger is detected, but instead secretly alter the state of an internal variable so that an incorrect OTP is generated at a later point. Make sure to run through the complete workflow to determine if attaching the debugger causes a crash or malfunction.

#### Remediation

If anti-debugging is missing or too easily bypassed, make suggestions in line with the effectiveness criteria listed above. This may include adding more detection mechansims, or better integrating existing mechanisms with other defenses.

#### References

- [1] Matenaar et al. - Patent Application - MOBILE DEVICES WITH INHIBITED APPLICATION DEBUGGING AND METHODS OF OPERATION - https://www.google.com/patents/US8925077
- [2] Bluebox Security - Android Reverse Engineering & Defenses - https://slides.night-labs.de/AndroidREnDefenses201305.pdf
- [3] Tim Strazzere - Android Anti-Emulator - https://github.com/strazzere/anti-emulator/
- [4] Anti-Debugging Fun with Android ART - https://www.vantagepoint.sg/blog/88-anti-debugging-fun-with-android-art
- [5] ptrace man page - http://man7.org/linux/man-pages/man2/ptrace.2.html

### Testing File Integrity Checks

#### Overview

In the "Tampering and Reverse Engineering" chapter, we discussed Android's APK code signature check. We also saw that determined reverse engineers can easily bypass this check by re-packaging and re-signing an app. To make this process more involved, a protection scheme can be augmented with CRC checks on the app bytecode and native libraries as well as important data files. These checks can be implemented both on the Java and native layer. The idea is to have additional controls in place so that the only runs correctly in its unmodified state, even if the code signature is valid.

##### Sample Implementation

Integrity checks often calculate a checksum or hash over selected files. Files that are commonly protected include:

- AndroidManifest.xml
- Class files *.dex
- Native libraries (*.so)

The following sample implementation from the Android Cracking Blog <sup>[1]</sup> calculates a CRC over classes.dex and compares is with the expected value.


```java
private void crcTest() throws IOException {
 boolean modified = false;
 // required dex crc value stored as a text string.
 // it could be any invisible layout element
 long dexCrc = Long.parseLong(Main.MyContext.getString(R.string.dex_crc));

 ZipFile zf = new ZipFile(Main.MyContext.getPackageCodePath());
 ZipEntry ze = zf.getEntry("classes.dex");

 if ( ze.getCrc() != dexCrc ) {
  // dex has been modified
  modified = true;
 }
 else {
  // dex not tampered with
  modified = false;
 }
}
```

##### Bypassing File Integrity Checks

1. Patch out the anti-debugging functionality. Disable the unwanted behaviour by simply overwriting the respective bytecode or native code it with NOP instructions.
2. Use Frida or Xposed to hook APIs to hook file system APIs on the Java and native layers. Return a handle to the original file instead of the modified file.
3. Use Kernel module to intercept file-related system calls. When the process attempts to open the modified file, return a file descriptor for the unmodified version of the file instead.

Refer to the "Tampering and Reverse Engineering section" for examples of patching, code injection and kernel modules.

#### Effectiveness Assessment

Run the app on the device in an unmodified state and make sure that everything works. Then, apply simple patches to the classes.dex and any .so libraries contained in the app package. Re-package and re-sign the app as described in the chapter "Basic Security Testing" and run it. The app should detect the modification an cease to function. Note that some anti-tampering implementations respond in a stealthy way so that changes in behaviour are not immediately apparent.

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

-- V8.3: "The app detects, and responds to, tampering with executable files and critical data".

##### CWE

- N/A

##### Info

- [1] Android Cracking Blog - http://androidcracking.blogspot.sg/2011/06/anti-tampering-with-crc-check.html

### Testing Detection of Reverse Engineering Tools

#### Overview

Reverse engineers use a lot of tools, frameworks and apps to aid the reversing process, many of which you have encountered in this guide. Consequently, the presence of such tools on the device may indicate that the user is either attempting to reverse engineer the app, or is at least putting themselves as increased risk by installing such tools.

##### Detection Methods

Popular tools, if installed in their original form, can be detected by looking for associated application packages, files, processes, or other tool-specific modifications and artefacts.

-- TODO [Add list of tools and associated files, processes, libs, etc. etc. Cover the tools below] --

- Substrate for Android
- Xposed
- Frida
- Radare2
- Introspy-Android
- Drozer
- RootCloak
- Android SSL Trust Killer

###### Example: Ways of Detecting Frida

-- TODO [Write a few introductionary words] --

An obvious method for detecting frida and similar frameworks is to check the environment for related artefacts, such as package files, binaries, libraries, processes, temporary files, and others. As an example, I'll home in on fridaserver, the daemon responsible for exposing frida over TCP. One could use a Java method that iterates through the list of running processes to check whether fridaserver is running:

```c
public boolean checkRunningProcesses() {

  boolean returnValue = false;

  // Get currently running application processes
  List<RunningServiceInfo> list = manager.getRunningServices(300);

  if(list != null){
    String tempName;
    for(int i=0;i<list.size();++i){
      tempName = list.get(i).process;

      if(tempName.contains("fridaserver")) {
        returnValue = true;
      }
    }
  }
  return returnValue;
}
```

This works if frida is run in its default configuration. Perhaps it's also enough to stump some script kiddies doing their first little baby steps in reverse engineering. It can however be easily bypassed by renaming the fridaserver binary to "lol" or other names, so we should maybe find a better method.

By default, fridaserver binds to TCP port 27047, so checking whether this port is open is another idea. In native code, this could look as follows:

```c
boolean is_frida_server_listening() {
    struct sockaddr_in sa;

    memset(&sa, 0, sizeof(sa));
    sa.sin_family = AF_INET;
    sa.sin_port = htons(27047);
    inet_aton("127.0.0.1", &(sa.sin_addr));

    int sock = socket(AF_INET , SOCK_STREAM , 0);

    if (connect(sock , (struct sockaddr*)&sa , sizeof sa) != -1) {
      /* Frida server detected. Do something… */
    }

}   
```

Again, this detects fridaserver in its default mode, but the listening port can be changed easily via command line argument, so bypassing this is a little bit too trivial. The situation can be improved by pulling an nmap -sV. fridaserver uses the D-Bus protocol to communicate, so we send a D-Bus AUTH message to every open port and check for an answer, hoping for fridaserver to reveal itself.

```c
/*
 * Mini-portscan to detect frida-server on any local port.
 */

for(i = 0 ; i <= 65535 ; i++) {

    sock = socket(AF_INET , SOCK_STREAM , 0);
    sa.sin_port = htons(i);

    if (connect(sock , (struct sockaddr*)&sa , sizeof sa) != -1) {

        __android_log_print(ANDROID_LOG_VERBOSE, APPNAME,  "FRIDA DETECTION [1]: Open Port: %d", i);

        memset(res, 0 , 7);

        // send a D-Bus AUTH message. Expected answer is “REJECT"

        send(sock, "\x00", 1, NULL);
        send(sock, "AUTH\r\n", 6, NULL);

        usleep(100);

        if (ret = recv(sock, res, 6, MSG_DONTWAIT) != -1) {

            if (strcmp(res, "REJECT") == 0) {
               /* Frida server detected. Do something… */
            }
        }
    }
    close(sock);
}
```

We now have a pretty robust method of detecting fridaserver, but there's still some glaring issues. Most importantly, frida offers alternative modes of operations that don't require fridaserver! How do we detect those?

The common theme in all of frida's modes is code injection, so we can expect to have frida-related libraries mapped into memory whenever frida is used. The straightforward way to detect those is walking through the list of loaded libraries and checking for suspicious ones:

```c
char line[512];
FILE* fp;

fp = fopen("/proc/self/maps", "r");

if (fp) {
    while (fgets(line, 512, fp)) {
        if (strstr(line, "frida")) {
            /* Evil library is loaded. Do something… */
        }
    }

    fclose(fp);

    } else {
       /* Error opening /proc/self/maps. If this happens, something is off. */
    }
}
```

This detects any libraries containing "frida" in the name. On its surface this works, but there's some major issues:

- Remember how it wasn't a good idea to rely on fridaserver being called fridaserver? The same applies here - with some small modifications to frida, the frida agent libraries could simply be renamed.
- Detection relies on standard library calls such as fopen() and strstr(). Essentially, we're attempting to detect frida using functions that can be easily hooked with - you guessed it - frida. Obviously this isn't a very solid strategy.

Issue number one can be addressed by implementing a classic-virus-scanner-like strategy, scanning memory for the presence of "gadgets" found in frida's libraries. I chose the string "LIBFRIDA" which appears to be present in all versions of frida-gadget and frida-agent. Using the following code, we iterate through the memory mappings listed in /proc/self/maps, and search for the string in every executable section. Note that I ommitted the more boring functions for the sake of brevity, but you can find them on GitHub.

```c
static char keyword[] = "LIBFRIDA";
num_found = 0;

int scan_executable_segments(char * map) {
    char buf[512];
    unsigned long start, end;

    sscanf(map, "%lx-%lx %s", &start, &end, buf);

    if (buf[2] == 'x') {
        return (find_mem_string(start, end, (char*)keyword, 8) == 1);
    } else {
        return 0;
    }
}

void scan() {

    if ((fd = my_openat(AT_FDCWD, "/proc/self/maps", O_RDONLY, 0)) >= 0) {

    while ((read_one_line(fd, map, MAX_LINE)) > 0) {
        if (scan_executable_segments(map) == 1) {
            num_found++;
        }
    }

    if (num_found > 1) {

        /* Frida Detected */
    }

}
```

Note the use of my_openat() etc. instead of the normal libc library functions. These are custom implementations that do the same as their Bionic libc counterparts: They set up the arguments for the respective system call and execute the swi instruction (see below). Doing this removes the reliance on public APIs, thus making it less susceptible to the typical libc hooks. The complete implementation is found in syscall.S. The following is an assembler implementation of my_openat().

```
#include "bionic_asm.h"

.text
    .globl my_openat
    .type my_openat,function
my_openat:
    .cfi_startproc
    mov ip, r7
    .cfi_register r7, ip
    ldr r7, =__NR_openat
    swi #0
    mov r7, ip
    .cfi_restore r7
    cmn r0, #(4095 + 1)
    bxls lr
    neg r0, r0
    b __set_errno_internal
    .cfi_endproc

    .size my_openat, .-my_openat;
```

This is a bit more effective as overall, and is difficult to bypass with frida only, especially with some obuscation added. Even so, there are of course many ways of bypassing this as well. Patching and system call hooking come to mind. Remember, the reverse engineer always wins!

To experiment with the detection methods above, you can download and build the Android Studio Project. The app should generate entries like the following when frida is injected.

##### Bypassing Detection of Reverse Engineering Tools

1. Patch out the anti-debugging functionality. Disable the unwanted behaviour by simply overwriting the respective bytecode or native code it with NOP instructions.
2. Use Frida or Xposed to hook APIs to hook file system APIs on the Java and native layers. Return a handle to the original file instead of the modified file.
3. Use Kernel module to intercept file-related system calls. When the process attempts to open the modified file, return a file descriptor for the unmodified version of the file instead.

Refer to the "Tampering and Reverse Engineering section" for examples of patching, code injection and kernel modules.

#### Effectiveness Assessment

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of sentence "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

- V8.4: "The app detects the presence of widely used reverse engineering tools, such as code injection tools, hooking frameworks and debugging servers."

##### CWE

N/A

##### Info

- [1] Netitude Blog - Who owns your runtime? - https://labs.nettitude.com/blog/ios-and-android-runtime-and-anti-debugging-protections/

##### Tools

-- TODO [Add link to tools for "Testing Detection of Reverse Engineering Tools"] --
* Enjarify - https://github.com/google/enjarify

### Testing Emulator Detection

#### Overview

In the context of anti-reversing, the goal of emulator detection is to make it a bit more difficult to run the app on a emulated device, which in turn impedes some tools and techniques reverse engineers like to use. This forces the reverse engineer to defeat the emulator checks or utilize the physical device. This provides a barrier to entry for large scale device analysis.

#### Detection Techniques

There are several static indicators that indicate the device in question is being emulated. While all of these API calls could be hooked, this provides a modest first line of defense.

The first set of indicaters stem from the build.prop file

```
API Method          Value           Meaning
Build.ABI           armeabi         possibly emulator
BUILD.ABI2          unknown         possibly emulator
Build.BOARD         unknown         emulator
Build.Brand         generic         emulator
Build.DEVICE        generic         emulator
Build.FINGERPRINT   generic         emulator
Build.Hardware      goldfish        emulator
Build.Host          android-test    possibly emulator
Build.ID            FRF91           emulator
Build.MANUFACTURER  unknown         emulator
Build.MODEL         sdk             emulator
Build.PRODUCT       sdk             emulator
Build.RADIO         unknown         possibly emulator
Build.SERIAL        null            emulator
Build.TAGS          test-keys       emulator
Build.USER          android-build   emulator
```

It should be noted that the build.prop file can be edited on a rooted android device, or modified when compiling AOSP from source.  Either of these techniques would bypass the static string checks above.

The next set of static indicators utilize the Telephony manager. All android emulators have fixed values that this API can query.

```
API                                                     Value                   Meaning
TelephonyManager.getDeviceId()                          0's                     emulator
TelephonyManager.getLine1 Number()                      155552155               emulator
TelephonyManager.getNetworkCountryIso()                 us                      possibly emulator
TelephonyManager.getNetworkType()                       3                       possibly emulator
TelephonyManager.getNetworkOperator().substring(0,3)    310                     possibly emulator
TelephonyManager.getNetworkOperator().substring(3)      260                     possibly emulator
TelephonyManager.getPhoneType()                         1                       possibly emulator
TelephonyManager.getSimCountryIso()                     us                      possibly emulator
TelephonyManager.getSimSerial Number()                  89014103211118510720    emulator
TelephonyManager.getSubscriberId()                      310260000000000         emulator
TelephonyManager.getVoiceMailNumber()                   15552175049             emulator
```

Keep in mind that a hooking framework such as Xposed or Frida could hook this API to provide false data.

-- TODO [Dynamic Detection Techniques] --


#### Bypassing Emulator Detection


#### Effectiveness Assessment


#### References

- [1] Timothy Vidas & Nicolas Christin - Evading Android Runtime Analysis via Sandbox Detection - https://users.ece.cmu.edu/~tvidas/papers/ASIACCS14.pdf

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

- V8.5: "The app detects, and response to, being run in an emulator using any method."

##### CWE

N/A

##### Info

- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add links to tools for "Testing Emulator Detection"] --
* Enjarify - https://github.com/google/enjarify

### Testing Runtime Integrity Checks

#### Overview

Controls in this category verify the integrity of the app's own memory space, with the goal of protecting against memory patches applied during runtime. This includes unwanted changes to binary code or bytecode, functions pointer tables, and important data structures, as well as rogue code loaded into process memory. Intergrity can be verified either by:

1. Comparing the contents of memory, or a checksum over the contents, with known good values;
2. Searching memory for signatures of unwanted modifications.

You might notice some overlap with the category "detecting reverse engineering tools and frameworks", and in fact we already demonstrated the signature-based approach in that chapter, when we showed how to search for frida-related strings in memory. 

**Verifying the Global Offset Table**

In the world of ELF binaries, the Global Offset Table (GOT) is used as a layer of indirection for calling library functions. During runtime, the dynamic linker patches this table with the absolute addresses of global symbols. Because the GOT is located in writeable memory, it is possible to overwrite the stored function addresses and redirect legitimate function calls to adversary-controlled code. This type of hooks can be detected by verifying that each GOT entry points into a legitimately loaded library.

In contrast to GNU <code>ld</code>, which resolves symbol addresses only once they are needed for the first time (lazy binding), the Android linker resolves all external function and writes the respective GOT entries immediately when a library is loaded (immediate binding). During runtime, we can therefore expect all GOT entries to point to valid memory locations within the code sections of their respective libraries.

**Detecting Inline Hooks***

Inline hooks are implemented by overwriting the first few bytes of a function with a trampoline that redirects control flow to adversary-controlled code.

-- TODO [Needs more research and code samples] --

#### Bypassing Runtime Integrity Checks

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of sentence "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

#### Effectiveness Assessment

-- TODO [Describe how to test for this issue by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

-- TODO [Update reference "VX.Y" below and description] --
- VX.Y: "Requirement text, e.g. 'the keyboard cache is disabled on text inputs that process sensitive data'."

##### CWE
-- TODO [Add relevant CWE for "Testing Memory Integrity Checks"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] Michael Hale Ligh, Andrew Case, Jamie Levy, Aaron Walters (2014) *The Art of Memory Forensics.* Wiley. "Detecting GOT Overwrites", p. 743.

##### Tools

-- TODO [Add link to relevant tools for "Testing Memory Integrity Checks"] --
* Enjarify - https://github.com/google/enjarify

### Testing Device Binding

#### Overview

The goal of device binding is to impede an attacker when he tries to copy an app and its state from device A to device B and continue the execution of the app on device B. When device A has been deemend trusted, it might have more privileges than device B, which should not change when an app is copied from device A to device B.
In the past, Android developers often relied on the Secure ANDROID_ID (SSAID) and MAC addresses. However, the behavior of the SSAID has changed since Android O and the behavior of MAC addresses have changed in Android N <sup>[1]</sup>. Google has set a new set of recommendations in their SDK documentation regarding identifiers as well <sup>[2]</sup>.

##### Google InstanceID

Google InstanceID <sup>[5]</sup> uses tokens to authenticate the application instance running on the device. The moment the application has been reset, uninstalled, etc., the instanceID is reset, meaning that you have a new "instance" of the app.
You need to take the following steps into account for instanceID:
0. Configure your instanceID at your Google Developer Console for the given application. This includes managing the PROJECT_ID.

1. Setup Google play services. In your build.gradle, add:
```groovy
  apply plugin: 'com.android.application'
    ...

    dependencies {
        compile 'com.google.android.gms:play-services-gcm:10.2.4'
    }
```
2. Get an instanceID
```java
  String iid = InstanceID.getInstance(context).getId();
  //now submit this iid to your server.
```

3. Generate a token
```java
String authorizedEntity = PROJECT_ID; // Project id from Google Developer Console
String scope = "GCM"; // e.g. communicating using GCM, but you can use any
                      // URL-safe characters up to a maximum of 1000, or
                      // you can also leave it blank.
String token = InstanceID.getInstance(context).getToken(authorizedEntity,scope);
//now submit this token to the server.
```
4. Make sure that you can handle callbacks from instanceID in case of invalid device information, security issues, etc.
For this you have to extend the `InstanceIDListenerService` and handle the callbacks there:

```java
public class MyInstanceIDService extends InstanceIDListenerService {
  public void onTokenRefresh() {
    refreshAllTokens();
  }

  private void refreshAllTokens() {
    // assuming you have defined TokenList as
    // some generalized store for your tokens for the different scopes.
    // Please note that for application validation having just one token with one scopes can be enough.
    ArrayList<TokenList> tokenList = TokensList.get();
    InstanceID iid = InstanceID.getInstance(this);
    for(tokenItem : tokenList) {
      tokenItem.token =
        iid.getToken(tokenItem.authorizedEntity,tokenItem.scope,tokenItem.options);
      // send this tokenItem.token to your server
    }
  }
};

```
Lastly register the service in your AndroidManifest:
```xml
<service android:name=".MyInstanceIDService" android:exported="false">
  <intent-filter>
        <action android:name="com.google.android.gms.iid.InstanceID"/>
  </intent-filter>
</service>
```

When you submit the iid and the tokens to your server as well, you can use that server together with the Instance ID Cloud Service to validate the tokens and the iid. When the iid or token seems invalid, then you can trigger a safeguard procedure (e.g. inform server on possible copying, possible security issues, etc. or removing the data from the app and ask for a re-registration).

Please note that Firebase has support for InstanceID as well <sup>[4]</sup>.
-- TODO [SHOULD WE ADD THE SERVER CODE HERE TOO TO EXPLAIN HOW TOKENS CAN BE USED TO EVALUATE?] --

##### IMEI & Serial

Please note that Google recommends against using these identifiers unless there is a high risk involved with the application in general.

For pre-Android O devices, you can request the serial as follows:

```java
   String serial = android.os.Build.SERIAL;
```

From Android O onwards, you can request the device its serial as follows:

1. Set the permission in your Android Manifest:
```xml
  <uses-permission android:name="android.permission.READ_PHONE_STATE"/>
  <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```
2. Request the permission at runtime to the user: See https://developer.android.com/training/permissions/requesting.html for more details.
3. Get the serial:

```java
  String serial = android.os.Build.getSerial();
```

Retrieving the IMEI in Android works as follows:

1. Set the required permission in your Android Manifest:
```xml
  <uses-permission android:name="android.permission.READ_PHONE_STATE"/>
```

2. If on Android M or higher: request the permission at runtime to the user: See https://developer.android.com/training/permissions/requesting.html for more details.

3. Get the IMEI:
```java
  TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
  String IMEI = tm.getDeviceId();
```

##### SSAID

Please note that Google recommends against using these identifiers unless there is a high risk involved with the application in general. you can retrieve the SSAID as follows:

```java
  String SSAID = Settings.Secure.ANDROID_ID;
```
#### Effectiveness Assessment

When the source-code is available, then there are a few codes you can look for, such as:
- The presence of unique identifiers that no longer work in the future
  - `Build.SERIAL` without the presence of `Build.getSerial()`
  - `htc.camera.sensor.front_SN` for HTC devices
  - `persist.service.bdroid.bdadd`
  - `Settings.Secure.bluetooth_address`, unless the system permission LOCAL_MAC_ADDRESS is enabled in the manifest.

- The presence of using the ANDROID_ID only as an identifier. This will influence the possible binding quality over time given older devices.
- The absence of both InstanceID, the `Build.SERIAL` and the IMEI.

```java
  TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
  String IMEI = tm.getDeviceId();
```

Furthermore, to reassure that the identifiers can be used, the AndroidManifest.xml needs to be checked in case of using the IMEI and the Build.Serial. It should contain the following permission: `<uses-permission android:name="android.permission.READ_PHONE_STATE"/>`.

There are a few ways to test the application binding:

##### Dynamic Analysis using an Emulator

1. Run the application on an Emulator
2. Make sure you can raise the trust in the instance of the application (e.g. authenticate)
3. Retrieve the data from the Emulator This has a few steps:
- ssh to your simulator using ADB shell
- run-as <your app-id (which is the package as described in the AndroidManifest.xml)>
- chmod 777 the contents of cache and shared-preferences
- exit the current user
- copy the contents of /dat/data/<your appid>/cache & shared-preferences to the sdcard
- use ADB or the DDMS to pull the contents
4. Install the application on another Emulator
5. Overwrite the data from step 3 in the data folder of the application.
- copy the contents of step 3 to the sdcard of the second emulator.
- ssh to your simulator using ADB shell
- run-as <your app-id (which is the pacakge as described in the AndroidManifest.xml)>
- chmod 777 the folders cache and shared-preferences
- copy the older contents of the sdcard to /dat/data/<your appid>/cache & shared-preferences
6. Can you continue in an authenticated state? If so, then binding might not be working properly.

##### Dynamic Analysis using two different rooted devices.

1. Run the application on your rooted device
2. Make sure you can raise the trust in the instance of the application (e.g. authenticate)
3. Retrieve the data from the first rooted device
4. Install the application on the second rooted device
5. Overwrite the data from step 3 in the data folder of the application.
6. Can you continue in an authenticated state? If so, then binding might not be working properly.

#### Remediation

The behavior of the SSAID has changed since Android O and the behavior of MAC addresses have changed in Android N <code>[1]</code>. Google has set a new set of recommendations in their SDK documentation regarding identifiers as well <code>[2]</code>. Because of this new behavior, we recommend developers to no relie on the SSAID alone, as the identifier has become less stable. For instance: The SSAID might change upon a factory reset or when the app is reinstalled after the upgrade to Android O. Please note that there are amounts of devices which have the same ANDROID_ID and/or have an ANDROID_ID that can be overriden.
Next, the Build.Serial was often used. Now, apps targetting Android O will get "UNKNOWN" when they request the Build.Serial.
Before we describe the usable identifiers, let's quickly discuss how they can be used for binding. There are 3 methods which allow for device binding:

- augment the credentials used for authentication with device identifiers. This can only make sense if the application needs to re-authenticate itself and/or the user frequently.
- obfuscate the data stored on the device using device-identifiers as keys for encryption methods. This can help in binding to a device when a lot of offline work is done by the app or when access to APIs depends on access-tokens stored by the application.
- Use a token based device authentication (InstanceID) to reassure that the same instance of the app is used.

The following 3 identifiers can be possibly used.

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

- V8.10: "The app implements a 'device binding' functionality using a device fingerprint derived from multiple properties unique to the device."

##### CWE

N/A

##### Info
- [1] Changes in the Android device identifiers - https://android-developers.googleblog.com/2017/04/changes-to-device-identifiers-in.html
- [2] Developer Android documentation - https://developer.android.com/training/articles/user-data-ids.html
- [3] Documentation on requesting runtime permissions - https://developer.android.com/training/permissions/requesting.html
- [4] Firebase InstanceID documentation - https://firebase.google.com/docs/reference/android/com/google/firebase/iid/FirebaseInstanceId
- [5] Google InstanceID documentation - https://developers.google.com/instance-id/

##### Tools

* ADB & DDMS
* Android Emulator or 2 rooted devices.

### Testing Obfuscation

#### Overview

-- TODO [Add content for overview on "Testing Obfuscation"] --

##### Simple Tricks

- Modifying the DEX file so static analysis tools can't load it;
- Using dynamic class loading and reflection to obfuscated the control flow;
- Pack or encrypt portions of the code and/or data;
- Frequently jumping between Java and native code.

![Identifier Renaming with ProGuard](Images/Chapters/0x05j/proguard.jpg)
*Identifier renaming with ProGuard.*

#### Effectiveness Assessment

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of sentence "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>." ] --

-- TODO [Add content on "Testing Obfuscation" without source code] --

-- TODO [Dumping process memory] --

```python
#! /usr/bin/env python
import re
import sys

pid = sys.argv[1]
startaddr = sys.argv[2]
endaddr = sys.argv[3]

mem_file = open("/proc/" + pid + "/mem", 'r', 0)
out_file = open("./" + pid + "_" + startaddr + "-" + endaddr + ".dump", 'w')

start = int(startaddr, 16)
end = int(endaddr, 16)
mem_file.seek(start)
chunk = mem_file.read(end - start)

out_file.write(chunk)

mem_file.close()
out_file.close()
```

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

-- TODO [Update reference "VX.Y" below and description] --
- VX.Y: "Requirement text, e.g. 'the keyboard cache is disabled on text inputs that process sensitive data'."

##### CWE

-- TODO [Add relevant CWE for "Testing Obfuscation"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add links to relevant tools for "Testing Obfuscation"] --
* Enjarify - https://github.com/google/enjarify
