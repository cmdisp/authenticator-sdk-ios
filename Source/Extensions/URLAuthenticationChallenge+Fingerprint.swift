//
//  URLAuthenticationChallenge+Fingerprint.swift
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

extension URLAuthenticationChallenge {
    
    func sha256Fingerprint() -> String {
        guard let serverTrust = self.protectionSpace.serverTrust else {
            return ""
        }
        
        var result = SecTrustResultType.invalid
        if (SecTrustEvaluate(serverTrust, &result) != errSecSuccess){
            return "";
        }
        
        guard let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0) else {
            return ""
        }
        
        let data = SecCertificateCopyData(certificate) as NSData
        let length = CC_SHA256_DIGEST_LENGTH

        var buffer = [UInt8](repeating: 0, count: Int(length))
        CC_SHA256(data.bytes, CC_LONG(data.length), &buffer)
        
        let fingerPrint = NSMutableString()
        for byte in buffer {
            fingerPrint.appendFormat("%02x", byte)
        }
        
        return fingerPrint.trimmingCharacters(in: .whitespaces)
    }
}
