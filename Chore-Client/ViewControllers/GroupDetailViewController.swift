//
//  GroupDetailViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/14/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import AZDropdownMenu

class GroupDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var users: [User] = []
    var chores: [Chore] = []
    var group: Group!
    var menu: AZDropdownMenu!

    @IBOutlet weak var groupDetailTableView: UITableView!
    
    @IBAction func unwindToGroupDetailVC(segue:UIStoryboardSegue) { }

    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.menu = AZDropdownMenu(titles: ["Add New Chore", "Add New User"])
        self.menu.itemHeight = 70
        let margins = view.layoutMarginsGuide
        
        // Pin the leading edge of myView to the margin's leading edge
//        menu.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
//
//        // Pin the trailing edge of myView to the margin's trailing edge
//        menu.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        menu.heightAnchor.constraint(equalToConstant: 70).isActive = true
        let button = UIBarButtonItem(title: "add", style: .plain, target: self, action: #selector(showDropdown))
        self.navigationItem.rightBarButtonItem = button
        self.getGroupChores {
            DispatchQueue.main.async {
                self.groupDetailTableView.reloadData()
            }
        }
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
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
    
    @objc func showDropdown() {
        if (self.menu.isDescendant(of: self.view) == true) {
            self.menu.hideMenu()
        } else {
            self.menu.showMenuFromView(self.view)
        }
    }
    
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
