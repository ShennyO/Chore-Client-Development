//
//  NewChoreViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/15/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift

class NewChoreViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var choreNameLabel: UITextField!
    @IBOutlet weak var choreDescriptionTextField: UITextField!
    @IBOutlet weak var choreDatePicker: UIDatePicker!
    @IBOutlet weak var addButton: UIButton!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addButton.isEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addButton.configureButton()
        choreNameLabel.delegate = self
        choreDescriptionTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if textField == choreDescriptionTextField {
            let maxLength = 40
            let currentString: NSString = textField.text as! NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else if textField == choreNameLabel {
            let maxLength = 15
            let currentString: NSString = textField.text as! NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else {
            return true
        }
        
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        createChore {
            DispatchQueue.main.async {
                self.addButton.isEnabled = false
                self.performSegue(withIdentifier: "unwindToGroupDetail", sender: self)
            }
        }
    }
    

}

extension NewChoreViewController {
    func createChore(completion: @escaping ()->()) {
        
        let stringDueDate = self.choreDatePicker.date.toString()
        let groupID = Int(KeychainSwift().get("groupID")!)
        
        Network.instance.fetch(route: Route.createChore(name: self.choreNameLabel.text!, due_date: stringDueDate, description: self.choreDescriptionTextField.text!, id: groupID!)) { (data) in
            print("Chore Created")
            completion()
        }
    }
}

extension Date{
    
    public func toString() -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let stringDate = formatter.string(from: self)
        return stringDate
    }
}
