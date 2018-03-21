//
//  UserTasksViewController.swift
//  Chore-Client
//
//  Created by Yveslym on 3/20/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class UserTasksViewController: UIViewController {

    // - MARK: IBOUTLET
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var userTaskRecordTableView: UITableView!
    
    // - MARK: PROPERTIES
    
    var group: Group!
    var user: User!
    var progressTasks: [Chore] = []
    var completedTasks: [Chore] = []
    
    // - MARK: IBACTIONS
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameLabel.text = self.user.username
        let imageURL = URL(string: self.user.image_file)
        self.userProfileImageView.kf.setImage(with: imageURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
        self.userProfileImageView.contentMode = .scaleAspectFill
        self.userProfileImageView.layer.cornerRadius = 0.5 * self.userProfileImageView.bounds.size.width
        self.userProfileImageView.clipsToBounds = true
        self.userTaskRecordTableView.dataSource = self
        self.userTaskRecordTableView.delegate = self
        self.progressTasks = group.userInProgressTasks(userId: self.user.id)
        self.completedTasks = group.userCompletedTasks(userId: self.user.id)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension UserTasksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
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
       
       
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userProgressTaskCell") as! UserCompletedChoreTableViewCell
            let imageURL = URL(string: self.group.image_file)
            cell.groupProfileImageView.kf.setImage(with: imageURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
            let progressTask = progressTasks[indexPath.row]
            cell.choreNameLabel.text = progressTask.name
            cell.choreDescriptionLabel.text = progressTask.description
            cell.choreDateLabel.text = progressTask.due_date
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "userCompletedTaskCell") as! UserCompletedChoreTableViewCell
            let imageURL = URL(string: self.group.image_file)
            cell.groupProfileImageView.kf.setImage(with: imageURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
            let completedTask = completedTasks[indexPath.row]
            cell.choreNameLabel.text = completedTask.name
            cell.choreDescriptionLabel.text = completedTask.description
            cell.choreDateLabel.text = completedTask.due_date
            return cell
        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            if self.progressTasks.count != 0{
            let header = HeaderViewHelper.createTitleHeaderView(title: "In Progress Tasks", fontSize: 20, frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70))
            return header
            }
            else{
                return nil
            }
        } else {
            if self.completedTasks.count != 0{
            let header = HeaderViewHelper.createTitleHeaderView(title: "Completed Tasks", fontSize: 20, frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 70))
            return header
        }
        else{
            return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
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











