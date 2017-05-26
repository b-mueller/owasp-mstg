## Testing Anti-Reversing Defenses on iOS

### Testing Jailbreak Detection

#### Overview

In the context of reverse engineering defense, jailbreak detection mechansism are added to make it a bit more difficult to run the app on a jailbroken device, which in turn impedes some tools and techniques reverse engineers like to use. As is the case with most other defenses, jailbreak detection is not a very effective defense on its own, but having some checks sprinkled throughout the app can improve the effectiveness of the overall anti-tampering scheme. Typical jailbreak detection techniques on iOS include:

##### File-based Checks

Checking for the existence of files and directories typically associated with jailbreaks, such as:

~~~
/Applications/Cydia.app
/Applications/FakeCarrier.app
/Applications/Icy.app
/Applications/IntelliScreen.app
/Applications/MxTube.app
/Applications/RockApp.app
/Applications/SBSettings.app
/Applications/WinterBoard.app
/Applications/blackra1n.app
/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist
/Library/MobileSubstrate/DynamicLibraries/Veency.plist
/Library/MobileSubstrate/MobileSubstrate.dylib
/System/Library/LaunchDaemons/com.ikey.bbot.plist
/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist
/bin/bash
/bin/sh
/etc/apt
/etc/ssh/sshd_config
/private/var/lib/apt
/private/var/lib/cydia
/private/var/mobile/Library/SBSettings/Themes
/private/var/stash
/private/var/tmp/cydia.log
/usr/bin/sshd
/usr/libexec/sftp-server
/usr/libexec/ssh-keysign
/usr/sbin/sshd
/var/cache/apt
/var/lib/apt
/var/lib/cydia
/var/log/syslog
/var/tmp/cydia.log
~~~

##### Checking File Permissions

Attempting to write a file to the /private/ directory. This should only be successful on jailbroken devices.

~~~

NSError *error;
NSString *stringToBeWritten = @"This is a test.";
[stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES
         encoding:NSUTF8StringEncoding error:&error];
