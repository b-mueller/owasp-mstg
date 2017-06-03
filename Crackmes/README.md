# UnCrackable Mobile Apps

<img align="left" width="100px" src="../Document/Images/Other/uncrackable-logo.png">

Welcome to the UnCrackable Apps for Android and iOS, a collection of mobile reverse engineering challenges. These challenges are used as examples throughout the Mobile Security Testing Guide. Of course, you can also solve them for fun. If you do solve any of the challenges, please take a moment to do our brief post-cracking [survey](https://www.surveymonkey.com/r/2TS2MZJ).

# Android

## [UnCrackable App for Android Level 1](https://github.com/OWASP/owasp-mstg/tree/master/Crackmes/Android/Level_01/)

This app holds a secret inside. Can you find it?

- Objective: A secret string is hidden somewhere in this app. Find a way to extract it. 
- Author: [Bernhard Mueller](https://github.com/b-mueller)

### Installation

```
$ adb install UnCrackable-Level1.apk
```

### Solutions

- [Solution using frida by c0dmtr1x](https://www.codemetrix.net/hacking-android-apps-with-frida-2/)
- [Multiple solutions by David Weinstein](https://www.nowsecure.com/blog/2017/04/27/owasp-ios-crackme-tutorial-frida/)
- [Solution using static analysis](https://github.com/OWASP/owasp-mstg/blob/master/Document/0x05c-Reverse-Engineering-and-Tampering.md#user-content-statically-analyzing-java-code)
- [Solution using jdb](https://github.com/OWASP/owasp-mstg/blob/master/Document/0x05c-Reverse-Engineering-and-Tampering.md#user-content-debugging-release-apps)
- [Solution using frida by Eduardo Novella](https://enovella.github.io/android/reverse/2017/05/18/android-owasp-crackmes-level-1.html)
- [Solution using Xposed by sh3llc0d3r](http://sh3llc0d3r.com/owasp-uncrackable-android-level1/)

## [UnCrackable App for Android Level 2](https://github.com/OWASP/owasp-mstg/tree/master/Crackmes/Android/Level_02/)

This app holds a secret inside. May include traces of native code.

- Objective: A secret string is hidden somewhere in this app. Find a way to extract it. 
- Author: [Bernhard Mueller](https://github.com/b-mueller)
- Special thanks to Michael Helwig for finding and fixing an oversight in the anti-tampering mechanism.

### Installation

```
$ adb install UnCrackable-Level2.apk
```

### Solutions

- [Solution using frida and radare2 by c0dmtr1x](https://www.codemetrix.net/hacking-android-apps-with-frida-3/)
- [Solution using frida by Eduardo Novella](https://enovella.github.io/android/reverse/2017/05/20/android-owasp-crackmes-level-2.html)
- [Solution using patches by sh3llc0d3r](http://sh3llc0d3r.com/owasp-uncrackable-android-level2/)

## [UnCrackable App for Android Level 3](https://github.com/OWASP/owasp-mstg/tree/master/Crackmes/Android/Level_03/)

The crackme from hell!

- Objective: A secret string is hidden somewhere in this app. Find a way to extract it. 
- Author: [Bernhard Mueller](https://github.com/b-mueller)
- Special thanks to Eduardo Novella for testing, feedback and pointing out flaws in the initial build(s).

### Installation

```
$ adb install UnCrackable-Level3.apk
```

### Solutions

- [Solution using frida by Eduardo Novella](https://enovella.github.io/android/reverse/2017/05/20/android-owasp-crackmes-level-3.html)
- [Solution using patches by sh3llc0d3r](http://sh3llc0d3r.com/owasp-uncrackable-android-level3/)

## [Android License Validator](https://github.com/OWASP/owasp-mstg/tree/master/Crackmes/Android/License_01/)

A brand new Android app sparks your interest. Of course, you are planning to purchase a license for the app eventually, but you'd still appreciate a test run before shelling out $1. Unfortunately no keygen is available! 

- Objective: Generate a valid serial key that is accepted by this app.
- Author: [Bernhard Mueller](https://github.com/b-mueller)

### Installation

Copy the binary to your Android device and run using the shell.

```
$ adb push validate /data/local/tmp
[100%] /data/local/tmp/validate
$ adb shell chmod 755 /data/local/tmp/validate
$ adb shell /data/local/tmp/validate
Usage: ./validate <serial>
$ adb shell /data/local/tmp/validate 1234
Incorrect serial (wrong format).
```

### Solutions

- [Dynamic Symbolic Execution in the Android Reverse Engineering Guide](https://github.com/OWASP/owasp-mstg/blob/master/Document/0x05c-Reverse-Engineering-and-Tampering.md#user-content-symbolic-execution) (by the author)

# iOS

## [UnCrackable App for iOS Level 1](https://github.com/OWASP/owasp-mstg/tree/master/Crackmes/iOS/Level_01/)

This app holds a secret inside. Can you find it?

Objective: A secret string is hidden somewhere in this binary. Find a way to extract it. The app will give you a hint when started.

- Author: [Bernhard Mueller](https://github.com/b-mueller)

### Installation

Open the "Device" window in XCode and drag the IPA file into the list below "Installed Apps". 

Note: The IPA is signed with an Enterprise distribution certificate. You'll need to install the provisioning profile and trust the developer to run the app the "normal" way. Alternatively, re-sign the app with your own certificate, or run it on a jailbroken device (you'll want to do one of those anyway to crack it).

### Solutions

- [Solution by Ryan Teoh](http://www.ryantzj.com/cracking-owasp-mstg-ios-crackme-the-uncrackable.html)

## [UnCrackable App for iOS Level 2](https://github.com/OWASP/owasp-mstg/tree/master/Crackmes/iOS/Level_02/)

This app holds a secret inside - and this time it won't be tampered with!

- Author: [Bernhard Mueller](https://github.com/b-mueller)

Objective: Find the secret code - it is related to alcoholic beverages.

Note: Due to its anti-tampering the app won't run correctly if the main executable is modified and/or re-signed. You'll need to trust the developer run it the standard way on a non-jailbroken device (General Settings -> Profile & Device Management) and to verify the solution. 

### Installation

Open the "Device" window in XCode and drag the IPA file into the list below "Installed Apps". 

Note: The IPA is signed with an Enterprise distribution certificate. You'll need to install the provisioning profile and trust the developer to run the app the "normal" way. Alternatively, re-sign the app with your own certificate, or run it on a jailbroken device (you'll want to do one of those anyway to crack it).

### Solutions

- [Solution by Ryan Teoh](http://www.ryantzj.com/cracking-owasp-mstg-ios-crackme-the-uncrackable.html)
