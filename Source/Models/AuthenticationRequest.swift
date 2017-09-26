//
//  AuthenticationRequest.swift
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

public class AuthenticationRequest: Codable, Equatable {
    
    // MARK: - Properties
    
    public var id: String
    public var authType: AuthType
    public var expiry: Int
    public var pin: String?
    public var ip: String?
    public var geoIp: GeoIp?
    public var created: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case authType = "auth_type"
        case expiry
        case pin
        case ip
        case geoIp = "geoip"
        case created = "created_at"
    }
    
    public static func == (lhs: AuthenticationRequest, rhs: AuthenticationRequest) -> Bool {
        return lhs.id == rhs.id
    }
}
