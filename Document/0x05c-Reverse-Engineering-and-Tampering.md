## Tampering and Reverse Engineering on Android

Its openness makes Android a favorable environment for reverse engineers. However, dealing with both Java and native code can make things more complicated at times. In the following chapter, we'll look at some peculiarities of Android reversing and OS-specific tools as processes.

In comparison to "the other" mobile OS, Android offers some big advantages to reverse engineers. Because Android is open source, you can study the source code of the Android Open Source Project (AOSP), modify the OS and its standard tools in any way you want. Even on standard retail devices, it is easily possible to do things like activating developer mode and sideloading apps without jumping through many hoops. From the powerful tools shipping with the SDK, to the wide range of available reverse engineering tools, there's a lot of niceties to make your life easier.

However, there's also a few Android-specific challenges. For example, you'll need to deal with both Java bytecode and native code. Java Native Interface (JNI) is sometimes used on purpose to confuse reverse engineers. Developers sometimes use the native layer to "hide" data and functionality, or may structure their apps such that execution frequently jumps between the two layers. This can complicate things for reverse engineers (to be fair, there might also be legitimate reasons for using JNI, such as improving performance or supporting legacy code).

You'll need a working knowledge about both the Java-based Android environment and the Linux OS and Kernel that forms the basis of Android - or better yet, know all these components inside out. Plus, they need the right toolset to deal with both native code and bytecode running inside the Java virtual machine.

Note that in the following sections we'll use the OWASP Mobile Testing Guide Crackmes <sup>[1]</sup> as examples for demonstrating various reverse engineering techniques, so expect partial and full spoilers. We encourage you to have a crack at the challenges yourself before reading on!

### What You Need

At the very least, you'll need Android Studio <sup>[2]</sup>, which comes with the Android SDK, platform tools and emulator, as well as a manager app for managing the various SDK versions and framework components. With Android Studio, you also get an SDK Manager app that lets you install the Android SDK tools and manage SDKs for various API levels, as well as the emulator and an AVD Manager application to create emulator images. Make sure that the following is installed on your system:

- The newest SDK Tools and SDK Platform-Tools packages. These packages include the Android Debugging Bridge (ADB) client as well as other tools that interface with the Android platform. In general, these tools are backward-compatible, so you need only one version of those installed.

- The Android NDK. This is the Native Development Kit that contains prebuilt toolchains for cross-compiling native code for different architectures.

In addition to the SDK and NDK, you'll also something to make Java bytecode more human-friendly. Fortunately, Java decompilers generally deal well with Android bytecode. Popular free decompilers include JD <sup>[3]</sup>, Jad <sup>[4]</sup>, Proycon <sup>[5]</sup> and CFR <sup>[6]</sup>. For convenience, we have packed some of these decompilers into our <code>apkx</code> wrapper script <sup>[7]</sup>. This script completely automates the process of extracting Java code from release APK files and makes it easy to experiment with different backends (we'll also use it in some of the examples below).

Other than that, it's really a matter of preference and budget. A ton of free and commercial disassemblers, decompilers, and frameworks with different strengths and weaknesses exist - we'll cover some of them below.

#### Setting up the Android SDK

Local Android SDK installations are managed through Android Studio. Create an empty project in Android Studio and select "Tools->Android->SDK Manager" to open the SDK Manager GUI. The "SDK Platforms" tab lets you install SDKs for multiple API levels. Recent API levels are:

- API 21: Android 5.0
- API 22: Android 5.1
- API 23: Android 6.0
- API 24: Android 7.0
- API 25: Android 7.1
- API 26: Android O Developer Preview

<img src="Images/Chapters/0x05c/sdk_manager.jpg" width="500px"/>

Depending on your OS, installed SDKs are found at the following location:

```
Windows:

C:\Users\<username>\AppData\Local\Android\sdk

MacOS:

/Users/<username>/Library/Android/sdk
```

Note: On Linux, you'll need pick your own SDK location. Common locations are <code>/opt</code>, <code>/srv</code>, and <code>/usr/local</code>.

#### Setting up the Android NDK

The Android NDK contains prebuilt versions of the native compiler and toolchain. Traditionally, both the GCC and Clang compilers were supported, but active support for GCC ended with revision 14 of the NDK. What's the right version to use depends on both the device architecture and host OS. The prebuilt toolchains are located in the <code>toolchains</code>directory of the NDK, which contains one subdirectory per architecture.

|Architecture | Toolchain name|
|------------ | --------------|
|ARM-based|arm-linux-androideabi-&lt;gcc-version&gt;|
|x86-based|x86-&lt;gcc-version&gt;|
|MIPS-based|mipsel-linux-android-&lt;gcc-version&gt;|
|ARM64-based|aarch64-linux-android-&lt;gcc-version&gt;|
|X86-64-based|x86_64-&lt;gcc-version&gt;|
|MIPS64-based|mips64el-linux-android-&lt;gcc-version&gt;|

In addition to the picking the right architecture, you need to specify the correct sysroot for the native API level you want to target. The sysroot is a directory that contains the system headers and libraries for your target. Available native APIs vary by Android API level. Possible sysroots for respective Android API levels reside under <code>$NDK/platforms/</code>, each API-level directory contains subdirectories for the various CPUs and architectures.

One possibility to set up the build system is exporting the compiler path and necessary flags as environment variables. To make things easier however, the NDK allows you to create a so-called standalone toolchain - a "temporary" toolchain that incorporates the required settings.

To set up a standalone toolchain, download the latest stable version of the NDK <sup>[8]</sup>. Extract the ZIP file, change into the NDK root directory and run the following command:


```bash
$ ./build/tools/make_standalone_toolchain.py --arch arm --api 24 --install-dir /tmp/android-7-toolchain
```

This creates a standalone toolchain for Android 7.0 in the directory <code>/tmp/android-7-toolchain</code>. For convenience, you can export an environment variable that points to your toolchain directory - we'll be using this in the examples later. Run the following command, or add it to your <code>.bash_profile</code> or other startup script.

```bash
$  export TOOLCHAIN=/tmp/android-7-toolchain
```

### Building a Reverse Engineering Environment For Free

With a little effort you can build a reasonable GUI-powered reverse engineering environment for free.

For navigating the decompiled sources we recommend using IntelliJ <sup>[9]</sup>, a relatively light-weight IDE that works great for browsing code and allows for basic on-device debugging of the decompiled apps. However, if you prefer something that's clunky, slow and complicated to use, Eclipse <sup>[10]</sup> is the right IDE for you (note: This piece of advice is based on the author's personal bias).

If you don’t mind looking at Smali instead of Java code, you can use the smalidea plugin for IntelliJ for debugging on the device <sup>[11]</sup>. Smalidea supports single-stepping through the bytecode, identifier renaming and watches for non-named registers, which makes it much more powerful than a JD + IntelliJ setup.

