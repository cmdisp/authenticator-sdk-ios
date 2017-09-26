//
//  AuthenticatorConfig.swift
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

public protocol AuthenticatorConfig {
    var publicKey: String { get }
    var defaultFingerprints: [String] { get }
    var apiBaseUrl: String { get }
    var certificateUpdateInterval: TimeInterval { get }
}

struct AuthenticatorConfigDefault: AuthenticatorConfig {
    var publicKey = "MIIBCgKCAQEAsH+SP53J8v5qORDS4I6S3tuFGuw/RtariaYEg+he2jlgXfpD+MQCtyWmAtTvZtOwFxsDJvLr9O1iDlsKAvMTBZ0UVkixfWGg0Uo5+Qty23WnNH74CHDv2aD1A7GmTjC8ixC5QOjSFqHHP3j8OHtA6TQNTfpWHiZD7jHZRc1dRh+ga/SPrVeTqIDFrs7QfclXnricX/3VoPgWPL7GWy0zHjpBqVP106ETh0tDWFAiZ9ie/eDXUt9s/hHbuJVe4zeOsiZ2TGmZfx2Lf1w57c9EtEuPhsBiWt+HBiq1tqMT5DJZ3hj+vM/mgzaWRQhzz661E+D61R2/jhLf9Hx6SBBBMQIDAQAB"
    var defaultFingerprints = ["d2bb051ea4e70d31ac3c9e3090cbca3affcef0ffb3106a951d5d564ba027e249"]
    var apiBaseUrl = "https://api.auth.cmtelecom.com/authenticator/v1.0"
    var certificateUpdateInterval: TimeInterval = 3600
}
