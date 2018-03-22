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
import IQKeyboardManagerSwift

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
        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        self.loaded = true
    }
   
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
        if self.loaded == false {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }

        
        self.getGroups {
            
            self.getRequests {
                DispatchQueue.main.async {
                    self.groupsTableView.reloadData()


                   // self.activity.alpha = 0.0


                    if self.loaded == false {
                     ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                    }

                }
            }
            
        }
    }
    


    override func viewDidLoad() {
        
//        self.navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.largeTitleTextAttributes = [
//            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 30, weight: UIFont.Weight.heavy)
//        ]
        
//        navigationController?.navigationBar.backgroundColor = UIColor.white
        
         IQKeyboardManager.sharedManager().enable = true
    }


   

    
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
            cell.choresCountLabel.text = (chores == 1) ? "\(chores) chore" : "\(chores) tasks"
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
        Network.instance.fetch(route: .groupRequestResponse(response: answer, group_id: groupID, request_id: requestID!)) { data, resp in
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
        
        Network.instance.fetch(route: Route.getUserGroups) { (data, resp) in
            let jsonGroups = try? JSONDecoder().decode(Groups.self, from: data)
            if let groups = jsonGroups?.groups {
                self.groups = groups
                completion()
            }
        }
    }
    
    func getRequests(completion: @escaping ()->()) {
        Network.instance.fetch(route: Route.getGroupRequests) { (data, resp) in
            let jsonRequests = try? JSONDecoder().decode([Request].self, from: data)
            if let requests = jsonRequests {
                self.requests = requests
                completion()
            }
        }
    }
}
