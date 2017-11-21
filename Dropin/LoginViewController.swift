//
//  LoginViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/4/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        usernameTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self

        let usernameToolBar = UIToolbar().ToolbarPiker(#selector(SignUpViewController.dismissPicker))
        let passwordToolBar = UIToolbar().ToolbarPiker(#selector(SignUpViewController.dismissPicker))
        usernameTextField.inputAccessoryView = usernameToolBar
        passwordTextField.inputAccessoryView = passwordToolBar
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField?) {
        if(usernameTextField.text!.count > 3
            && passwordTextField.text!.count > 0) {
            loginButton.isHidden = false
        } else {
            loginButton.isHidden = true
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        if textField == self.passwordTextField {
            dismissPicker()
        }
        
        return true
    }
    
    @objc func dismissPicker() {
        textFieldChanged(nil)
        self.view.endEditing(true)
    }
    
    @IBAction func login(_ sender: UIButton?) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        let package: NSDictionary = NSMutableDictionary()
        
        package.setValue(username, forKey: "username")
        package.setValue(password, forKey: "password")
        
        let url:URL = URL(string: login_url)!
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
            
            guard let _:Data = data, let _:URLResponse = response  , error == nil else {
                
                return
            }
            
            let json: Any?
            
            do
            {
                json = try JSONSerialization.jsonObject(with: data!, options: [])
            }
            catch
            {
                return
            }
            
            guard let data = json as? NSDictionary else
            {
                return
            }
            
            if let result = data["result"] as? Int
            {
                if result == 0 {
                    if let message = data["message"] as? String {
                        let alert = UIAlertController(title: "Uh oh...",
                                                      message: message,
                                                      preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Okay",
                                                      style: UIAlertActionStyle.default,
                                                      handler: nil))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                else if result == 1 {
                    if let auth_token = data["auth_token"] as? String,
                        let username = data["username"] as? String {
                        
                        let session_data:[String:String] = ["auth_token": auth_token,
                                                            "username": username]
                        
                        UserDefaults.standard.set(session_data, forKey: "session_data")
                        
                        DispatchQueue.main.async(execute: launchByAuthStatus)
                    }
                }
            }
        })
        
        task.resume()
    }

}
