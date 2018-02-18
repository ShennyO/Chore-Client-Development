//
//  RegisterViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/17/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmationTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func signUpTapped(_ sender: Any) {
        createUser {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        
        
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true)
            
    }
    
    
}

extension RegisterViewController {
    func createUser(completion: @escaping ()->()) {
        guard let firstName = self.firstNameTextField.text, let lastName = self.lastNameTextField.text, let username = self.usernameTextField.text, let email = self.emailTextField.text, let password = self.passwordTextField.text, let confirmation = self.confirmationTextField.text else {
            return
        }
        
        Network.instance.fetch(route: .createUser(firstName: firstName, lastName: lastName, email: email, password: password, confirmation: confirmation, username: username)) { (data) in
            print("User Created")
            completion()
        }
    }
}
