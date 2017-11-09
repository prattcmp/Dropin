//
//  Drop.swift
//  Dropin
//
//  Created by Christopher Pratt on 10/14/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Alamofire
import SwiftyJSON
import MapKit

class Drop: Equatable {
    var id: Int!
    var coordinates: CLLocationCoordinate2D!
    
    var expires_at: Date!
    var created_at: Date!
    var from: User!
    var to: User!
    
    init(empty: Bool) {
        self.id = 0
        self.coordinates = CLLocationCoordinate2DMake(0.0, 0.0)
        self.expires_at = Date()
        self.created_at = Date()
        self.from = User(empty: true)
        self.to = User(empty: true)
    }
    
    init(id: Int, from: User, to: User, coordinates: CLLocationCoordinate2D, expires_at: Date, created_at: Date) {
        self.id = id
        self.from = from
        self.to = to
        self.coordinates = coordinates
        self.expires_at = expires_at
        self.created_at = created_at
    }
    
    static func ==(lhs: Drop, rhs: Drop) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    static func send(to: [User], coordinates: CLLocationCoordinate2D, done: @escaping ((_ isSuccess: Bool, _ message: String) -> Void)) {
        let (username, auth_token) = fetchAuth()
        let coordinates = String(coordinates.latitude) + "," + String(coordinates.longitude)
        let friends = try? JSONSerialization.data(withJSONObject: to.map{ $0.toDict() }, options: [])
        
        let params: Parameters = [
            "username": username,
            "token": auth_token,
            "friends": String(data: friends!, encoding: .ascii)!,
            "coordinates": coordinates
        ]
        
        Alamofire.request(send_drops, method: .post, parameters: params).validate().responseJSON {
            response in
            if let data = response.data {
                let json = try! JSON(data: data)
                if let result = json["result"].int, let message = json["message"].string {
                    if result == 1 {
                        done(true, message)
                    } else {
                        done(false, message)
                    }
                }
            }
        }
    }
    
    static func getDropByID(id: Int, done: @escaping ((_ isSuccess: Bool, _ message: String, _ drop: Drop) -> Void)) {
        let (username, auth_token) = fetchAuth()
        
        let params: Parameters = [
            "username": username,
            "token": auth_token,
            "id": id
        ]
        
        Alamofire.request(get_drop_by_id, method: .post, parameters: params).validate().responseJSON {
            response in
            if let data = response.data {
                let json = try! JSON(data: data)
                if let result = json["result"].int, let message = json["message"].string {
                    if result == 1 {
                        if let id = json["to_id"].int,
                            let coordinates = json["coordinates"].string,
                            let expires_at = json["expires_at"].string,
                            let created_at = json["created_at"].string {
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let expires = dateFormatter.date(from: expires_at) as Date!
                            let created = dateFormatter.date(from: created_at) as Date!
                            
                            let coord_array = coordinates.components(separatedBy: ",")
                            let clCoordinates = CLLocationCoordinate2DMake(Double(coord_array[0])!, Double(coord_array[1])!)
                            
                            done(true, message, Drop(id: id, from: User(), to: User(id: id), coordinates: clCoordinates, expires_at: expires!, created_at: created!))
                        }
                    } else {
                        done(false, message, Drop(empty: true))
                    }
                }
            }
        }
    }
    
    static func getByFromID(id: Int, done: @escaping ((_ isSuccess: Bool, _ message: String, _ drops: [Drop]) -> Void)) {
        let (username, auth_token) = fetchAuth()
        
        let params: Parameters = [
            "username": username,
            "token": auth_token,
            "id": id
        ]
        
        Alamofire.request(get_drops_from, method: .post, parameters: params).validate().responseJSON {
            response in
            
            if (response.result.isFailure || (response.result.value) == nil) {
                done(false, "", [])
                return
            }
            
            if let data = response.data {
                let json = try! JSON(data: data)
                if let result = json["result"].int, let message = json["message"].string {
                    if result == 1 {
                        var my_drops = [Drop]()
                        if let drops = json["drops"].array {
                            drops.forEach { drop in
                                if let id = drop["id"].int,
                                    let user_id = drop["user_id"].int,
                                    let coordinates = drop["coordinates"].string,
                                    let expires_at = drop["expires_at"].string,
                                    let created_at = drop["created_at"].string {
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    let expires = dateFormatter.date(from: expires_at) as Date!
                                    let created = dateFormatter.date(from: created_at) as Date!
                                    
                                    let coord_array = coordinates.components(separatedBy: ",")
                                    let clCoordinates = CLLocationCoordinate2DMake(Double(coord_array[0])!, Double(coord_array[1])!)
                                    
                                    my_drops.append(Drop(id: id, from: currentUser, to: User(id: user_id), coordinates: clCoordinates, expires_at: expires!, created_at: created!))
                                }
                            }
                            done(true, message, my_drops)
                        }
                    } else {
                        done(false, message, [Drop]())
                    }
                }
            }
        }
    }
    
    static func getByToID(id: Int, done: @escaping ((_ isSuccess: Bool, _ message: String, _ drops: [Drop]) -> Void)) {
        let (username, auth_token) = fetchAuth()
        
        let params: Parameters = [
            "username": username,
            "token": auth_token,
            "id": id
        ]
        
        Alamofire.request(get_drops_to, method: .post, parameters: params).validate().responseJSON {
            response in
            
            if (response.result.isFailure || (response.result.value) == nil) {
                done(false, "", [])
                return
            }
            
            if let data = response.data {
                let json = try! JSON(data: data)
                if let result = json["result"].int, let message = json["message"].string {
                    if result == 1 {
                        var my_drops = [Drop]()
                        if let drops = json["drops"].array {
                            drops.forEach { drop in
                                if let coordinates = drop["coordinates"].string,
                                    let from_id = drop["user_id"].int,
                                    let from_username = drop["username"].string,
                                    let from_name = drop["name"].string,
                                    let expires_at = drop["expires_at"].string,
                                    let created_at = drop["created_at"].string {
                                    
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    dateFormatter.timeZone = TimeZone(identifier: "UTC")!
                                    let expires = dateFormatter.date(from: expires_at) as Date!
                                    let created = dateFormatter.date(from: created_at) as Date!
                                    
                                    let coord_array = coordinates.components(separatedBy: ",")
                                    let clCoordinates = CLLocationCoordinate2DMake(Double(coord_array[0])!, Double(coord_array[1])!)
                                    
                                    my_drops.append(Drop(id: id, from: User(id: from_id, username: from_username, name: from_name), to: currentUser, coordinates: clCoordinates, expires_at: expires!, created_at: created!))
                                }
                            }
                            done(true, message, my_drops)
                        }
                    } else {
                        done(false, message, [Drop]())
                    }
                }
            }
        }
    }
}
