//
//  AppSettings.swift
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

struct AppSettings {
    
    /// Device registration verified
    var isVerified: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isVerified")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "isVerified")
        }
    }
    
    /// Phone number
    var phoneNumber: String? {
        get {
            return UserDefaults.standard.string(forKey: "phoneNumber")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "phoneNumber")
        }
    }
    
    /// Environment ID
    var environmentId: String? {
        get {
            return UserDefaults.standard.string(forKey: "environmentId")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "environmentId")
        }
    }

    /// Device secret. For demo purposes this value is stored in UserDefaults. It's recommended to store the secret in the Keychain
    var deviceSecret: String? {
        get {
            return UserDefaults.standard.string(forKey: "deviceSecret")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "deviceSecret")
        }
    }
}
