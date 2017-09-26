//
//  AppDelegate.swift
//
//  Copyright (c) 2017 CM
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import AuthenticatorSDK
import UserNotifications

var appSettings = AppSettings()

let authenticator = Authenticator(appKey: "YOUR_APP_KEY_HERE")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Setup authenticator
        UNUserNotificationCenter.current().delegate = self
        authenticator.notificationManager.registerPushNotificationCategories()
        
        // Setup navigation controller and main window
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        UINavigationBar.appearance().tintColor = UIColor.black
        
        let phoneVerificationView = storyBoard.instantiateViewController(
            withIdentifier: String(describing: PhoneVerificationViewController.self)
        )
        
        var viewControllers = [phoneVerificationView]
        
        if appSettings.isVerified {
            let authenticationView = storyBoard.instantiateViewController(
                withIdentifier: String(describing: AuthenticationViewController.self)
            )
            viewControllers.append(authenticationView)
        }
        
        navigationController = storyBoard.instantiateInitialViewController() as? UINavigationController
        navigationController?.viewControllers = viewControllers
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        
        checkDeviceStatus()
        
        return true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        checkDeviceStatus()
    }
    
    /// Check if the device registration is still valid
    private func checkDeviceStatus() {
        guard appSettings.isVerified else {
            return
        }
        
        authenticator.deviceClient.registration { (registration, error) in
            if registration?.registrationStatus == .unverified {
                appSettings.isVerified = false
                self.navigationController?.popToRootViewController(animated: false)
            }
        }
    }
}

extension AppDelegate {
    
    // MARK: - Push notification registration
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let development: Bool
        
        #if DEBUG
            development = true
        #else
            development = false
        #endif
        
        authenticator.deviceClient.register(pushToken: deviceToken, pushEnabled: application.isRegisteredForRemoteNotifications, development: development)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint(error)
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // MARK: - Notification center delegates
    
    /// Notification received
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        NotificationCenter.default.post(
            name: AppConfig.notificationNames.pushNotificationReceived,
            object: nil,
            userInfo: ["notification": notification.request.content]
        )
    }
    
    /// The user interacts with the notification
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        let content = response.notification.request.content

        guard let authId = content.authenticationRequestId, let environmentId = content.environmentId, let authStatus = AuthStatus(rawValue: actionIdentifier) else {
            completionHandler()
            return
        }
        
        guard let deviceSecret = appSettings.deviceSecret else {
            debugPrint("No device environment secret")
            completionHandler()
            return
        }
        
        authenticator.authClient.updateStatus(id: authId, environmentId: environmentId, deviceSecret: deviceSecret, status: authStatus) { (auth: AuthenticationRequest?, error) in
            completionHandler()
        }
    }
}
