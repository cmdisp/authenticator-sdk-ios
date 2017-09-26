# Authenticator SDK for iOS

[![Platform](https://img.shields.io/cocoapods/p/AuthenticatorSDK.svg)]()
[![Carthage](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods](https://img.shields.io/cocoapods/v/AuthenticatorSDK.svg)]()
[![License](https://img.shields.io/cocoapods/l/AuthenticatorSDK.svg?style=flat)]()

SDK guide for iOS developers

## Prerequisites

- [App manager app](https://appmanager.cmtelecom.com)
- [Authenticator environment](https://dashboard.auth.cmtelecom.com)

## Requirements

- iOS 8.0+
- Xcode 9.0
- Swift 4.0

## Installation

### CocoaPods

The SDKs can be installed using [CocoaPods](https://cocoapods.org) package manager

`Podfile`

```ruby
platform :ios, '8.0'

target 'MyApp' do
  use_frameworks!
  pod 'AuthenticatorSDK', '~> 4.0'
end
```

### Carthage

Using [Carthage](https://github.com/Carthage/Carthage) package manager

`Cartfile`

```
github "cmdisp/authenticator-sdk-ios" ~> 4.0
```

## Usage

### Initialization / startup

1. Initialize the Authenticator SDK with the App key obtained from the [App manager](https://appmanager.cmtelecom.com)

### Verify device registration

1. Verify the phone number using SMS verification

### Register environment

1. Push message with category `auth_qr` arrives
2. Show QR code scanner
3. Wait for the user to scan the QR code
4. Retrieve the info from the scanned QR code
5. Register the environment

### Authentication request

1. Obtain authentication request
2. Show authentication request information
  - Instant: show approve/deny buttons
   - OTP: show one-time password
3. Wait for the user to respond or the authentication request expires
   - Update the status to `approved` or `denied`
4. Hide authentication request

### Check device registration status

1. Check device registration status on application startup or when the application enters the foreground and prompt the user to re-register when device registration `registrationStatus` is `unverified`

## Initialization

### Initialize the SDK

The initialization process should happen as early as possible, preferably in the `AppDelegate` class within the `didFinishLaunchingWithOptions:` method.

**Example:**

```swift
import UIKit
import AuthenticatorSDK
import UserNotifications

let authenticator = Authenticator(appKey: "YOUR_APP_KEY_HERE")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        // Configure authenticator
        UNUserNotificationCenter.current().delegate = self
        authenticator.notificationManager.registerPushNotificationCategories()
	}
```

### Enable push notifications

Select your project target and go to `Capabilities`. Make sure the `Push Notifications` toggle is on.

Open `Info.plist` and add the key: `Required background modes` with sub item: `App downloads content in response to push notifications` or view as source and add the following lines:

```xml
<key>UIBackgroundModes</key>
<array>
	<string>remote-notification</string>
</array>
```

Go the the [Apple Developer Portal](https://developers.apple.com) and create a provisioning profile that is enabled for push notifications.

Set the `UNUserNotificationCenter` delegate to the AppDelegate instance.

```swift
UNUserNotificationCenter.current().delegate = self`
```

Register the device token with authenticator by implementing the `application:didRegisterForRemoteNotificationsWithDeviceToken:` method and register the device token using `authenticator.deviceClient.register(pushToken: Data, pushEnabled: Bool, development: Bool)`

```swift
/// AppDelegate.swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
	let development: Bool
	
	#if DEBUG
		development = true
	#else
		development = false
	#endif
	
	authenticator.deviceClient.register(
		pushToken: deviceToken, 
		pushEnabled: application.isRegisteredForRemoteNotifications, 
		development: development
	)
}
```

Add the `UNUserNotificationCenterDelegate` protocol to AppDelegate and implement the notification center delegate methods.

```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
```

**Example:**

```swift
/// Notification received
func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
   debugPrint(notification.request.content.userInfo)
}
    
/// The user interacts with the notification
func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
   let actionIdentifier = response.actionIdentifier
   let content = response.notification.request.content

   guard let authId = content.authenticationRequestId, let environmentId = content.environmentId, let authStatus = AuthStatus(rawValue: actionIdentifier) else {
       completionHandler()
       return
   }
   
   guard let deviceSecret = appSettings.deviceSecret else {
       // No device environment secret
       completionHandler()
       return
   }
   
   authenticator.authClient.updateStatus(id: authId, environmentId: environmentId, deviceSecret: deviceSecret, status: authStatus) { (auth: AuthenticationRequest?, error) in
       completionHandler()
   }
}
```

### Extension

An extension on `UNNotificationContent` is included to help extract authentication request information from push messages.

It adds two additional properties:

```swift
var environmentId : String?

var authenticationRequestId : String?
```

#### Example

```swift
public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
	let actionIdentifier = response.actionIdentifier
	let content = response.notification.request.content

  	let environmentId = content.environmentId
  	let authId = content.authenticationRequestId
}
```

### Customize push notification categories

`registerPushNotificationCategories()` creates a default authentication category with approve/deny actions. It is possible to change the text of the approve/deny buttons by creating custom `UNNotificationAction` actions.

#### Example

```swift
let approveAction = UNNotificationAction(type: .approved, title: "Approve")
let denyAction = UNNotificationAction(type: .denied, title: "Deny")
   
let authCategory = UNNotificationCategory(type: .authInstant, actions: [approveAction, denyAction])
   
authenticator.notificationManager.registerPushNotificationCategories(categories: [authCategory], options: [.alert, .badge, .sound]) { (error) in
	// completion
}
```

## Device registration

### Verify phone number

Verify the phone number. The phone number must be specified in international format (E.164).

```swift
let phoneNumber = "+31601234567"

authenticator.deviceClient.register(phoneNumber: phoneNumber) { (registration, error) in
	guard let registration = registration, error == nil else {
		// Error registering phone number
      	return
  	}
  
  	switch (registration.registrationStatus) {
  	case .pending:
  		// Send user to pin verification view
  	case .verified:
      	// Device already verified, send user to authentication view
  	default:
  		// Invalid registration status
  	}
}
```

### Verify code

Verify the SMS verification code

```swift
let pin = "12345"

authenticator.deviceClient.register(verificationCode: pin) { (registration, error) in
	guard let registration = registration, error == nil else {
		// Error sending verification code
      	return
  	}
  
  	switch (registration.registrationStatus) {
  	case .verified:
  		// Verified, send user to authentication view
  	default:
      	// Invalid registration status
  	}
}
```

### Send device token

Send the push token to the authenticator server

```swift
// AppDelegate.swift
func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
	let development: Bool
	
	#if DEBUG
		development = true
	#else
		development = false
	#endif
	
	authenticator.deviceClient.register(pushToken: deviceToken, pushEnabled: application.isRegisteredForRemoteNotifications, development: development)
}
```

### Status

Retrieve the device status

```swift
authenticator.deviceClient.registration { (registration, error) in
	let registrationStatus = registration?.registrationStatus
}
```

## Environments

### Get environments

Get a list of all registered environments

```swift
authenticator.environmentClient.environments(completion: ([Environment]?, ApiError?) -> Void)
```

#### Example

```swift
authenticator.environmentClient.environments { (environments: [Environment]?, error) in
	guard let environments = environments, error == nil else {
		// Error loading environments
		return
  	}
}
```

### Register environment

Create the link between this device and an environment using the identifier and secret obtained from the QR code.

```swift
authenticator.environmentClient.register(id: String, deviceSecret: String, completion: ((ApiError?) -> Void)?)
```

The `QrCodeScanResult` is a helper class that can be used to extract the Environment ID and Secret from the QR code content.

#### Example

```swift
let scanResult = QrCodeScanResult(result: qrCodeContent)
   
guard let environmentId = scanResult.environmentId, let deviceSecret = scanResult.deviceEnvironmentSecret else {
	// Invalid QR code
  	return
}
   
authenticator.environmentClient.register(id: environmentId, deviceSecret: deviceSecret) { (error) in
  	guard error == nil else {
		// Could not register the QR code
      	return
  	}
  	
  	// Success. Store environment ID and secret in the keychain
}
```

> See the Example project for an implementation of a QR code reader.

### Unregister environment

Delete the link between the device and the environment.

```swift
authenticator.environmentClient.unregister(id: String, deviceSecret: String, completion: ((ApiError?) -> Void)?)
```

#### Example

```swift
authenticator.environmentClient.unregister(id: environmentId, deviceSecret: deviceSecret) { (error) in
	guard error == nil else {
		// Could not unregister the environment
      	return
  	}
  	// Successfully unregistered
}
```

## Authentication requests

### Get authentication request

Get the current open authentication request for an environment.

```swift
authenticator.authClient.authenticationRequest(environmentId: String, deviceSecret: String, completion: (AuthenticationRequest?, ApiError?) -> Void)
```

#### Example

```swift
authenticator.authClient.authenticationRequest(environmentId: environmentId, deviceSecret: deviceSecret) { (authentication, error) in
	guard error == nil else {
		// Error loading authentication request
		return 
	}
}
```

### Update status

Set the status (`AuthStatus`) of an open authentication request of type **instant** to either `.approved` or `.denied`.

```swift
authenticator.authClient.updateStatus(id: String, environmentId: String, deviceSecret: String, status: AuthStatus, completion: (AuthenticationRequest?, ApiError?) -> Void)
```

#### Example

```swift
authenticator.authClient.updateStatus(id: authId, environmentId: environmentId, deviceSecret: deviceSecret, status: authStatus) { (auth: AuthenticationRequest?, error) in
	guard error == nil else {
		// Error updating status
		return 
	}
}
```

## License

Authenticator is available under the MIT license. See the LICENSE file for more info.