APKTool <sup>[12]</sup> is a popular free tool that can extract and disassemble resources directly from the APK archive and disassemble Java bytecode to Smali format (Smali/Baksmali is an assembler/disassembler for the Dex format. It's also Icelandic for "Assembler/Disassembler"). APKTool allows you to reassemble the package, which is useful for patching and applying changes to the Manifest.

More elaborate tasks such as program analysis and automated de-obfuscation can be achieved with open source reverse engineering frameworks such as Radare2 <sup>[13]</sup> and Angr <sup>[14]</sup>. You'll find usage examples for many of these free tools and frameworks throughout the guide.

#### Commercial Tools

Even though it is possible to work with a completely free setup, you might want to consider investing in commercial tools. The main advantage of these tools is convenience: They come with a nice GUI, lots of automation, and end user support. If you earn your daily bread as a reverse engineer, this will save you a lot of time.

##### JEB

JEB <sup>[15]</sup>, a commercial decompiler, packs all the functionality needed for static and dynamic analysis of Android apps into an all-in-one package, is reasonably reliable and you get quick support. It has a built-in debugger, which allows for an efficient workflow – setting breakpoints directly in the decompiled (and annotated sources) is invaluable, especially when dealing with ProGuard-obfuscated bytecode. Of course convenience like this doesn’t come cheap - and since version 2.0 JEB has changed from a traditional licensing model to a subscription-based one, so you'll need to pay a monthly fee to use it.

##### IDA Pro

IDA Pro <sup>[16]</sup> understands ARM, MIPS and of course Intel ELF binaries, plus it can deal with Java bytecode. It also comes with debuggers for both Java applications and native processes. With its capable disassembler and powerful scripting and extension capabilities, IDA Pro works great for static analysis of native programs and libraries. However, the static analysis facilities it offers for Java code are somewhat basic – you get the Smali disassembly but not much more. There’s no navigating the package and class structure, and some things (such as renaming classes) can’t be done which can make working with more complex Java apps a bit tedious.

### Reverse Engineering

Reverse engineering is the process of taking an app apart to find out how it works. You can do this by examining the compiled app (static analysis), observing the app during runtime (dynamic analysis), or a combination of both.

#### Statically Analyzing Java Code

Unless some nasty, tool-breaking anti-decompilation tricks have been applied, Java bytecode can be converted back into source code without too many problems. We'll be using UnCrackable App for Android Level 1 in the following examples, so download it if you haven't already. First, let's install the app on a device or emulator and run it to see what the crackme is about.

```
$ wget https://github.com/OWASP/owasp-mstg/raw/master/Crackmes/Android/Level_01/UnCrackable-Level1.apk
$ adb install UnCrackable-Level1.apk
```

<!-- <img src="Images/Chapters/0x05c/crackme-1.jpg" align="left" width="45%"/> -->
<img src="Images/Chapters/0x05c/crackme-2.jpg" width="350px"/>


Seems like we're expected to find some kind of secret code!

Most likely, we're looking for a secret string stored somewhere inside the app, so the next logical step is to take a look inside. First, unzip the APK file and have a look at the content.

```
$ unzip UnCrackable-Level1.apk -d UnCrackable-Level1
Archive:  UnCrackable-Level1.apk
  inflating: UnCrackable-Level1/AndroidManifest.xml  
  inflating: UnCrackable-Level1/res/layout/activity_main.xml  
  inflating: UnCrackable-Level1/res/menu/menu_main.xml  
 extracting: UnCrackable-Level1/res/mipmap-hdpi-v4/ic_launcher.png  
 extracting: UnCrackable-Level1/res/mipmap-mdpi-v4/ic_launcher.png  
 extracting: UnCrackable-Level1/res/mipmap-xhdpi-v4/ic_launcher.png  
 extracting: UnCrackable-Level1/res/mipmap-xxhdpi-v4/ic_launcher.png  
 extracting: UnCrackable-Level1/res/mipmap-xxxhdpi-v4/ic_launcher.png  
 extracting: UnCrackable-Level1/resources.arsc  
  inflating: UnCrackable-Level1/classes.dex  
  inflating: UnCrackable-Level1/META-INF/MANIFEST.MF  
  inflating: UnCrackable-Level1/META-INF/CERT.SF  
  inflating: UnCrackable-Level1/META-INF/CERT.RSA  

```

In the standard case, all the Java bytecode and data related to the app is contained in a file named <code>classes.dex</code> in the app root directory. This file adheres to the Dalvik Executable Format (DEX), an Android-specific way of packaging Java programs. Most Java decompilers expect plain class files or JARs as input, so you need to convert the classes.dex file into a JAR first. This can be done using <code>dex2jar</code> or <code>enjarify</code>.

Once you have a JAR file, you can use any number of free decompilers to produce Java code. In this example, we'll use CFR as our decompiler of choice. CFR is under active development, and brand-new releases are made available regularly on the author's website <sup>[6]</sup>. Conveniently, CFR has been released under a MIT license, which means that it can be used freely for any purposes, even though its source code is not currently available.

The easiest way to run CFR is through <code>apkx</code>, which also packages <code>dex2jar</code> and automates the extracting, conversion and decompilation steps. Install it as follows:

```
$ git clone https://github.com/b-mueller/apkx
$ cd apkx
$ sudo ./install.sh
```

This should copy <code>apkx</code> to <code>/usr/local/bin</code>. Run it on <code>UnCrackable-Level1.apk</code>:

```bash
$ apkx UnCrackable-Level1.apk
Extracting UnCrackable-Level1.apk to UnCrackable-Level1
Converting: classes.dex -> classes.jar (dex2jar)
dex2jar UnCrackable-Level1/classes.dex -> UnCrackable-Level1/classes.jar
Decompiling to UnCrackable-Level1/src (cfr)
```

You should now find the decompiled sources in the directory <code>Uncrackable-Level1/src</code>. To view the sources, a simple text editor (preferably with syntax highlighting) is fine, but loading the code into a Java IDE makes navigation easier. Let's import the code into IntelliJ, which also gets us on-device debugging functionality as a bonus.

Open IntelliJ and select "Android" as the project type in the left tab of the "New Project" dialog. Enter "Uncrackable1" as the application name and "vantagepoint.sg" as the company name. This results in the package name "sg.vantagepoint.uncrackable1", which matches the original package name. Using a matching package name is important if you want to attach the debugger to the running app later on, as Intellij uses the package name to identify the correct process.

<img src="Images/Chapters/0x05c/intellij_new_project.jpg" width="650px" />

In the next dialog, pick any API number - we don't want to actually compile the project, so it really doesn't matter. Click "next" and choose "Add no Activity", then click "finish".

Once the project is created, expand the "1: Project" view on the left and navigate to the folder <code>app/src/main/java</code>. Right-click and delete the default package "sg.vantagepoint.uncrackable1" created by IntelliJ.

<img src="Images/Chapters/0x05c/delete_package.jpg" width="400px"/>

Now, open the <code>Uncrackable-Level1/src</code> directory in a file browser and drag the <code>sg</code> directory into the now empty <code>Java</code> folder in the IntelliJ project view (hold the "alt" key to copy the folder instead of moving it).

<img src="Images/Chapters/0x05c/drag_code.jpg" width="700px" />

You'll end up with a structure that resembles the original Android Studio project from which the app was built.

<img src="Images/Chapters/0x05c/final_structure.jpg" width="400px"/>

As soon as IntelliJ is done indexing the code, you can browse it just like any normal Java project. Note that many of the decompiled packages, classes and methods have weird one-letter names... this is because the bytecode has been "minified" with ProGuard at build time. This is a a basic type of obfuscation that makes the bytecode a bit more difficult to read, but with a fairly simple app like this one it won't cause you much of a headache - however, when analyzing a more complex app, it can get quite annoying.

A good practice to follow when analyzing obfuscated code is to annotate names of classes, methods and other identifiers as you go along. Open the <code>MainActivity</code> class in the package <code>sg.vantagepoint.a</code>. The method <code>verify</code> is what's called when you tap on the "verify" button. This method passes the user input to a static method called <code>a.a</code>, which returns a boolean value. It seems plausible that <code>a.a</code> is responsible for verifying whether the text entered by the user is valid or not, so we'll start refactoring the code to reflect this.

![User Input Check](Images/Chapters/0x05c/check_input.jpg)

Right-click the class name - the first <code>a</code> in <code>a.a</code> - and select Refactor->Rename from the drop-down menu (or press Shift-F6). Change the class name to something that makes more sense given what you know about the class so far. For example, you could call it "Validator" (you can always revise the name later as you learn more about the class). <code>a.a</code> now becomes <code>Validator.a</code>. Follow the same procedure to rename the static method <code>a</code> to <code>check_input</code>.

![Refactored class and method names](Images/Chapters/0x05c/refactored.jpg)

Congratulations - you just learned the fundamentals of static analysis! It is all about theorizing, annotating, and gradually revising theories about the analyzed program, until you understand it completely - or at least, well enough for whatever you want to achieve.

Next, ctrl+click (or command+click on Mac) on the <code>check_input</code> method. This takes you to the method definition. The decompiled method looks as follows:

```java
    public static boolean check_input(String string) {
        byte[] arrby = Base64.decode((String)"5UJiFctbmgbDoLXmpL12mkno8HT4Lv8dlat8FxR2GOc=", (int)0);
        byte[] arrby2 = new byte[]{};
        try {
            arrby = sg.vantagepoint.a.a.a(Validator.b("8d127684cbc37c17616d806cf50473cc"), arrby);
            arrby2 = arrby;
        }sa
        catch (Exception exception) {
            Log.d((String)"CodeCheck", (String)("AES error:" + exception.getMessage()));
        }
        if (string.equals(new String(arrby2))) {
            return true;
        }
        return false;
    }
```

So, we have a base64-encoded String that's passed to a function named <code>a</code> in the package <code>sg.vantagepoint.a.a</code> (again everything is called <code>a</code>) along with something that looks suspiciously like a hex-encoded encryption key (16 hex bytes = 128bit, a common key length). What exactly does this particular <code>a</code> do? Ctrl-click it to find out.

```java
public class a {
    public static byte[] a(byte[] object, byte[] arrby) {
        object = new SecretKeySpec((byte[])object, "AES/ECB/PKCS7Padding");
        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(2, (Key)object);
        return cipher.doFinal(arrby);
    }
}
```

Now we are getting somewhere: It's simply standard AES-ECB. Looks like the base64 string stored in <code>arrby1</code> in <code>check_input</code> is a ciphertext, which is decrypted using 128bit AES, and then compared to the user input. As a bonus task, try to decrypt the extracted ciphertext and get the secret value!

An alternative (and faster) way of getting the decrypted string is by adding a bit of dynamic analysis into the mix - we'll revisit UnCrackable Level 1 later to show how to do this, so don't delete the project yet!

#### Statically Analyzing Native Code

Dalvik and ART both support the Java Native Interface (JNI), which defines defines a way for Java code to interact with native code written in C/C++. Just like on other Linux-based operating systes, native code is packaged into ELF dynamic libraries ("*.so"), which are then loaded by the Android app during runtime using the <code>System.load</code> method.

Android JNI functions consist of native code compiled into Linux ELF libraries. It's pretty much standard Linux fare. However, instead of relying on widely used C libraries such as glibc, Android binaries are built against a custom libc named Bionic <sup>[17]</sup>. Bionic adds support for important Android-specific services such as system properties and logging, and is not fully POSIX-compatible.

Download HelloWorld-JNI.apk from the OWASP MSTG repository and, optionally, install and run it on your emulator or Android device.

```bash
$ wget HelloWord-JNI.apk
$ adb install HelloWord-JNI.apk
```

This app is not exactly spectacular: All it does is show a label with the text "Hello from C++". In fact, this is the default app Android generates when you create a new project with C/C++ support - enough however to show the basic principles of how JNI calls work.

<img src="Images/Chapters/0x05c/helloworld.jpg" width="300px" />

Decompile the APK with <code>apkx</code>. This extract the source code into the <code>HelloWorld/src</code> directory.

```bash
$ wget https://github.com/OWASP/owasp-mstg/blob/master/OMTG-Files/03_Examples/01_Android/01_HelloWorld-JNI/HelloWord-JNI.apk
$ apkx HelloWord-JNI.apk
Extracting HelloWord-JNI.apk to HelloWord-JNI
Converting: classes.dex -> classes.jar (dex2jar)
dex2jar HelloWord-JNI/classes.dex -> HelloWord-JNI/classes.jar
```

The MainActivity is found in the file <code>MainActivity.java</code>. The "Hello World" text view is populated in the <code>onCreate()</code> method:

```java
public class MainActivity
extends AppCompatActivity {
    static {
        System.loadLibrary("native-lib");
    }

    @Override
    protected void onCreate(Bundle bundle) {
        super.onCreate(bundle);
        this.setContentView(2130968603);
        ((TextView)this.findViewById(2131427422)).setText((CharSequence)this.stringFromJNI());
    }

    public native String stringFromJNI();
}

}
```

Note the declaration of <code>public native String stringFromJNI</code> at the bottom. The <code>native</code> keyword informs the Java compiler that the implementation for this method is provided in a native language. The corresponding function is resolved during runtime. Of course, this only works if a native library is loaded that exports a global symbol with the expected signature. This signature is composed of the package name, class name and method name. In our case for example, this means that the programmer must have implemented the following C or C++ function:

```c
JNIEXPORT jstring JNICALL Java_sg_vantagepoint_helloworld_MainActivity_stringFromJNI(JNIEnv *env, jobject)
```

So where is the native implementation of this function? If you look into the <code>lib</code> directory of the APK archive, you'll see a total of eight subdirectories named after different processor architectures. Each of this directories contains a version of the native library <code>libnative-lib.so</code>, compiled for the processor architecture in question. When <code>System.loadLibrary</code> is called, the loader selects the correct version based on what device the app is running on.

<img src="Images/Chapters/0x05c/archs.jpg" width="300px" />

Following the naming convention mentioned above, we can expect the library to export a symbol named <code>Java_sg_vantagepoint_helloworld_MainActivity_stringFromJNI</code>. On Linux systems, you can retrieve the list of symbols using <code>readelf</code> (included in GNU binutils) or <code>nm</code>. On Mac OS, the same can be achieved with the <code>greadelf</code> tool, which you can install via Macports or Homebrew. The following example uses <code>greadelf</code>:

```
$ greadelf -W -s libnative-lib.so | grep Java
     3: 00004e49   112 FUNC    GLOBAL DEFAULT   11 Java_sg_vantagepoint_helloworld_MainActivity_stringFromJNI
```

This is the native function that gets eventually executed when the <code>stringFromJNI</code> native method is called.

To disassemble the code, you can load <code>libnative-lib.so</code> into any disassembler that understands ELF binaries (i.e. every disassembler in existence). If the app ships with binaries for different architectures, you can theoretically pick the architecture you're most familiar with, as long as the disassembler knows how to deal with it. Each version is compiled from the same source and implements exactly the same functionality. However, if you're planning to debug the library on a live device later, it's usually wise to pick an ARM build.

To support both older and newer ARM processors, Android apps ship with multple ARM builds compiled for different Application Binary Interface (ABI) versions. The ABI defines how the application's machine code is supposed to interact with the system at runtime. The following ABIs are supported:

- armeabi: ABI is for ARM-based CPUs that support at least the ARMv5TE instruction set.
- armeabi-v7a: This ABI extends armeabi to include several CPU instruction set extensions.
- arm64-v8a: ABI for ARMv8-based CPUs that support AArch64, the new 64-bit ARM architecture.

Most disassemblers will be able to deal with any of those architectures. Below, we'll be viewing the <code>armeabi-v7a</code> version in IDA Pro. It is located in <code>lib/armeabi-v7a/libnative-lib.so</code>. If you don't own an IDA Pro license, you can do the same thing with demo or evaluation version available on the Hex-Rays website <sup>[13]</sup>.

Open the file in IDA Pro. In the "Load new file" dialog, choose "ELF for ARM (Shared Object)" as the file type (IDA should detect this automatically), and "ARM Little-Endian" as the processor type.

<img src="Images/Chapters/0x05c/IDA_open_file.jpg" width="700px" />

Once the file is open, click into the "Functions" window on the left and press <code>Alt+t</code> to open the search dialog. Enter "java" and hit enter. This should highlight the <code>Java_sg_vantagepoint_helloworld_MainActivity_stringFromJNI</code> function. Double-click it to jump to its address in the disassembly Window. "Ida View-A" should now show the disassembly of the function.

<img src="Images/Chapters/0x05c/helloworld_stringfromjni.jpg" width="700px" />

Not a lot of code there, but let's analyze it. The first thing we need to know is that the first argument passed to every JNI is a JNI interface pointer. An interface pointer is a pointer to a pointer. This pointer points to a function table - an array of even more pointers, each of which points to a JNI interface function (is your head spinning yet?). The function table is initialized by the Java VM, and allows the native function to interact with the Java environment.

<img src="Images/Chapters/0x05c/JNI_interface.png" width="700px" />

With that in mind, let's have a look at each line of assembly code.

```
LDR  R2, [R0]
```

Remember - the first argument (located in R0) is a pointer to the JNI function table pointer. The <code>LDR</code> instruction loads this function table pointer into R2.

```
LDR  R1, =aHelloFromC
```

This instruction loads the pc-relative offset of the string "Hello from C++" into R1. Note that this string is located directly after the end of the function block at offset 0xe84. The addressing relative to the program counter allows the code to run independent of its position in memory.

```
LDR.W  R2, [R2, #0x29C]
```

This instruction loads the function pointer from offset 0x29C into the JNI function pointer table into R2. This happens to be the <code>NewStringUTF</code> function. You can look the list of function pointers in jni.h, which is included in the Android NDK. The function prototype looks as follows:

```
jstring     (*NewStringUTF)(JNIEnv*, const char*);
```

The function expects two arguments: The JNIEnv pointer (already in R0) and a String pointer. Next, the current value of PC is added to R1, resulting in the absolute address of the static string "Hello from C++" (PC + offset).

```
ADD  R1, PC
```

Finally, the program executes a branch instruction to the NewStringUTF function pointer loaded into R2:

```
BX   R2
```

When this function returns, R0 contains a pointer to the newly constructed UTF string. This is the final return value, so R0 is left unchanged and the function ends.

#### Debugging and Tracing

So far, we've been using static analysis techniques without ever running our target apps. In the real world - especially when reversing more complex apps or malware - you'll find that pure static analysis is very difficult. Observing and manipulating an app during runtime makes it much, much easier to decipher its behavior. Next, we'll have a look at dynamic analysis methods that help you do just that.

Android apps support two different types of debugging: Java-runtime-level debugging using Java Debug Wire Protocol (JDWP) and Linux/Unix-style ptrace-based debugging on the native layer, both of which are valuable for reverse engineers.

##### Activating Developer Options

Since Android 4.2, the "Developer options" submenu is hidden by default in the Settings app. To activate it, you need to tap the "Build number" section of the "About phone" view 7 times. Note that the location of the build number field can vary slightly on different devices - for example, on LG Phones, it is found under "About phone > Software information" instead. Once you have done this, "Developer options" will be shown at bottom of the Settings menu. Once developer options are activated, debugging can be enabled with the "USB debugging" switch.

##### Debugging Release Apps

Dalvik and ART support the Java Debug Wire Protocol (JDWP), a protocol used for communication between the debugger and the Java virtual machine (VM) which it debugs. JDWP is a standard debugging protocol that is supported by all command line tools and Java IDEs, including JDB, JEB, IntelliJ and Eclipse. Android's implementation of JDWP also includes hooks for supporting extra features implemented by the Dalvik Debug Monitor Server (DDMS).

Using a JDWP debugger allows you to step through Java code, set breakpoints on Java methods, and inspect and modify local and instance variables. You'll be using a JDWP debugger most of the time when debugging "normal" Android apps that don't do a lot of calls into native libraries.

In the following section, we'll show how to solve UnCrackable App for Android Level 1 using JDB only. Note that this is not an *efficient* way to solve this crackme - you can do it much faster using Frida and other methods, which we'll introduce later in the guide. It serves however well an an introduction to the capabilities of the Java debugger.

###### Repackaging

Every debugger-enabled process runs an extra thread for handling JDWP protocol packets.  this thread is started only for apps that have the <code>android:debuggable="true"</code> tag set in their Manifest file's <code>&lt;application&gt;</code> element. This is typically the configuration on Android devices shipped to end users.

When reverse engineering apps, you'll often only have access to the release build of the target app. Release builds are not meant to be debugged - after all, that's what *debug builds* are for. If the system property <code>ro.debuggable</code> set to "0", Android disallows both JDWP and native debugging of release builds, and although this is easy to bypass, you'll still likely encounter some limitations, such as a lack of line breakpoints. Nevertheless, even an imperfect debugger is still an invaluable tool - being able to inspect the runtime state of a program makes it *a lot* easier to understand what's going on.

To "convert" a release build release into a debuggable build, you need to modify a flag in the app's Manifest file. This modification breaks the code signature, so you'll also have to re-sign the the altered APK archive.

To do this, you first need a code signing certificate. If you have built a project in Android Studio before, the IDE has already created a debug keystore and certificate in <code>$HOME/.android/debug.keystore</code>. The default password for this keystore is "android" and the key is named "androiddebugkey".

The Java standard distibution includes <code>keytool</code> for managing keystores and certificates. You can create your own signing certificate and key and add it to the debug keystore as follows:

```
$ keytool -genkey -v -keystore ~/.android/debug.keystore -alias signkey -keyalg RSA -keysize 2048 -validity 20000
```

With a certificate available, you can now repackage the app using the following steps. Note that the Android Studio build tools directory must be in path for this to work - it is located at <code>[SDK-Path]/build-tools/[version]</code>. The <code>zipalign</code> and <code>apksigner</code> tools are found in this directory. Repackage UnCrackable-Level1.apk as follows:

1. Use apktool to unpack the app and decode AndroidManifest.xml:

```bash
$ apktool d --no-src UnCrackable-Level1.apk
```

2. Add android:debuggable = “true” to the manifest using a text editor:

```xml
<application android:allowBackup="true" android:debuggable="true" android:icon="@drawable/ic_launcher" android:label="@string/app_name" android:name="com.xxx.xxx.xxx" android:theme="@style/AppTheme">
```

3. Repackage and sign the APK.

```bash
$ cd UnCrackable-Level1
$ apktool b
$ zipalign -v 4 dist/UnCrackable-Level1.apk ../UnCrackable-Repackaged.apk
$ cd ..
$ apksigner sign --ks  ~/.android/debug.keystore --ks-key-alias signkey UnCrackable-Repackaged.apk
```

Note: If you experience JRE compatibility issues with <code>apksigner</code>, you can use <code>jarsigner</code> instead. Note that in this case, <code>zipalign</code> is called *after* signing.

```bash
$ jarsigner -verbose -keystore ~/.android/debug.keystore UnCrackable-Repackaged.apk signkey
$ zipalign -v 4 dist/UnCrackable-Level1.apk ../UnCrackable-Repackaged.apk
```

4. Reinstall the app:

```bash
$ adb install UnCrackable-Repackaged.apk
```

##### The 'Wait For Debugger' Feature

UnCrackable App is not stupid: It notices that it has been run in debuggable mode and reacts by shutting down. A modal dialog is shown immediately and the crackme terminates once you tap the OK button.

Fortunately, Android's Developer options contain the useful "Wait for Debugger" feature, which allows you to automatically suspend a selected app doing startup until a JDWP debugger connects. By using this feature, you can connect the debugger before the detection mechanism runs, and trace, debug and deactivate that mechanism. It's really an unfair advantage, but on the other hand, reverse engineers never play fair!

<img src="Images/Chapters/0x05c/debugger_detection.jpg" width="350px" />

In the Developer Settings, pick <code>Uncrackable1</code> as the debugging application and activate the "Wait for Debugger" switch.

<img src="Images/Chapters/0x05c/developer-options.jpg" width="350px" />

Note: Even with <code>ro.debuggable</code> set to 1 in <code>default.prop</code>, an app won't show up in the "debug app" list unless the <code>android:debuggable</code> flag is set to <code>true</code> in the Manifest.

##### The Android Debug Bridge

The <code>adb</code> command line tool, which ships with the Android SDK, bridges the gap between your local development environment and a connected Android device. Commonly you'll debug apps on the emulator or on a device connected via USB. Use the <code>adb devices</code> command to list the currently connected devices.

```bash
$ adb devices
List of devices attached
090c285c0b97f748  device
```

The <code>adb jdwp</code> command lists the process ids of all debuggable processes running on the connected device (i.e., processes hosting a JDWP transport). With the <code>adb forward</code> command, you can open a listening socket on your host machine and forward TCP connections to this socket to the JDWP transport of a chosen process.

```bash
$ adb jdwp
12167
$ adb forward tcp:7777 jdwp:12167
```

We're now ready to attach JDB. Attaching the debugger however causes the app to resume, which is something we don't want. Rather, we'd like to keep it suspended so we can do some exploration first. To prevent the process from resuming, we pipe the <code>suspend</code> command into jdb:

```bash
$ { echo "suspend"; cat; } | jdb -attach localhost:7777

Initializing jdb ...
> All threads suspended.
>
```

We are now attached to the suspended process and ready to go ahead with jdb commands. Entering <code>?</code> prints the complete list of. Unfortunately, the Android VM doesn't support all available JDWP features. For example, the <code>redefine</code> command, which would let us redefine the code for a class - a potentially very useful feature - is not supported. Another important restriction is that line breakpoints won't work, because the release bytecode doesn't contain line information. Method breakpoints do work however. Useful commands that work include:

- classes: List all loaded classes
- class / method / fields <class id>: Print details about a class and list its method and fields
- locals: print local variables in current stack frame
- print / dump <expr>: print information about an object
- stop in <method>: set a method breakpoint
- clear <method>: remove a method breakpoint
- set <lvalue> = <expr>:  assign new value to field/variable/array element

Let's revisit the decompiled code of UnCrackable App Level 1 and think about possible solutions. A good approach would be to suspend the app at a state where the secret string is stored in a variable in plain text so we can retrieve it. Unfortunately, we won't get that far unless we deal with the root / tampering detection first.

By reviewing the code, we can gather that the method <code>sg.vantagepoint.uncrackable1.MainActivity.a</code> is responsible for displaying the "This in unacceptable..." message box. This method hooks the "OK" button to a class that implements the <code>OnClickListener</code> interface. The <code>onClick</code> event handler on the "OK" button is what actually terminates the app. To prevent the user from simply cancelling the dialog, the <code>setCancelable</code> method is called.

```java
  private void a(final String title) {
        final AlertDialog create = new AlertDialog$Builder((Context)this).create();
        create.setTitle((CharSequence)title);
        create.setMessage((CharSequence)"This in unacceptable. The app is now going to exit.");
        create.setButton(-3, (CharSequence)"OK", (DialogInterface$OnClickListener)new b(this));
        create.setCancelable(false);
        create.show();
    }
```

We can bypass this with a little runtime tampering. With the app still suspended, set a method breakpoint on <code>android.app.Dialog.setCancelable</code> and resume the app.

```
> stop in android.app.Dialog.setCancelable                        
Set breakpoint android.app.Dialog.setCancelable
> resume
All threads resumed.
>
Breakpoint hit: "thread=main", android.app.Dialog.setCancelable(), line=1,110 bci=0
main[1]
```

The app is now suspended at the first instruction of the <code>setCancelable</code> method. You can print the arguments passed to <code>setCancelable</code> using the <code>locals</code> command (note that the arguments are incorrectly shown under "local variables").

```
main[1] locals
Method arguments:
Local variables:
flag = true
```

In this case, <code>setCancelable(true)</code> was called, so this can't be the call we're looking for. Resume the process using the <code>resume</code> command.

```
main[1] resume
Breakpoint hit: "thread=main", android.app.Dialog.setCancelable(), line=1,110 bci=0
main[1] locals
flag = false
```

We've now hit a call to <code>setCancelable</code> with the argument <code>false</code>. Set the variable to <code>true</code> with the <code>set</code> command and resume.

```
main[1] set flag = true
 flag = true = true
main[1] resume
```

Repeat this process, setting <code>flag</code> to <code>true</code> each time the breakpoint is hit, until the alert box is finally displayed (the breakpoint will hit 5 or 6 times). The alert box should now be cancelable! Tap anywhere next to the box and it will close without terminating the app.

Now that the anti-tampering is out of the way we're ready to extract the secret string! In the "static analysis" section, we saw that the string is decrypted using AES, and then compared with the string entered into the messagebox. The method <code>equals</code> of the <code>java.lang.String</code> class is used to compare the input string with the secret. Set a method breakpoint on <code>java.lang.String.equals</code>, enter any text into the edit field, and tap the "verify" button. Once the breakpoint hits, you can read the method argument with the using the <code>locals</code> command.

```
> stop in java.lang.String.equals
Set breakpoint java.lang.String.equals
>    
Breakpoint hit: "thread=main", java.lang.String.equals(), line=639 bci=2

main[1] locals
Method arguments:
Local variables:
other = "radiusGravity"
main[1] cont

Breakpoint hit: "thread=main", java.lang.String.equals(), line=639 bci=2

main[1] locals
Method arguments:
Local variables:
other = "I want to believe"
main[1] cont     
```

This is the plaintext string we are looking for!

###### Debugging Using an IDE

A pretty neat trick is setting up a project in an IDE with the decompiled sources, which allows you to set method breakpoints directly in the source code. In most cases, you should be able single-step through the app, and inspect the state of variables through the GUI. The experience won't be perfect - it's not the original source code after all, so you can't set line breakpoints and sometimes things will simply not work correctly. Then again, reversing code is never easy, and being able to efficiently navigate and debug plain old Java code is a pretty convenient way of doing it, so it's usually worth giving it a shot. A similar method has been described in the NetSPI blog <sup>[18]</sup>.

In order to debug an app from the decompiled source code, you should first create your Android project and copy the decompiled java sources into the source folder as described above at "Statically Analyzing Java Code" part. Set the debug app (in this tutorial it is Uncrackable1) and make sure you turned on "Wait For Deugger" switch from "Developer Options".

Once you tap the Uncrackable app icon from the launcher, it will get suspended in "wait for a debugger" mode.

<img src="Images/Chapters/0x05c/waitfordebugger.png" width="350px" />

Now you can set breakpoints and attach to the Uncrackable1 app process using the "Attach Debugger" button on the toolbar.

<img src="Images/Chapters/0x05c/set_breakpoint_and_attach_debugger.png" width="700px" />

Note that only method breakpoints work when debugging an app from decompiled sources. Once a method breakpoint is hit, you will get the chance to single step throughout the method execution.

<img src="Images/Chapters/0x05c/Choose_Process.png" width="300px" />

After you choose the Uncrackable1 application from the list, the debugger will attach to the app process and you will hit the breakpoint that was set on the <code>onCreate()</code> method. Uncrackable1 app triggers anti-debugging and anti-tampering controls within the <code>onCreate()</code> method. That's why it is a good idea to set a breakpoint on the <code>onCreate()</code> method just before the anti-tampering and anti-debugging checks performed.

Next, we will single-step through the <code>onCreate()</code> method by clicking the "Force Step Into" button on the Debugger view. The "Force Step Into" option allows you to debug the Android framework functions and core Java classes that are normally ignored by debuggers.

<img src="Images/Chapters/0x05c/Force_Step_Into.png" width="700px" />

Once you "Force Step Into", the debugger will stop at the beginning of the next method which is the <code>a()</code> method of class <code>sg.vantagepoint.a.c</code>.

<img src="Images/Chapters/0x05c/fucntion_a_of_class_sg_vantagepoint_a.png" width="700px" />

This method searches for "su" binary within well known directories. Since we are running the app on a rooted device/emulator we need to defeat this check by manipulating variables and/or function return values.

<img src="Images/Chapters/0x05c/variables.png" width="700px" />

You can see the directory names inside the "Variables" window by stepping into the <code>a()</code> method and stepping through the method by clicking "Step Over" button in the Debugger view.

<img src="Images/Chapters/0x05c/step_over.png" width="700px" />

Step into the <code>System.getenv</code> method call y using the "Force Step Into" functionality.

After you get the colon separated directory names, the debugger cursor will return back to the beginning of <code>a()</code> method; not to the next executable line. This is just because we are working on the decompiled code insted of the original source code. So it is crucial for the analyst to follow the code flow while debugging decompiled applications. Othervise, it might get complicated to identify which line will be executed next.

If you don't want to debug core Java and Android classes, you can step out of the function by clicking "Step Out" button in the Debugger view. It might be a good approach to "Force Step Into" once you reach the decompiled sources and "Step Out" of the core Java and Android classes. This will help you to speed up your debugging while keeping eye on the return values of the core class functions.

<img src="Images/Chapters/0x05c/step_out.png" width="700px" />

After it gets the directory names, <code>a()</code> method will search for the existence of the </code>su</code> binary within these directories. In order to defeat this control, you can modify the directory names (parent) or file name (child) at cycle which would otherwise detect the <code>su</code> binary on your device. You can modify the variable content by pressing F2 or Right-Click and "Set Value".

<img src="Images/Chapters/0x05c/set_value.png" width="700px" />

<img src="Images/Chapters/0x05c/modified_binary_name.png" width="700px" />

Once you modify the binary name or the directory name, <code>File.exists</code> should return <code>false</code>.

<img src="Images/Chapters/0x05c/file_exists_false.png" width="700px" />

This defeats the first root detection control of Uncrackable App Level 1. The remaining anti-tampering and anti-debugging controls can be defeated in similar ways to finally reach secret string verification functionality.

<img src="Images/Chapters/0x05c/anti_debug_anti_tamper_defeated.png" width="350px" />

<img src="Images/Chapters/0x05c/MainActivity_verify.png" width="700px" />

The secret code is verified by the method <code>a()</code> of class <code>sg.vantagepoint.uncrackable1.a</code>. Set a breakpoint on method <code>a()</code> and "Force Step Into" when you hit the breakpoint. Then, single-step until you reach the call to <code>String.equals</code>. This is where user supplied input is compared with the secret string.

<img src="Images/Chapters/0x05c/sg_vantagepoint_uncrackable1_a_function_a.png" width="700px" />

You can see the secret string in the "Variables" view at the time you reach the <code>String.equals</code> method call.

<img src="Images/Chapters/0x05c/secret_code.png" width="700px" />

<img src="Images/Chapters/0x05c/success.png" width="350px" />

##### Debugging Native Code

Native code on Android is packed into ELF shared libraries and runs just like any other native Linux program. Consequently, you can debug them using standard tools, including GDB and the built-in native debuggers of IDEs such as IDA Pro and JEB, as long as they support the processor architecture of the device (most devices are based on ARM chipsets, so this is usually not an issue).

We'll now set up our JNI demo app, HelloWorld-JNI.apk, for debugging. It's the same APK you downloaded in "Statically Analyzing Native Code". Use <code>adb install</code> to install it on your device or on an emulator.

```bash
$ adb install HelloWorld-JNI.apk
```

If you followed the instructions at the start of this chapter, you should already have the Android NDK. It contains prebuilt versions of gdbserver for various architectures. Copy the <code>gdbserver binary</code> to your device:

```bash
$ adb push $NDK/prebuilt/android-arm/gdbserver/gdbserver /data/local/tmp
```

The <code>gdbserver --attach&lt;comm&gt; &lt;pid&gt;</code> command causes gdbserver to attach to the running process and bind to the IP address and port specified in <code>comm</code>, which in our case is a <code>HOST:PORT</code> descriptor. Start HelloWorld-JNI on the device, then connect to the device and determine the PID of the HelloWorld process. Then, switch to the root user and attach <code>gdbserver</code> as follows.

```bash
$ adb shell
$ ps | grep helloworld
u0_a164   12690 201   1533400 51692 ffffffff 00000000 S sg.vantagepoint.helloworldjni
$ su
# /data/local/tmp/gdbserver --attach localhost:1234 12690
Attached; pid = 12690
Listening on port 1234
```

The process is now suspended, and <code>gdbserver</code> listening for debugging clients on port <code>1234</code>. With the device connected via USB, you can forward this port to a local port on the host using the <code>abd forward</code> command:

```bash
$ adb forward tcp:1234 tcp:1234
```

We'll now use the prebuilt version of <code>gdb</code> contained in the NDK toolchain (if you haven't already, follow the instructions above to install it).

