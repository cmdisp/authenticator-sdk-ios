//
//  Device.swift
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

public struct DeviceRegistration: Decodable {
    
    // MARK: - Properties
    
    public var id: String
    public var registrationStatus: RegistrationStatus
    public var pushEnabled: Bool
    public var development: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case registrationStatus = "registration_status"
        case pushEnabled = "push_enabled"
        case development
    }
}

struct DeviceRegistrationUpdate: Encodable {
    
    // MARK: - Properties
    
    let manufacturer: String = "Apple"
    
    var osVersion: String = {
        return UIDevice.current.systemVersion
    }()
    
    var appVersion : String = {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }()
    
    var appVersionCode : String = {
        return Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String ?? ""
    }()
    
    var appId : String = {
        return Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String ?? ""
    }()
    
    var languageCode: String = {
        return Locale.current.languageCode ?? "en"
    }()
    
    var model: String = {
        return UIDevice.current.model
    }()
    
    var modelId: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }()
    
    let platform = "iOS"
    
    var pushToken: String?
    var pushEnabled: Bool?
    var development: Bool?
    var phoneNumber: String?
    var verificationCode: String?
    var appKey: String?
    
    enum CodingKeys: String, CodingKey {
        case manufacturer
        case osVersion = "os_version"
        case appVersion = "app_version"
        case appId = "app_id"
        case languageCode = "language_code"
        case model
        case modelId = "model_id"
        case platform = "platform"
        case pushToken = "push_token"
        case pushEnabled = "push_enabled"
        case development
        case phoneNumber = "phone_number"
        case verificationCode = "verification_code"
        case appKey = "app_key"
    }
}
