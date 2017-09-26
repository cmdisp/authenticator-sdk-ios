//
//  NotificationManager.swift
//
//  Copyright (c) 2017 CM Telecom B.V.
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
import UserNotifications

public protocol NotificationManager {

    /// Register authentication notification categories
    func registerPushNotificationCategories()
    
    /// Register authentication notification categories
    func registerPushNotificationCategories(completion: ((Error?) -> Void)?)

    /// Register notification categories
    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use registerPushNotificationCategories:categories:options:completion: instead")
    func registerPushNotificationCategories(categories: Set<UIUserNotificationCategory>, types: UIUserNotificationType, completion: ((Error?) -> Void)?)
    
    /// Register notification categories
    @available(iOS 10.0, *)
    func registerPushNotificationCategories(categories: Set<UNNotificationCategory>, options: UNAuthorizationOptions, completion: ((Error?) -> Void)?)
}

class NotificationCenterManager: NotificationManager {
    
    // MARK: - Notification category registration
    
    /// Register authentication notification categories
    public func registerPushNotificationCategories() {
        self.registerPushNotificationCategories(completion: nil)
    }
    
    /// Register authentication notification categories
    public func registerPushNotificationCategories(completion: ((Error?) -> Void)?) {
        let approveTitle = NSLocalizedString("Approve", comment: "Notification approve action")
        let denyTitle = NSLocalizedString("Deny", comment: "Notification deny action")
        
        if #available(iOS 10, *) {
            let approveAction = UNNotificationAction(type: .approved, title: approveTitle)
            let denyAction = UNNotificationAction(type: .denied, title: denyTitle)
            let authCategory = UNNotificationCategory(type: .authInstant, actions: [approveAction, denyAction])
            
            self.registerPushNotificationCategories(categories: [authCategory], options: [.alert, .badge, .sound], completion: completion)
        } else {
            let approveAction = UIMutableUserNotificationAction(type: .approved, title: approveTitle)
            let denyAction = UIMutableUserNotificationAction(type: .denied, title: denyTitle)
            let authCategory = UIMutableUserNotificationCategory(type: .authInstant, actions: [approveAction, denyAction])
 
            self.registerPushNotificationCategories(categories: [authCategory], types: [.alert, .badge, .sound], completion: completion)
        }
    }
    
    /// Register notification categories
    @available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use registerPushNotificationCategories:categories:options:completion: instead.")
    public func registerPushNotificationCategories(categories: Set<UIUserNotificationCategory>, types: UIUserNotificationType = [.sound, .alert, .badge], completion: ((Error?) -> Void)? = nil)  {
        let settings = UIUserNotificationSettings(types: types, categories: categories)
        UIApplication.shared.registerUserNotificationSettings(settings)
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
            
            if let completion = completion {
                completion(nil)
            }
        }
    }
    
    /// Register notification categories
    @available(iOS 10.0, *)
    public func registerPushNotificationCategories(categories: Set<UNNotificationCategory>, options: UNAuthorizationOptions = [.sound, .alert, .badge], completion: ((Error?) -> Void)? = nil)  {
        UNUserNotificationCenter.current().setNotificationCategories(categories)
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                
                if let completion = completion {
                    completion(error)
                }
            }
        }
    }
}
