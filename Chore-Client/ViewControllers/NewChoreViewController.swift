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

    // - MARK: IBOUTLETS
    
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
        choreNameLabel.deactivateAutoCorrectAndCap()
        choreDescriptionTextField.deactivateAutoCorrectAndCap()
        addButton.configureButton()
        choreNameLabel.delegate = self
        choreDescriptionTextField.delegate = self
        // Do any additional setup after loading the view.
    }
    
    //TEXTFIELD DELEGATE FUNCTION
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool
    {
        if textField == choreDescriptionTextField {
            let maxLength = 60
            let currentString: NSString = textField.text as! NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else if textField == choreNameLabel {
            let maxLength = 30
            let currentString: NSString = textField.text as! NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        } else {
            return true
        }
        
    }
    
    // - MARK: IBACTION

    @IBAction func addButtonTapped(_ sender: Any) {
        if self.choreNameLabel.text != ""{
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
            createChore {
                DispatchQueue.main.async {
                    self.addButton.isEnabled = false
                    ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                    self.performSegue(withIdentifier: "unwindToGroupDetail", sender: self)
                }
                }
        }
        else{
            ViewControllerUtils().hideActivityIndicator(uiView: self.view)
            let alert = UIAlertController(title: "Empty name", message: "Chores cannot have an empty name", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Return", style: .cancel, handler: nil)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }

}

extension NewChoreViewController {
    func createChore(completion: @escaping ()->()) {
        
        let stringDueDate = self.choreDatePicker.date.toString()
        let groupID = Int(KeychainSwift().get("groupID")!)
        
        Network.instance.fetch(route: Route.createChore(name: self.choreNameLabel.text!, due_date: stringDueDate, description: self.choreDescriptionTextField.text!, id: groupID!)) { (data, resp) in
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
