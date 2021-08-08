//
//  Github.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import Foundation

enum Order {
    case asc
    case dsc
    
    var value:String {
        switch self {
        case .asc: return "asc"
        case .dsc: return "dsc"
        }
    }
}


public final class Github: NSObject  {
    
    static var baseURL: String  = "https://api.github.com"
    typealias repoResult = (_ result: Result<[Repository], Error>) -> Void
    typealias issueResult = (_ result: Result<[Issue], Error>) -> Void
    typealias loginResult = (_ result: Result<User, Error>) -> Void
    
    static func login(withUser: String, completion: @escaping loginResult) {
        
        let semaphore = DispatchSemaphore (value: 0)
        var request = URLRequest(url: URL(string: "\(baseURL)/users/\(withUser)")!,timeoutInterval: Double.infinity)
        request.addValue("logged_in=no", forHTTPHeaderField: "Cookie")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                
                semaphore.signal()
                return
            }
            if let error  = error {
                completion(.failure(error))
            }
            
            if let response1 = String(data: data, encoding: .utf8), let user = response1.toJSON() as? [String:Any]{
                
                let name = user["login"] as? String ?? ""
                let id   = user["id"] as? Int ?? 0
                let node_id   = user["node_id"] as? String ?? ""
                let avatar_url   = user["avatar_url"] as? String ?? ""
                let gravatar_id = user["gravatar_id"] as? String ?? ""
                let html_url   = user["html_url"] as? String ?? "0"
                let followers_url   = user["followers_url"] as? String ?? ""
                let following_url   = user["following_url"] as? String ?? ""
                let organizations_url = user["organizations_url"] as? String ?? ""
                let repos_url   = user["repos_url"] as? String ?? ""
                let location   = user["location"] as? String ?? ""
                let followers   = user["followers"] as? Int ?? 0
                let following = user["following"] as? Int ?? 0
                
                if id != 0 {
                    let user = User(uid: id, node_id: node_id, name: name, avatar_url: avatar_url, gravatar_id: gravatar_id, html_url: html_url, followers_url: followers_url, following_url: following_url, organizations_url: organizations_url, repos_url: repos_url, following: following, location: location, followers: followers)
                    
                    LoggedInUser.save(user)
                    completion(.success(user))
                }else{
                    completion(.failure(NSError(domain: "", code: 401, userInfo: [ NSLocalizedDescriptionKey: "This user credentials are not valid.  Please provide a valid User Credentials"])))
                }
                
            }
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    
    static func searchRepositories(with keyword: String, order: Order, completion: @escaping repoResult) {
        let parameters = ["q": keyword,"order":order.value]
        var components = URLComponents(string: "\(baseURL)/search/repositories")!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        let request = URLRequest(url: components.url!)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard
                let data = data,                              // is there data
                let response = response as? HTTPURLResponse,  // is there HTTP response
                200 ..< 300 ~= response.statusCode,           // is statusCode 2XX
                error == nil                                  // was there no error
            else {
                if let error  = error {
                    completion(.failure(error))
                }
                return
            }
            var repos: [Repository] = []
            
            if let responseObject = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any], let items = responseObject["items"] as? [[String: Any]]  {
                
                for item in items {
                    
                    let id = item["id"] as? Int ?? 0
                    let node_id = item["node_id"] as? String ?? ""
                    let name = item["name"] as? String ?? ""
                    let full_name = item["full_name"] as? String ?? ""
                    let isPrivate = item["private"] as? Bool ?? false
                    let html_url = item["html_url"] as? String ?? ""
                    let description = item["description"] as? String ?? ""
                    let watchers = item["watchers"] as? Int ?? 0
                    let language = item["language"] as? String ?? ""
                    let forks = item["forks"] as?  Int ?? 0
                    let open_issues = item["open_issues"] as? Int ?? 0
                    let score = item["score"] as? Int ?? 0
                    let issues = (item["issues_url"] as? String)?.replacingOccurrences(of: "{/number}", with: "") ?? ""
                    
                    
                    let repo = Repository(id: id, node_id: node_id, name: name, fullName: full_name, isPrivate: isPrivate , url: html_url, description: description, forks: forks, score: score, watchers: watchers, language: language, openIssues: open_issues, issuesURL: issues)
                    repos.append(repo)
                }
            }
            completion(.success(repos))
        }
        task.resume()
    }
    
    static func pullOwnRepositories(for user: User, completion: @escaping repoResult) {
        
        let semaphore = DispatchSemaphore (value: 0)
        
        var request = URLRequest(url: URL(string: "\(baseURL)/users/\(user.name)/repos")!,timeoutInterval: Double.infinity)
        request.addValue("logged_in=no", forHTTPHeaderField: "Cookie")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                semaphore.signal()
                return
            }
            
            var myRepos: [Repository] = []
            
            if let response1 = String(data: data, encoding: .utf8), let repos = response1.toJSON() as? [[String:Any]]{
                
                for repo in repos {
                    let id = repo["id"] as? Int ?? 0
                    let node_id = repo["node_id"] as? String ?? ""
                    let name = repo["name"] as? String ?? ""
                    let full_name = repo["full_name"] as? String ?? ""
                    let isPrivate = repo["private"] as? Bool ?? false
                    let html_url = repo["html_url"] as? String ?? ""
                    let description = repo["description"] as? String ?? ""
                    let watchers = repo["watchers"] as? Int ?? 0
                    let language = repo["language"] as? String ?? ""
                    let forks = repo["forks"] as?  Int ?? 0
                    let open_issues = repo["open_issues"] as? Int ?? 0
                    let score = repo["score"] as? Int ?? 0
                    let issues = (repo["issues_url"] as? String)?.replacingOccurrences(of: "{/number}", with: "") ?? ""
                    
                    let repo = Repository(id: id, node_id: node_id, name: name, fullName: full_name, isPrivate: isPrivate , url: html_url, description: description, forks: forks, score: score, watchers: watchers, language: language, openIssues: open_issues, issuesURL: issues)
                    myRepos.append(repo)
                }
            }
            completion(.success(myRepos))
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    
    static func showIssues(for repo: Repository, completion: @escaping issueResult) {
        
        let semaphore = DispatchSemaphore (value: 0)
        var issuesArray: [Issue] = []
        var request = URLRequest(url: URL(string: repo.issues_url)!,timeoutInterval: Double.infinity)
        request.addValue("logged_in=no", forHTTPHeaderField: "Cookie")
        
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                
                semaphore.signal()
                return
            }
            if let error  = error {
                completion(.failure(error))
            }
            
            if let response1 = String(data: data, encoding: .utf8), let issues = response1.toJSON() as? [[String:Any]]{
                
                for issue in issues {
                    
                    let state = issue["state"] as? String ?? ""
                    let assignee = issue["assignee"] as? String ?? ""
                    let id = issue["id"] as? Int ?? 0
                    let title = issue["title"] as? String ?? ""
                    let created_at = issue["created_at"] as? String ?? ""
                    let updated_at = issue["updated_at"] as? String ?? ""
                    
                    let issue = Issue(id: id, title: title, state: state, assignee: assignee, created_at: created_at, updated_at: updated_at)
                    
                    issuesArray.append(issue)
                }
                completion(.success(issuesArray))
            }
            
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait()
    }
    
    
    
    
}

