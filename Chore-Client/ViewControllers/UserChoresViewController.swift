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
        getUserChores {
            DispatchQueue.main.async {
                self.choresTableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userChores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.choresTableView.dequeueReusableCell(withIdentifier: "userChoreCell") as! UserChoreTableViewCell
        cell.choreNameLabel.text = self.userChores[indexPath.row].name
//        cell.chorePenaltyLabel.text = self.userChores[indexPath.row].penalty
        cell.choreDescriptionLabel.text = self.userChores[indexPath.row].due_date
        return cell
    }
    

    
}

extension UserChoresViewController {
    func getUserChores(completion: @escaping ()->()) {
        Network.instance.fetch(route: .getUserChores) { (data) in
            let jsonChores = try? JSONDecoder().decode([Chore].self, from: data)
            if let chores = jsonChores {
                self.userChores = chores
                completion()
            }
        }
    }
}
