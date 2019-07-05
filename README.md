<img src="https://apptilaus.com/files/logo_green.svg"  width="300">

## Apptilaus Subscriptions SDK for iOS

[![Tweet](https://img.shields.io/twitter/url/http/shields.io.svg?style=social)](https://twitter.com/intent/tweet?text=Analyse%20subscriptions%20for%20your%20app!%20No%20SDK%20required!%20&url=http://apptilaus.com&hashtags=subscriptions,apps,appstore,analytics)&nbsp;[![Version](https://img.shields.io/cocoapods/v/Apptilaus.svg?style=flat)](https://cocoapods.org/pods/Apptilaus)&nbsp;[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)&nbsp;[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat)](https://developer.apple.com/iphone/index.action)&nbsp;[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat)](https://developer.apple.com/swift)&nbsp;[![License](https://img.shields.io/cocoapods/l/Apptilaus.svg?style=flat)](http://cocoapods.org/pods/Apptilaus)&nbsp;

## Overview ##

**Apptilaus** iOS SDK is an open-source SDK that provides a simplest way to analyse cross-device subscriptions via [**Apptilaus Service**](https://apptilaus.com).

## Table of contents

* [Example apps](#example-apps)
* [Working with the Library](#integration)
   * [Add the SDK to your project](#sdk-add)
   * [Add iOS frameworks](#sdk-frameworks)
   * [Prerequisite](#prerequisite)   
   * [Initial Setup](#basic-setup)
      * [Register Subscriptions](#register-subscription)
      * [Register Subscriptions with parameters](#register-subscription-params)
   * [Advanced Setup](#advanced-setup)
      * [Session Tracking](#session-tracking)
      * [GDPR Right to Erasure](#gdpr-opt-out)
      * [On-Premise Setup](#on-premise)
      * [User Enrichment](#user-data)
   * [Build your app](#build-the-app)
* [Licence](#licence)


## <a id="example-apps"></a>Example 

There are example apps inside the [`examples directory`][Examples] for [`iOS (Objective-C)`][Example-ObjC], [`iOS (Swift)`][Example-Swift]. You can open any of these Xcode projects to see an example of how the Apptilaus SDK can be integrated.

-----

## <a id="integration">Working with the Library

Here is the steps to integrate the Apptilaus SDK into your iOS project using Xcode.

-----

### <a id="sdk-add"></a>Add the SDK to your project

If you're using [CocoaPods][cocoapods], you can add the following line to your `Podfile`:

```ruby
pod 'Apptilaus', '~> 1.0.2'
```

or:

```ruby
pod 'Apptilaus', :git => 'https://github.com/Apptilaus/ios_subscriptions_sdk.git', :tag => '1.0.2'
```

Run `$ pod install` in your project directory.

---

If you're using [Carthage][carthage], you can add following line to your `Cartfile` and continue from [this step](#sdk-frameworks):

```ruby
github "Apptilaus/ios_subscriptions_sdk"
```
---

### <a id="sdk-frameworks"></a>Add iOS frameworks

1. Select your project in the Project Navigator
2. In the left-hand side of the main view, select your target
3. In the `Build Phases` tab, expand the `Link Binary with Libraries` group
4. At the bottom of that section, select the `+` button
5. Select the `AdSupport.framework`, then the `Add` button 
6. Repeat the same steps to add the `iAd.framework` and `StoreKit.framework`
7. Change the `Status` of the frameworks to `Optional`.

-----

### <a id="prerequisite"></a>Prerequisite 

Before getting started you must perform the steps outlined above.

-----

### <a id="basic-setup"></a>Initial Setup

* Add the following import definitions to the of your application delegate:

Swift:
```swift
import Apptilaus
```

Objective-C:
```objc
#import <Apptilaus/Apptilaus-umbrella.h>
```

---

* Add the call to `Apptilaus` in the `didFinishLaunching` or `didFinishLaunchingWithOptions` method of your app delegate:

Swift:
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    // Your other application code.....
    // We've recommend to implement Apptilaus Library right before the end of the method.

    let apptilausAppId = "AppID"
    let apptilausToken = "AppToken"

    ApptilausManager.shared.setup(withAppId: apptilausAppId, appToken: apptilausToken)

}
```

Objective-C:
```objc
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Your other application code.....

    // We've recommend to implement Apptilaus Library right before the end of the method.

    NSString *apptilausAppId = @"AppID";
    NSString *apptilausToken = @"AppToken";

    [ApptilausManager.shared setupWithAppId:apptilausAppId appToken:apptilausToken enableSessionTracking:NO];
}
```

**Note**: Initialising the Apptilaus SDK like this is `very important`. Otherwise, it will not work properly.

Replace `AppID` and `AppToken` with your App ID and App Token accordingly. You can find app credentials in the [admin panel][admin-panel].

---

#### <a id="register-subscription"></a>Register Subscriptions

In your `SKPaymentTransactionObserver` add the following call to Apptilaus SDK for registering purchases in `SKPaymentQueue`:

Swift:
```swift
func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
        // Your purchase processing code
        if transaction.transactionState == .purchased {
            ApptilausManager.shared.register(transaction: transaction)
        } 
    }
}
```

Objective-C:
```objc
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            [[ApptilausManager shared] registerWithTransaction:transaction customParams:nil];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            NSLog(@"Transaction %@ failed with error: %@", transaction, transaction.error);
        }
    }
}
```
---

#### <a id="register-subscription-params"></a>Register Subscriptions with parameters

You could also add custom parameters to purchase registering method adding the following lines:

Swift:
```swift
func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
    for transaction in transactions {
        //Your purchase processing code
        if transaction.transactionState == .purchased {
            let customParameters: [String : Any] = [
                "foo": "bar",
                "goats_count": 123
            ];

            ApptilausManager.shared.register(transaction: transaction, customParams: customParameters)
        }
    }
```

Objective-C:
```objc
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
    
    
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            NSDictionary<NSString *, id> *customParams = @{
                 @"foo": @"bar",
                 @"goats_count": @123
            };
            [[ApptilausManager shared] registerWithTransaction:transaction customParams:customParams];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            NSLog(@"Transaction %@ failed with error: %@", transaction, transaction.error);
        }
        
        
    }
}
```

---

### <a id="advanced-setup"></a>Advanced Setup

#### <a id="session-tracking"></a>Session tracking

To track first session and user activities, use the `sessionTrackingEnabled` parameter when calling setup method:

Swift:
```swift
ApptilausManager.shared.setup(withAppId: apptilausAppId, appToken: apptilausToken, enableSessionTracking: true)
```

Objective-C:
```objc
[ApptilausManager.shared setupWithAppId:apptilausAppId appToken:apptilausToken enableSessionTracking:YES];
```

---

### <a id="gdpr-opt-out"></a>GDPR Right to Erasure

In accordance with article 17 of the EU's General Data Protection Regulation (GDPR), you can notify Apptilaus when a user has exercised their right to be forgotten. Calling the following method will instruct the Apptilaus SDK to communicate the user's choice to be forgotten to the Apptilaus backend and data storage:

Swift:
```swift
ApptilausManager.shared.gdprOptOut(customParams: nil) { (success, errorOpt) in
    if (success) {
        print("Opt-out success")
    } else {
        print("Opt-out error: \(errorOpt)")
    }
```

Objective-C:
```objc
[ApptilausManager.shared gdprOptOutWithCustomParams:nil completionHandler:^(BOOL success, NSError *error) {
    if (success) {
        NSLog(@"Opt-out success");
    } else {
        NSLog(@"Opt-out error: %@", error);
    }
}];
```
---

Upon receiving this information, Apptilaus will erase the user's data and the Apptilaus SDK will stop tracking the user. No requests from this device will stored by Apptilaus in the future.

---

#### <a id="on-premise"></a>On-premise Setup

To work with your own installation of Apptilaus Service you can also set a custom base URL in the `didFinishLaunching` or `didFinishLaunchingWithOptions` method of your app delegate:

Swift:
```swift

    ApptilausManager.shared.baseUrl = "https://subscriptions.custom.domain/v1/purchase/"

```

Objective-C:
```objc

    ApptilausManager.shared.baseUrl = @"https://subscriptions.custom.domain/v1/purchase/";

```
---

#### <a id="user-data"></a>User Enrichment

You can optionally set your internal user ID string to track user purchases. It could be done at any moment, e.g. during the app launch, or after app authentication process:

Swift:
```swift

    ApptilausManager.shared.userId = "123456789"

```

Objective-C:
```objc

    ApptilausManager.shared.userId = @"123456789";

```

---

### <a id="build-the-app"></a>Build your app

Build and run your app. If the build succeeds, you should carefully read the SDK logs in the console. After completing purchase, you should see the info log `[Apptilaus]: Purchase Processed`.

---

[apptilaus.com]:  http://apptilaus.com
[admin-panel]:   https://go.apptilaus.com

[arc]:         http://en.wikipedia.org/wiki/Automatic_Reference_Counting
[carthage]:    https://github.com/Carthage/Carthage
[releases]:    https://github.com/Apptilaus/ios_subscriptions_sdk/releases
[cocoapods]:   http://cocoapods.org

[Examples]:  Examples/
[Example-ObjC]:  Examples/Example-ObjC
[Example-Swift]:  Examples/Example-Swift
[partmer-docs]:  Docs/English/
[partmer-docs-adjust]:  Docs/English/adjust.md
[partmer-docs-amplitude]:  Docs/English/amplitude.md
[partmer-docs-appmetrica]:  Docs/English/appmetrica.md
[partmer-docs-appsflyer]:  Docs/English/appsflyer.md

## <a id="licence"></a>Licence and Copyright

The Apptilaus SDK is licensed under the MIT License.

**Apptilaus** (c) 2018-2019 All Rights Reserved

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[![Analytics](https://ga-beacon.appspot.com/UA-125243602-3/ios_subscriptions_sdk/README.md)](https://github.com/igrigorik/ga-beacon)
