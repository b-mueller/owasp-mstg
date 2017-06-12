
## Mobile App Taxonomy

The following section is a brief introduction to the 3 different types of mobile applications, namely the (1) Native App, (2) Hybrid App and (3) Web App. Before we dive into them, it is essential to first understand what a mobile app is.

### Mobile App

The term `mobile app` refers to applications (self-contained computer programs), designed to execute and enhance the functionality of a mobile device. In this guide we will focus on the mobile apps designed to run on Android and iOS operating systems, as cumulatively they take more than 99% of the market share<sup>[12]</sup>. Due to the expansion of these operating systems to other device types, like smart watches, TVs, cars, etc. a more general term `app` is more appropriate. Nevertheless, for historic reasons, both terms are used interchangeably to refer to an application that can run on some of these systems, regardless of the exact device type.

Today, mobile internet usage has surpassed desktop usage for the first time in history and mobile apps are the most widespread kind of applications<sup>[10]</sup>.

### Native App

Most operating systems, including Android and iOS, come with set of high-level APIs that can be used to develop applications specifically for that system. Such applications are called `native` for the system for which they have been developed. Usually, when discussing about `mobile app`, the assumption is that it is a `native app`, that is implemented in a particular programming language for either iOS (Objective-C or Swift) or Android (Java).

Native mobile apps provide fast performance and a high degree of reliability. They usually adhere to the design principles (e.g. Android Design Principles<sup>[13]</sup>), providing a more consistent UI, compared to `hybrid` and `web` apps. Due to their close integration with the operating system, native apps have access to almost every component of the device (camera, sensors, hardware backed key stores, etc.)

Please note that there is a little ambiguity when discussion `native` apps for Android. Namely, Android provides two sets of APIs to develop against, Android SDK and Android NDK. The SDK (or Software Development Kit) is a Java API and is the default API against which applications are built. The NDK (or Native Development Kit) is a C/C++ based API used for developing only parts of the application that require specific optimization, or can otherwise benefit from lower level API. Normally, you can only distribute apps build with the SDK, which potentially can have parts implemented against NDK. Therefore we say that Android `native **apps**` (build against SDK) can have `native **code**` (build against NDK).

Biggest downside of native apps is that they target only one specific platform. To build the same app for both Android and iOS, one needs to maintain two independent code bases.

### Web App

Mobile Web apps, or simply Web apps, are websites designed to look and feel like a native app. They run in a browser and are usually developed in HTML5. Normally, both Android and iOS allow for launcher icons to be created out of bookmarked Web apps, which simply run the default web browser and load the bookmarked app.

Web apps have limited integration with the components of the device and usually have a noticeable difference in performance. Since they typically target multiple platforms, their UI does not follow some of the design principles users are used to. Their biggest advantage is the price for supporting multiple platforms (only slight adaptation in the UI can server well most desktop and mobile operating systems), as well as their flexibility for delivering new content (as they are not delivered over an official application store, which sometimes take weeks to distribute through).

### Hybrid App

Hybrid apps attempt to fill the gap between native and web apps. Namely, hybrid apps are (distributed and executed as) native apps, that have majority of their content implemented on top of web technologies, running in an embedded web browser (web view). As such, hybrid apps inherit some of the pros and cons of both native and web apps.

A web-to-native abstraction layer enables access to device capabilities for hybrid apps that are not accessible to mobile web applications. Depending on the framework used for developing, one code base can result in multiple applications, targeting separate platforms, with a UI closely resembling that of the targeted platform. Nevertheless, usually significant effort is required to exactly match the look and feel of a native app.

Following is a non-exhaustive list of more popular frameworks for developing Hybrid Apps:

* Apache Cordova - https://cordova.apache.org/
* Framework 7 - http://framework7.io/
* Ionic - https://ionicframework.com/
* jQuery Mobile - https://jquerymobile.com/
* Native Script - https://www.nativescript.org/
* Onsen UI - https://onsen.io/
* React Native - http://www.reactnative.com/
* Sencha Touch - https://www.sencha.com/products/touch/
