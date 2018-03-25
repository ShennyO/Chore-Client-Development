//
//  LoginViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/7/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift
import IQKeyboardManagerSwift

class LoginViewController: UIViewController {
    //USE EMAIL, NOT USERNAME
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        self.hideKeyboardWhenTappedAround()
        loginButton.configureButton()
        registerButton.configureButton()
        self.usernameTextField.autocorrectionType = .no
        self.passwordTextField.autocorrectionType = .no
        self.usernameTextField.autocapitalizationType = .none
        self.usernameTextField.autocapitalizationType = .none
         self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        IQKeyboardManager.sharedManager().enable = true
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        self.loginButton.zoomInWithEasing()
        let trimmedUsernameText = self.usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPasswordText = self.passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        
        Network.instance.fetch(route: Route.loginUser(email: trimmedUsernameText!, password: trimmedPasswordText!)) { (data, resp) in
            let jsonUser = try? JSONDecoder().decode(User.self, from: data)
            
            if let user = jsonUser {
                print("Login successful")
                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                UserDefaults.standard.synchronize()
                self.keychain.set(user.authentication_token, forKey: "token")
                self.keychain.set(user.email, forKey: "email")
                self.keychain.set(user.username, forKey: "username")
                self.keychain.set(String(user.id), forKey: "id")

                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toMain", sender: self)
                    ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                }
            } else {
                DispatchQueue.main.async {
                    ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                    let alert = UIAlertController(title: "Invalid Login", message: "Username or password incorrect", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
        }
    }
}

extension LoginViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.usernameTextField.placeholder = nil
        self.passwordTextField.placeholder = nil
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.usernameTextField.placeholder = "Email"
        self.usernameTextField.placeHolderColor = UIColor.white
        self.passwordTextField.placeHolderColor = UIColor.white
        self.passwordTextField.placeholder = "Password"
    }
}






