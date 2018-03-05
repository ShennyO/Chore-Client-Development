//
//  GroupsViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/8/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift
import FoldingCell

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RequestDelegate {
    
    let kCloseCellHeight: CGFloat = 50
    let kOpenCellHeight: CGFloat = 200
    let kRowsCount = 10
    var cellHeights: [CGFloat] = []
    @IBOutlet weak var groupsTableView: UITableView!
    //var delegate: RequestDelegate!
    
   
    
    var groups: [Group] = []
    var requests: [Request] = []
    
    /// function to setup the foldable cell
    private func setup() {
        self.cellHeights = Array(repeating: kCloseCellHeight, count: kRowsCount)
        self.groupsTableView.estimatedRowHeight = kCloseCellHeight
        self.groupsTableView.rowHeight = UITableViewAutomaticDimension
        //self.groupsTableView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getGroups {
            
            self.getRequests {
                DispatchQueue.main.async {
                    self.groupsTableView.reloadData()
                }
            }
           
        }
    }
    
    override func viewDidLoad() {
        self.setup()
        self.getRequests {
            DispatchQueue.main.async {
                self.groupsTableView.reloadData()
            }
        }
    }
    
    @IBAction func createGroup(_ sender: UIButton){
       
        self.performSegue(withIdentifier: "createGroup", sender: self)
        
    }
    
    // - MARK: IBACTION
    
    @IBAction func unwindToGroupsVC(segue:UIStoryboardSegue) { }
    

    
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
    
     func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard case let cell as RequestTableViewCell = cell else {
            return
        }
        
        cell.backgroundColor = .clear
        
        if cellHeights[indexPath.row] == kCloseCellHeight {
            cell.unfold(false, animated: false, completion: nil)
        } else {
            cell.unfold(true, animated: false, completion: nil)
        }
        
        cell.number = indexPath.row
    }
    
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
       
        if indexPath.section == 0{
        return cellHeights[indexPath.row]
        }
        else{
            return 70
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        if indexPath.section == 0 {
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        let requestCell = tableView.cellForRow(at: indexPath) as! RequestTableViewCell
            requestCell.request = requests[indexPath.row]
            
            
        if cell.isAnimating() {
            return
        }
        
        var duration = 0.0
        let cellIsCollapsed = cellHeights[indexPath.row] == kCloseCellHeight
        if cellIsCollapsed {
            cellHeights[indexPath.row] = kOpenCellHeight
            
            cell.unfold(true, animated: true, completion: nil)
            duration = 0.5
        } else {
            cellHeights[indexPath.row] = kCloseCellHeight
            cell.unfold(false, animated: true, completion: nil)
            duration = 1.1
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            self.groupsTableView.beginUpdates()
            self.groupsTableView.endUpdates()
        }, completion: nil)
        }else{
             self.performSegue(withIdentifier: "toGroupDetail", sender: self)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = self.groupsTableView.dequeueReusableCell(withIdentifier: "requestCell") as! RequestTableViewCell
           
           
            let durations: [TimeInterval] = [0.5, 0.7, 0.9,1.5]
            cell.durationsForExpandedState = durations
            cell.durationsForCollapsedState = durations
            cell.groupName.text = requests[indexPath.row].group_name
            let members: Int? = self.requests[indexPath.row].group.members.count
            let chores: Int? =  self.requests[indexPath.row].group.chores.count
            cell.participantLabel.text = ("\(members ?? 0) members")
            cell.choresNumber.text = ("\(chores ?? 0) Chores")
            
            return cell
        } else {
            let cell = self.groupsTableView.dequeueReusableCell(withIdentifier: "groupCell") as! GroupTableViewCell
            
            
            let members: Int? = groups[indexPath.row].members.count
            let chore: Int? = groups[indexPath.row].chores.count
            cell.groupNameLabel.text = self.groups[indexPath.row].name
            cell.groupChoreCountLabel.text = (chore != 0) ? "\(chore ?? 0) chores" : " No chores"
            cell.groupMemberCountLabel.text = (members == 1) ? " you are the only member of this group" : ("\(members ?? 0) members in this group")
            
            let user_id = Int(KeychainSwift().get("id")!)
            let assignedChore = groups[indexPath.row].chores.filter{$0.user_id == user_id}
            
            cell.assignedChore.text = ("\(assignedChore.count) assigned")
            
            
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

// - MARK: NETWORKING

extension GroupsViewController {
    
    
    
    func completeRequest(indexPath: IndexPath, answer: Bool) {
        let groupID = self.requests[indexPath.row].group_id!
        let requestID = self.requests[indexPath.row].id
        Network.instance.fetch(route: .requestResponse(response: answer, group_id: groupID, request_id: requestID!)) { (data) in
            print("accepted Request")
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
        Network.instance.fetch(route: Route.getUserGroups) { (data) in
             if data != nil{
            let jsonGroups = try? JSONDecoder().decode(Groups.self, from: data!)
            if let groups = jsonGroups?.groups {
                self.groups = groups
                completion()
                }
            }
        }
    }
    
    func getRequests(completion: @escaping ()->()) {
        Network.instance.fetch(route: Route.getGroupRequests) { (data) in
             if data != nil{
            let jsonRequests = try? JSONDecoder().decode(Resq.self, from: data!)
            if let requests = jsonRequests {
                self.requests = requests.request
                completion()
                }
                
            }
        }
    }
}
struct Resq: Decodable{
    let request:[Request]
}






