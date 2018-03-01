//
//  LoginViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/7/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift
import Spring


class LoginViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: SpringButton!
    
    
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
usernameTextField.delegate = self
        passwordTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        //loginButton.layer.animation(forKey: "shake")
        //loginButton.curve = "easeIn"
        
        self.loginButton.animate()
        
        Network.instance.fetch(route: .loginUser(email: self.usernameTextField.text!, password: self.passwordTextField.text!)) { (data) in
             if  data != nil{
                let jsonUser = try? JSONDecoder().decode(User.self, from: data!)
            
            if let user = jsonUser {
                print("Login successful")
                self.keychain.set(user.authentication_token, forKey: "token")
                self.keychain.set(user.email, forKey: "email")
                self.keychain.set(user.username, forKey: "username")
                self.keychain.set(String(user.id), forKey: "id")

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toMain", sender: self)
                }
                
            }
        }
            else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Invalid Login", message: "Username or password incorrect", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
        }
    }
}
extension LoginViewController:UITextFieldDelegate{
    
}



