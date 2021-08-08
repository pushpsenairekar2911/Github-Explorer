//
//  HttpRequest.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import Foundation

enum ResultType<T> {
    case success
    case notFound
    case failure(T)
}

private func handleRsponse (_ response:HTTPURLResponse ,serverdata:Data) -> ResultType<GithubException> {
    
    switch response.statusCode {
    case 200...299:
        return .success
        
    case 404:
        return .notFound
    default:
//        return .failure(serverdata);
    
        return .notFound
    }
}

internal typealias NetworkRouterCompletion = (_ response:HTTPURLResponse?, _ data:Data? ,_ error:GithubException?)->();

internal func httpRequest(request: URLRequest, isXMPPRequired : Bool = false, completionHandler:@escaping NetworkRouterCompletion){
    
    guard NetworkReachability.isConnectedToNetwork else {
        completionHandler(nil,nil,GithubException(errorCode: GihubConstants.ERROR_INTERNET_UNAVAILABLE, errorDescription: GihubConstants.ERROR_INTERNET_UNAVAILABLE_MESSAGE));
        return;
    }
    dataTaskWith(request: request) { (response,data, error)  in
        completionHandler(response,data , error)
    }
}

internal func dataTaskWith(request : URLRequest, completionHandler: @escaping NetworkRouterCompletion) {
    
    let session = URLSession.shared;
    session.configuration.timeoutIntervalForRequest = 30
    
     let task = session.dataTask(with: request){ (data, response, error) -> Void in
        
      
        // ensure there is no error for this HTTP response
        guard error == nil else {
            return
        }
        
        // ensure there is data returned from this HTTP response
        guard let content = data else {
            return;
        }
    
        
        if let response = response as? HTTPURLResponse{
           
            let Result = handleRsponse(response, serverdata: content);
            
            switch Result{
            case .success:
                completionHandler(response, data , nil);
                break;
            case .notFound:
                completionHandler(nil,nil, GithubException(errorCode: "URL_NOT_FOUND", errorDescription: "Not Found"))
                break;
            case .failure(let networkFailureError):
                completionHandler(nil,nil, networkFailureError)
                break;
            }
        }
    }
    
    task.resume();
}


import Foundation

internal protocol ParameterEncoder {
    static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws
}

var boundary =  "Boundary-" + UUID().uuidString;

internal struct JSONParameterEncoder:ParameterEncoder {
    
    public static func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
     
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: []);
            urlRequest.httpBody = jsonAsData;
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept");
            }
        } catch  {
            throw error;
        }
    }
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

internal func createMediaPost(urlstring:String, headers:HTTPHeaders, params:Parameters, mediaInfo: (fileName : String, mediaData : Data)) -> URLRequest{
    
    let url:URL = URL(string: urlstring)!;
    
    var request = URLRequest(url:url as URL);
    request.httpMethod = HTTPMethod.post.rawValue;
    
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type");
    
    request.allHTTPHeaderFields = headers as? [String : String];
    
    request.httpBody = createBodyWithParameters(parameters: params as? [String : String], filePathKey: "file", mediaInfo: mediaInfo, boundary: boundary)

    return request;
}

private func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, mediaInfo: (fileName : String, mediaData : Data), boundary: String) -> Data {
    
    var body = Data();
    
    if parameters != nil {
        for (key, value) in parameters! {
            body.append( "--\(boundary)\r\n");
            body.append( "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n");
            body.append( "\(value)\r\n");
        }
    }
    
    let filename = mediaInfo.fileName;
    let mimetype = "image/jpg";
    
    body.append( "--\(boundary)\r\n");
    body.append( "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n");
    body.append( "Content-Type: \(mimetype)\r\n\r\n");
    body.append(mediaInfo.mediaData); // get media data from URL
    body.append( "\r\n");
    
    body.append( "--\(boundary)--\r\n");
    
    return body;
}

//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
class DataUploader:NSObject{
    
    static let sharedInstance = DataUploader();
    var session:URLSession?

    var uploadProgress: ((Float)->Void)?
    
    func uploadFiles(request: URLRequest, data: Data) {
        
        let configuration = URLSessionConfiguration.default;
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main);
        if let task = self.session?.uploadTask(with: request, from: data){
            task.resume();
        }
    }
}

