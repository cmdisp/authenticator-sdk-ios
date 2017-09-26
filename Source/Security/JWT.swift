//
//  JWT.swift
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

struct JWT {
    
    /// Default JWT headers
    fileprivate static let headers = [
        "alg": "HS256",
        "typ": "JWT",
    ]
    
    /// Generate a JSON Web Token using HMAC-SHA256
    ///
    /// - Parameters:
    ///   - claims: JWT claims
    ///   - key: Secret key
    /// - Returns: JWT string
    static func encode(claims: JWTClaims? = nil, key: String) -> String? {
        let claims = claims ?? JWTClaims()
        
        do {
            let header = try JSONSerialization.data(withJSONObject: headers)
            let payload = try JSONSerialization.data(withJSONObject: claims.values)
            let input = "\(header.base64UrlEncodedString()).\(payload.base64UrlEncodedString())"
            
            guard let signature = HMAC.sign(message: input, algorithm: .sha256, key: key) else {
                return nil
            }
            return "\(input).\(signature.base64UrlEncodedString())"
        } catch {
            return nil
        }
    }
}
