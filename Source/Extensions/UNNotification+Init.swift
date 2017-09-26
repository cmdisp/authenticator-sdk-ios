//
//  UNNotification+Init.swift
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

import Foundation
import UserNotifications

@available(iOS 10.0, *)
public extension UNNotificationAction {
    
    /// Creates a `UNNotificationAction` for a specific action type
    ///
    /// - Parameters:
    ///   - type: Action type
    ///   - title: Button title
    convenience init(type: NotificationActionType, title: String) {
        switch type {
        case .approved:
            self.init(identifier: type.rawValue, title: title, options: [.authenticationRequired])
        case .denied:
            self.init(identifier: type.rawValue, title: title, options: [.authenticationRequired, .destructive])
        }
    }
}

@available(iOS 10.0, *)
public extension UNNotificationCategory {
    
    /// Creates a `UNNotificationCategory` for a specific category
    ///
    /// Example:
    ///    let approveAction = UNNotificationAction(type: .approved, title: "Approve")
    ///    let denyAction = UNNotificationAction(type: .denied, title: "Deny")
    ///
    ///    let authCategory = UNNotificationCategory(type: .authInstant, actions: [approveAction, denyAction])
    ///
    /// - Parameters:
    ///   - type: category type
    ///   - actions: array of `UNNotificationAction` actions
    convenience init(type: NotificationCategoryType, actions: [UNNotificationAction]) {
        switch type {
        case .authInstant, .authQr:
            self.init(identifier: type.rawValue, actions: actions, intentIdentifiers: [], options: [])
        }
    }
}
