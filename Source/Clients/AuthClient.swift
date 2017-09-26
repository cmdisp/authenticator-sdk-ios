//
//  AuthClient.swift
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

public protocol AuthClient {
    
    /// Retrieve the latest authentication request for a specific environment
    ///
    /// - Parameters:
    ///   - environmentId: Environment ID
    ///   - deviceSecret: Device environment secret
    ///   - completion: Completion handler
    func authenticationRequest(environmentId: String, deviceSecret: String, completion: @escaping (AuthenticationRequest?, ApiError?) -> Void)
    
    /// Update authentication request status
    ///
    /// - Parameters:
    ///   - id: Authentication request ID
    ///   - environmentId: Environment ID
    ///   - deviceSecret: Device environment secret
    ///   - status: Authentication status
    ///   - completion: Completion handler
    func updateStatus(id: String, environmentId: String, deviceSecret: String, status: AuthStatus, completion: @escaping (AuthenticationRequest?, ApiError?) -> Void)
}

class AuthApiClient: AuthClient {
    
    // MARK: - Properties
    
    let apiClient: ApiClient
    
    // MARK: - Init
    
    /// Creates an authentication client
    ///
    /// - Parameter apiClient: API client
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Public
    
    /// Retrieve the latest authentication request for a specific environment
    ///
    /// - Parameters:
    ///   - environmentId: Environment ID
    ///   - deviceSecret: Device environment secret
    ///   - completion: Completion handler
    public func authenticationRequest(environmentId: String, deviceSecret: String, completion: @escaping (AuthenticationRequest?, ApiError?) -> Void) {
        authenticationRequests(environmentId: environmentId, deviceSecret: deviceSecret) { (authentications: [AuthenticationRequest]?, error) in
            completion(authentications?.first, error)
        }
    }

    /// Update authentication request status
    ///
    /// - Parameters:
    ///   - id: Authentication request ID
    ///   - environmentId: Environment ID
    ///   - deviceSecret: Device environment secret
    ///   - status: Authentication status
    ///   - completion: Completion handler
    public func updateStatus(id: String, environmentId: String, deviceSecret: String, status: AuthStatus, completion: @escaping (AuthenticationRequest?, ApiError?) -> Void) {
        guard let deviceId = apiClient.settings.deviceId else {
            completion(nil, ApiError.noDeviceRegistration)
            return
        }
        
        var claims = JWTClaims()
        claims.expiration = Date().addingTimeInterval(30)
        claims.authenticationRequestId = id
        
        let parameters: Parameters = [
            "auth_status": "\(status)"
        ]
        
        do {
            let postData = try JSONEncoder().encode(parameters)
            claims.signature = HMAC.sign(data: postData, algorithm: .sha256, key: deviceSecret)?.hex
        }
        catch {
        }
        
        let token = JWT.encode(key: deviceSecret) ?? ""

        let headers: Headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let url = (self.apiClient.baseUrl ?? "") + "/device/\(deviceId)/instant/\(id)"
        
        self.apiClient.request(url: url, method: .put, parameters: parameters, headers: headers, completion: completion)
    }
    
    // MARK: - Private
    
    /// Retrieve all authentication requests for a device
    ///
    /// - Parameters:
    ///   - environmentId: Environment ID
    ///   - deviceSecret: Device environment secret
    ///   - completion: Completion handler
    fileprivate func authenticationRequests(environmentId: String, deviceSecret: String, completion: @escaping ([AuthenticationRequest]?, ApiError?) -> Void) {
        guard let deviceId = apiClient.settings.deviceId else {
            completion(nil, ApiError.noDeviceRegistration)
            return
        }
        
        let token = JWT.encode(key: deviceSecret) ?? ""
        
        let headers: Headers = [
            "Authorization": "Bearer \(token)"
        ]
        
        let url = (self.apiClient.baseUrl ?? "") + "/device/\(deviceId)/environment/\(environmentId)/auth"
        
        self.apiClient.request(url: url, headers: headers, completion: completion)
    }
}
