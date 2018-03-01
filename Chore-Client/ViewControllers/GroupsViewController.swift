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
    
    let kCloseCellHeight: CGFloat = 172
    let kOpenCellHeight: CGFloat = 250
    let kRowsCount = 10
    var cellHeights: [CGFloat] = []
    @IBOutlet weak var groupsTableView: UITableView!
   
    
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
    
    
    @IBAction func unwindToGroupsVC(segue:UIStoryboardSegue) { }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70
//    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.requests.count
        } else {
            return 0//self.groups.count
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
        return cellHeights[indexPath.row]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath) as! FoldingCell
        
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
            duration = 0.8
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { () -> Void in
            self.groupsTableView.beginUpdates()
            self.groupsTableView.endUpdates()
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = self.groupsTableView.dequeueReusableCell(withIdentifier: "requestCell") as! RequestTableViewCell
           // cell.requestLabel.text = " You have been invited to: \(self.requests[indexPath.row].group_name)"
            //cell.indexPath = indexPath
            //cell.delegate = self
            let durations: [TimeInterval] = [0.26, 0.2, 0.2]
            cell.durationsForExpandedState = durations
            cell.durationsForCollapsedState = durations
            cell.groupName.text = requests[indexPath.row].group_name
            return cell
        } else {
            let cell = self.groupsTableView.dequeueReusableCell(withIdentifier: "groupCell") as! GroupTableViewCell
            cell.groupNameLabel.text = self.groups[indexPath.row].name
            
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
            let jsonRequests = try? JSONDecoder().decode([Request].self, from: data!)
            if let requests = jsonRequests {
                self.requests = requests
                completion()
                }
            }
        }
    }
}
extension GroupsViewController{
//    fileprivate struct C {
//        struct CellHeight {
//            //static let close: CGFloat = //*** // equal or greater foregroundView height
//            //static let open: CGFloat = //*** // equal or greater containerView height
//        }
//    }
    
    

}






