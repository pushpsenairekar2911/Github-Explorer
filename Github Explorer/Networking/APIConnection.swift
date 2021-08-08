//
//  APIConnection.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import Foundation

internal enum Host {
    
    case rest_host
    case client_host
   
}

internal struct SettingsRoutes {
    
    static var apiHost =  "api.github.com/"
    
    static var clientHost = ""

}
internal protocol EndPointType {
    
    var baseURL: Host { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var headers: HTTPHeaders? { get }
    var parameters: Parameters? { get }
    var urlElements : [String : Any]? { get }
}

public enum HTTPMethod : String {
   
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
    case patch   = "PATCH"
}

internal typealias Parameters = [String:Any];
internal typealias HTTPHeaders = [String:String?];


internal struct API: EndPointType {
    
    public var parameters: Parameters?
    
    public var baseURL: Host
    
    public var path: String
    
    public var httpMethod: HTTPMethod
    
    public var headers: HTTPHeaders?
    
    public var urlElements: [String : Any]?
    
    init(baseUrl:Host ,path:String , httpMethod:HTTPMethod , headers:HTTPHeaders? ,parameters:Parameters?, urlElements : [String : Any]?) {
        
        self.baseURL = baseUrl;
        self.path = path;
        self.httpMethod = httpMethod;
        self.headers = headers;
        self.parameters = parameters;
        self.urlElements = urlElements;
        
    }
    
    internal enum Routes{
        
        case rest_host
        case client_host
        
        var value:String {
            switch self {
                
            case .rest_host: return "https://" + SettingsRoutes.apiHost;
                
            case .client_host: return "https://" + SettingsRoutes.clientHost;
            }
        }
    }
    var buildRequest:URLRequest {
        
        var url:String {
            
            switch self.baseURL {
            case .client_host:
                return Routes.client_host.value + self.path;
            case .rest_host:
                return Routes.rest_host.value + self.path;
            }
        }
        var request : URLRequest?
        if(parameters == nil && self.httpMethod.rawValue == "GET"){
            
            var items = [URLQueryItem]()
            
            if let apiurlElements = urlElements {
                
                for (key,value) in apiurlElements {
                    
                    items.append(URLQueryItem(name: key, value: value as? String))
                }
            }
            
            let urlComponents = NSURLComponents(string: url)
            if !items.isEmpty {
                urlComponents!.queryItems = items
            }
            
            request = URLRequest(url: urlComponents!.url!,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 60.0)
            request?.httpMethod = self.httpMethod.rawValue
            
            addAdditionalHeaders(self.headers, request: &request!)
        }else {

            request = URLRequest(url: URL(string: url)!,
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 60.0)
            request?.httpMethod = self.httpMethod.rawValue
            addAdditionalHeaders(self.headers, request: &request!)
            if let param = self.parameters {
                
                do
                {
                    try JSONParameterEncoder.encode(urlRequest: &request!, with: param);
                    
                } catch  {
                   print(error);
                }
            }
        }
        
        return request!;
    }
}

fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
    
    guard let headers = additionalHeaders else { return }
    
    for (key, value) in headers {
        request.setValue(value, forHTTPHeaderField: key)
    }
}

