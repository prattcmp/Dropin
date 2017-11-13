//
//  PushToken.swift
//  Dropin
//
//  Created by Christopher Pratt on 11/11/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Alamofire
import SwiftyJSON
import MapKit

class PushToken {
    static func add(token: String, done: @escaping ((_ isSuccess: Bool, _ message: String) -> Void)) {
        let (username, auth_token) = fetchAuth()
        
        let params: Parameters = [
            "username": username,
            "token": auth_token,
            "push_token": token
        ]
        
        Alamofire.request(add_push_token, method: .post, parameters: params).validate().responseJSON {
            response in
            
            if (response.result.isFailure || (response.result.value) == nil) {
                done(false, "")
                return
            }
            
            if let data = response.data {
                let json = try! JSON(data: data)
                if let result = json["result"].int, let message = json["message"].string {
                    if result == 1 {
                            done(true, message)
                    } else {
                        done(false, "")
                    }
                }
            
                done(false, "")
            }
        }
    }
}
