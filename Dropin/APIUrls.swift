//
//  APIUrls.swift
//  Dropin
//
//  Created by Christopher Pratt on 8/16/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

let base_url = "https://api.wedropin.com/"

// Auth
let signup_url = base_url + "auth/signup"
let login_url = base_url + "auth/login"
let validate_url = base_url + "auth/validate"
let name_set_url = base_url + "user/name/set"

// User
let get_user_by_id = base_url + "user/get/id"
let get_current_user = base_url + "user/get/current"
let add_friend = base_url + "user/friends/add"
let remove_friend = base_url + "user/friends/remove"
let block_friend = base_url + "user/friends/block"
let get_friends = base_url + "user/friends/get"

// Drops
let send_drops = base_url + "drops/send"
let get_drops_from = base_url + "drops/get/from"
let get_drops_to = base_url + "drops/get/to"
let get_drop_by_id = base_url + "drops/get/id"

// Push Tokens
let add_push_token = base_url + "push_token/add"
