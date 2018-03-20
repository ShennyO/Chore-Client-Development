//
//  GroupsViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/8/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift
import Kingfisher
import SnapKit

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RequestDelegate{
    
    
    @IBOutlet weak var groupsTableView: UITableView!
    
    var groups: [Group] = [] {
        didSet {
            DispatchQueue.main.async {
                self.groupsTableView.reloadData()
            }
            
        }
    }
    
   // var activity :  UIActivityIndicatorView!
    
    var requests: [Request] = []
    var shown: Bool = false
    var loaded: Bool = false
    

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.loaded = true
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
<<<<<<< HEAD
        
        
=======
        if self.loaded == false {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
>>>>>>> a320a6281b49667175b95739c0479db5248f8b90
        
        self.getGroups {
            
            self.getRequests {
                DispatchQueue.main.async {
                    self.groupsTableView.reloadData()
<<<<<<< HEAD
                   // self.activity.alpha = 0.0
=======
                    if self.loaded == false {
                     ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                    }
>>>>>>> a320a6281b49667175b95739c0479db5248f8b90
                }
            }
            
        }
    }
    
<<<<<<< HEAD
    override func viewDidLoad() {
        //self.activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
       // self.activity.frame = CGRect(x: self.view.frame.width/2, y: self.view.frame.height/2 , width: 80, height: 80)
        //self.activity.startAnimating()
       // self.view.addSubview(self.activity)
    }
=======
   
>>>>>>> a320a6281b49667175b95739c0479db5248f8b90
    
    @IBAction func unwindToGroupsVC(segue:UIStoryboardSegue) { }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 115
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.requests.count
        } else {
            return self.groups.count
        }
        
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = self.groupsTableView.dequeueReusableCell(withIdentifier: "requestCell") as! GroupRequestTableViewCell
            cell.requestLabel.text = "You have been invited to: \(self.requests[indexPath.row].group_name!)"
            cell.indexPath = indexPath
            cell.delegate = self
            return cell
        } else {
            let cell = self.groupsTableView.dequeueReusableCell(withIdentifier: "groupCell") as! GroupTableViewCell
            let imageURL = URL(string: self.groups[indexPath.row].image_file)
            cell.groupNameLabel.text = self.groups[indexPath.row].name
            cell.groupProfileImage.kf.setImage(with: imageURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
            cell.groupProfileImage.contentMode = .scaleAspectFill
            cell.groupProfileImage.clipsToBounds = true
            let members = self.groups[indexPath.row].members.count
            let chores = self.groups[indexPath.row].chores.count
            cell.membersCountLabel.text = (members == 1) ? "\(members) member" : "\(members) members"
            cell.choresCountLabel.text = (chores == 1) ? "\(chores) chore" : "\(chores) chores"
            return cell
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toGroupDetail" {
                let groupDetailVC = segue.destination as! GroupDetailViewController
                let index = self.groupsTableView.indexPathForSelectedRow!
                groupDetailVC.group = self.groups[index.row]
                KeychainSwift().set(String(self.groups[index.row].id), forKey: "groupID")
            }
        }
    }
    
   

}

extension GroupsViewController {
    
    
    func completeRequest(indexPath: IndexPath, answer: Bool) {
        let groupID = self.requests[indexPath.row].group_id!
        let requestID = self.requests[indexPath.row].id
        Network.instance.fetch(route: .groupRequestResponse(response: answer, group_id: groupID, request_id: requestID!)) { (data) in
            self.requests.remove(at: indexPath.row)
            self.getGroups {
                self.getRequests {
                    DispatchQueue.main.async {
                        self.groupsTableView.reloadData()
                    }
                }
            }
        }
    }
    
    
    func getGroups(completion: @escaping ()->()) {
        
        self.shown = true
        
        Network.instance.fetch(route: Route.getUserGroups) { (data) in
            let jsonGroups = try? JSONDecoder().decode(Groups.self, from: data)
            if let groups = jsonGroups?.groups {
                self.groups = groups
                completion()
            }
        }
    }
    
    func getRequests(completion: @escaping ()->()) {
        Network.instance.fetch(route: Route.getGroupRequests) { (data) in
            let jsonRequests = try? JSONDecoder().decode([Request].self, from: data)
            if let requests = jsonRequests {
                self.requests = requests
                completion()
            }
        }
    }
}
