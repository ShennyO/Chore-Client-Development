//
//  GroupDetailViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/14/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import AZDropdownMenu

class GroupDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    
    var users: [User] = []
    var chores: [Chore] = []
    var group: Group!
   
    var addUserButton = UIButton(type: .custom)

    @IBOutlet weak var groupDetailTableView: UITableView!
    
    @IBAction func unwindToGroupDetailVC(segue:UIStoryboardSegue) { }

    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.addUserButton.addTarget(self, action: #selector(ButtonClick(_:)), for: UIControlEvents.touchUpInside)
        self.users = self.group.members
        self.getGroupChores {
            DispatchQueue.main.async {
                self.groupDetailTableView.reloadData()
            }
        }
       
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.addSubview(addUserButton)
        addUserButton.layer.cornerRadius = addUserButton.layer.frame.size.width/2
        addUserButton.backgroundColor = UIColor(red: 1.0, green: 177/255, blue: 49/255, alpha: 1.0)
        addUserButton.clipsToBounds = true
        addUserButton.setImage(UIImage(named:"PlusButton"), for: .normal)
        addUserButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addUserButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            addUserButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 90),
            addUserButton.widthAnchor.constraint(equalToConstant: 30),
            addUserButton.heightAnchor.constraint(equalToConstant: 30)])
    }
    
    @objc func ButtonClick(_ sender: UIButton){
        print("button tapped")
        self.performSegue(withIdentifier: "toAddNewGroupUser", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toAddNewGroupUser" {
                let addNewGroupUserVC = segue.destination as! AddNewGroupUserViewController
                addNewGroupUserVC.selectedGroup = self.group
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 180
        } else {
            return 70
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return self.chores.count
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let tableViewCell = cell as? ProfileTableViewCell else { return }
            tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 {
            let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "groupChoreCell") as! GroupChoreTableViewCell
            cell.choreNameLabel.text = self.chores[indexPath.row].name
            cell.dueDateLabel.text = self.chores[indexPath.row].due_date
            return cell
        } else {
            let tableViewCell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "profileTableViewCell") as! ProfileTableViewCell
            tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
            return tableViewCell
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! ProfileCollectionViewCell
        return cell
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
