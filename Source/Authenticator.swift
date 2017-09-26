//
//  AuthenticatorSDK.swift
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

public class Authenticator {
    
    // MARK: - Public Properties
    
    /// Environment client
    public var environmentClient: EnvironmentClient
    
    /// Authentication request client
    public var authClient: AuthClient
    
    /// Notification manager
    public var notificationManager: NotificationManager
    
    // Device registration client
    public var deviceClient: DeviceClient
    
    // MARK: - Private Properties
    
    private var apiClient: ApiClient
    private let config : AuthenticatorConfig
    private var certificateClient: CertificateClient
    private var settingsManager = SettingsManager()
    private var deviceApiClient: DeviceApiClient
    
    // MARK: - Init
    
    /// Creates an `Authenticator` instance
    ///
    /// - Parameter appKey: App manager app key
    /// - Parameter config: Authenticator config
    public init(appKey: String, config: AuthenticatorConfig? = nil) {
        self.config = config ?? AuthenticatorConfigDefault()
    
        apiClient = ApiClient(baseUrl: self.config.apiBaseUrl, settingsManager: settingsManager)
        
        // certificate client doesn't use certificate pinning
        certificateClient = CertificateClient(baseUrl: self.config.apiBaseUrl, publicKey: self.config.publicKey)
        
        environmentClient = EnvironmentApiClient(apiClient: apiClient)
        authClient = AuthApiClient(apiClient: apiClient)
        notificationManager = NotificationCenterManager()
        deviceApiClient = DeviceApiClient(apiClient: apiClient, appKey: appKey)
        deviceClient = deviceApiClient
        
        updateCertificates()
        deviceApiClient.register()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: Notification.Name.UIApplicationWillEnterForeground,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Application entered foreground
    @objc private func applicationWillEnterForeground() {
        deviceApiClient.register()
        updateCertificates()
    }
    
    /// Load new certificate fingerprints and save to settings on success.
    private func updateCertificates() {
        if settingsManager.settings.fingerprints.isEmpty {
            settingsManager.settings.fingerprints = config.defaultFingerprints
        }
        
        if let updateDate = settingsManager.settings.certificateUpdate {
            let elapsed = Date().timeIntervalSince(updateDate)
            if elapsed < config.certificateUpdateInterval {
                return
            }
        }
        
        certificateClient.certificates { (certificates: [Certificate]?, error) in
            guard error == nil, let certificates = certificates else {
                return
            }
            
            var fingerprints = [String]()
            for cert in certificates {
                fingerprints.append(cert.hash)
            }
            
            if !fingerprints.isEmpty {
                self.settingsManager.settings.fingerprints = fingerprints
                self.settingsManager.settings.certificateUpdate = Date()
                self.settingsManager.save()
            }
        }
    }
}
