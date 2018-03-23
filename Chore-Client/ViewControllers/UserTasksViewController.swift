//
//  UserTasksViewController.swift
//  Chore-Client
//
//  Created by Yveslym on 3/20/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import Kingfisher

class UserTasksViewController: UIViewController {

    // - MARK: IBOUTLET
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userTaskRecordTableView: UITableView!
    
    // - MARK: PROPERTIES
    
    var group: Group!
    var user: User!
    var progressTasks: [Chore] = []
    var completedTasks: [Chore] = []
    var userName: String!
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        title = "\(self.user.username)"
        
        hideNavigation(tint: UIColor.white)
        
    }
    
    // - MARK: IBACTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        userName = self.user.username
        self.usernameLabel.text = self.user.username
        self.userTaskRecordTableView.dataSource = self
        self.userTaskRecordTableView.delegate = self
        self.progressTasks = group.userInProgressTasks(userId: self.user.id)
        self.completedTasks = group.userCompletedTasks(userId: self.user.id)
//        let header = HeaderViewHelper.createTitleImageHeaderView(title: userName, fontSize: 30, frame: CGRect(x: 0, y: -100, width: 50, height: 100), imageURL: self.user.image_file)
//        self.userTaskRecordTableView.tableFooterView = header
        
        // Do any additional setup after loading the view.
    }

    override var additionalSafeAreaInsets: UIEdgeInsets {
        // Since its a read-write property and we are only interested in reading
        // we will return only the value that we are interesting in. Setter
        // here is redundant.
        set {
            super.additionalSafeAreaInsets = UIEdgeInsetsMake(-100.0, 100.0, 100.0, 100.0)
        }
        
        get {
            return UIEdgeInsetsMake(-100.0, 0.0, 0.0, 0.0)
        }
    }


}

extension UserTasksViewController: UITableViewDelegate, UITableViewDataSource {
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else if section == 1 {
            if self.group.userInProgressTasks(userId: self.user.id).count != 0 {
                return self.progressTasks.count
            } else {
                return 0
            }
            
        } else {
            if self.group.userCompletedTasks(userId: self.user.id).count != 0 {
                return self.completedTasks.count
            } else {
                return 0
            }
        }
    
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
       
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userProgressTaskCell") as! UserCompletedChoreTableViewCell
            let imageURL = URL(string: self.group.image_file)
            cell.groupProfileImageView.kf.setImage(with: imageURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
            let progressTask = progressTasks[indexPath.row]
            cell.choreNameLabel.text = progressTask.name
            cell.choreDescriptionLabel.text = progressTask.description
            cell.choreDateLabel.text = progressTask.due_date
            return cell
            
        } else if indexPath.section == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCompletedTaskCell") as! UserCompletedChoreTableViewCell
            let imageURL = URL(string: self.group.image_file)
            cell.groupProfileImageView.kf.setImage(with: imageURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
            let completedTask = completedTasks[indexPath.row]
            cell.choreNameLabel.text = completedTask.name
            cell.choreDescriptionLabel.text = completedTask.description
            cell.choreDateLabel.text = completedTask.due_date
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "placeHolderCell")
            return cell!
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            
            let header = HeaderViewHelper.createTitleImageHeaderView(title: userName, fontSize: 30, frame: CGRect(x: 0, y: -100, width: 50, height: 100), imageURL: self.user.image_file)
            return header
        } else if section == 1 {
            if self.progressTasks.count != 0{
                let header = HeaderViewHelper.createTitleHeaderView(title: "In Progress Tasks", fontSize: 20, frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70), color: UIColor.white)
                return header
            }
            else{
                return nil
            }
            
        } else {
            if self.completedTasks.count != 0{
                let header = HeaderViewHelper.createTitleHeaderView(title: "Completed Tasks", fontSize: 20, frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70), color: UIColor.white)
            return header
        }
        else{
            return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return self.view.frame.height * 0.6
        } else if section == 1 {
            if self.progressTasks.count == 0 {
                return 0
            } else {
                return 70
            }
        } else {
            if self.completedTasks.count == 0 {
                return 0
            } else {
                return 70
            }
        }
    }
    
    
}