```
$ $TOOLCHAIN/bin/gdb libnative-lib.so
GNU gdb (GDB) 7.11
(...)
Reading symbols from libnative-lib.so...(no debugging symbols found)...done.
(gdb) target remote :1234
Remote debugging using :1234
0xb6e0f124 in ?? ()
```

We have successfully attached to the process! The only problem is that at this point, we're already too late to debug the JNI function <code>StringFromJNI()</code> as it only runs once at startup. We can again solve this problem by activating the "Wait for Debugger" option. Go to "Developer Options" -> "Select debug app" and pick HelloWorldJNI, then activate the "Wait for debugger" switch. Then, terminate and re-launch the app. It should be suspended automatically.

Our objective is to set a breakpoint at the start of the native function <code>Java_sg_vantagepoint_helloworldjni_MainActivity_stringFromJNI()</code> before resuming the app. Unfortunately, this isn't possible at this early point in execution because <code>libnative-lib.so</code> isn't yet mapped into process memory - it is loaded dynamically during runtime. To get this working, we'll first use JDB to gently control the process into the state we need.

First, we resume execution of the Java VM by attaching JDB. We don't want the process to resume immediately though, so we pipe the <code>suspend</code> command into JDB as follows:

```bash
$ adb jdwp
14342
$ adb forward tcp:7777 jdwp:14342
$ { echo "suspend"; cat; } | jdb -attach localhost:7777
```

