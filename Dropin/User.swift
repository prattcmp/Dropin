//
//  User.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/28/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class User: Equatable {
    var id: Int!
    var username: String!
    var name: String!
    var friends = [User]()
    var drops = [Drop]()
    
    init(empty: Bool) {
        self.id = 0
        self.username = ""
        self.name = ""
    }
    
    required init() {
        self.getCurrentUser() { (_ isSuccess: Bool, _ id: Int, _ username: String, _ name: String) in
            self.id = id
            self.username = username
            self.name = name
            
            self.refreshFriends {_ in }
        }
    }
    
    init(id: Int) {
        self.getUserByID(id: id) { (_ isSuccess: Bool, _ username: String, _ name: String) in
            self.id = id
            self.username = username
            self.name = name
        }
        
        self.refreshFriends {_ in }
    }
    
    init(id: Int, username: String, name: String) {
        self.id = id
        self.username = username
        self.name = name
        
        self.refreshFriends {_ in }
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    func refreshFriends(done: @escaping ((_ isSuccess: Bool) -> Void)) {
        self.getFriends { (_ isSuccess: Bool, _ message: String, _ friends: [User]) in
            self.friends = friends
            
            done(true)
        }
    }
    
    func refreshDrops(done: @escaping ((_ isSuccess: Bool) -> Void)) {
        Drop.getByToID(id: self.id) { (_ isSuccess: Bool, _ message: String, _ drops: [Drop]) in
            self.drops = drops
            
            Drop.getByFromID(id: self.id) { (_ isSuccess: Bool, _ message: String, _ drops: [Drop]) in
                self.drops += drops
                self.drops.sort(by: { $0.expires_at.compare($1.expires_at) == .orderedDescending})
                
                done(true)
            }
        }
    }
    
    func toDict() -> Dictionary<String, String> {
        return ["id": String(self.id), "username": self.username, "name": self.name]
    }
    
    func getCurrentUser(done: @escaping ((_ isSuccess: Bool, _ id: Int, _ username: String, _ name: String) -> Void)) {
        let package: NSDictionary = NSMutableDictionary()
        
        let (username, auth_token) = fetchAuth()
        
        package.setValue(username, forKey: "username")
        package.setValue(auth_token, forKey: "token")
        
        let url:URL = URL(string: get_current_user)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        var paramString = ""
        
        
        for (key, value) in package
        {
            paramString = paramString + (key as! String) + "=" + (value as! String) + "&"
        }
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                done(false, 0, "", "")
                return
            }
            
            let json: Any?
            
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            }
            catch
            {
                done(false, 0, "", "")
                return
            }
            
            guard let data = json as? NSDictionary else
            {
                done(false, 0, "", "")
                return
            }
            
            if let result = data["result"] as? Int
            {
                if result == 0 {
                    done(false, 0, "", "")
                    return
                }
                else if result == 1 {
                    if let data_name = data["name"] as? String,
                        let data_username = data["username"] as? String,
                        let data_id = data["id"] as? Int
                    {
                        done(true, data_id, data_username, data_name)
                        return
                    }
                    else
                    {
                        done(false, 0, "", "")
                        return
                    }
                }
            }
        })
        
        task.resume()
    }
    
    func getUserByID(id: Int, done: @escaping ((_ isSuccess: Bool, _ username: String, _ name: String) -> Void)) {
        let package: NSDictionary = NSMutableDictionary()
        
        let (username, auth_token) = fetchAuth()
        
        package.setValue(String(id), forKey: "user_id")
        package.setValue(username, forKey: "username")
        package.setValue(auth_token, forKey: "token")
        
        let url:URL = URL(string: get_user_by_id)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        var paramString = ""
        
        
        for (key, value) in package
        {
            paramString = paramString + (key as! String) + "=" + (value as! String) + "&"
        }
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                done(false, "", "")
                return
            }
            
            let json: Any?
            
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            }
            catch
            {
                done(false, "", "")
                return
            }
            
            guard let data = json as? NSDictionary else
            {
                done(false, "", "")
                return
            }
            
            if let result = data["result"] as? Int
            {
                if result == 0 {
                    done(false, "", "")
                    return
                }
                else if result == 1 {
                    if let data_name = data["name"] as? String,
                        let data_username = data["username"] as? String
                    {
                        done(true, data_username, data_name)
                        return
                    }
                    else
                    {
                        done(false, "", "")
                        return
                    }
                }
            }
        })
        
        task.resume()
    }
    
    func getFriends(done: @escaping ((_ isSuccess: Bool, _ message: String, _ friends: [User]) -> Void)) {
        let package: NSDictionary = NSMutableDictionary()
        
        let (username, auth_token) = fetchAuth()
        
        package.setValue(username, forKey: "username")
        package.setValue(auth_token, forKey: "token")
        
        let url:URL = URL(string: get_friends)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        var paramString = ""
        
        
        for (key, value) in package
        {
            paramString = paramString + (key as! String) + "=" + (value as! String) + "&"
        }
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                done(false, "", [User]())
                return
            }
            
            let json: Any?
            
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            }
            catch
            {
                done(false, "", [User]())
                return
            }
            
            guard let data = json as? NSDictionary else
            {
                done(false, "", [User]())
                return
            }
            
            if let result = data["result"] as? Int
            {
                if result == 1 {
                    var friends = [User]()
                    for friend in data["friends"] as! [Dictionary<String, Any>]  {
                        let user = User(id: (friend["id"] as! Int),
                                        username: (friend["username"] as! String),
                                        name: (friend["name"] as! String) )
                        friends.append(user)
                    }
                    
                    done(true, "", friends)
                    return
                }
                else {
                    done(false, "", [User]())
                    return
                }
            }
        })
        
        task.resume()
    }
    
    func addFriend(username: String, done: @escaping ((_ isSuccess: Bool, _ message: String, _ friend: User) -> Void)) {
        var friendUsername = username
        
        if friendUsername.hasPrefix("@") {
            friendUsername.remove(at: friendUsername.startIndex)
        }
        
        let package: NSDictionary = NSMutableDictionary()
        
        let (username, auth_token) = fetchAuth()
        
        package.setValue(friendUsername, forKey: "friend_username")
        package.setValue(username, forKey: "username")
        package.setValue(auth_token, forKey: "token")
        
        let url:URL = URL(string: add_friend)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        var paramString = ""
        
        
        for (key, value) in package
        {
            paramString = paramString + (key as! String) + "=" + (value as! String) + "&"
        }
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                done(false, "", User(empty: true))
                return
            }
            
            let json: Any?
            
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            }
            catch
            {
                done(false, "", User(empty: true))
                return
            }
            
            guard let data = json as? NSDictionary else
            {
                done(false, "", User(empty: true))
                return
            }
            
            if let result = data["result"] as? Int,
                let message = data["message"] as? String
            {
                if result == 0 {
                    done(false, message, User(empty: true))
                    return
                }
                else if result == 1 {
                    if let id = data["id"] as? Int,
                        let username = data["username"] as? String,
                        let name = data["name"] as? String
                    {
                        let user = User(id: id, username: username, name: name)
                        
                        done(true, message, user)
                        return
                    }
                    else
                    {
                        done(false, message, User(empty: true))
                        return
                    }
                }
            }
        })
        
        task.resume()
    }
    
    func removeFriend(id: Int, done: @escaping ((_ isSuccess: Bool, _ message: String) -> Void)) {
        
        let package: NSDictionary = NSMutableDictionary()
        
        let (username, auth_token) = fetchAuth()
        
        package.setValue(String(id), forKey: "id")
        package.setValue(username, forKey: "username")
        package.setValue(auth_token, forKey: "token")
        
        let url:URL = URL(string: remove_friend)!
        let session = URLSession.shared
        
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = URLRequest.CachePolicy.reloadIgnoringCacheData
        
        var paramString = ""
        
        
        for (key, value) in package
        {
            paramString = paramString + (key as! String) + "=" + (value as! String) + "&"
        }
        
        request.httpBody = paramString.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {
            (
            data, response, error) in
            
            guard let _:Data = data, let _:URLResponse = response, error == nil else {
                done(false, "")
                return
            }
            
            let json: Any?
            
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            }
            catch
            {
                done(false, "")
                return
            }
            
            guard let data = json as? NSDictionary else
            {
                done(false, "")
                return
            }
            
            if let result = data["result"] as? Int,
                let message = data["message"] as? String
            {
                if result == 0 {
                    done(false, message)
                    return
                }
                else if result == 1 {
                    done(true, message)
                    return
                }
            }
        })
        
        task.resume()
    }
    
}
