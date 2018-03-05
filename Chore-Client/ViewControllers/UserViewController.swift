//
//  UserViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/15/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift

class UserViewController: UIViewController {

    // - MARK: IBOUTLET
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var choreRecordTableView: UITableView!
    
    // - MARK: PROPERTIES
    
    var currentUser: Member!
    var userChores:[Chore] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getUser() {
            DispatchQueue.main.async {
                self.userNameLabel.text = self.currentUser.username
            }
        }
        getUserChores {
            DispatchQueue.main.async {
                 self.choreRecordTableView.reloadData()
            }
           
        }
    }

    

}

extension UserViewController {
    func getUser(completion: @escaping()->()) {
        let username = KeychainSwift().get("username")
        Network.instance.fetch(route: Route.getUser(username: username!)) { (data) in
            if data != nil{
            let jsonUser = try? JSONDecoder().decode(Member.self, from: data!)
            if let user = jsonUser {
                self.currentUser = user
                completion()
                }
            }
        }
    }
}

// - Mark: TABLE VIEW CONTROLLER CYCLE

extension UserViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userChores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.choreRecordTableView.dequeueReusableCell(withIdentifier: "userChoreCell") as! UserChoreTableViewCell
        cell.choreNameLabel.text = self.userChores[indexPath.row].name
        //        cell.chorePenaltyLabel.text = self.userChores[indexPath.row].penalty
        cell.dueDate.text = self.userChores[indexPath.row].due_date ?? "No due date set yet"
        cell.chore = userChores[indexPath.row]
        
        return cell
    }
}

extension UserViewController {
    func getUserChores(completion: @escaping ()->()) {
        Network.instance.fetch(route: .getUserChores) { (data) in
            if data != nil{
                
                let jsonChores = try? JSONDecoder().decode([Chore].self, from: data!)
                if let chores = jsonChores {
                    self.userChores = chores
                    completion()
                }
            }
        }
    }
}