Next, we want to suspend the process at the point the Java runtime loads <code>libnative-lib.so</code>. In JDB, set a breakpoint on the <code>java.lang.System.loadLibrary()</code> method and resume the process. After the breakpoint has been hit, execute the <code>step up</code> command, which will resume the process until <code>loadLibrary()</code>returns. At this point, <code>libnative-lib.so</code> has been loaded.

```
> stop in java.lang.System.loadLibrary
> resume
All threads resumed.
Breakpoint hit: "thread=main", java.lang.System.loadLibrary(), line=988 bci=0
> step up
main[1] step up
>
Step completed: "thread=main", sg.vantagepoint.helloworldjni.MainActivity.<clinit>(), line=12 bci=5

main[1]
```

Execute <code>gdbserver</code> to attach to the suspended app. This will have the effect that the app is "double-suspended" by both the Java VM and the Linux kernel.


```bash
$ adb forward tcp:1234 tcp:1234
$ $TOOLCHAIN/arm-linux-androideabi-gdb libnative-lib.so
GNU gdb (GDB) 7.7
Copyright (C) 2014 Free Software Foundation, Inc.
(...)
(gdb) target remote :1234
Remote debugging using :1234
0xb6de83b8 in ?? ()
```

Execute the <code>resume</code> command in JDB to resume execution of the Java runtime (we're done using JDB, so you can also detach it at this point). You can start exploring the process with GDB. The <code>info sharedlibrary</code> command displays the loaded libraries, which should include <code>libnative-lib.so</code>. The <code>info functions</code> command retrieves a list of all known functions. The JNI function <code>java_sg_vantagepoint_helloworldjni_MainActivity_stringFromJNI()</code> should be listed as a non-debugging symbol. Set a breakpoint at the address of that function and resume the process.

```bash
(gdb) info sharedlibrary
(...)
0xa3522e3c  0xa3523c90  Yes (*)     libnative-lib.so
(gdb) info functions
All defined functions:

Non-debugging symbols:
0x00000e78  Java_sg_vantagepoint_helloworldjni_MainActivity_stringFromJNI
(...)
0xa3522e78  Java_sg_vantagepoint_helloworldjni_MainActivity_stringFromJNI
(...)
(gdb) b *0xa3522e78
Breakpoint 1 at 0xa3522e78
(gdb) cont
```

Your breakpoint should be hit when the first instruction of the JNI function is executed. You can now display a disassembly of the function using the <code>disassemble</code> command.

```
Breakpoint 1, 0xa3522e78 in Java_sg_vantagepoint_helloworldjni_MainActivity_stringFromJNI() from libnative-lib.so
(gdb) disass $pc
Dump of assembler code for function Java_sg_vantagepoint_helloworldjni_MainActivity_stringFromJNI:
=> 0xa3522e78 <+0>: ldr r2, [r0, #0]
   0xa3522e7a <+2>: ldr r1, [pc, #8]  ; (0xa3522e84 <Java_sg_vantagepoint_helloworldjni_MainActivity_stringFromJNI+12>)
   0xa3522e7c <+4>: ldr.w r2, [r2, #668]  ; 0x29c
   0xa3522e80 <+8>: add r1, pc
   0xa3522e82 <+10>:  bx  r2
   0xa3522e84 <+12>:  lsrs  r4, r7, #28
   0xa3522e86 <+14>:  movs  r0, r0
End of assembler dump.
```

From here on, you can single-step through the program, print the contents of registers and memory, or tamper with them, to explore the inner workings of the JNI function (which, in this case, simply returns a string). Use the <code>help</code> command to get more information on debugging, running and examining data.

##### Execution Tracing

Besides being useful for debugging, the JDB command line tool also offers basic execution tracing functionality. To trace an app right from the start we can pause the app using the Android "Wait for Debugger" feature or a <code>kill –STOP</code> command and attach JDB to set a deferred method breakpoint on an initialization method of our choice. Once the breakpoint hits, we activate method tracing with the <code>trace go methods</code> command and resume execution. JDB will dump all method entries and exits from that point on.

```bash
$ adb forward tcp:7777 jdwp:7288
$ { echo "suspend"; cat; } | jdb -attach localhost:7777
Set uncaught java.lang.Throwable
Set deferred uncaught java.lang.Throwable
Initializing jdb ...
> All threads suspended.
> stop in com.acme.bob.mobile.android.core.BobMobileApplication.<clinit>()          
Deferring breakpoint com.acme.bob.mobile.android.core.BobMobileApplication.<clinit>().
It will be set after the class is loaded.
> resume
All threads resumed.M
Set deferred breakpoint com.acme.bob.mobile.android.core.BobMobileApplication.<clinit>()

Breakpoint hit: "thread=main", com.acme.bob.mobile.android.core.BobMobileApplication.<clinit>(), line=44 bci=0
main[1] trace go methods
main[1] resume
Method entered: All threads resumed.
```

The Dalvik Debug Monitor Server (DDMS) a GUI tool included with Android Studio. At first glance it might not look like much, but make no mistake: Its Java method tracer is one of the most awesome tools you can have in your arsenal, and is indispensable for analyzing obfuscated bytecode.

Using DDMS is a bit confusing however: It can be launched in several ways, and different trace viewers will be launched depending on how the trace was obtained. There’s a standalone tool called "Traceview" as well as a built-in viewer in Android Studio, both of which offer different ways of navigating the trace. You’ll usually want to use the viewer built into Android studio which gives you a nice, zoom-able hierarchical timeline of all method calls. The standalone tool however is also useful, as it has a profile panel that shows the time spent in each method, as well as the parents and children of each method.

To record an execution trace in Android studio, open the "Android" tab at the bottom of the GUI. Select the target process in the list and the click the little “stop watch” button on the left. This starts the recording. Once you are done, click the same button to stop the recording. The integrated trace view will open showing the recorded trace. You can scroll and zoom the timeline view using the mouse or trackpad.

Alternatively, execution traces can also be recorded in the standalone Android Device Monitor. The Device Monitor can be started from within Android Studo (Tools -> Android -> Android Device Monitor) or from the shell with the <code>ddms</code> command.

To start recording tracing information, select the target process in the "Devices" tab and click the “Start Method Profiling” button. Click the stop button to stop recording, after which the Traceview tool will open showing the recorded trace. An interesting feature of the standalone tool is the "profile" panel on the bottom, which shows an overview of the time spent in each method, as well as each method’s parents and children. Clicking any of the methods in the profile panel highlights the selected method in the timeline panel.

As an aside, DDMS also offers convenient heap dump button that will dump the Java heap of a process to a <code>.hprof</code> file. More information on Traceview can be found in the Android Studio user guide.

###### Tracing System Calls

Moving down a level in the OS hierarchy, we arrive at privileged functions that require the powers of the Linux kernel. These functions are available to normal processes via the system call interface. Instrumenting and intercepting calls into the kernel is an effective method to get a rough idea of what a user process is doing, and is often the most efficient way to deactivate low-level tampering defenses.

Strace is a standard Linux utility that is used to monitor interaction between processes and the kernel. The utility is not included with Android by default, but can be easily built from source using the Android NDK. This gives us a very convenient way of monitoring system calls of a process. Strace however depends on the <code>ptrace()</code> system call to attach to the target process, so it only works up to the point that anti-debugging measures kick in.

As a side note, if the Android "stop application at startup: feature is unavailable we can use a shell script to make sure that strace attached immediately once the process is launched (not an elegant solution but it works):

```bash
$ while true; do pid=$(pgrep 'target_process' | head -1); if [[ -n "$pid" ]]; then strace -s 2000 - e “!read” -ff -p "$pid"; break; fi; done
```

###### Ftrace

Ftrace is a tracing utility built directly into the Linux kernel. On a rooted device, ftrace can be used to trace kernel system calls in a more transparent way than is possible with strace, which relies on the ptrace system call to attach to the target process.

Conveniently, ftrace functionality is found in the stock Android kernel on both Lollipop and Marshmallow. It can be enabled with the following command:

```bash
$ echo 1 > /proc/sys/kernel/ftrace_enabled
```

The <code>/sys/kernel/debug/tracing</code> directory holds all control and output files and related to ftrace. The following files are found in this directory:

- available_tracers: This file lists the available tracers compiled into the kernel.
- current_tracer: This file is used to set or display the current tracer.
- tracing_on: Echo 1 into this file to allow/start update of the ring buffer. Echoing 0 will prevent further writes into the ring buffer.

###### KProbes

The KProbes interface provides us with an even more powerful way to instrument the kernel: It allows us to insert probes into (almost) arbitrary code addresses within kernel memory. Kprobes work by inserting a breakpoint instruction at the specified address. Once the breakpoint is hit, control passes to the Kprobes system, which then executes the handler function(s) defined by the user as well as the original instruction. Besides being great for function tracing, KProbes can be used to implement rootkit-like functionality such as file hiding.

Jprobes and Kretprobes are additional probe types based on Kprobes that allow hooking of function entries and exits.

Unfortunately, the stock Android kernel comes without loadable module support, which is a problem given that Kprobes are usually deployed as kernel modules. Another issue is that the Android kernel is compiled with strict memory protection which prevents patching some parts of Kernel memory. Using Elfmaster’s system call hooking method <sup>[16]</code> results in a Kernel panic on default Lolllipop and Marshmallow due to sys_call_table being non-writable. We can however use Kprobes on a sandbox by compiling our own, more lenient Kernel (more on this later).

##### Emulation-based Analysis

Even in its standard form that ships with the Android SDK, the Android emulator – a.k.a. “emulator” - is a somewhat capable reverse engineering tool. It is based on QEMU, a generic and open source machine emulator. QEMU emulates a guest CPU by translating the guest instructions on-the-fly into instructions the host processor can understand. Each basic block of guest instructions is disassembled and translated into an intermediate representation called Tiny Code Generator (TCG). The TCG block is compiled into a block of host instructions, stored into a code cache, and executed. After execution of the basic block has completed, QEMU repeats the process for the next block of guest instructions (or loads the already translated block from the cache). The whole process is called dynamic binary translation.

Because the Android emulator is a fork of QEMU, it comes with the full QEMU feature set, including its monitoring, debugging and tracing facilities. QEMU-specific parameters can be passed to the emulator with the -qemu command line flag. We can use QEMU’s built-in tracing facilities to log executed instructions and virtual register values. Simply starting qemu with the "-d" command line flag will cause it to dump the blocks of guest code, micro operations or host instructions being executed. The –d in_asm option logs all basic blocks of guest code as they enter QEMU’s translation function. The following command logs all translated blocks to a file:

```bash
$ emulator -show-kernel -avd Nexus_4_API_19 -snapshot default-boot -no-snapshot-save -qemu -d in_asm,cpu 2>/tmp/qemu.log
```

Unfortunately, it is not possible to generate a complete guest instruction trace with QEMU, because code blocks are written to the log only at the time they are translated – not when they’re taken from the cache. For example, if a block is repeatedly executed in a loop, only the first iteration will be printed to the log. There’s no way to disable TB caching in QEMU (save for hacking the source code). Even so, the functionality is sufficient for basic tasks, such as reconstructing the disassembly of a natively executed cryptographic algorithm.

Dynamic analysis frameworks, such as PANDA and DroidScope, build on QEMU to provide more complete tracing functionality. PANDA/PANDROID is your best if you’re going for a CPU-trace based analysis, as it allows you to easily record and replay a full trace, and is relatively easy to set up if you follow the build instructions for Ubuntu.

###### DroidScope

DroidScope - an extension to the DECAF dynamic analysis framework <sup>[20]</sup> - is a malware analysis engine based on QEMU. It adds instrumentation on several levels, making it possible to fully reconstruct the semantics on the hardware, Linux and Java level.

DroidScope exports instrumentation APIs that mirror the different context levels (hardware, OS and Java) of a real Android device. Analysis tools can use these APIs to query or set information and register callbacks for various events. For example, a plugin can register callbacks for native instruction start and end, memory reads and writes, register reads and writes, system calls or Java method calls.

All of this makes it possible to build tracers that are practically transparent to the target application (as long as we can hide the fact it is running in an emulator). One limitation is that DroidScope is compatible with the Dalvik VM only.

###### PANDA

PANDA <sup>[21]</sup> is another QEMU-based dynamic analysis platform. Similar to DroidScope, PANDA can be extended by registering callbacks that are triggered upon certain QEMU events. The twist PANDA adds is its record/replay feature. This allows for an iterative workflow: The reverse engineer records an execution trace of some the target app (or some part of it) and then replays it over and over again, refining his analysis plugins with each iteration.

PANDA comes with some pre-made plugins, such as a stringsearch tool and a syscall tracer. Most importantly, it also supports Android guests and some of the DroidScope code has even been ported over. Building and running PANDA for Android (“PANDROID”) is relatively straightforward. To test it, clone Moiyx’s git repository and build PANDA as follows:

~~~
$ cd qemu
$ ./configure --target-list=arm-softmmu --enable-android $ makee
~~~

As of this writing, Android versions up to 4.4.1 run fine in PANDROID, but anything newer than that won’t boot. Also, the Java level introspection code only works on the specific Dalvik runtime of Android 2.3. Anyways, older versions of Android seem to run much faster in the emulator, so if you plan on using PANDA sticking with Gingerbread is probably best. For more information, check out the extensive documentation in the PANDA git repo.

##### VxStripper

Another very useful tool built on QEMU is VxStripper by Sébastien Josse <sup>[22]</sup>. VXStripper is specifically designed for de-obfuscating binaries. By instrumenting QEMU's dynamic binary translation mechanisms, it dynamically extracts an intermediate representation of a binary. It then applies simplifications to the extracted intermediate representation, and recompiles the simplified binary using LLVM. This is a very powerful way of normalizing obfuscated programs. See Sébastien's paper <sup>[23]</sup> for more information.

### Tampering and Runtime Instrumentation

First, we'll look at some simple ways of modifying and instrumenting mobile apps. *Tampering* means making patches or runtime changes to the app to affect its behavior - usually in a way that's to our advantage. For example, it could be desirable to deactivate SSL pinning or deactivate binary protections that hinder the testing process. *Runtime Instrumentation* encompasses adding hooks and runtime patches to observe the app's behavior. In mobile app-sec however, the term is used rather loosely to refer to all kinds runtime manipulation, including overriding methods to change behavior.

#### Patching and Re-Packaging

Making small changes to the app Manifest or bytecode is often the quickest way to fix small annoyances that prevent you from testing or reverse engineering an app. On Android, two issues in particular pop up regularly:

1. You can't attach a debugger to the app because the android:debuggable flag is not set to true in the Manifest;
2. You cannot intercept HTTPS traffic with a proxy because the app empoys SSL pinning.

In most cases, both issues can be fixed by making minor changes and re-packaging and re-signing the app (the exception are apps that run additional integrity checks beyond default Android code signing - in theses cases, you also have to patch out those additional checks as well).

##### Example: Disabling SSL Pinning

Certificate pinning is an issue for security testers who want to intercepts HTTPS communication for legitimate reasons. To help with this problem, the bytecode can be patched to deactivate SSL pinning. To demonstrate how Certificate Pinning can be bypassed, we will walk through the necessary steps to bypass Certificate Pinning implemented in an example application.

The first step is to disassemble the APK with <code>apktool</code>:

```bash
$ apktool d target_apk.apk
```

You then need to locate the certificate pinning checks in the Smali source code. Searching the smali code for keywords such as “X509TrustManager” should point you in the right direction.

In our example, a search for "X509TrustManager" returns one class that implements a custom Trustmanager. The derived class implements methods named <code>checkClientTrusted</code>, <code>checkServerTrusted</code> and <code>getAcceptedIssuers</code>.

Insert the <code>return-void</code> opcode was added to the first line of each of these methods to bypass execution. This causes each method to return immediately. return value. With this modification, no certificate checks are performed, and the application will accept all certificates.

```smali
.method public checkServerTrusted([LJava/security/cert/X509Certificate;Ljava/lang/String;)V
  .locals 3
  .param p1, "chain"  # [Ljava/security/cert/X509Certificate;
  .param p2, "authType"   # Ljava/lang/String;

  .prologue     
  return-void      # <-- OUR INSERTED OPCODE!
  .line 102
  iget-object v1, p0, Lasdf/t$a;->a:Ljava/util/ArrayList;

  invoke-virtual {v1}, Ljava/util/ArrayList;->iterator()Ljava/util/Iterator;

  move-result-object v1

  :goto_0
  invoke-interface {v1}, Ljava/util/Iterator;->hasNext()Z
```

#### Hooking Java Methods with Xposed

Xposed is a "framework for modules that can change the behavior of the system and apps without touching any APKs" <sup>[24]</code>. Technically, it is an extended version of Zygote that exports APIs for running Java code when a new process is started. By running Java code in the context of the newly instantiated app, it is possible to resolve, hook and override Java methods belonging to the app. Xposed uses [reflection](https://docs.oracle.com/javase/tutorial/reflect/) to examine and modify the running app. Changes are applied in memory and persist only during the runtime of the process - no patches to the application files are made.

To use Xposed, you first need to install the Xposed framework on a rooted device. Modifications are then deployed in the form of separate apps ("modules") that can be toggled on and off in the Xposed GUI.

##### Example: Bypassing Root Detection with XPosed

Let's assume you're testing an app that is stubbornly quitting on your rooted device. You decompile the app and find the following highly suspect method:

```java
package com.example.a.b

public static boolean c() {
  int v3 = 0;
  boolean v0 = false;

  String[] v1 = new String[]{"/sbin/", "/system/bin/", "/system/xbin/", "/data/local/xbin/",
    "/data/local/bin/", "/system/sd/xbin/", "/system/bin/failsafe/", "/data/local/"};

    int v2 = v1.length;

    for(int v3 = 0; v3 < v2; v3++) {
      if(new File(String.valueOf(v1[v3]) + "su").exists()) {
         v0 = true;
         return v0;
      }
    }

    return v0;
}
```

This method iterates through a list of directories, and returns "true" (device rooted) if the <code>su</code> binary is found in any of them. Checks like this are easy to deactivate - all you have to do is to replace the code with something that returns "false". Methok hooking using an Xposed module is one way to do this.

This method  <code>XposedHelpers.findAndHookMethodfindAndHookMethod</code> allows you to override existing class methods. From the decompiled code, we know that the method performing the check is called <code>c()</code> and located in the class <code>com.example.a.b</code>. An Xposed module that overrides the function to always return "false" looks as follows.

```java
package com.awesome.pentestcompany;

import static de.robv.android.xposed.XposedHelpers.findAndHookMethod;
import de.robv.android.xposed.IXposedHookLoadPackage;
import de.robv.android.xposed.XposedBridge;
import de.robv.android.xposed.XC_MethodHook;
import de.robv.android.xposed.callbacks.XC_LoadPackage.LoadPackageParam;

public class DisableRootCheck implements IXposedHookLoadPackage {

    public void handleLoadPackage(final LoadPackageParam lpparam) throws Throwable {
        if (!lpparam.packageName.equals("com.example.targetapp"))
            return;

        findAndHookMethod("com.example.a.b", lpparam.classLoader, "c", new XC_MethodHook() {
            @Override

            protected void beforeHookedMethod(MethodHookParam param) throws Throwable {
                XposedBridge.log("Caught root check!");
                param.setResult(false);
            }

        });
    }
}
```

Modules for Xposed are developed and deployed with Android Studio just like regular Android apps. For more details on writing compiling and installing Xposed modules, refer to the tutorial provided by its author, rovo89 <sup>[24]</sup>.

#### Dynamic Instrumentation with FRIDA

Frida "lets you inject snippets of JavaScript or your own library into native apps on Windows, macOS, Linux, iOS, Android, and QNX" <sup>[26]</sup>. While it was originally based on Google’s V8 Javascript runtime, since version 9 Frida now uses Duktape internally.

Code injection can be achieved in different ways. For example, Xposed makes some permanent modifications to the Android app loader that provide hooks to run your own code every time a new process is started. In contrast, Frida achieves code injection by writing code directly into process memory. The process is outlined in a bit more detail below.

When you "attach" Frida to a running app, it uses ptrace to hijack a thread in a running process. This thread is used to allocate a chunk of memory and populate it with a mini-bootstrapper. The bootstrapper starts a fresh thread, connects to the Frida debugging server running on the device, and loads a dynamically generated library file containing the Frida agent and instrumentation code. The original, hijacked thread is restored to its original state and resumed, and execution of the process continues as usual.

Frida injects a complete JavaScript runtime into the process, along with a powerful API that provides a wealth of useful functionality, including calling and hooking of native functions and injecting structured data into memory. It also supports interaction with the Android Java runtime, such as interacting with objects inside the VM.

![Frida](Images/Chapters/0x04/frida.png)

*FRIDA Architecture, source: http://www.frida.re/docs/hacking/*

Here are some more APIs FRIDA offers on Android:

- Instantiate Java objects and call static and non-static class methods;
- Replace Java method implementations;
- Enumerate live instances of specific classes by scanning the Java heap (Dalvik only);
- Scan process memory for occurrences of a string;
- Intercept native function calls to run your own code at function entry and exit.

Some features unfortunately don’t work yet on current Android devices platforms. Most notably, the FRIDA Stalker - a code tracing engine based on dynamic recompilation - does not support ARM at the time of this writing (version 7.2.0). Also, support for ART has been included only recently, so the Dalvik runtime is still better supported.

##### Installing Frida

To install Frida locally, simply use Pypi:

~~~
$ sudo pip install frida
~~~

Your Android device doesn't need to be rooted to get Frida running, but it's the easiest setup and we assume a rooted device here unless noted otherwise. Download the frida-server binary from the [Frida releases page](https://github.com/frida/frida/releases). Make sure that the server version (at least the major version number) matches the version of your local Frida installation. Usually, Pypi will install the latest version of Frida, but if you are not sure, you can check with the Frida command line tool:

~~~
$ frida --version
9.1.10
$ wget https://github.com/frida/frida/releases/download/9.1.10/frida-server-9.1.10-android-arm.xz
~~~

Copy frida-server to the device and run it:

~~~
$ adb push frida-server /data/local/tmp/
$ adb shell "chmod 755 /data/local/tmp/frida-server"
$ adb shell "su -c /data/local/tmp/frida-server &"
~~~

With frida-server running, you should now be able to get a list of running processes with the following command:

~~~
$ frida-ps -U
  PID  Name
-----  --------------------------------------------------------------
  276  adbd
  956  android.process.media
  198  bridgemgrd
 1191  com.android.nfc
 1236  com.android.phone
 5353  com.android.settings
  936  com.android.systemui
(...)
~~~

The `-U` option lets Frida search for USB devices or emulators.

To trace specific (low level) library calls, you can use the `frida-trace` command line tool:

~~~
frida-trace -i "open" -U com.android.chrome
~~~

This generates a little javascript in `__handlers__/libc.so/open.js` that Frida injects into the process and that traces all calls to the `open` function in `libc.so`. You can modify the generated script according to your needs, making use of Fridas [Javascript API](https://www.frida.re/docs/javascript-api/).

To work with Frida interactively, you can use `frida CLI` which hooks into a process and gives you a command line interface to Frida's API.

~~~
frida -U com.android.chrome
~~~

You can also use frida CLI to load scripts via the `-l` option, e.g to load `myscript.js`:

~~~
frida -U -l myscript.js com.android.chrome
~~~

Frida also provides a Java API which is especially helpful for dealing with Android apps. It lets you work with Java classes and objects directly. This is a script to overwrite the "onResume" function of an Activity class:

~~~
Java.perform(function () {
    var Activity = Java.use("android.app.Activity");
    Activity.onResume.implementation = function () {
        console.log("[*] onResume() got called!");
        this.onResume();
    };
});
~~~

The script above calls Java.perform to make sure that our code gets executed in the context of the Java VM. It instantiates a wrapper for the `android.app.Activity` class via `Java.use` and overwrites the `onResume` function. The new `onResume` function outputs a notice to the console and calls the original `onResume` method by invoking `this.onResume` every time an activity is resumed in the the app.

Frida also lets you search for instantiated objects on the heap and work with them. The following script searches for instances of `android.view.View` objects and calls their `toString` method. The result is printed to the console:

~~~
setImmediate(function() {
    console.log("[*] Starting script");
    Java.perform(function () {
        Java.choose("android.view.View", {
             "onMatch":function(instance){
                  console.log("[*] Instance found: " + instance.toString());
             },
             "onComplete":function() {
                  console.log("[*] Finished heap search")
             }
        });
    });
});
~~~

The output would look like this:

~~~
[*] Starting script
[*] Instance found: android.view.View{7ccea78 G.ED..... ......ID 0,0-0,0 #7f0c01fc app:id/action_bar_black_background}
[*] Instance found: android.view.View{2809551 V.ED..... ........ 0,1731-0,1731 #7f0c01ff app:id/menu_anchor_stub}
[*] Instance found: android.view.View{be471b6 G.ED..... ......I. 0,0-0,0 #7f0c01f5 app:id/location_bar_verbose_status_separator}
[*] Instance found: android.view.View{3ae0eb7 V.ED..... ........ 0,0-1080,63 #102002f android:id/statusBarBackground}
[*] Finished heap search
~~~

Notice that you can also make use of Java's reflection capabilities. To list the public methods of the `android.view.View` class you could create a wrapper for this class in Frida and call `getMethods()` from its `class` property:

~~~
Java.perform(function () {
    var view = Java.use("android.view.View");
    var methods = view.class.getMethods();
    for(var i = 0; i < methods.length; i++) {
        console.log(methods[i].toString());
    }
});
~~~

Besides loading scripts via `frida CLI`, Frida also provides Python, C, NodeJS, Swift and various other bindings.

##### Solving the OWASP Uncrackable Crackme Level1 with Frida

Frida gives you the possibility to solve the OWASP UnCrackable Crackme Level 1 easily. We have already seen that we can hook method calls with Frida above.

When you start the App on an emulator or a rooted device, you find that the app presents a dialog box and exits as soon as you press "Ok" because it detected root:

![Crackme Root Detected Dialog](Images/Chapters/0x05c/crackme-frida-1.png)

Let us see how we can prevent this.
The decompiled main method (using CFR decompiler) looks like this:

```
package sg.vantagepoint.uncrackable1;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.os.Bundle;
import android.text.Editable;
import android.view.View;
import android.widget.EditText;
import sg.vantagepoint.uncrackable1.a;
import sg.vantagepoint.uncrackable1.b;
import sg.vantagepoint.uncrackable1.c;

public class MainActivity
extends Activity {
    private void a(String string) {
        AlertDialog alertDialog = new AlertDialog.Builder((Context)this).create();
        alertDialog.setTitle((CharSequence)string);
        alertDialog.setMessage((CharSequence)"This in unacceptable. The app is now going to exit.");
        alertDialog.setButton(-3, (CharSequence)"OK", (DialogInterface.OnClickListener)new b(this));
        alertDialog.show();
    }

    protected void onCreate(Bundle bundle) {
        if (sg.vantagepoint.a.c.a() || sg.vantagepoint.a.c.b() || sg.vantagepoint.a.c.c()) {
            this.a("Root detected!"); //This is the message we are looking for
        }
        if (sg.vantagepoint.a.b.a((Context)this.getApplicationContext())) {
            this.a("App is debuggable!");
        }
        super.onCreate(bundle);
        this.setContentView(2130903040);
    }

    public void verify(View object) {
        object = ((EditText)this.findViewById(2131230720)).getText().toString();
        AlertDialog alertDialog = new AlertDialog.Builder((Context)this).create();
        if (a.a((String)object)) {
            alertDialog.setTitle((CharSequence)"Success!");
            alertDialog.setMessage((CharSequence)"This is the correct secret.");
        } else {
            alertDialog.setTitle((CharSequence)"Nope...");
            alertDialog.setMessage((CharSequence)"That's not it. Try again.");
        }
        alertDialog.setButton(-3, (CharSequence)"OK", (DialogInterface.OnClickListener)new c(this));
        alertDialog.show();
    }
}
```

Notice the `Root detected` message in the `onCreate` method and the various methods called in the the `if`-statement before which perform the actual root checks. Also note the `This is unacceptable...` message from the first method of the class, `private void a`. Obviously, this is where the dialog box gets displayed. There is a `alertDialog.onClickListener` callback set in the `setButton` method call which is responsible for closing the application via `System.exit(0)` after successful root detection. Using Frida, we can prevent the app from exiting by hooking the callback.

The onClickListener implementation for the dialog button doesn't to much:

```
package sg.vantagepoint.uncrackable1;

class b implements android.content.DialogInterface$OnClickListener {
    final sg.vantagepoint.uncrackable1.MainActivity a;

    b(sg.vantagepoint.uncrackable1.MainActivity a0)
    {
        this.a = a0;
        super();
    }

    public void onClick(android.content.DialogInterface a0, int i)
    {
        System.exit(0);
    }
}
```

It just exits the app. Now we intercept it using Frida to prevent the app from exiting after root detection:

```
setImmediate(function() { //prevent timeout
    console.log("[*] Starting script");

    Java.perform(function() {

      bClass = Java.use("sg.vantagepoint.uncrackable1.b");
      bClass.onClick.implementation = function(v) {
         console.log("[*] onClick called");
      }
      console.log("[*] onClick handler modified")

    })
})
```

We wrap our code in a setImmediate function to prevent timeouts (you may or may not need this), then call Java.perform to make use of Frida’s methods for dealing with Java. Afterwards we retrieve a wrapper for the class that implements the `OnClickListener` interface and overwrite its `onClick` method. Unlike the original, our new version of `onClick` just writes some console output and *does not exit the app*. If we inject our version of this method via Frida, the app should not exit anymore when we click the `OK` button of the dialog.

Save the above script as `uncrackable1.js` and load it:

```
frida -U -l uncrackable1.js sg.vantagepoint.uncrackable1
```

After you see the `onClickHandler modified` message, you can safely press the OK button in the app. The app does not exit anymore.

We can now try to input a "secret string". But where do we get it?

Looking at the class `sg.vantagepoint.uncrackable1.a` you can see the encrypted string to which our input gets compared:

```
package sg.vantagepoint.uncrackable1;

import android.util.Base64;
import android.util.Log;

public class a {
    public static boolean a(String string) {
        byte[] arrby = Base64.decode((String)"5UJiFctbmgbDoLXmpL12mkno8HT4Lv8dlat8FxR2GOc=", (int)0);
        byte[] arrby2 = new byte[]{};
        try {
            arrby2 = arrby = sg.vantagepoint.a.a.a((byte[])a.b((String)"8d127684cbc37c17616d806cf50473cc"), (byte[])arrby);
        }
        catch (Exception var2_2) {
            Log.d((String)"CodeCheck", (String)("AES error:" + var2_2.getMessage()));
        }
        if (!string.equals(new String(arrby2))) return false;
        return true;
    }

    public static byte[] b(String string) {
        int n = string.length();
        byte[] arrby = new byte[n / 2];
        int n2 = 0;
        while (n2 < n) {
            arrby[n2 / 2] = (byte)((Character.digit(string.charAt(n2), 16) << 4) + Character.digit(string.charAt(n2 + 1), 16));
            n2 += 2;
        }
        return arrby;
    }
}
```

Notice the string.equals comparison at the end of the a method and the creation of the string `arrby2` in the `try` block above. `arrby2` is the return value of the function `sg.vantagepoint.a.a.a`. The `string.equals` comparison compares our input to `arrby2`. So what we are after is the return value of `sg.vantagepoint.a.a.a.`

Instead of reversing the decryption routines to reconstruct the secret key, we can simply ignore all the decryption logic in the app and hook the `sg.vantagepoint.a.a.a` function to catch its return value.
Here is the complete script that prevents the exiting on root and intercepts the decryption of the secret string:

```
setImmediate(function() {
    console.log("[*] Starting script");

    Java.perform(function() {

        bClass = Java.use("sg.vantagepoint.uncrackable1.b");
        bClass.onClick.implementation = function(v) {
         console.log("[*] onClick called.");
        }
        console.log("[*] onClick handler modified")


        aaClass = Java.use("sg.vantagepoint.a.a");
        aaClass.a.implementation = function(arg1, arg2) {
            retval = this.a(arg1, arg2);
            password = ''
            for(i = 0; i < retval.length; i++) {
               password += String.fromCharCode(retval[i]);
            }

            console.log("[*] Decrypted: " + password);
            return retval;
        }
        console.log("[*] sg.vantagepoint.a.a.a modified");


    });

});
```

After running the script in Frida and seeing the `[*] sg.vantagepoint.a.a.a modified` message in the console, enter a random value for "secret string" and press verify. You should get an output similar to this:

```
michael@sixtyseven:~/Development/frida$ frida -U -l uncrackable1.js sg.vantagepoint.uncrackable1
     ____
    / _  |   Frida 9.1.16 - A world-class dynamic instrumentation framework
   | (_| |
    > _  |   Commands:
   /_/ |_|       help      -> Displays the help system
   . . . .       object?   -> Display information about 'object'
   . . . .       exit/quit -> Exit
   . . . .
   . . . .   More info at http://www.frida.re/docs/home/

[*] Starting script
[USB::Android Emulator 5554::sg.vantagepoint.uncrackable1]-> [*] onClick handler modified
[*] sg.vantagepoint.a.a.a modified
[*] onClick called.
[*] Decrypted: I want to believe
```
The hooked function outputted our decrypted string. Without having to dive too deep into the application code and its decryption routines, we were able to extract the secret string successfully.

We've now covered the basics of static/dynamic analysis on Android. Of course, the only way to *really* learn it is hands-on experience: Start by building your own projects in Android Studio and observing how your code gets translated to bytecode and native code, and have a shot at our cracking challenges.

In the remaining sections, we'll introduce a few advanced subjects including kernel modules and dynamic execution.

### Binary Analysis Frameworks

Binary analysis frameworks provide you powerful ways of automating tasks that would be almost impossible to complete manually. In the section, we'll have a look at the Angr framework, a python framework for analyzing binaries that is useful for both static and dynamic symbolic ("concolic") analysis. Angr operates on the VEX intermediate language, and comes with a loader for ELF/ARM binaries, so it is perfect for dealing with native Android binaries.

Our target program is a simple license key validation program. Granted, you won't usually find a license key validator like this in the wild, but it should be useful enough to demonstrate the basics of static/symbolic analysis of native code. You can use the same techniques on Android apps that ship with obfuscated native libraries (in fact, obfuscated code is often put into native libraries, precisely to make de-obfuscation more difficult).

#### Installing Angr

Angr is written in Python 2 and available from PyPI. It is easy to install on \*nix operating systems and Mac OS using pip:

```
$ pip install angr
```

It is recommended to create a dedicated virtual environment with Virtualenv as some of its dependencies contain forked versions Z3 and PyVEX that overwrite the original versions (you may skip this step if you don't use these libraries for anything else - on the other hand, using Virtualenv is generally a good idea).

Quite comprehensive documentation for angr is available on Gitbooks, including an installation guide, tutorials and usage examples [5]. A complete API reference is also available [6].

#### Using the Disassembler Backends

<a name="symbolicexec"></a>
#### Symbolic Execution

Symbolic execution allows you to determine the conditions necessary to reach a specific target. It does this by translating the program’s semantics into a logical formula, whereby some variables are represented as symbols with specific constraints. By resolving the constraints, you can find out the conditions necessary so that some branch of the program gets executed.

Amongst other things, this is useful in cases where we need to find the right inputs for reaching a certain block of code. In the following example, we'll use Angr to solve a simple Android crackme in an automated fashion. The crackme takes the form of a native ELF binary that can be downloaded here:

https://github.com/angr/angr-doc/tree/master/examples/android_arm_license_validation

Running the executable on any Android device should give you the following output.

```bash
$ adb push validate /data/local/tmp
[100%] /data/local/tmp/validate
$ adb shell chmod 755 /data/local/tmp/validate
$ adb shell /data/local/tmp/validate
Usage: ./validate <serial>
$ adb shell /data/local/tmp/validate 12345
Incorrect serial (wrong format).
```

So far, so good, but we really know nothing about how a valid license key might look like. Where do we start? Let's fire up IDA Pro to get a first good look at what is happening.

![Disassembly of function main.](Images/Chapters/0x05c/license-check-1.jpg)

The main function is located at address 0x1874 in the disassembly (note that this is a PIE-enabled binary, and IDA Pro chooses 0x0 as the image base address). Function names have been stripped, but luckily we can see some references to debugging strings: It appears that the input string is base32-decoded (call to sub_1340). At the beginning of main, there's also a length check at loc_1898 that verifies that the length of the input string is exactly 16. So we're looking for a 16 character base32-encoded string! The decoded input is then passed to the function sub_1760, which verifies the validity of the license key.

The 16-character base32 input string decodes to 10 bytes, so we know that the validation function expects a 10 byte binary string. Next, we have a look at the core validation function at 0x1760:

```assembly_x68
.text:00001760 ; =============== S U B R O U T I N E =======================================
.text:00001760
.text:00001760 ; Attributes: bp-based frame
.text:00001760
.text:00001760 sub_1760                                ; CODE XREF: sub_1874+B0
.text:00001760
.text:00001760 var_20          = -0x20
.text:00001760 var_1C          = -0x1C
.text:00001760 var_1B          = -0x1B
.text:00001760 var_1A          = -0x1A
.text:00001760 var_19          = -0x19
.text:00001760 var_18          = -0x18
.text:00001760 var_14          = -0x14
.text:00001760 var_10          = -0x10
.text:00001760 var_C           = -0xC
.text:00001760
.text:00001760                 STMFD   SP!, {R4,R11,LR}
.text:00001764                 ADD     R11, SP, #8
.text:00001768                 SUB     SP, SP, #0x1C
.text:0000176C                 STR     R0, [R11,#var_20]
.text:00001770                 LDR     R3, [R11,#var_20]
.text:00001774                 STR     R3, [R11,#var_10]
.text:00001778                 MOV     R3, #0
.text:0000177C                 STR     R3, [R11,#var_14]
.text:00001780                 B       loc_17D0
.text:00001784 ; ---------------------------------------------------------------------------
.text:00001784
.text:00001784 loc_1784                                ; CODE XREF: sub_1760+78
.text:00001784                 LDR     R3, [R11,#var_10]
.text:00001788                 LDRB    R2, [R3]
.text:0000178C                 LDR     R3, [R11,#var_10]
.text:00001790                 ADD     R3, R3, #1
.text:00001794                 LDRB    R3, [R3]
.text:00001798                 EOR     R3, R2, R3
.text:0000179C                 AND     R2, R3, #0xFF
.text:000017A0                 MOV     R3, #0xFFFFFFF0
.text:000017A4                 LDR     R1, [R11,#var_14]
.text:000017A8                 SUB     R0, R11, #-var_C
.text:000017AC                 ADD     R1, R0, R1
.text:000017B0                 ADD     R3, R1, R3
.text:000017B4                 STRB    R2, [R3]
.text:000017B8                 LDR     R3, [R11,#var_10]
.text:000017BC                 ADD     R3, R3, #2
.text:000017C0                 STR     R3, [R11,#var_10]
.text:000017C4                 LDR     R3, [R11,#var_14]
.text:000017C8                 ADD     R3, R3, #1
.text:000017CC                 STR     R3, [R11,#var_14]
.text:000017D0
.text:000017D0 loc_17D0                                ; CODE XREF: sub_1760+20
.text:000017D0                 LDR     R3, [R11,#var_14]
.text:000017D4                 CMP     R3, #4
.text:000017D8                 BLE     loc_1784
.text:000017DC                 LDRB    R4, [R11,#var_1C]
.text:000017E0                 BL      sub_16F0
.text:000017E4                 MOV     R3, R0
.text:000017E8                 CMP     R4, R3
.text:000017EC                 BNE     loc_1854
.text:000017F0                 LDRB    R4, [R11,#var_1B]
.text:000017F4                 BL      sub_170C
.text:000017F8                 MOV     R3, R0
.text:000017FC                 CMP     R4, R3
.text:00001800                 BNE     loc_1854
.text:00001804                 LDRB    R4, [R11,#var_1A]
.text:00001808                 BL      sub_16F0
.text:0000180C                 MOV     R3, R0
.text:00001810                 CMP     R4, R3
.text:00001814                 BNE     loc_1854
.text:00001818                 LDRB    R4, [R11,#var_19]
.text:0000181C                 BL      sub_1728
.text:00001820                 MOV     R3, R0
.text:00001824                 CMP     R4, R3
.text:00001828                 BNE     loc_1854
.text:0000182C                 LDRB    R4, [R11,#var_18]
.text:00001830                 BL      sub_1744
.text:00001834                 MOV     R3, R0
.text:00001838                 CMP     R4, R3
.text:0000183C                 BNE     loc_1854
.text:00001840                 LDR     R3, =(aProductActivat - 0x184C)
.text:00001844                 ADD     R3, PC, R3      ; "Product activation passed. Congratulati"...
.text:00001848                 MOV     R0, R3          ; char *
.text:0000184C                 BL      puts
.text:00001850                 B       loc_1864
.text:00001854 ; ---------------------------------------------------------------------------
.text:00001854
.text:00001854 loc_1854                                ; CODE XREF: sub_1760+8C
.text:00001854                                         ; sub_1760+A0 ...
.text:00001854                 LDR     R3, =(aIncorrectSer_0 - 0x1860)
.text:00001858                 ADD     R3, PC, R3      ; "Incorrect serial."
.text:0000185C                 MOV     R0, R3          ; char *
.text:00001860                 BL      puts
.text:00001864
.text:00001864 loc_1864                                ; CODE XREF: sub_1760+F0
.text:00001864                 SUB     SP, R11, #8
.text:00001868                 LDMFD   SP!, {R4,R11,PC}
.text:00001868 ; End of function sub_1760
```

We can see a loop with some XOR-magic happening at loc_1784, which supposedly decodes the input string. Starting from loc_17DC, we see a series of comparisons of the decoded values with values obtained from further sub-function calls. Even though this doesn't look like highly sophisticated stuff, we'd still need to do some more analysis to completely reverse this check and generate a license key that passes it. But now comes the twist: By using dynamic symbolic execution, we can construct a valid key automatically! The symbolic execution engine can map a path between the first instruction of the license check (0x1760) and the code printing the "Product activation passed" message (0x1840) and determine the constraints on each byte of the input string. The solver engine then finds an input that satisfies those constraints: The valid license key.

We need to provide several inputs to the symbolic execution engine:

- The address to start execution from. We initialize the state with the first instruction of the serial validation function. This makes the task significantly easier (and in this case, almost instant) to solve, as we avoid symbolically executing the Base32 implementation.

- The address of the code block we want execution to reach. In this case, we want to find a path to the code responsible for printing the "Product activation passed" message. This block starts at 0x1840.

- Addresses we don't want to reach. In this case, we're not interesting in any path that arrives at the block of code printing the "Incorrect serial" message, at 0x1854.

Note that Angr loader will load the PIE executable with a base address of 0x400000, so we have to add this to the addresses above. The solution looks as follows.

```python
#!/usr/bin/python

# This is how we defeat the Android license check using Angr!
# The binary is available for download on GitHub:
# https://github.com/b-mueller/obfuscation-metrics/tree/master/crackmes/android/01_license_check_1
# Written by Bernhard -- bernhard [dot] mueller [at] owasp [dot] org

import angr
import claripy
import base64

load_options = {}

# Android NDK library path:
load_options['custom_ld_path'] = ['/Users/berndt/Tools/android-ndk-r10e/platforms/android-21/arch-arm/usr/lib']

b = angr.Project("./validate", load_options = load_options)

# The key validation function starts at 0x401760, so that's where we create the initial state.
# This speeds things up a lot because we're bypassing the Base32-encoder.

state = b.factory.blank_state(addr=0x401760)

initial_path = b.factory.path(state)
path_group = b.factory.path_group(state)

# 0x401840 = Product activation passed
# 0x401854 = Incorrect serial

path_group.explore(find=0x401840, avoid=0x401854)
found = path_group.found[0]

# Get the solution string from *(R11 - 0x24).

addr = found.state.memory.load(found.state.regs.r11 - 0x24, endness='Iend_LE')
concrete_addr = found.state.se.any_int(addr)
solution = found.state.se.any_str(found.state.memory.load(concrete_addr,10))

print base64.b32encode(solution)
```

Note the last part of the program where the final input string is obtained - it appears if we were simply reading the solution from memory. We are however reading from symbolic memory - neither the string nor the pointer to it actually exist! What's really happening is that the solver is computing possible concrete values that could be found at that program state, would we observer the actual program run to that point.

Running this script should return the following:

```
(angr) $ python solve.py
WARNING | 2017-01-09 17:17:03,664 | cle.loader | The main binary is a position-independent executable. It is being loaded with a base address of 0x400000.
JQAE6ACMABNAAIIA
```

### Customizing Android for Reverse Engineering

Working on real device has advantages especially for interactive, debugger-supported static / dynamic analysis. For one, it is simply faster to work on a real device. Also, being run on a real device gives the target app less reason to be suspicious and misbehave. By instrumenting the live environment at strategic points, we can obtain useful tracing functionality and manipulate the environment to help us bypass any anti-tampering defenses the app might implement.

#### Customizing the RAMDisk

The initramfs is a small CPIO archive stored inside the boot image. It contains a few files that are required at boot time before the actual root file system is mounted. On Android, the initramfs stays mounted indefinitely, and it contains an important configuration file named default.prop that defines some basic system properties. By making some changes to this file, we can make the Android environment a bit more reverse-engineering-friendly. For our purposes, the most important settings in default.prop are <code>ro.debuggable</code> and <code>ro.secure</code>.

```bash
$ cat /default.prop                                         
#
# ADDITIONAL_DEFAULT_PROPERTIES
#
ro.secure=1
ro.allow.mock.location=0
ro.debuggable=1
ro.zygote=zygote32
persist.radio.snapshot_enabled=1
persist.radio.snapshot_timer=2
persist.radio.use_cc_names=true
persist.sys.usb.config=mtp
rild.libpath=/system/lib/libril-qc-qmi-1.so
camera.disable_zsl_mode=1
ro.adb.secure=1
dalvik.vm.dex2oat-Xms=64m
dalvik.vm.dex2oat-Xmx=512m
dalvik.vm.image-dex2oat-Xms=64m
dalvik.vm.image-dex2oat-Xmx=64m
ro.dalvik.vm.native.bridge=0
```

Setting ro.debuggable to 1 causes all apps running on the system to be debuggable (i.e., the debugger thread runs in every process), independent of the android:debuggable attribute in the app’s Manifest. Setting ro.secure to 0 causes adbd to be run as root.
To modify initrd on any Android device, back up the original boot image using TWRP, or simply dump it with a command like:

```bash
$ adb shell cat /dev/mtd/mtd0 >/mnt/sdcard/boot.img
$ adb pull /mnt/sdcard/boot.img /tmp/boot.img
```

Use the abootimg tool as described in Krzysztof Adamski’s how-to to extract the contents of the boot image:

```bash
$ mkdir boot
$ cd boot
$ ../abootimg -x /tmp/boot.img
$ mkdir initrd
$ cd initrd
$ cat ../initrd.img | gunzip | cpio -vid
```

Take note of the boot parameters written to bootimg.cfg – you will need to these parameters later when booting your new kernel and ramdisk.

```bash
$ ~/Desktop/abootimg/boot$ cat bootimg.cfg
bootsize = 0x1600000
pagesize = 0x800
kerneladdr = 0x8000
ramdiskaddr = 0x2900000
secondaddr = 0xf00000
tagsaddr = 0x2700000
name =
cmdline = console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 maxcpus=2 msm_watchdog_v2.enable=1
```

Modify default.prop and package your new ramdisk:

```bash
$ cd initrd
$ find . | cpio --create --format='newc' | gzip > ../myinitd.img
```

#### Customizing the Android Kernel

The Android kernel is a powerful ally to the reverse engineer. While regular Android apps are hopelessly restricted and sandboxed, you - the reverser - can customize and alter the behavior of the operating system and kernel any way you wish. This gives you a really unfair advantage, because most integrity checks and anti-tampering features ultimately rely on services performed by the kernel. Deploying a kernel that abuses this trust, and unabashedly lies about itself and the environment, goes a long way in defeating most reversing defenses that malware authors (or normal developers) can throw at you.

Android apps have several ways of interacting with the OS environment. The standard way is through the APIs of the Android Application Framework. On the lowest level however, many important functions, such as allocating memory and accessing files, are translated into perfectly old-school Linux system calls. In ARM Linux, system calls are invoked via the SVC instruction which triggers a software interrupt. This interrupt calls the vector_swi() kernel function, which then uses the system call number as an offset into a table of function pointers (a.k.a. sys_call_table on Android).

The most straightforward way of intercepting system calls is injecting your own code into kernel memory, then overwriting the original function in the system call table to redirect execution. Unfortunately, current stock Android kernels enforce memory restrictions that prevent this from working. Specifically, stock Lollipop and Marshmallow kernel are built with the CONFIG_STRICT_MEMORY_RWX option enabled. This prevents writing to kernel memory regions marked as read-only, which means that any attempts to patch kernel code or the system call table result in a segmentation fault and reboot. A way to get around this is to build your own kernel: You can then deactivate this protection, and make many other useful customizations to make reverse engineering easier. If you're reversing Android apps on a regular basis, building your own reverse engineering sandbox is a no-brainer.

For hacking purposes, I recommend using an AOSP-supported device. Google’s Nexus smartphones and tablets are the most logical candidates – kernels and system components built from the AOSP run on them without issues. Alternatively, Sony’s Xperia series is also known for its openness. To build the AOSP kernel you need a toolchain (set of programs to cross-compile the sources) as well as the appropriate version of the kernel sources. Follow Google's instructions to identify the correct git repo and branch for a given device and Android version.

https://source.android.com/source/building-kernels.html#id-version

For example, to get kernel sources for Lollipop that are compatible with the Nexus 5, you need to clone the "msm" repo and check out one the "android-msm-hammerhead" branch (hammerhead is the codename of the Nexus 5, and yes, finding the right branch is a confusing process). Once the sources are downloaded, create the default kernel config with the command make hammerhead_defconfig (or whatever_defconfig, depending on your target device).

```bash
$ git clone https://android.googlesource.com/kernel/msm.git
$ cd msm
$ git checkout origin/android-msm-hammerhead-3.4-lollipop-mr1
$ export ARCH=arm
$ export SUBARCH=arm
$ make hammerhead_defconfig
$ vim .config
```

I recommend using the following settings to enable the most important tracing facilities, add loadable module support, and open up kernel memory for patching.

```
CONFIG_MODULES=Y
CONFIG_STRICT_MEMORY_RWX=N
CONFIG_DEVMEM=Y
CONFIG_DEVKMEM=Y
CONFIG_KALLSYMS=Y
CONFIG_KALLSYMS_ALL=Y
CONFIG_HAVE_KPROBES=Y
CONFIG_HAVE_KRETPROBES=Y
CONFIG_HAVE_FUNCTION_TRACER=Y
CONFIG_HAVE_FUNCTION_GRAPH_TRACER=Y
CONFIG_TRACING=Y
CONFIG_FTRACE=Y
CONFIG KDB=Y
```

Once you are finished editing save the .config file and build the kernel.

```bash
$ export ARCH=arm
$ export SUBARCH=arm
$ export CROSS_COMPILE=/path_to_your_ndk/arm-eabi-4.8/bin/arm-eabi-
$ make
```

Once you are finished editing save the .config file. Optionally, you can now create a standalone toolchain for cross-compiling the kernel and later tasks. To create a toolchain for Android Nougat, run make-standalone-toolchain.sh from the Android NDK package as follows:

```bash
$ cd android-ndk-rXXX
$ build/tools/make-standalone-toolchain.sh --arch=arm --platform=android-24 --install-dir=/tmp/my-android-toolchain
```

Set the CROSS_COMPILE environment variable to point to your NDK directory and run "make" to build
the kernel.

```bash
$ export CROSS_COMPILE=/tmp/my-android-toolchain/bin/arm-eabi-
$ make
```

#### Booting the Custom Environment

Before booting into the new Kernel, make a copy of the original boot image from your device. Look up the location of the boot partition as follows:

```bash
root@hammerhead:/dev # ls -al /dev/block/platform/msm_sdcc.1/by-name/         
lrwxrwxrwx root     root              1970-08-30 22:31 DDR -> /dev/block/mmcblk0p24
lrwxrwxrwx root     root              1970-08-30 22:31 aboot -> /dev/block/mmcblk0p6
lrwxrwxrwx root     root              1970-08-30 22:31 abootb -> /dev/block/mmcblk0p11
lrwxrwxrwx root     root              1970-08-30 22:31 boot -> /dev/block/mmcblk0p19
(...)
lrwxrwxrwx root     root              1970-08-30 22:31 userdata -> /dev/block/mmcblk0p28
```

Then, dump the whole thing into a file:

```bash
$ adb shell "su -c dd if=/dev/block/mmcblk0p19 of=/data/local/tmp/boot.img"
$ adb pull /data/local/tmp/boot.img
```

Next, extract the ramdisk as well as some information about the structure of the boot image. There are various tools that can do this - I used Gilles Grandou's abootimg tool. Install the tool and run the following command on your boot image:

```bash
$ abootimg -x boot.img
```

This should create the files bootimg.cfg, initrd.img and zImage (your original kernel) in the local directory.

You can now use fastboot to test the new kernel. The "fastboot boot" command allows you to run the kernel without actually flashing it (once you’re sure everything works, you can make the changes permanent with fastboot flash - but you don't have to). Restart the device in fastboot mode with the following command:

```bash
$ adb reboot bootloader
```

Then, use the "fastboot boot" command to boot Android with the new kernel. In addition to the newly built kernel and the original ramdisk, specify the kernel offset, ramdisk offset, tags offset and commandline (use the values listed in your previously extracted bootimg.cfg).

```bash
$ fastboot boot zImage-dtb initrd.img --base 0 --kernel-offset 0x8000 --ramdisk-offset 0x2900000 --tags-offset 0x2700000 -c "console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 maxcpus=2 msm_watchdog_v2.enable=1"
```

The system should now boot normally. To quickly verify that the correct kernel is running, navigate to Settings->About phone and check the “kernel version” field.

<img src="Images/Chapters/0x05c/custom_kernel.jpg" width="350px" />

#### System Call Hooking Using Kernel Modules

System call hooking allows us to attack any anti-reversing defenses that depend on functionality provided by the kernel. With our custom kernel in place, we can now use a LKM to load additional code into the kernel. We also have access to the /dev/kmem interface, which we can use to patch kernel memory on-the-fly. This is a classical Linux rootkit technique and has been described for Android by Dong-Hoon You [1].

<img src="Images/Chapters/0x05c/syscall_hooking.jpg" width="700px"/>

The first piece of information we need is the address of sys_call_table. Fortunately, it is exported as a symbol in the Android kernel (iOS reversers are not so lucky). We can look up the address in the /proc/kallsyms file:

```bash
$ adb shell "su -c echo 0 > /proc/sys/kernel/kptr_restrict"
$ adb shell cat /proc/kallsyms | grep sys_call_table
c000f984 T sys_call_table
```

This is the only memory address we need for writing our kernel module - everything else can be calculated using offsets taken from the Kernel headers (hopefully you didn't delete them yet?).

##### Example: File Hiding

In this howto, we're going to use a Kernel module to hide a file. Let's create a file on the device so we can hide it later:

```bash
$ adb shell "su -c echo ABCD > /data/local/tmp/nowyouseeme"             
$ adb shell cat /data/local/tmp/nowyouseeme
ABCD
```bash

Finally it's time to write the kernel module. For file hiding purposes, we'll need to hook one of the system calls used to open (or check for the existence of) files. Actually, there many of those - open, openat, access, accessat, facessat, stat, fstat, and more. For now, we'll only hook the openat system call - this is the syscall used by the "/bin/cat" program when accessing a file, so it should be servicable enough for a demonstration.

You can find the function prototypes for all system calls in the kernel header file arch/arm/include/asm/unistd.h. Create a file called kernel_hook.c with the following code:

```c
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/unistd.h>
#include <linux/slab.h>
#include <asm/uaccess.h>

asmlinkage int (*real_openat)(int, const char __user*, int);

void **sys_call_table;

int new_openat(int dirfd, const char \__user* pathname, int flags)
{
  char *kbuf;
  size_t len;

  kbuf=(char*)kmalloc(256,GFP_KERNEL);
  len = strncpy_from_user(kbuf,pathname,255);

  if (strcmp(kbuf, "/data/local/tmp/nowyouseeme") == 0) {
    printk("Hiding file!\n");
    return -ENOENT;
  }

  kfree(kbuf);

  return real_openat(dirfd, pathname, flags);
}

int init_module() {

  sys_call_table = (void*)0xc000f984;
  real_openat = (void*)(sys_call_table[__NR_openat]);

return 0;

}
```

To build the kernel module, you need the kernel sources and a working toolchain - since you already built a complete kernel before, you are all set. Create a Makefile with the following content:

```make
KERNEL=[YOUR KERNEL PATH]
TOOLCHAIN=[YOUR TOOLCHAIN PATH]

obj-m := kernel_hook.o

all:
        make ARCH=arm CROSS_COMPILE=$(TOOLCHAIN)/bin/arm-eabi- -C $(KERNEL) M=$(shell pwd) CFLAGS_MODULE=-fno-pic modules

clean:
        make -C $(KERNEL) M=$(shell pwd) clean
```

Run "make" to compile the code – this should create the file kernel_hook.ko. Copy the kernel_hook.ko file to the device and load it with the insmod command. Verify with the lsmod command that the module has been loaded successfully.

```bash
$ make
(...)
$ adb push kernel_hook.ko /data/local/tmp/
[100%] /data/local/tmp/kernel_hook.ko
$ adb shell su -c insmod /data/local/tmp/kernel_hook.ko
$ adb shell lsmod
kernel_hook 1160 0 [permanent], Live 0xbf000000 (PO)
```

Now, we’ll access /dev/kmem to overwrite the original function pointer in sys_call_table with the address of our newly injected function (this could have been done directly in the kernel module as well, but using /dev/kmem gives us an easy way to toggle our hooks on and off). I have adapted the code from Dong-Hoon You’s Phrack article <code>[19]</code> for this purpose - however, I used the file interface instead of mmap(), as I found the latter to cause kernel panics for some reason. Create a file called kmem_util.c with the following code:

```c
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <asm/unistd.h>
#include <sys/mman.h>

#define MAP_SIZE 4096UL
#define MAP_MASK (MAP_SIZE - 1)

int kmem;
void read_kmem2(unsigned char *buf, off_t off, int sz)
{
  off_t offset; ssize_t bread;
  offset = lseek(kmem, off, SEEK_SET);
  bread = read(kmem, buf, sz);
  return;
}

void write_kmem2(unsigned char *buf, off_t off, int sz) {
  off_t offset; ssize_t written;
  offset = lseek(kmem, off, SEEK_SET);
  if (written = write(kmem, buf, sz) == -1) { perror("Write error");
    exit(0);
  }
  return;
}

int main(int argc, char *argv[]) {

  off_t sys_call_table;
  unsigned int addr_ptr, sys_call_number;

  if (argc < 3) {
    return 0;
  }

  kmem=open("/dev/kmem",O_RDWR);

  if(kmem<0){
    perror("Error opening kmem"); return 0;
  }

  sscanf(argv[1], "%x", &sys_call_table); sscanf(argv[2], "%d", &sys_call_number);
  sscanf(argv[3], "%x", &addr_ptr); char buf[256];
  memset (buf, 0, 256); read_kmem2(buf,sys_call_table+(sys_call_number*4),4);
  printf("Original value: %02x%02x%02x%02x\n", buf[3], buf[2], buf[1], buf[0]);       
  write_kmem2((void*)&addr_ptr,sys_call_table+(sys_call_number*4),4);
  read_kmem2(buf,sys_call_table+(sys_call_number*4),4);
  printf("New value: %02x%02x%02x%02x\n", buf[3], buf[2], buf[1], buf[0]);
  close(kmem);

  return 0;
}
```

Build kmem_util.c using the prebuilt toolchain and copy it to the device. Note that from Android Lollipop, all executables must be compiled with PIE support:

```bash
$ /tmp/my-android-toolchain/bin/arm-linux-androideabi-gcc -pie -fpie -o kmem_util kmem_util.c
$ adb push kmem_util /data/local/tmp/
$ adb shell chmod 755 /data/local/tmp/kmem_util
```

Before we start messing with kernel memory we still need to know the correct offset into the system call table. The openat system call is defined in unistd.h which is found in the kernel sources:

```bash
$ grep -r "__NR_openat" arch/arm/include/asm/unistd.h
\#define __NR_openat            (__NR_SYSCALL_BASE+322)
```

The final piece of the puzzle is the address of our replacement-openat. Again, we can get this address from /proc/kallsyms.

```bash
$ adb shell cat /proc/kallsyms | grep new_openat
bf000000 t new_openat    [kernel_hook]
```

Now we have everything we need to overwrite the sys_call_table entry. The syntax for kmem_util is:

```bash
./kmem_util <syscall_table_base_address> <offset> <func_addr>
```

The following command patches the openat system call table to point to our new function.

```bash
$ adb shell su -c /data/local/tmp/kmem_util c000f984 322 bf000000
Original value: c017a390
New value: bf000000
```


Assuming that everything worked, /bin/cat should now be unable to "see" the file.

```bash
$ adb shell su -c cat /data/local/tmp/nowyouseeme
tmp-mksh: cat: /data/local/tmp/nowyouseeme: No such file or directory
```

Voilá! The file "nowyouseeme" is now somewhat hidden from the view of all usermode processes (note that there's a lot more you need to do to properly hide a file, including hooking stat(), access(), and other system calls, as well as hiding the file in directory listings).

File hiding is of course only the tip of the iceberg: You can accomplish a whole lot of things, including bypassing many root detection measures, integrity checks, and anti-debugging tricks. You can find some additional examples in the "case studies" section in the Bernhard Mueller's Hacking Soft Tokens Paper <sup>[27]</sup>.

### References

- [1] UnCrackable Mobile Apps - https://github.com/OWASP/owasp-mstg/blob/master/Crackmes/
- [2] Android Studio - https://developer.android.com/studio/index.html
- [3] JD - http://jd.benow.ca/
- [4] JAD - http://www.javadecompilers.com/jad
- [5] Proycon - http://proycon.com/en/
- [6] CFR - http://www.benf.org/other/cfr/
- [7] apkx - APK Decompilation for the Lazy - https://github.com/b-mueller/apkx
- [8] NDK Downloads - https://developer.android.com/ndk/downloads/index.html#stable-downloads
- [9] IntelliJ IDEA - https://www.jetbrains.com/idea/
- [10] Eclipse - https://eclipse.org/ide/
- [11] Smalidea - https://github.com/JesusFreke/smali/wiki/smalidea
- [12] APKTool - https://ibotpeaches.github.io/Apktool/
- [13] Radare2 - https://www.radare.org
- [14] Angr - http://angr.io/
- [15] JEB Decompiler - https://www.pnfsoftware.com
- [16] IDA Pro - https://www.hex-rays.com/products/ida/
- [17] Bionic libc - https://github.com/android/platform_bionic
- [18] NetSPI Blog - Attacking Android Applications with Debuggers - https://blog.netspi.com/attacking-android-applications-with-debuggers/
- [19] Phrack Magazine - Android Platform based Linux kernel rootkit
- [20] DECAF - https://github.com/sycurelab/DECAF
- [21] PANDA - https://github.com/moyix/panda/blob/master/docs/
- [22] VxStripper - http://vxstripper.pagesperso-orange.fr
- [23] Dynamic Malware Recompliation - http://ieeexplore.ieee.org/document/6759227/
- [24] Xposed - http://repo.xposed.info/module/de.robv.android.xposed.installer
- [25] Xposed Development Tutorial - https://github.com/rovo89/XposedBridge/wiki/Development-tutorial
- [26] Frida - https://www.frida.re
- [27] Hacking Soft Tokens on - https://packetstormsecurity.com/files/138504/HITB_Hacking_Soft_Tokens_v1.2.pdf
