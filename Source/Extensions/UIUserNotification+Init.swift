//
//  UIUserNotificationAction+Init.swift
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

@available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's UNNotificationAction instead.")
public extension UIMutableUserNotificationAction {
    
    /// Creates a `UIMutableUserNotificationAction` for a specific action type
    ///
    /// - Parameters:
    ///   - type: Action type
    ///   - title: Button title
    convenience init(type: NotificationActionType, title: String) {
        self.init()
        
        self.isAuthenticationRequired = true
        self.activationMode = .background
        
        switch type {
        case .approved:
            self.identifier = type.rawValue
            self.title = title
        case .denied:
            self.identifier = type.rawValue
            self.title = title
            self.isDestructive = true
        }
    }
}

@available(iOS, introduced: 8.0, deprecated: 10.0, message: "Use UserNotifications Framework's UNNotificationCategory instead.")
public extension UIMutableUserNotificationCategory {
    
    /// Creates a `UIMutableUserNotificationCategory` for a specific category
    ///
    /// Example:
    ///    let approveAction = UIMutableUserNotificationAction(type: .approved, title: "Approve")
    ///    let denyAction = UIMutableUserNotificationAction(type: .denied, title: "Deny")
    ///
    ///    let authCategory = UIMutableUserNotificationCategory(type: .authInstant, actions: [approveAction, denyAction])
    ///
    /// - Parameters:
    ///   - type: category type
    ///   - actions: array of `UIUserNotificationAction` actions
    convenience init(type: NotificationCategoryType, actions: [UIUserNotificationAction]) {
        switch type {
        case .authInstant, .authQr:
            self.init()
            
            self.identifier = type.rawValue
            self.setActions(actions, for: .default)
            self.setActions(actions, for: .minimal)
        }
    }
}
