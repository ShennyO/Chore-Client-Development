//
//  NewChoreViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/15/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift

class NewChoreViewController: UIViewController {

    @IBOutlet weak var choreNameLabel: UITextField!
    @IBOutlet weak var penaltyNameLabel: UITextField!
    @IBOutlet weak var rewardNameLabel: UITextField!
    @IBOutlet weak var choreDatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        createChore {
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "unwindToGroupDetail", sender: self)
            }
        }
    }
    

}

extension NewChoreViewController {
    func createChore(completion: @escaping ()->()) {
        
        let stringDueDate = self.choreDatePicker.date.toString()
        let groupID = Int(KeychainSwift().get("groupID")!)
        
        Network.instance.fetch(route: Route.createChore(name: self.choreNameLabel.text!, due_date: stringDueDate, penalty: self.penaltyNameLabel.text!, reward: self.rewardNameLabel.text!, id: groupID!)) { (data) in
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
