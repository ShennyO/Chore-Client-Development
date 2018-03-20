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

class RegisterViewController: UIViewController {

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
    @IBOutlet weak var imagePlaceHolderButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var mainStack: UIStackView!
    var user: User!
     let photoHelper = PhotoHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.signUpButton.configureButton()
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
         //Do any additional setup after loading the view.

          IQKeyboardManager.sharedManager().enable = false
        
        
        self.hideKeyboardWhenTappedAround()
        
        self.buttonConstraint.constant = (self.view.frame.height - 50)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        photoHelper.completionHandler = {(image) in
            //guard let image = image
            DispatchQueue.main.async {
                self.imagePlaceHolderButton.setImage(image, for: UIControlState.normal)
                self.imagePlaceHolderButton.imageView?.setNeedsDisplay()
                self.imagePlaceHolderButton.imageView?.layer.cornerRadius = 0.5 * (self.imagePlaceHolderButton.imageView?.bounds.size.width)!
                self.imagePlaceHolderButton.imageView?.clipsToBounds = true
            }
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0{
//                self.view.frame.origin.y -= keyboardSize.height
//            }
            UIView.animate(withDuration: 1.5, animations: {
                 self.moveTheViewUpAndDown.constant = -(self.view.center.y)/2
                //self.mainStack.center.y -= keyboardSize.height
                //self.textFieldStack.center.y -= 50
//                self.imagePlaceHolderButton.imageView?.frame.size.height = 90
//                self.imagePlaceHolderButton.imageView?.frame.size.width = 90
                //self.moveTheViewUpAndDown.setMultiplier(multiplier: 0.3)
            })
           
        }
    }
//
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0{
//                //self.view.frame.origin.y += keyboardSize.height
//            }
            UIView.animate(withDuration: 1.5, animations: {
                self.moveTheViewUpAndDown.constant = 0
                 //self.mainStack.center.y += keyboardSize.height
//                self.imagePlaceHolderButton.imageView?.frame.size.height = 120
//                self.imagePlaceHolderButton.imageView?.frame.size.width = 120
                 //self.moveTheViewUpAndDown.setMultiplier(multiplier: 0.4)
                 //self.textFieldStack.center.y += 50
            })
        }
    }

    @IBAction func addProfilePicButtonTapped(_ sender: Any){
        
//        photoHelper.completionHandler = { (image) in
//            guard let imageData = UIImageJPEGRepresentation(image, 1)
//                else {return}
//            DispatchQueue.main.async {
//                self.Uploaded = true
//                self.profileImage.image = image
//                self.profileImage.setNeedsDisplay()
//            }
//            Network.instance.imageUpload(route: .userUpload, imageData: imageData)
//
//        }
        
       
        photoHelper.presentActionSheet(from: self)
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
            
            // add userImage
            self.setProfilePic()
            
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
            self.getUser(username: username) {
                completion()
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
    
    func setProfilePic() {
        if let image: UIImage = self.imagePlaceHolderButton.imageView?.image{
        let imageData = UIImageJPEGRepresentation(image, 1)
            Network.instance.imageUpload(route: .userUpload, imageData: imageData!)
    }
  }
}

// - MARK: TEXTFIELD LIFE CYCLE
extension RegisterViewController: UITextFieldDelegate{
    
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
}


