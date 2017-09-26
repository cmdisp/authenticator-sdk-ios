//
//  DeviceClient.swift
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

public protocol DeviceClient {

    /// Retrieve the device registration
    ///
    /// - Parameter completion: Completion handler
    /// - Returns: Void
    func registration(completion: @escaping (DeviceRegistration?, ApiError?) -> Void)
    
    /// Request phone number verification
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number
    ///   - completion: Completion handler
    /// - Returns: Void
    func register(phoneNumber: String, completion: @escaping (DeviceRegistration?, ApiError?) -> Void)
    
    /// Verify the verification code
    ///
    /// - Parameters:
    ///   - verificationCode: The verification code
    ///   - completion: Completion handler
    /// - Returns: Void
    func register(verificationCode: String, completion: @escaping (DeviceRegistration?, ApiError?) -> Void)
    
    /// Register push notification token
    ///
    /// - Parameters:
    ///   - pushToken: The push token
    ///   - pushEnabled: Enabled for push notifications
    ///   - development: Development build
    ///   - completion: Completion handler
    func register(pushToken: Data, pushEnabled: Bool, development: Bool, completion: ((DeviceRegistration?, ApiError?) -> Void)?)
    
    /// Register push notification token
    ///
    /// - Parameters:
    ///   - pushToken: The push token
    ///   - pushEnabled: Enabled for push notifications
    ///   - development: Development build
    func register(pushToken: Data, pushEnabled: Bool, development: Bool)
}

public class DeviceApiClient: DeviceClient {
    
    // MARK: - Properties
    
    private let apiClient: ApiClient
    
    private let appKey: String
    
    // MARK: - Init
    
    /// Creates a device client
    ///
    /// - Parameter apiClient: API client
    init(apiClient: ApiClient, appKey: String) {
        self.apiClient = apiClient
        self.appKey = appKey
    }
    
    // MARK: - Public methods
    
    /// Retrieve the device registration
    ///
    /// - Parameter completion: Completion handler
    /// - Returns: Void
    public func registration(completion: @escaping (DeviceRegistration?, ApiError?) -> Void) {
        guard let deviceId = apiClient.settings.deviceId else {
            completion(nil, ApiError.noDeviceRegistration)
            return
        }
        
        guard let url = URL(string:(self.apiClient.baseUrl ?? "") + "/device/\(deviceId)") else {
            return
        }
        
        self.apiClient.request(url: url, method: .get, completion: completion)
    }
    
    /// Request phone number verification
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number
    ///   - completion: Completion handler
    /// - Returns: Void
    public func register(phoneNumber: String, completion: @escaping (DeviceRegistration?, ApiError?) -> Void) {
        createUpdate(phoneNumber: phoneNumber, completion: completion)
    }
    
    /// Verify the verification code
    ///
    /// - Parameters:
    ///   - verificationCode: The verification code
    ///   - completion: Completion handler
    /// - Returns: Void
    public func register(verificationCode: String, completion: @escaping (DeviceRegistration?, ApiError?) -> Void) {
        createUpdate(verificationCode: verificationCode, completion: completion)
    }
    
    /// Register push notification token
    ///
    /// - Parameters:
    ///   - pushToken: The push token
    ///   - pushEnabled: Enabled for push notifications
    ///   - development: Development build
    ///   - completion: Completion handler
    public func register(pushToken: Data, pushEnabled: Bool, development: Bool, completion: ((DeviceRegistration?, ApiError?) -> Void)? = nil) {
        createUpdate(pushToken: pushToken, pushEnabled: pushEnabled, development: development, completion: completion)
    }
    
    /// Register push notification token
    ///
    /// - Parameters:
    ///   - pushToken: The push token
    ///   - pushEnabled: Enabled for push notifications
    ///   - development: Development build
    public func register(pushToken: Data, pushEnabled: Bool, development: Bool) {
        createUpdate(pushToken: pushToken, pushEnabled: pushEnabled, development: development, completion: nil)
    }
    
    /// Update device registration
    ///
    /// - Parameters:
    ///   - completion: Completion handler
    func register(completion: ((DeviceRegistration?, ApiError?) -> Void)? = nil) {
        createUpdate(completion: completion)
    }
    
    private func createUpdate(phoneNumber: String? = nil, verificationCode: String? = nil, pushToken: Data? = nil, pushEnabled: Bool? = nil, development: Bool? = nil, completion: ((DeviceRegistration?, ApiError?) -> Void)? = nil) {
        var device = DeviceRegistrationUpdate()
        device.pushToken = pushToken?.hex
        device.pushEnabled = pushEnabled
        device.development = development
        device.phoneNumber = phoneNumber
        device.verificationCode = verificationCode
        device.appKey = appKey
        
        var httpBody: Data
        
        do {
            httpBody = try JSONEncoder().encode(device)
        } catch {
            if let h = completion {
                h(nil, ApiError.requestError(statusCode: -1, message: "Invalid request body"))
            }
            return
        }
        
        var url = (self.apiClient.baseUrl ?? "") + "/device"
        
        var httpMethod: RequestMethod = .post
        if let deviceId = apiClient.settings.deviceId {
            httpMethod = .put
            url += "/\(deviceId)"
        }
        
        self.apiClient.request(url: URL(string: url)!, method: httpMethod, httpBody: httpBody) { (deviceInfo: DeviceRegistration?, error) in
            if let deviceId = deviceInfo?.id {
                self.apiClient.settings.deviceId = deviceId
                self.apiClient.settingsManager.save()
            }
            
            if let h = completion {
                h(deviceInfo, error)
            }
        }
    }
}
