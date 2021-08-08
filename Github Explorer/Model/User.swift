//
//  User.swift
//  Github Explorer
//
//  Created by Pushpsen Airekar on 08/08/21.
//

import Foundation


class User: Codable {
    
    let uid: Int
    let node_id: String
    let name: String
    let avatar_url: String
    let gravatar_id: String
    let html_url: String
    let followers_url: String
    let following_url: String
    let organizations_url: String
    let repos_url: String
    let location: String
    let followers: Int
    let following: Int
    
    
    init(uid: Int, node_id: String, name: String, avatar_url: String, gravatar_id: String,html_url: String, followers_url: String, following_url: String, organizations_url: String, repos_url: String, following: Int,location: String, followers: Int) {
        
        self.uid =  uid
        self.node_id =  node_id
        self.name =  name
        self.avatar_url =  avatar_url
        self.gravatar_id =  gravatar_id
        self.html_url =  html_url
        self.followers_url =  followers_url
        self.following_url =  following_url
        self.organizations_url =  organizations_url
        self.repos_url =  repos_url
        self.location =  location
        self.followers =  followers
        self.following =  following

    }
}


struct LoggedInUser {
    static let key = "loggedInUser"
    static func save(_ value: User!) {
         UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: key)
    }
    static func information() -> User! {
        var userData: User!
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            userData = try? PropertyListDecoder().decode(User.self, from: data)
            return userData!
        } else {
            return userData
        }
    }
    static func remove() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
