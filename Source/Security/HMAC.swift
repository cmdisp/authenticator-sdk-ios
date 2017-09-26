//
//  Security.swift
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

struct HMAC {
    
    /// HMAC algorithm
    enum Algorithm {
        case sha256
        case sha384
        case sha512
        
        public var algorithm: CCHmacAlgorithm {
            switch self {
            case .sha256: return CCHmacAlgorithm(kCCHmacAlgSHA256)
            case .sha384: return CCHmacAlgorithm(kCCHmacAlgSHA384)
            case .sha512: return CCHmacAlgorithm(kCCHmacAlgSHA512)
            }
        }
        
        public var digestLength: Int {
            switch self {
            case .sha256: return Int(CC_SHA256_DIGEST_LENGTH)
            case .sha384: return Int(CC_SHA384_DIGEST_LENGTH)
            case .sha512: return Int(CC_SHA512_DIGEST_LENGTH)
            }
        }
    }
    
    /// Calculate HMAC signature
    ///
    /// - Parameters:
    ///   - data: Input data
    ///   - algorithm: HMAC algorithm
    ///   - key: Secret key
    /// - Returns: signature string
    static func sign(data: Data, algorithm: Algorithm, key: Data) -> Data {
        let signature = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: algorithm.digestLength)
        
        defer {
            signature.deallocate(capacity: algorithm.digestLength)
        }
        
        data.withUnsafeBytes { dataBytes in
            key.withUnsafeBytes { keyBytes in
                CCHmac(algorithm.algorithm, keyBytes, key.count, dataBytes, data.count, signature)
            }
        }
        
        return Data(bytes: signature, count: algorithm.digestLength)
    }
    
    /// Calculate HMAC signature
    ///
    /// - Parameters:
    ///   - data: Input data
    ///   - algorithm: HMAC algorithm
    ///   - key: Secret key
    /// - Returns: signature string
    static func sign(data: Data, algorithm: Algorithm, key: String) -> Data? {
        guard let keyData = key.data(using: .utf8) else {
            return nil
        }
        
        return sign(data: data, algorithm: algorithm, key: keyData)
    }
    
    /// Calculate HMAC signature
    ///
    /// - Parameters:
    ///   - message: Input string
    ///   - algorithm: HMAC algorithm
    ///   - key: Secret key
    /// - Returns: signature string
    static func sign(message: String, algorithm: Algorithm, key: String) -> Data? {
        guard let messageData = message.data(using: .utf8), let keyData = key.data(using: .utf8) else {
            return nil
        }
        
        return sign(data: messageData, algorithm: algorithm, key: keyData)
    }
}
