//
//  GroupDetailViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/14/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift
import Kingfisher


class GroupDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, CompleteChoreCompletionDelegate, addNewDelegate {
    func newChore() {
        self.performSegue(withIdentifier: "toNewChore", sender: self)
    }
    
    func newUser() {
        self.performSegue(withIdentifier: "toAddNewGroupUser", sender: self)
    }
    
    
    var users: [User] = []
    var chores: [Chore] = []
    var group: Group!
    //for chore completion requests
    var requests: [Request] = []
   


    @IBOutlet weak var groupDetailTableView: UITableView!
    
    @IBAction func unwindToGroupDetailVC(segue:UIStoryboardSegue) { }

    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.users = self.group.members
        
        self.getGroupChores {
            self.getChoreCompletionRequests(completion: {
                DispatchQueue.main.async {
                    self.groupDetailTableView.reloadData()
                }
            })
        }
       
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
        } else if indexPath.section == 1 {
            return 55
        } else if indexPath.section == 2 {
            return 55
        }
        else {
            return 100
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 3{
            return self.chores.count
        } else if section == 2 {
            return self.requests.count
        } else {
            return 1
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 3 {
            let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "groupChoreCell") as! GroupChoreTableViewCell
            cell.choreNameLabel.text = self.chores[indexPath.row].name
            cell.dueDateLabel.text = self.chores[indexPath.row].due_date
            cell.currentIndex = indexPath
            cell.delegate = self
            if self.chores[indexPath.row].assigned {
                //TODO: must be changed to self.chores
                if self.chores[indexPath.row].user.image_file != nil {
                    let imageURL = URL(string: self.chores[indexPath.row].user.image_file)
                    cell.assignButton.kf.setImage(with: imageURL!, for: .normal)
                } else {
                    cell.assignButton.setImage(UIImage(named: "AccountIcon"), for: .normal)
                }
                
                cell.assignButton.layer.cornerRadius = cell.assignButton.layer.frame.size.width/2
                cell.assignButton.clipsToBounds = true
                cell.assignButtonHeight.constant = 60
                cell.assignButton.isUserInteractionEnabled = false
    
            } else {
                cell.assignButton.setImage(nil, for: .normal)
                cell.assignButtonHeight.constant = 30
                cell.assignButton.layer.cornerRadius = 0
                cell.assignButton.isUserInteractionEnabled = true
            }
            return cell
        } else if indexPath.section == 0 {
            let tableViewCell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "profileTableViewCell") as! ProfileTableViewCell
            tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
            return tableViewCell
        } else if indexPath.section == 2{
            let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "choreCompletionRequestCell") as! ChoreCompletionRequestTableViewCell
            cell.choreCompletionLabel.text = "\(self.requests[indexPath.row].sender_id!) has finished said chore"
            cell.index = indexPath
            cell.delegate = self
            return cell
        } else {
            let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "addNew") as! GroupDetailAddNewTableViewCell
            cell.delegate = self
            return cell
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! ProfileCollectionViewCell
        cell.usernameLabel.text = self.users[indexPath.row].username
       
            let imageURL = URL(string: self.users[indexPath.row].image_file)
            cell.profilePicture.kf.setImage(with: imageURL!)
            cell.profilePicture.kf.setImage(with: imageURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
            
        return cell
    }
    

}

extension GroupDetailViewController: assignButtonDelegate {
    
    func completeChoreCompletionRequest(index: IndexPath, answer: Bool) {
        let request = self.requests[index.row]
        Network.instance.fetch(route: .choreRequestResponse(response: answer, chore_id: request.chore_id, uuid: request.uuid, request_id: request.id)) { (data) in
            self.getChoreCompletionRequests {
                self.getGroupChores {
                    DispatchQueue.main.async {
                        self.groupDetailTableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    func takeChore(indexPath: IndexPath, completion: @escaping ()->()) {
        let selectedChore = self.chores[indexPath.row]
        guard let stringUserID = KeychainSwift().get("id") else {return}
        guard let userID = Int(stringUserID) else {return}
        Network.instance.fetch(route: .takeChore(group_id: self.group.id, chore_id: selectedChore.id, user_id: userID)) { (data) in
            completion()
        }
    }
    
    func assignChore(indexPath: IndexPath) {
        takeChore(indexPath: indexPath) {
            self.getGroupChores {
                DispatchQueue.main.async {
                    self.groupDetailTableView.reloadData()
                }
            }
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
    
    func getChoreCompletionRequests(completion: @escaping ()->()) {
        let currentGroupID = Int(KeychainSwift().get("groupID")!)
        Network.instance.fetch(route: .getChoreRequests(group_id: currentGroupID!)) { (data) in
            let jsonRequests = try? JSONDecoder().decode([Request].self, from: data)
            if let requests = jsonRequests {
                self.requests = requests
                completion()
            }
        }
    }
}
