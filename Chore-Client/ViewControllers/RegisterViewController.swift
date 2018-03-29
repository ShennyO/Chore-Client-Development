//
//  RegisterViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/17/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift
import IQKeyboardManagerSwift

class RegisterViewController: UIViewController{

    @IBOutlet weak var buttonConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelUpAndDown: NSLayoutConstraint!
    
    @IBOutlet weak var textFieldStack: UIStackView!
    @IBOutlet weak var moveTheViewUpAndDown: NSLayoutConstraint!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
   
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mainStack: UIStackView!
    var user: User!
    let photoHelper = PhotoHelper()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        self.usernameTextField.desActivateAutoCorrectAndCap()
        self.passwordTextField.desActivateAutoCorrectAndCap()
        self.firstNameTextField.desActivateAutoCorrectAndCap()
        self.lastNameTextField.desActivateAutoCorrectAndCap()
        self.emailTextField.desActivateAutoCorrectAndCap()
        
        
        
       
        super.viewDidLoad()
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.emailTextField.delegate = self
        self.usernameTextField.delegate = self
        self.emailTextField.tag = 1

        self.passwordTextField.tag = 1
       
        self.signUpButton.configureButton()
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
         //Do any additional setup after loading the view.

          IQKeyboardManager.sharedManager().enable = false
        
        
        self.hideKeyboardWhenTappedAround()
        
        self.buttonConstraint.constant = (self.view.frame.height - 50)
    }
    


    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

            UIView.animate(withDuration: 1.5, animations: {
                 self.moveTheViewUpAndDown.constant = -(keyboardSize.height)/2
                           })
           
        }
    }
//
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {

            UIView.animate(withDuration: 1.5, animations: {
                self.moveTheViewUpAndDown.constant = 0
          
            })
        }
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        self.signUpButton.zoomInWithEasing()
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        let keychain = KeychainSwift()
        createUser {
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            UserDefaults.standard.synchronize()
            keychain.set(self.user.authentication_token, forKey: "token")
            keychain.set(self.user.email, forKey: "email")
            keychain.set(self.user.username, forKey: "username")
            keychain.set(String(self.user.id), forKey: "id")
            
            DispatchQueue.main.async {
                ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                self.performSegue(withIdentifier: "toMain", sender: self)
            }
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
       self.cancelButton.zoomInWithEasing()
        dismiss(animated: true)
            
    }
}

extension RegisterViewController {
    func createUser(completion: @escaping ()->()) {
        guard let firstName = self.firstNameTextField.text, !firstName.isEmpty, let lastName = self.lastNameTextField.text, !lastName.isEmpty, let username = self.usernameTextField.text, !username.isEmpty, let email = self.emailTextField.text, !email.isEmpty, let password = self.passwordTextField.text, !password.isEmpty else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Invalid Sign Up", message: "Sign Up information not complete", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                ViewControllerUtils().hideActivityIndicator(uiView: self.view)
            }
            
            return
        }
        
        if password.count < 6 {
            let alert = UIAlertController(title: "Invalid Sign Up", message: "Password must be at least 6 characters", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            ViewControllerUtils().hideActivityIndicator(uiView: self.view)
        }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Network.instance.fetch(route: .createUser(firstName: firstName, lastName: lastName, email: trimmedEmail, password: trimmedPassword, confirmation: trimmedPassword, username: trimmedUsername)) { (data, resp) in
            if resp.statusCode == 403 {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Invalid Sign Up", message: "Username or Email in Use", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                }
                
                return
            }
            else if resp.statusCode == 200{
                let jsonUser = try? JSONDecoder().decode(User.self, from: data)
                if let loggedUser = jsonUser {
                    self.user = loggedUser
                    
                    completion()
                }
                
            }
            
        }
    }
}
extension RegisterViewController {
    func getUser(username: String, completion: @escaping()->()) {
        Network.instance.fetch(route: .getUser(username: username)) { (data, resp)  in
            let jsonUser = try? JSONDecoder().decode(User.self, from: data)
            if let loggedUser = jsonUser {
                self.user = loggedUser
                
                completion()
            }
        }
    }
}

// - MARK: TEXTFIELD LIFE CYCLE
extension RegisterViewController: UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            if (textField.text?.count)! < 6 {
                let alert = UIAlertController(title: "Invalid", message: "Minimum of 6 characters required", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                textField.text = ""
            }
        }
        self.emailTextField.placeholder = "Email"
        self.firstNameTextField.placeholder = "First name"
        self.lastNameTextField.placeholder = "Last name"
        self.passwordTextField.placeholder = "Password"
        self.usernameTextField.placeholder = " Username"
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
    }
    
}


