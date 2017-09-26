//
//  RSA.swift
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

struct RSA {
    
    /// Verifies the cryptographic signature of a block of data using a public key and specified algorithm.
    ///
    /// - Parameters:
    ///   - content: Content to be verified
    ///   - signature: Content signature
    ///   - key: RSA Public key
    /// - Returns: `true` when the signature is valid
    static func verify(content: Data?, signature: Data?, key: Data) -> Bool {
        guard let content = content, let signature = signature else {
            return false
        }
        
        if #available(iOS 10.0, *) {
            let keyDict: [CFString: Any] = [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic,
            ]

            guard let secKey = SecKeyCreateWithData(key as CFData, keyDict as CFDictionary, nil) else {
                return false
            }

            return SecKeyVerifySignature(secKey, .rsaSignatureMessagePKCS1v15SHA256, content as CFData, signature as CFData, nil)
        } else {
            guard let publicKey = keyRef(key: key) else {
                return false
            }
        
            let publicKeyBlockSize = SecKeyGetBlockSize(publicKey)
            let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        
            let result = hashBytes(content: content).withUnsafeBytes { hashBytes in
                signature.withUnsafeBytes { signatureBytes in
                    SecKeyRawVerify(publicKey, .PKCS1SHA256, hashBytes, digestLength, signatureBytes, publicKeyBlockSize)
                }
            }
        
            return result == noErr
        }
    }
    
    /// Verifies the cryptographic signature of a block of data using a public key and specified algorithm.
    ///
    /// - Parameters:
    ///   - content: Content to be verified
    ///   - signature: Content signature
    ///   - key: RSA Public key
    /// - Returns: `true` when the signature is valid
    static func verify(content: Data?, signature: Data?, key: String) -> Bool {
        guard let keyData = Data(base64Encoded: key) else {
            return false
        }
        
        return verify(content: content, signature: signature, key: keyData)
    }
    
    /// Get the public key reference
    ///
    /// - Parameter key: Public key data
    /// - Returns: Public key reference
    private static func keyRef(key: Data) -> SecKey? {
        let persistKey = UnsafeMutablePointer<AnyObject?>(mutating: nil)
        
        guard let tag = UUID().uuidString.data(using: .utf8) else {
            return nil
        }
        
        defer {
            removeKey(tag: tag)
        }
        
        var attributes: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrApplicationTag: tag,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
            kSecValueData: key,
            kSecReturnPersistentRef: true
        ]
        
        let status = SecItemAdd(attributes as CFDictionary, persistKey)
        guard status == errSecSuccess || status == errSecDuplicateItem else {
            return nil
        }
        
        attributes.removeValue(forKey: kSecValueData)
        attributes.removeValue(forKey: kSecReturnPersistentRef)
        attributes[kSecReturnRef] = true
        
        var keyCopyResult: AnyObject? = nil
        SecItemCopyMatching(attributes as CFDictionary, &keyCopyResult)
        guard let keyResult = keyCopyResult else {
            return nil
        }
        
        return (keyResult as! SecKey)
    }
    
    /// Remove the key from the keychain
    ///
    /// - Parameter tag: The key identifier
    private static func removeKey(tag: Data) {
        let attributes: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag: tag,
        ]
        
        SecItemDelete(attributes as CFDictionary)
    }
    
    /// Calculate the SHA256 hash bytes from content
    ///
    /// - Parameter content: The data
    /// - Returns: Hash bytes
    private static func hashBytes(content: Data) -> Data {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hashBytes: [UInt8] = Array(repeating: 0x0, count: digestLength)
        var context = CC_SHA256_CTX()
        
        CC_SHA256_Init(&context)
        content.withUnsafeBytes { bytes in
            _ = CC_SHA256_Update(&context, bytes, CC_LONG(content.count))
        }
        
        CC_SHA256_Final(&hashBytes, &context)
        
        return Data(bytes: hashBytes, count: digestLength)
    }
}
