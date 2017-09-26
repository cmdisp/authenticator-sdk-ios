//
//  JWTClaims.swift
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

struct JWTClaims {
    
    // MARK: - Properties
    
    var values: [String: Any]
    
    /// Create a new instance of JWT claims. Default expiration is set to 60 seconds
    ///
    /// - Parameter values: Parameters
    public init(values: [String: Any]? = nil) {
        self.values = values ?? [:]
        
        notBefore = Date()
        issuedAt = Date()
        expiration = Date().addingTimeInterval(60)
    }
    
    public subscript(key: String) -> Any? {
        get {
            return values[key]
        }
        
        set {
            if let newValue = newValue, let date = newValue as? Date {
                values[key] = Int(date.timeIntervalSince1970)
            } else {
                values[key] = newValue
            }
        }
    }
}

extension JWTClaims {
    
    // MARK: - Public Properties
    
    public var expiration: Date? {
        get {
            if let expiration = values["exp"] as? TimeInterval {
                return Date(timeIntervalSince1970: expiration)
            }
            return nil
        }
        set {
            self["exp"] = newValue
        }
    }
    
    public var notBefore: Date? {
        get {
            if let expiration = values["nbf"] as? TimeInterval {
                return Date(timeIntervalSince1970: expiration)
            }
            return nil
        }
        set {
            self["nbf"] = newValue
        }
    }
    
    public var issuedAt: Date? {
        get {
            if let expiration = values["iat"] as? TimeInterval {
                return Date(timeIntervalSince1970: expiration)
            }
            return nil
        }
        set {
            self["iat"] = newValue
        }
    }
    
    public var signature: String? {
        get {
            return values["sig"] as? String
        }
        set {
            self["sig"] = newValue
        }
    }
    
    public var authenticationRequestId: String? {
        get {
            return values["auth_id"] as? String
        }
        set {
            self["auth_id"] = newValue
        }
    }
    
    public var deviceId: String? {
        get {
            return values["device_id"] as? String
        }
        set {
            self["device_id"] = newValue
        }
    }
}
