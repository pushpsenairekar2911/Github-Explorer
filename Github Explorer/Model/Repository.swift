//
//  Repository.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import Foundation


public class Repository: Decodable {
    
    let id: Int
    let node_id: String
    let name: String
    let full_name: String
    let isPrivate: Bool
    let html_url: String
    let description: String
    let forks: Int
    let score: Int
    let watchers: Int
    let language: String
    let openIssues: Int
    let issues_url: String
    
    init(id: Int, node_id: String, name: String, fullName: String, isPrivate: Bool, url: String, description: String, forks: Int, score: Int, watchers: Int, language: String, openIssues: Int, issuesURL: String) {
        
        self.id = id
        self.node_id = node_id
        self.name = name
        self.full_name = fullName
        self.isPrivate = isPrivate
        self.html_url = url
        self.description = description
        self.forks = forks
        self.score = score
        self.watchers = watchers
        self.language = language
        self.openIssues = openIssues
        self.issues_url = issuesURL
    }
    
    
    
}
