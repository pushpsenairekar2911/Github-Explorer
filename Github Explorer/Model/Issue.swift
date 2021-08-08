//
//  Repository.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import Foundation


public class Issue: Decodable {
    
    let id: Int
    let title: String
    let state: String
    let assignee: String
    let created_at: String
    let updated_at: String
    
    init(id: Int, title: String, state: String, assignee: String, created_at: String, updated_at: String) {
        
        self.id = id
        self.title = title
        self.state = state
        self.assignee = assignee
        self.created_at = created_at
        self.updated_at = updated_at
    }
}
