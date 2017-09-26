//
//  HttpClient.swift
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

typealias Parameters = [String : String]
typealias Headers = [String : String]

class HttpClient: NSObject, URLSessionDelegate {
    
    // MARK: - Properties
    
    var baseUrl: String?
    var publicKey: String?
    
    lazy var jsonEncoder: JSONEncoder = {
        return JSONEncoder()
    }()
    
    lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        return decoder
    }()
    
    lazy var urlSession: URLSession = {
        [unowned self] in URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
    }()
    
    lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZ"
        return df
    }()
    
    let userAgent: String = {
        guard let info = Bundle.main.infoDictionary else {
            return "Authenticator"
        }
        let executable = info[kCFBundleExecutableKey as String] as? String ?? "Unknown"
        let bundle = info[kCFBundleIdentifierKey as String] as? String ?? "Unknown"
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
        let appBuild = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
        return "\(executable)/\(appVersion) (\(bundle); build:\(appBuild); iOS \(versionString))"
    }()
    
    var defaultHeaders: [String:String] = [
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json; charset=utf-8",
    ]
    
    // MARK: - Init
    
    /// Create a new HTTP client with optional base URL and public key
    ///
    /// - Parameters:
    ///   - baseUrl: The API base URL
    ///   - publicKey: Public key for decryption of certificates
    public init(baseUrl: String? = nil, publicKey: String? = nil) {
        defaultHeaders["User-Agent"] = self.userAgent
        
        self.baseUrl = baseUrl
        self.publicKey = publicKey
        
        super.init()
    }
    
    /// Perform a HTTP request
    ///
    /// - Parameters:
    ///   - url: Request URL
    ///   - method: HTTP Method
    ///   - parameters: Request parameters
    ///   - headers: Request headers
    ///   - completion: Completion handler
    public func request<T: Decodable>(url: String, method: RequestMethod = .get, parameters: Parameters? = nil, headers: Headers? = nil, completion: ((T?, ApiError?) -> Void)? = nil) {
        guard let url = URL(string: url) else {
            return
        }
        
        var httpBody: Data?
        
        if let p = parameters {
            do {
                httpBody = try jsonEncoder.encode(p)
            }
            catch {
                if let h = completion {
                    h(nil, ApiError.requestError(statusCode: -1, message: "Invalid request body"))
                }
                return
            }
        }

        request(url: url, method: method, httpBody: httpBody, headers: headers, completion: completion)
    }
    
    /// Perform a HTTP request
    ///
    /// - Parameters:
    ///   - url: Request URL
    ///   - method: HTTP Method
    ///   - httpBody: Request data
    ///   - headers: Request headers
    ///   - completion: Completion handler
    public func request<T: Decodable>(url: URL, method: RequestMethod = .get, httpBody: Data? = nil, headers: Headers? = nil, completion: ((T?, ApiError?) -> Void)? = nil) {
        var urlRequest = URLRequest(url: url)
        
        urlRequest.httpMethod = String(describing: method)
        
        if let httpBody = httpBody {
            urlRequest.httpBody = httpBody
        }
        
        for h in defaultHeaders {
            urlRequest.setValue(h.value, forHTTPHeaderField: h.key)
        }
        
        if let headers = headers {
            for h in headers {
                urlRequest.setValue(h.value, forHTTPHeaderField: h.key)
            }
        }
        
        let task = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            if let h = completion {
                guard error == nil else {
                    h(nil, ApiError.requestError(statusCode: -1, message: error?.localizedDescription ?? "Request error"))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    h(nil, ApiError.requestError(statusCode: -1, message: "Invalid response"))
                    return
                }

                guard let responseData = data else {
                    h(nil, ApiError.requestError(statusCode: httpResponse.statusCode, message: "Invalid response data"))
                    return
                }
                
                if httpResponse.statusCode == 204 {
                    h(nil, nil)
                    return
                }
                
                do {
                    if let publicKey = self.publicKey {
                        self.jsonDecoder.userInfo[Certificate.publicKeyUserInfoKey] = publicKey
                    }
                    
                    if httpResponse.statusCode >= 400 {
                        let obj = try self.jsonDecoder.decode(ApiErrorResponse.self, from: responseData)
                        h(nil, ApiError.requestError(statusCode: httpResponse.statusCode, message: obj.message))
                    } else {
                        let obj = try self.jsonDecoder.decode(T.self, from: responseData)
                        h(obj, nil)
                    }
                } catch let e {
                    h(nil, ApiError.requestError(statusCode: httpResponse.statusCode, message: "Error decoding response: \(e)"))
                }
            }
        }
        
        task.resume()
    }
}