extension DataUploader:URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome streamTask: URLSessionStreamTask) {
        // The task became a stream task - start the task
        print( "didBecome streamTask")
        streamTask.resume()
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        // The task became a download task - start the task
        print( "didBecome downloadTask")
        downloadTask.resume()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // We've got a URLAuthenticationChallenge - we simply trust the HTTPS server and we proceed
        print( "didReceive challenge")
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willPerformHTTPRedirection response: HTTPURLResponse, newRequest request: URLRequest, completionHandler: (URLRequest?) -> Void) {
        // The original request was redirected to somewhere else.
        // We create a new dataTask with the given redirection request and we start it.
        if let urlString = request.url?.absoluteString {
            print( "willPerformHTTPRedirection to \(urlString)")
        } else {
            print( "willPerformHTTPRedirection")
        }
        if let task = self.session?.dataTask(with: request) {
            task.resume()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // We've got an error
        if let err = error {
            print( "Error: \(err.localizedDescription)")
        } else {
            print( "Error. Giving up")
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
        // We've got the response headers from the server.
        print( "didReceive response")
        completionHandler(URLSession.ResponseDisposition.allow)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // We've got the response body
        print( "didReceive data")
        if let responseText = String(data: data, encoding: .utf8) {
            print( "\nServer's response text")
            print(responseText)
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
            print(json as Any);
        } catch let error as NSError {
            print( "Error parsing JSON: \(error.localizedDescription)")
        }
        
        self.session?.finishTasksAndInvalidate()
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        let uploadProgress:Float = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        print(uploadProgress*100)
    }
}


extension Data {
    
    var DataToString:String? {
        return String(data: self, encoding: .utf8);
    }
    
    var exception: (GithubException) {
        
        do {
            let serverError = try JSONDecoder().decode(CometChatCodableError.self, from: self);
            return GithubException(errorCode: serverError.error.code, errorDescription: serverError.error.message);
        } catch  {
            return GithubException(errorCode: "SOMETHING_WENT_WRONG", errorDescription: error.localizedDescription);
        }
    }
    
    var rootObjects: (Any?,GithubException?) {
        
        do {
            let rootObjec = try JSONSerialization.jsonObject(with: self, options: []);
            if (rootObjec as? [String:Any]) != nil {
                if let dictionary = rootObjec as? [String: Any] {
                    return (dictionary["data"],nil);
                }
            }
        } catch  {
            return(nil,error.error);
        }
        return(nil,GithubException(errorCode: GihubConstants.ERROR_JSON_EXCEPTION, errorDescription: GihubConstants.ERROR_JSON_EXCEPTION_MESSAGE));
    }
    mutating func append(_ string: String) {
        self.append(string.data(using: .utf8)!)
    }
}
extension Error{
    
    var error: GithubException {
        return GithubException(errorCode: GihubConstants.ERROR_JSON_EXCEPTION, errorDescription: self.localizedDescription);
    }
}
extension Dictionary{
    
    var DictonaryToString: (String?,Error?){
        
        do{
            return (try JSONSerialization.data(withJSONObject: self, options: []).DataToString,nil);
        }catch{
            return(nil,error);
        }
    }
    
}
extension String {
    
    var toDictionary:[String: Any]? {
        
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any];
            } catch {
                 print(error.localizedDescription);
            }
        }
        return nil
    }
    

}

extension Optional where Wrapped == String {
    
    var isBlank: Bool {
        return self != nil && self != "" ? false : true ;
    }
}

extension Double {
    func roundTo(places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Sequence where Element: Equatable {
    var uniqueElements: [Element] {
        return self.reduce(into: []) {
            uniqueElements, element in
            
            if !uniqueElements.contains(element) {
                uniqueElements.append(element)
            }
        }
    }
}

extension Date {
    static var currentTimeStamp: Int64{
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
struct CometChatCodableError: Codable {
    
    let error: Error
    
    enum CodingKeys: String, CodingKey {
        case error = "error"
    }
    
    struct Error: Codable {
        let code: String
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case code = "code"
            case message = "message"
        }
    }
}
