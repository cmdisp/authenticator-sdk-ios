//
//  Certificate.swift
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

class Certificate: Decodable {
    
    // MARK: - Properties
    
    public static let publicKeyUserInfoKey = CodingUserInfoKey(rawValue: "publicKey")!
    
    var hash: String
    var algorithm: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case signature
        case hash
        case algorithm
    }
    
    /// Creates a new `Certificate` instance with hash and algorithm
    ///
    /// - Parameters:
    ///   - hash: Certificate hash
    ///   - algorithm: Hash algorithm
    init(hash: String, algorithm: String) {
        self.hash = hash.lowercased()
        self.algorithm = algorithm.lowercased()
    }
    
    /// Creates a new `Certificate` instance from a JSONDecoder
    ///
    /// - Parameter decoder: JSONDecoder
    /// - Throws: an error when the certificate data cannot be decoded or verified
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let cert = try container.decode(String.self, forKey: .data)
        let signature = try container.decode(String.self, forKey: .signature)

        let certData = Data(base64Encoded: cert)
        let signatureData = Data(base64Encoded: signature)

        if let publicKey = decoder.userInfo[Certificate.publicKeyUserInfoKey] as? String {
            if (RSA.verify(content: certData, signature: signatureData, key: publicKey)) {
                if let certData = certData, let obj = try JSONSerialization.jsonObject(with: certData, options: []) as? [String: Any] {
                    if let hashValue = obj["hash"] as? String, let algorithmValue = obj["algorithm"] as? String {
                        self.init(hash: hashValue, algorithm: algorithmValue)
                        return
                    }
                }
            }
        }

        throw DecodingError.dataCorruptedError(forKey: .data, in: container, debugDescription: "Invalid data")
    }
}
