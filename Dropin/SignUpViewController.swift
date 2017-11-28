//
//  SignUpViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 8/14/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!

    override func viewDidAppear(_ animated: Bool) {
        usernameTextField.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.birthdayTextField.delegate = self
        
        let usernameToolBar = UIToolbar().ToolbarPiker(#selector(SignUpViewController.dismissPicker))
        let passwordToolBar = UIToolbar().ToolbarPiker(#selector(SignUpViewController.dismissPicker))
        usernameTextField.inputAccessoryView = usernameToolBar
        passwordTextField.inputAccessoryView = passwordToolBar
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField?) {
        if(usernameTextField.text!.count > 3
            && passwordTextField.text!.count > 0
            && birthdayTextField.text!.count > 7) {
            createAccountButton.isHidden = false
        } else {
            createAccountButton.isHidden = true
        }
        
    }
    
    @IBAction func birthdayTextFieldOpened(_ sender: UITextField) {
        // Update the birthday text field to show a datepicker
        let datePickerView  : UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        birthdayTextField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(handleDatePicker), for: UIControlEvents.valueChanged)
        
        let birthdayToolBar = UIToolbar().ToolbarPiker(#selector(SignUpViewController.dismissPicker))
    
        birthdayTextField.inputAccessoryView = birthdayToolBar
    }
    
    @IBAction func createAccount(_ sender: UIButton?) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let birthday = birthdayTextField.text!
        
        let package: NSDictionary = NSMutableDictionary()
        
        package.setValue(username, forKey: "username")
        package.setValue(password, forKey: "password")
        package.setValue(birthday, forKey: "birthday")
        
        let url:URL = URL(string: signup_url)!
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
                    
                        DispatchQueue.main.async { launchByAuthStatus() }
                    }
                }
            }
        })
        
        task.resume()
    }
    
    @objc func handleDatePicker(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        birthdayTextField.text = dateFormatter.string(from: sender.date)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        }
        else if textField == self.passwordTextField {
            self.birthdayTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    @objc func dismissPicker() {
        textFieldChanged(nil)
        self.view.endEditing(true)
    }
    
}
