//
//  EmailViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 1/6/18.
//  Copyright © 2018 Dropin. All rights reserved.
//

import UIKit
class EmailViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField?) {
        if(emailTextField.text!.count > 5) {
            nextButton.isHidden = false
        } else {
            nextButton.isHidden = true
        }
        
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        let email_address = emailTextField.text!
        let package: NSDictionary = NSMutableDictionary()
        
        if(fetchAuth().0 == "") {
            launchAuthScreen()
            return
        }
        let (username, auth_token) = fetchAuth()
        
        package.setValue(username, forKey: "username")
        package.setValue(auth_token, forKey: "token")
        package.setValue(email_address, forKey: "email_address")
        
        let url: URL = URL(string: email_set_url)!
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
                    if let email_address = data["email_address"] as? String
                    {
                        UserDefaults.standard.set(email_address, forKey: "email_address")
                        
                        DispatchQueue.main.async { launchByAuthStatus() }
                        return
                    }
                }
            }
        })
        
        task.resume()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissPicker()
        
        return true
    }
    
    func dismissPicker() {
        textFieldChanged(nil)
        self.view.endEditing(true)
    }
}

