//
//  UserChoresViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/13/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class UserChoresViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var choresTableView: UITableView!
    var userChores: [Chore] = []
   
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserCompletedChores {
            DispatchQueue.main.async {
                self.choresTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userChores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.choresTableView.dequeueReusableCell(withIdentifier: "completedChoreCell") as! UserCompletedChoreTableViewCell
        cell.choreNameLabel.text = self.userChores[indexPath.row].name
//        cell.chorePenaltyLabel.text = self.userChores[indexPath.row].penalty
        cell.choreDateLabel.text = self.userChores[indexPath.row].due_date
        cell.choreGroupLabel.text = self.userChores[indexPath.row].groupname
        return cell
    }
    

    
}

extension UserChoresViewController {
    func getUserCompletedChores(completion: @escaping ()->()) {
        Network.instance.fetch(route: .getUserCompletedChores) { (data) in
            let jsonChores = try? JSONDecoder().decode([Chore].self, from: data)
            if let chores = jsonChores {
                self.userChores = chores
                completion()
            }
        }
    }
    func createChoreCompletionRequests(index: IndexPath) {
        Network.instance.fetch(route: .sendChoreCompletionRequest(chore_id: self.userChores[index.row].id)) { (data) in
            print("Requests created")
        }
    }
}
