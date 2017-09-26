//
//  QrCodeScanResult.swift
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

/// Helper class to extract the environment ID and device environment Secret from a QR code scan
public class QrCodeScanResult {
    
    // MARK: - Properties
    
    fileprivate var result: String
    
    /// result components split by comma
    fileprivate var components: [String] {
        get {
            return self.result.components(separatedBy: ",")
        }
    }
    
    /// Environment ID
    public var environmentId: String? {
        get {
            guard let uuid = components.first, uuid.count == 36 else {
                return nil
            }
            return uuid
        }
    }
    
    /// Device Environment Secret
    public var deviceEnvironmentSecret: String? {
        get {
            guard components.count > 1, !components[1].isEmpty else {
                return nil
            }
            
            return components[1]
        }
    }
    
    // MARK: - Init
    
    /// Create a new `QrCodeScanResult` instance
    ///
    /// - Parameter result: QR code result
    public init(result: String) {
        self.result = result
    }
}
