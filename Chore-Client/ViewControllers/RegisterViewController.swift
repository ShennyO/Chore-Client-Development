//
//  RegisterViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/17/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    var user: User!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signUpButton.configureButton()
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        // Do any additional setup after loading the view.

//        self.hideKeyboardWhenTappedAround()
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }

    
    @IBAction func signUpTapped(_ sender: Any) {
        
        let keychain = KeychainSwift()
        createUser {
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            UserDefaults.standard.synchronize()
            keychain.set(self.user.authentication_token, forKey: "token")
            keychain.set(self.user.email, forKey: "email")
            keychain.set(self.user.username, forKey: "username")
            keychain.set(String(self.user.id), forKey: "id")
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "toMain", sender: self)
            }

        }
        
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
            
    }
    
    
}

extension RegisterViewController {
    func createUser(completion: @escaping ()->()) {
        guard let firstName = self.firstNameTextField.text, !firstName.isEmpty, let lastName = self.lastNameTextField.text, !lastName.isEmpty, let username = self.usernameTextField.text, !username.isEmpty, let email = self.emailTextField.text, !email.isEmpty, let password = self.passwordTextField.text, !password.isEmpty else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Invalid Sign Up", message: "Sign Up information not complete", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            
            return
        }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Network.instance.fetch(route: .createUser(firstName: firstName, lastName: lastName, email: trimmedEmail, password: trimmedPassword, confirmation: trimmedPassword, username: trimmedUsername)) { (data) in
            print("User Created")
            completion()
        }
    }
}

//extension UIViewController {
//    
//    
//    func hideKeyboardWhenTappedAround() {
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
//        tap.cancelsTouchesInView = false
//        view.addGestureRecognizer(tap)
//    }
//    
//    @objc func dismissKeyboard() {
//        view.endEditing(true)
//    }
//}

