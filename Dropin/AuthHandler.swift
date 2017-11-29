//
//  AuthStatus.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/5/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

let navController = UINavigationController()
var currentUser: User!

func getUsername() -> String {
    let session_data = UserDefaults.standard.object(forKey: "session_data") as? [String: String] ?? [String: String]()
    
    return session_data["username"] ?? String()
}

func launchAuthScreen() {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    let authStoryboard : UIStoryboard = UIStoryboard(name: "UserAuth", bundle: nil)
    let authViewController : UIViewController = authStoryboard.instantiateViewController(withIdentifier: "Welcome") as UIViewController
    
    appDelegate?.window = UIWindow(frame: UIScreen.main.bounds)
    appDelegate?.window?.rootViewController = authViewController
    appDelegate?.window?.makeKeyAndVisible()
}

func launchNameScreen() {
    let appDelegate = UIApplication.shared.delegate as? AppDelegate

    let nameStoryboard : UIStoryboard = UIStoryboard(name: "CreateName", bundle: nil)
    let nameViewController : UIViewController = nameStoryboard.instantiateViewController(withIdentifier: "Name") as UIViewController
    
    appDelegate?.window = UIWindow(frame: UIScreen.main.bounds)
    appDelegate?.window?.rootViewController = nameViewController
    appDelegate?.window?.makeKeyAndVisible()
}

func launchDropin(_ launchScreen: String = "") {
    currentUser = User()
    
    navController.isToolbarHidden = true
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let dropinViewController: DropinViewController = DropinViewController(launchScreen)

    navController.viewControllers = [dropinViewController]
    
    let center = UNUserNotificationCenter.current()
    center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
        // Enable or disable features based on authorization.
    }
    UIApplication.shared.registerForRemoteNotifications()
    
    appDelegate.window = UIWindow(frame: UIScreen.main.bounds)
    appDelegate.window!.rootViewController = navController
    appDelegate.window?.makeKeyAndVisible()
}

func fetchAuth() -> (String, String) {
    let session_data = UserDefaults.standard.object(forKey: "session_data") as? [String: String] ?? [String: String]()
    
    if session_data.isEmpty {
        return ("", "")
    }
    
    let username = session_data["username"] ?? String()
    let auth_token = session_data["auth_token"] ?? String()
    
    if auth_token.isEmpty || username.isEmpty {
        return ("", "")
    }
    
    return (username, auth_token)
}

func launchByAuthStatus(_ launchScreen: String = "") {
    if(fetchAuth().0 == "") {
        launchAuthScreen()
        return
    }
    let (username, auth_token) = fetchAuth()
    
    let package: NSDictionary = NSMutableDictionary()
    
    package.setValue(username, forKey: "username")
    package.setValue(auth_token, forKey: "token")
    
    let url:URL = URL(string: validate_url)!
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
            print("error = \(String(describing: error))")
            return
        }
        
        let json: Any?
        
        do
        {
            json = try JSONSerialization.jsonObject(with: data!, options: [])
        }
        catch
        {
            DispatchQueue.main.async(execute: launchAuthScreen)
            return
        }
        
        guard let data = json as? NSDictionary else
        {
            return
        }
        
        if let result = data["result"] as? Int
        {
            if result == 0 {
                logout()
                return
            }
            else if result == 1 {
                if (UserDefaults.standard.object(forKey: "name") as? String) != nil {
                    // Reset the push token on the server if user logs back in
                    if let token = UserDefaults.standard.object(forKey: "device_push_token")  as? String {
                        PushToken.add(token: token, done: {_,_ in })
                    }
                    
                    DispatchQueue.main.async { launchDropin(launchScreen) }
                    
                    return
                }
                else {
                    if let name = data["name"] as? String
                    {
                        UserDefaults.standard.set(name, forKey: "name")
                        DispatchQueue.main.async { launchDropin(launchScreen) }
                        return
                    }
                    else {
                        DispatchQueue.main.async(execute: launchNameScreen)
                        return
                    }
                }
            }
        }
    })
    
    task.resume()
}

func logout() {
    UserDefaults.standard.removeObject(forKey: "session_data")
    UserDefaults.standard.removeObject(forKey: "name")
    
    DispatchQueue.main.async(execute: launchAuthScreen)
}