if(error==nil){
   //Device is jailbroken
   return YES;
 } else {
   //Device is not jailbroken
   [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
 }

~~~

##### Checking Protocol Handlers

Attempting to open a Cydia URL. The Cydia app store, which is installed by default by practically every jailbreaking tool, installs the cydia:// protocol handler. 

~~~
if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]]){
~~~

##### Calling System APIs 

-- TODO [Fork-based check] --

Executing privileged actions. Calling the system() function with a NULL argument on a non jailbroken device will return ”0”; doing the same on a jailbroken device will return ”1”. This is since the function will check whether /bin/sh can be accessed, and this is only the case on jailbroken devices. Another possibility would be trying to write into a location outside the application’s sandbox. This can be done by having the application attempt to create a file in, for example, the /private directory. If the file is successfully created, it means the device is jailbroken.'

##### Using the Dynamic Loader

-- TODO [dyld-based check] --

##### SSH Loopback Connection

-- TODO [Connect to localhost:22] --

#### Bypassing Jailbreak Detection

Once you start the application, which has jailbreak detection enabled on a jailbroken device, you will notice one of the following:

1. The application closes immediately without any notification
2. There is a popup window indicating that the application won't run on a jailbroken device

In the first case, it's worth checking if the application is fully functional on non-jailbroken device. It might be that the application is in reality crashing or has a bug that causes exiting. This might happen when you're testing a preproduction version of the application.

Let's look on how to bypass jailbreak detection using once again Damn Vulnerable iOS application as an example. 
After loading the binary into Hopper, you need to wait until the application is fully disassembled (look at the top bar). Then we can look for 'jail' string in the search box. We see two different classes, which are `SFAntiPiracy` and `JailbreakDetectionVC`.
You might also want to decompile the functions to see what they are doing and especially what do they return.

![Disassembling with Hopper](Images/Chapters/0x06b/HopperDisassembling.png "Disassembling with Hopper")
![Decompiling with Hopper](Images/Chapters/0x06b/HopperDecompile.png "Decompiling with Hopper")

As you can see, there is a class method `+[SFAntiPiracy isTheDeviceJailbroken]` and instance method `-[JailbreakDetectionVC isJailbroken]`. The main difference for us is that we can inject cycript and call class method directly, whereas when it comes to instance method, we must first look for instances of target class. The function `choose` will look for the memory heap for known signature of a given class and return an array of instances that were found. It's important to put an application into a desired state, so that the class is indeed instantiated. 

Let's inject cycript into our process (look for your PID with `top`):

```
iOS8-jailbreak:~ root# cycript -p 12345
cy# [SFAntiPiracy isTheDeviceJailbroken]
true
```

As you can see our class method was called directly and returned true. Now, let's call `-[JailbreakDetectionVC isJailbroken]` instance method. First, we have to call `choose` function to look for instances of `JailbreakDetectionVC` class. 

```
cy# a=choose(JailbreakDetectionVC)
[]
```

Ooops! The returned array is empty. It means that there are no instances of this class registed within the runtime. In fact, we haven't clicked second 'Jailbreak Test' button, which indeed initializes this class:

```
cy# a=choose(JailbreakDetectionVC)
[#"<JailbreakDetectionVC: 0x14ee15620>"]
cy# [a[0] isJailbroken]
True
```

![The device is jailbroken](Images/Chapters/0x06j/deviceISjailbroken.png "The device is jailbroken")

Hence you now understand why it's important to have your application in a desired state. 
Now bypassing jailbreak detection in this case with cycript is trivial. We can see that the function returns Boolean and we just need to replace the return value. We can do it by replacing function implementation with cycript. Please note that this will actually replace function under given name, so beware of side effects in case if the function modifies anything in the application:

```
cy# JailbreakDetectionVC.prototype.isJailbroken=function(){return false}
cy# [a[0] isJailbroken]
false
```

![The device is NOT jailbroken](Images/Chapters/0x06j/deviceisNOTjailbroken.png "The device is NOT jailbroken")
In this case we have bypassed Jailbreak detection of the application!

Now, imagine that the application is closing immediately upon detecting that the device is jailbroken. In this case you have no chance (time) to launch cycript and replace function implementation. Instead, you would have to use CydiaSubstrate, use proper hooking function, like `MSHookMessageEx` and compile the tweak. There are good sources on how to perform this [15-16], however, we will provide possibly faster and more flexible approach.

**Frida** is a dynamic instrumentation framework, which allows you to use among other a JavaScript API to instrument the apps. One feature that we will use in bypassing jailbreak detection is to perform so-called early instrumentation, i.e. replace function implementation on startup.

1. First, ensure that `frida-server` is running on your iDevice
2. iDevice must be connected via USB cable
3. Use `frida-trace` on your workstation:

```
$ frida-trace -U -f /Applications/DamnVulnerableIOSApp.app/DamnVulnerableIOSApp  -m "-[JailbreakDetectionVC isJailbroken]"
```

This will actually start DamnVulnerableIOSApp, trace calls to `-[JailbreakDetectionVC isJailbroken]` and create JS hook with `onEnter` and `onLeave` callback functions. Now it's trivial to replace return value with `value.replace()` as shown in the example below:

```
    onLeave: function (log, retval, state) {
    console.log("Function [JailbreakDetectionVC isJailbroken] originally returned:"+ retval);
    retval.replace(0);  
      console.log("Changing the return value to:"+retval);
    }
```

Running this will have the following result:

```
$ frida-trace -U -f /Applications/DamnVulnerableIOSApp.app/DamnVulnerableIOSApp  -m "-[JailbreakDetectionVC isJailbroken]:"

Instrumenting functions...                                           `...
-[JailbreakDetectionVC isJailbroken]: Loaded handler at "./__handlers__/__JailbreakDetectionVC_isJailbroken_.js"
Started tracing 1 function. Press Ctrl+C to stop.                       
Function [JailbreakDetectionVC isJailbroken] originally returned:0x1
Changing the return value to:0x0
           /* TID 0x303 */
  6890 ms  -[JailbreakDetectionVC isJailbroken]
Function [JailbreakDetectionVC isJailbroken] originally returned:0x1
Changing the return value to:0x0
 22475 ms  -[JailbreakDetectionVC isJailbroken]
 ```
 
Please note that there were two calls to `-[JailbreakDetectionVC isJailbroken]`, which corresponds to two physical taps on the app GUI.
 
Frida is a very powerful and versatile tool. Refer to the documentation [3] to get more details.

-- TODO [a generic Frida script that catches many JB detection methods] --

Hooking Objective-C methods and native functions:

~~~~python
import frida
import sys

try:
	session = frida.get_usb_device().attach("Target Process")
except frida.ProcessNotFoundError:
	print "Failed to attach to the target process. Did you launch the app?"
	sys.exit(0);

script = session.create_script("""

	// Handle fork() based check

  var fork = Module.findExportByName("libsystem_c.dylib", "fork");

	Interceptor.replace(fork, new NativeCallback(function () {
		send("Intercepted call to fork().");
	    return -1;
	}, 'int', []));

  var system = Module.findExportByName("libsystem_c.dylib", "system");

	Interceptor.replace(system, new NativeCallback(function () {
		send("Intercepted call to system().");
	    return 0;
	}, 'int', []));

	// Intercept checks for Cydia URL handler

	var canOpenURL = ObjC.classes.UIApplication["- canOpenURL:"];

	Interceptor.attach(canOpenURL.implementation, {
		onEnter: function(args) {
		  var url = ObjC.Object(args[2]);
		  send("[UIApplication canOpenURL:] " + path.toString());
		  },
		onLeave: function(retval) {
			send ("canOpenURL returned: " + retval);
	  	}

	});		

	// Intercept file existence checks via [NSFileManager fileExistsAtPath:]

	var fileExistsAtPath = ObjC.classes.NSFileManager["- fileExistsAtPath:"];
	var hideFile = 0;

	Interceptor.attach(fileExistsAtPath.implementation, {
		onEnter: function(args) {
		  var path = ObjC.Object(args[2]);
		  // send("[NSFileManager fileExistsAtPath:] " + path.toString());

		  if (path.toString() == "/Applications/Cydia.app" || path.toString() == "/bin/bash") {
		  	hideFile = 1;
		  }
		},
		onLeave: function(retval) {
			if (hideFile) {
		  		send("Hiding jailbreak file...");MM
				retval.replace(0);
				hideFile = 0;
			}

			// send("fileExistsAtPath returned: " + retval);
	  }
	});


	/* If the above doesn't work, you might want to hook low level file APIs as well

		var openat = Module.findExportByName("libsystem_c.dylib", "openat");
		var stat = Module.findExportByName("libsystem_c.dylib", "stat");
		var fopen = Module.findExportByName("libsystem_c.dylib", "fopen");
		var open = Module.findExportByName("libsystem_c.dylib", "open");
		var faccesset = Module.findExportByName("libsystem_kernel.dylib", "faccessat");

	*/

""")

def on_message(message, data):
	if 'payload' in message:
	  		print(message['payload'])

script.on('message', on_message)
script.load()
sys.stdin.read()
~~~~


#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of remark "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

##### With Source Code

-- TODO [Add content for static analysis of "Testing Jailbreak Detection" with source code] --

##### Without Source Code

-- TODO [Add content for static analysis of "Testing Jailbreak Detection" without source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing Jailbreak Detection" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Jailbreak Detection".] --

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

-- TODO [Update reference to "VX.Y" below for "Testing Jailbreak Detection"] --
- VX.Y: "Requirement text, e.g. 'the keyboard cache is disabled on text inputs that process sensitive data'."

##### CWE

-- TODO [Add relevant CWE for "Testing Jailbreak Detection"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] - Jailbreak Detection Methods on the Trustware Spiderlabs Blog - https://www.trustwave.com/Resources/SpiderLabs-Blog/Jailbreak-Detection-Methods/
- [2] - Dana Geist, Marat Nigmatullin: Jailbreak/Root Detection Evasion Study on iOS and Android - http://delaat.net/rp/2015-2016/p51/report.pdf
- [3] - http://frida.re/

##### Tools

-- TODO [Add relevant tools for "Testing Jailbreak Detection"] --
* Enjarify - https://github.com/google/enjarify

### Testing Anti-Debugging

#### Overview

Debugging is a highly effective way of analyzing the runtime behaviour of an app. It allows the reverse engineer to step through the code, stop execution of the app at arbitrary point, inspect and modify the state of variables, and a lot more.

-- TODO [Typical debugging defenses] --


Detecting Mach Exception Ports <sup>[1]</sup>:

~~~c
#include <mach/task.h>
#include <mach/mach_init.h>
#include <stdbool.h>

static bool amIAnInferior(void)
{
	mach_msg_type_number_t count = 0;
	exception_mask_t masks[EXC_TYPES_COUNT];
	mach_port_t ports[EXC_TYPES_COUNT];
	exception_behavior_t behaviors[EXC_TYPES_COUNT];
	thread_state_flavor_t flavors[EXC_TYPES_COUNT];
	exception_mask_t mask = EXC_MASK_ALL & ~(EXC_MASK_RESOURCE | EXC_MASK_GUARD);

	kern_return_t result = task_get_exception_ports(mach_task_self(), mask, masks, &count, ports, behaviors, flavors);
	if (result == KERN_SUCCESS)
	{
		for (mach_msg_type_number_t portIndex = 0; portIndex < count; portIndex++)
		{
			if (MACH_PORT_VALID(ports[portIndex]))
			{
				return true;
			}
		}
	}
	return false;
}
~~~


Disabling <code>ptrace()</code>.

~~~c
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);

#define PT_DENY_ATTACH 31

void disable_ptrace() {
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}
~~~

~~~c
void disable_ptrace() {

	asm(
		"mov	r0, #31\n\t"	// PT_DENY_ATTACH
		"mov	r1, #0\n\t"
		"mov	r2, #0\n\t"
		"mov 	ip, #26\n\t"	// syscall no.
		"svc    0\n"
	);
}
~~~


~~~c
- (void)protectAgainstPtrace {
    int                 junk;
    int                 mib[4];
    struct kinfo_proc   info;
    size_t              size;
    
    info.kp_proc.p_flag = 0;
    
    // Initialize mib, which tells sysctl the info we want, in this case
    // we're looking for information about a specific process ID.
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    

    while(1) {
     
        size = sizeof(info);
        junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
        assert(junk == 0);

        // We're being debugged if the P_TRACED flag is set.
        
        if ((info.kp_proc.p_flag & P_TRACED) != 0) {
            exit(0);
        }
        
        sleep(1);
        
    }
}
~~~

The app should either actively prevent debuggers from attaching, or terminate when a debugger is detected.

#### Bypassing Anti-Debugging Defenses

-- TODO [Bypass techniques] --

~~~c
#import <substrate.h>

#define PT_DENY_ATTACH 31

static int (*_my_ptrace)(int request, pid_t pid, caddr_t addr, int data);


static int $_my_ptrace(int request, pid_t pid, caddr_t addr, int data) {
	if (request == PT_DENY_ATTACH) {
		request = -1;
	}
	return _ptraceHook(request,pid,addr,data);
}

%ctor {
	MSHookFunction((void *)MSFindSymbol(NULL,"_ptrace"), (void *)$ptraceHook, (void **)&_ptraceHook);
}
~~~

#### White-box Testing

-- TODO [Describe how to assess this with access to the source code and build configuration] --

#### Black-box Testing

-- TODO [Needs more detail] --

Attach a debugger to the running process. This  should either fail, or the app should terminate or misbehave when the debugger has been detected. For example, if ptrace(PT_DENY_ATTACH) has been called, gdb will crash with a segmentation fault:

Note that some anti-debugging implementations respond in a stealthy way so that changes in behaviour are not immediately apparent. For example, a soft token app might not visibly respond when a debugger is detected, but instead secretly alter the state of an internal variable so that an incorrect OTP is generated at a later point. Make sure to run through the complete workflow to determine if attaching the debugger causes a crash or malfunction.

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Anti-Debugging"] --

#### References

##### OWASP Mobile Top 10 2014

-- TODO [Add link to OWASP Mobile Top 10 2014 for "Testing Anti-Debugging"] --

##### OWASP MASVS

- V...: ""

##### CWE

-- TODO [Add relevant CWE for "Testing Anti-Debugging"] --

##### Info

- [1] Detecting the Debugger on OS X - https://zgcoder.net/ramblings/osx-debugger-detection

##### Tools

-- TODO [Add tools for "Testing Anti-Debugging"] --


### Testing File Integrity Checks

#### Overview

-- TODO [Implementation from UnCrackable2] --

```c
int xyz(char *dst) {
    const struct mach_header * header;
    Dl_info dlinfo;

    if (dladdr(xyz, &dlinfo) == 0 || dlinfo.dli_fbase == NULL) {
        NSLog(@" Error: Could not resolve symbol xyz");
        [NSThread exit];
    }

    while(1) {
    
        header = dlinfo.dli_fbase;  // Pointer on the Mach-O header
        struct load_command * cmd = (struct load_command *)(header + 1); // First load command
        // Now iterate through load command
        //to find __text section of __TEXT segment
        for (uint32_t i = 0; cmd != NULL && i < header->ncmds; i++) {
            if (cmd->cmd == LC_SEGMENT) {
                // __TEXT load command is a LC_SEGMENT load command
                struct segment_command * segment = (struct segment_command *)cmd;
                if (!strcmp(segment->segname, "__TEXT")) {
                    // Stop on __TEXT segment load command and go through sections
                    // to find __text section
                    struct section * section = (struct section *)(segment + 1);
                    for (uint32_t j = 0; section != NULL && j < segment->nsects; j++) {
                        if (!strcmp(section->sectname, "__text"))
                            break; //Stop on __text section load command
                        section = (struct section *)(section + 1);
                    }
                    // Get here the __text section address, the __text section size
                    // and the virtual memory address so we can calculate
                    // a pointer on the __text section
                    uint32_t * textSectionAddr = (uint32_t *)section->addr;
                    uint32_t textSectionSize = section->size;
                    uint32_t * vmaddr = segment->vmaddr;
                    char * textSectionPtr = (char *)((int)header + (int)textSectionAddr - (int)vmaddr);
                    // Calculate the signature of the data,
                    // store the result in a string
                    // and compare to the original one
                    unsigned char digest[CC_MD5_DIGEST_LENGTH];
                    CC_MD5(textSectionPtr, textSectionSize, digest);     // calculate the signature
                    for (int i = 0; i < sizeof(digest); i++)             // fill signature
                        sprintf(dst + (2 * i), "%02x", digest[i]);
                
                    // return strcmp(originalSignature, signature) == 0;    // verify signatures match
                    
                    return 0;
                }
            }
            cmd = (struct load_command *)((uint8_t *)cmd + cmd->cmdsize);
        }
    }
    
}
```

#### Bypassing File Integrity Checks

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

##### With Source Code

-- TODO [Add content for "Testing File Integrity Checks" with source-code] --

##### Without Source Code

-- TODO [Add content for "Testing File Integrity Checks" without source-code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing File Integrity Checks" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing File Integrity Checks".] --

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

-- TODO [Update reference below "VX.Y" for "Testing File Integrity Checks"] --
- VX.Y: "Requirement text, e.g. 'the keyboard cache is disabled on text inputs that process sensitive data'."

##### CWE

-- TODO [Add relevant CWE for "Testing File Integrity Checks"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] Android Cracking Blog - http://androidcracking.blogspot.com/2011/06/anti-tampering-with-crc-check.html
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add relevant tools for "Testing File Integrity Checks"] --
* Enjarify - https://github.com/google/enjarify

### Testing Detection of Reverse Engineering Tools

#### Overview

-- TODO [Provide a general description of the issue "Testing Detection of Reverse Engineering Tools".] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

##### With Source Code

-- TODO [Add content of static analysis of "Testing Detection of Reverse Engineering Tools" with source code] --

##### Without Source Code

-- TODO [Add content of static analysis of "Testing Detection of Reverse Engineering Tools" without source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing Detection of Reverse Engineering Tools" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Detection of Reverse Engineering Tools".] --

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

-- TODO [Update reference below "VX.Y" for "Testing Detection of Reverse Engineering Tools"] --
- VX.Y: "Requirement text, e.g. 'the keyboard cache is disabled on text inputs that process sensitive data'."

##### CWE

-- TODO [Add relevant CWE for "Testing Detection of Reverse Engineering Tools"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add relevant tools for "Testing Detection of Reverse Engineering Tools"] --
* Enjarify - https://github.com/google/enjarify

### Testing Runtime Integrity Checks

#### Overview

-- TODO [Provide a general description of the issue "Testing Memory Integrity Checks".] --

#### Examples

**Detecting Substrate Inline Hooks***

Inline hooks are implemented by overwriting the first few bytes of a function with a trampoline that redirects control flow to adversary-controlled code. They can be detected by scanning the function prologue of each function for unusual and telling instructions. For example, substrate 


inline int checkSubstrateTrampoline() attribute((always_inline));
int checkSubstrateTrampoline(void * funcptr) {
 
    unsigned int *funcaddr = (unsigned int *)funcptr;
 
    if(funcptr)
        // assuming the first word is the trampoline 
        if (funcaddr[0] == 0xe51ff004) // 0xe51ff004 = ldr pc, [pc-4]
            return 1; // bad
 
    return 0; // good
}
Example code from the Netitude blog <code>[2]</code>.

#### Effectiveness Assessment

-- TODO [Describe how to test for this issue "Testing Memory Integrity Checks" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Memory Integrity Checks".] --

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

-- TODO [Update reference below "VX.Y" for "Testing Memory Integrity Checks"] --
- VX.Y: "Requirement text, e.g. 'the keyboard cache is disabled on text inputs that process sensitive data'."

##### CWE

-- TODO [Add relevant CWE for "Testing Memory Integrity Checks"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add relevant tools for "Testing Memory Integrity Checks"] --
* Enjarify - https://github.com/google/enjarify

### Testing Device Binding

#### Overview

-- TODO [Provide a general description of the issue "Testing Device Binding".] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of remark "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

##### With Source Code

-- TODO [Add content for static analysis of "Testing Device Binding" with source code] --

##### Without Source Code

-- TODO [Add content for static analysis of "Testing Device Binding" without source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing Device Binding" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Device Binding".] --

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

-- TODO [Update reference "VX.Y" below for "Testing Device Binding"] --
- VX.Y: "Requirement text, e.g. 'the keyboard cache is disabled on text inputs that process sensitive data'."

##### CWE

-- TODO [Add relevant CWE for "Testing Device Binding"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add relevant tools for "Testing Device Binding"] --
* Enjarify - https://github.com/google/enjarify

### Testing Obfuscation

#### Overview

-- TODO [Provide a general description of the issue "Testing Obfuscation".] --

#### Static Analysis

-- TODO [Describe how to assess this given either the source code or installer package (APK/IPA/etc.), but without running the app. Tailor this to the general situation (e.g., in some situations, having the decompiled classes is just as good as having the original source, in others it might make a bigger difference). If required, include a subsection about how to test with or without the original sources.] --

-- TODO [Confirm purpose of remark "Use the &lt;sup&gt; tag to reference external sources, e.g. Meyer's recipe for tomato soup<sup>[1]</sup>."] --

##### With Source Code

-- TODO [Add content for static analysis of "Testing Obfuscation" with source code] --

##### Without Source Code

-- TODO [Add content for static analysis of "Testing Obfuscation" without source code] --

#### Dynamic Analysis

-- TODO [Describe how to test for this issue "Testing Obfuscation" by running and interacting with the app. This can include everything from simply monitoring network traffic or aspects of the app’s behavior to code injection, debugging, instrumentation, etc.] --

#### Remediation

-- TODO [Describe the best practices that developers should follow to prevent this issue "Testing Obfuscation".] --

#### References

##### OWASP Mobile Top 10 2016

* M9 - Reverse Engineering - https://www.owasp.org/index.php/Mobile_Top_10_2016-M9-Reverse_Engineering

##### OWASP MASVS

-- TODO [Update reference "VX.Y" below for "Testing Obfuscation"] --
- VX.Y: "Requirement text, e.g. 'the keyboard cache is disabled on text inputs that process sensitive data'."

##### CWE

-- TODO [Add relevant CWE for "Testing Obfuscation"] --
- CWE-312 - Cleartext Storage of Sensitive Information

##### Info

- [1] Meyer's Recipe for Tomato Soup - http://www.finecooking.com/recipes/meyers-classic-tomato-soup.aspx
- [2] Another Informational Article - http://www.securityfans.com/informational_article.html

##### Tools

-- TODO [Add relevant tools for "Testing Obfuscation"] --
* Enjarify - https://github.com/google/enjarify


