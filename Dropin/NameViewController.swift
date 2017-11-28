//
//  NameViewController.swift
//  Dropin
//
//  Created by Christopher Pratt on 9/5/17.
//  Copyright © 2017 Dropin. All rights reserved.
//

import UIKit

class NameViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.nameTextField.delegate = self
    }

    @IBAction func textFieldChanged(_ sender: UITextField?) {
        if(nameTextField.text!.count > 0) {
            startButton.isHidden = false
        } else {
            startButton.isHidden = true
        }
        
    }
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        let name = nameTextField.text!
        let package: NSDictionary = NSMutableDictionary()
        
        if(fetchAuth().0 == "") {
            launchAuthScreen()
            return
        }
        let (username, auth_token) = fetchAuth()
        
        package.setValue(username, forKey: "username")
        package.setValue(auth_token, forKey: "token")
        package.setValue(name, forKey: "name")
        
        let url:URL = URL(string: name_set_url)!
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
                    UserDefaults.standard.removeObject(forKey: "session_data")
                    
                    DispatchQueue.main.async(execute: launchAuthScreen)
                    return
                }
                else if result == 1 {
                    if let name = data["name"] as? String
                    {
                        UserDefaults.standard.set(name, forKey: "name")
                        
                        DispatchQueue.main.async { launchDropin() }
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
