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
    //TODO: change username to email
    // - MARK: OUTLETS
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    //Variables
    let keychain = KeychainSwift()
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        keychain.accessGroup = "K7R433H2CL.com.trasks.development"
//        self.hideKeyboardWhenTappedAround()
        loginButton.configureButton()
        registerButton.configureButton()
        self.usernameTextField.deactivateAutoCorrectAndCap()
        self.passwordTextField.deactivateAutoCorrectAndCap()
        self.usernameTextField.tag = 1
       
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
        
        /// ensure all field have been correctly taped
        do{
            try self.checkLoginCorrect(email: usernameTextField.text!, password: passwordTextField.text!)
        }
        catch let error as LoginEroor{
            switch error{
            case .emailIncorect: fallthrough
                
            case .passwordShort: fallthrough
                
            case .imcompletForm: error.errorMesage(self)
                
            }
        }
        catch{
            self.presentLoginErrorMessage(title: "Unexpected Error", message: " An Unexpected error happend, please try again")
        }
        
        
        
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
       textField.placeholder = nil
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.usernameTextField.placeholder = "Email"
        self.usernameTextField.placeHolderColor = UIColor.white
       
        self.passwordTextField.placeholder = "Password"
         self.passwordTextField.placeHolderColor = UIColor.white
    }
    func checkLoginCorrect(email: String, password: String)throws{
        
       
        if email.isEmpty || password.isEmpty{
        throw LoginEroor.imcompletForm
        }
        if !email.isValidEmail{
           throw LoginEroor.emailIncorect
        }
        if password.count < 6{
            throw LoginEroor.passwordShort
        }
    }
}

enum LoginEroor: Error{
    case passwordShort
    case emailIncorect
    case imcompletForm
    
    
    
    func errorMesage(_ viewController: UIViewController){
        switch self{
        case .emailIncorect:
            let title = "Incorrect Email"
            let message = "Make sure that the email is well formatted"
            viewController.presentLoginErrorMessage(title: title, message: message)
        case .passwordShort:
            let title = "SHort Password"
            let message = "password has to be more than 6 character"
            viewController.presentLoginErrorMessage(title: title, message: message)
        case .imcompletForm:
            let title = "Incompleted Form"
            let message = "No field should be empty"
            viewController.presentLoginErrorMessage(title: title, message: message)
        }
    }
}







