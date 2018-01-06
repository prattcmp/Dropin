//
//  UserLocations.swift
//  Dropin
//
//  Created by Christopher Pratt on 1/4/18.
//  Copyright © 2018 Dropin. All rights reserved.
//

import Alamofire
import SwiftyJSON
import MapKit

class UserLocation: Equatable {
    var user_id: Int!
    var name: String!
    var coordinates: CLLocationCoordinate2D!
    var created_at: Date!
    
    init(empty: Bool) {
        self.user_id = 0
        self.name = ""
        self.coordinates = CLLocationCoordinate2DMake(0.0, 0.0)
        self.created_at = Date()
    }
    
    init(user_id: Int, name: String, coordinates: CLLocationCoordinate2D, created_at: Date) {
        self.user_id = user_id
        self.name = name
        self.coordinates = coordinates
        self.created_at = created_at
    }
    
    static func ==(lhs: UserLocation, rhs: UserLocation) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    static func setEnabled(_ enabled: Bool, done: @escaping ((_ isSuccess: Bool, _ message: String) -> Void)) {
        let (username, auth_token) = fetchAuth()

        let params: Parameters = [
            "username": username,
            "token": auth_token,
            "enabled": enabled
        ]
        
        Alamofire.request(location_set_enabled, method: .post, parameters: params).validate().responseJSON {
            response in
            if let data = response.data {
                if let json = try? JSON(data: data) {
                    if let result = json["result"].int, let message = json["message"].string {
                        if result == 1 {
                            done(true, message)
                        } else {
                            done(false, message)
                        }
                    }
                } else {
                    done(false, "")
                }
            }
        }
    }
    
    static func getEnabled(done: @escaping ((_ isSuccess: Bool, _ message: String, _ enabled: Bool) -> Void)) {
        let (username, auth_token) = fetchAuth()
        
        let params: Parameters = [
            "username": username,
            "token": auth_token
        ]
        
        Alamofire.request(location_get_enabled, method: .post, parameters: params).validate().responseJSON {
            response in
            if let data = response.data {
                if let json = try? JSON(data: data) {
                    if let result = json["result"].int,
                        let message = json["message"].string,
                        let enabled = json["enabled"].int {
                        if result == 1 {
                            if enabled == 1 {
                                done(true, message, true)
                            } else {
                                done(true, message, false)
                            }
                        } else {
                            done(false, message, false)
                        }
                    }
                    done(false, "", false)
                } else {
                    done(false, "", false)
                }
            }
        }
    }
    
    static func update(coordinates: CLLocationCoordinate2D, done: @escaping ((_ isSuccess: Bool, _ message: String) -> Void)) {
        let (username, auth_token) = fetchAuth()
        
        let coordinates = String(coordinates.latitude) + "," + String(coordinates.longitude)
        
        let params: Parameters = [
            "username": username,
            "token": auth_token,
            "coordinates": coordinates
        ]
        
        Alamofire.request(location_update, method: .post, parameters: params).validate().responseJSON {
            response in
            if let data = response.data {
                if let json = try? JSON(data: data) {
                    if let result = json["result"].int, let message = json["message"].string {
                        if result == 1 {
                            done(true, message)
                        } else {
                            done(false, message)
                        }
                    }
                } else {
                    done(false, "")
                }
            }
        }
    }
    
    static func getAll(done: @escaping ((_ isSuccess: Bool, _ message: String, _ userLocations: [UserLocation]) -> Void)) {
        let (username, auth_token) = fetchAuth()
        
        let params: Parameters = [
            "username": username,
            "token": auth_token
        ]
        
        Alamofire.request(get_user_locations, method: .post, parameters: params).validate().responseJSON {
            response in
            
            if (response.result.isFailure || (response.result.value) == nil) {
                done(false, "", [])
                return
            }
            
            if let data = response.data {
                let json = try! JSON(data: data)
                if let result = json["result"].int, let message = json["message"].string {
                    if result == 1 {
                        var my_locations = [UserLocation]()
                        if let locations = json["locations"].array {
                            locations.forEach { location in
                                if let user_id = location["user_id"].int,
                                    let username = location["username"].string,
                                    let name = location["name"].string,
                                    let coordinates = location["coordinates"].string,
                                    let created_at = location["created_at"].string {
                                    
                                    let created = DropDateFormatter.stringToDate(created_at)
                                    
                                    let coord_array = coordinates.components(separatedBy: ",")
                                    let clCoordinates = CLLocationCoordinate2DMake(Double(coord_array[0])!, Double(coord_array[1])!)
                                    
                                    let location = UserLocation(user_id: user_id,
                                                                     name: name,
                                                                     coordinates: clCoordinates,
                                                                     created_at: created)
                                    my_locations.append(location)
                                }
                            }
                            done(true, message, my_locations)
                        }
                    } else {
                        done(false, message, [UserLocation]())
                    }
                }
            }
        }
    }
}
