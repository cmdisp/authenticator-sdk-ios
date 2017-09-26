//
//  EnvironmentClient.swift
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

public protocol EnvironmentClient {
    
    /// Retrieve all environments for a device registration
    ///
    /// - Parameter completion: Completion handler
    func environments(completion: @escaping ([Environment]?, ApiError?) -> Void)
    
    /// Register an environment
    ///
    /// - Parameters:
    ///   - id: Environment ID
    ///   - deviceSecret: Device secret key
    ///   - completion: Completion handler
    func register(id: String, deviceSecret: String, completion: @escaping (ApiError?) -> Void)
    
    /// Unregister an environment
    ///
    /// - Parameters:
    ///   - id: Environment ID
    ///   - deviceSecret: Environment secret key
    ///   - completion: Completion handler
    func unregister(id: String, deviceSecret: String, completion: @escaping (ApiError?) -> Void)
}

class EnvironmentApiClient: EnvironmentClient {
    
    let apiClient: ApiClient
    
    /// Creates an environment client
    ///
    /// - Parameter apiClient: Api Client
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    /// Retrieve all environments for a device registration
    ///
    /// - Parameter completion: Completion handler
    public func environments(completion: @escaping ([Environment]?, ApiError?) -> Void) {
        guard let deviceId = apiClient.settings.deviceId else {
            completion(nil, ApiError.noDeviceRegistration)
            return
        }
        
        let url = (self.apiClient.baseUrl ?? "") + "/device/\(deviceId)/environment"
        
        self.apiClient.request(url: url, completion: completion)
    }
    
    /// Register an environment
    ///
    /// - Parameters:
    ///   - id: Environment ID
    ///   - deviceSecret: Device secret key
    ///   - completion: Completion handler
    public func register(id: String, deviceSecret: String, completion: @escaping (ApiError?) -> Void) {
        guard let deviceId = apiClient.settings.deviceId else {
            completion(ApiError.noDeviceRegistration)
            return
        }
        
        let token = JWT.encode(key: deviceSecret) ?? ""
        
        let headers: Headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let url = (self.apiClient.baseUrl ?? "") + "/device/\(deviceId)/environment/\(id)"
        
        self.apiClient.request(url: url, method: .put, headers: headers) { (response: ApiResponse?, error) in
            completion(error)
        }
    }
    
    /// Unregister an environment
    ///
    /// - Parameters:
    ///   - id: Environment ID
    ///   - deviceSecret: Environment secret key
    ///   - completion: Completion handler
    public func unregister(id: String, deviceSecret: String, completion: @escaping (ApiError?) -> Void) {
        guard let deviceId = apiClient.settings.deviceId else {
            completion(ApiError.noDeviceRegistration)
            return
        }
        
        let token = JWT.encode(key: deviceSecret) ?? ""
        
        let headers: Headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let url = (self.apiClient.baseUrl ?? "") + "/device/\(deviceId)/environment/\(id)"
        
        self.apiClient.request(url: url, method: .delete, headers: headers) { (response: ApiResponse?, error) in
            completion(error)
        }
    }
}
