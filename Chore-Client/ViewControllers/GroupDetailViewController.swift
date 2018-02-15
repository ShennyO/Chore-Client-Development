//
//  GroupDetailViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/14/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class GroupDetailViewController: UIViewController, UITableViewDataSource {
    
    
    var users: [Member] = []
    var chores: [Chore] = []
    var group: Group!
    @IBOutlet weak var groupDetailTableView: UITableView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getGroupChores {
            DispatchQueue.main.async {
                self.groupDetailTableView.reloadData()
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.users.count
        } else {
            return self.chores.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//
//        } else {
            let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "groupChoreCell") as! GroupChoreTableViewCell
            cell.choreNameLabel.text = self.chores[indexPath.row].name
            cell.dueDateLabel.text = self.chores[indexPath.row].due_date
            return cell
//        }
        
    }

}

extension GroupDetailViewController {
    func getGroupChores(completion: @escaping ()->()) {
        Network.instance.fetch(route: Route.getGroupChores(chore_type: "group", id: self.group.id)) { (data) in
            let jsonChores = try? JSONDecoder().decode([Chore].self, from: data)
            if let chores = jsonChores {
                self.chores = chores
                completion()
            }
        }
    }
}
