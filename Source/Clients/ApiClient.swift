//
//  ApiClient.swift
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

class ApiClient: HttpClient {
    
    // MARK: - Properties
    
    let settingsManager: SettingsManager
    
    lazy var settings: Settings = {
        return settingsManager.settings
    }()
    
    // MARK: - Init
    
    /// Creates an API client with optional baseURL and device ID
    ///
    /// - Parameters:
    ///   - baseUrl: API base URL
    ///   - deviceId: The device identifier
    init(baseUrl: String? = nil, settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        
        super.init(baseUrl: baseUrl)
    }
    
    // MARK: - URLSessionDelegate
    
    /// Check the certificate fingerprint of the request against the fingerprints provided to the HttpClient. The request will be cancelled when there is no match.
    ///
    /// - Parameters:
    ///   - session: The URL Session
    ///   - challenge: The Authentication challenge
    ///   - completionHandler: The handler is called when a authentication challenge is received
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        var disposition = URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge
        var credential = URLCredential()
        
        for fingerprint in settings.fingerprints {
            if challenge.sha256Fingerprint() == fingerprint.lowercased() {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            }
        }
        
        completionHandler(disposition, credential)
    }
}
