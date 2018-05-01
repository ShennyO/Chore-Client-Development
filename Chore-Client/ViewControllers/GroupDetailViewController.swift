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


class GroupDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CompleteChoreCompletionDelegate {
    
    // - MARK: IBOUTLETS
    
    @IBOutlet weak var sideMenuTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var sideMenuGroupLabel: UILabel!
    @IBOutlet weak var sideMenuGroupImageView: UIImageView!
    @IBOutlet weak var sideMenuTableView: UITableView!
    @IBOutlet weak var sideMenuNewChoreButton: UIButton!
    @IBOutlet weak var sideMenuNewUserButton: UIButton!
    @IBOutlet weak var sideMenuLeaveButton: UIButton!
    @IBOutlet weak var sideMenuProfileButton: UIButton!
    @IBOutlet weak var groupDetailTableView: UITableView!
    @IBOutlet weak var previewPage: UIView!
    
    
    // - MARK: VARIABLES
    
    let sideMenuCellLabels = ["Completed Tasks"]
    let photoHelper = PhotoHelper()
    var users: [User] = []
    var chores: [Chore] = []
    var group: Group!
    var darkened = false
    var Uploaded = false
    //for chore completion requests
    var requests: [Request] = []
    var menuShowing = true
    var loaded: Bool = false
   
    @IBOutlet weak var textPreview: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.backgroundColor = UIColor.clear
        title = "\(self.group.name)"
        groupDetailTableView.separatorInset = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.loaded = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
//        if self.group.chores.isEmpty{
//            self.previewPage.frame = self.groupDetailTableView
//            //self.view.addSubview(self.textPreview)
//    self.groupDetailTableView.backgroundView?.addSubview(self.previewPage)
//        
//    }
        
        
        if loaded == false {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        if self.menuShowing {
            let sideMenuWidth = self.view.frame.width * 0.7
            let sideMenuStartingPoint = sideMenuWidth * -1
            self.sideMenuTrailingConstraint.constant = sideMenuStartingPoint
        }
        photoHelper.completionHandler = { (image) in
            guard let imageData = UIImageJPEGRepresentation(image, 1)
                else {return}
            DispatchQueue.main.async {
                self.Uploaded = true
                self.sideMenuGroupImageView.image = image
                self.sideMenuGroupImageView.setNeedsDisplay()
            }
            Network.instance.imageUpload(route:imageUploadRoute.groupUpload, imageData: imageData)
            
        }
        
        
        
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .right
        view.addGestureRecognizer(edgePan)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(swipe:)))
        let tapToClose = UITapGestureRecognizer(target: self, action: #selector(tapToClose(tap:)))
        tapToClose.cancelsTouchesInView = false
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(tapToClose)
        
        
        self.groupDetailTableView.separatorInset = UIEdgeInsets.zero
        self.groupDetailTableView.layoutMargins = UIEdgeInsets.zero
        
        sideMenuTableView.dataSource = self
        sideMenuTableView.delegate = self
        if Uploaded == false {
            let groupProfileURL = URL(string: self.group.image_file)
            self.sideMenuGroupImageView.kf.setImage(with: groupProfileURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
            self.sideMenuGroupImageView.contentMode = .scaleAspectFill
            self.sideMenuGroupImageView.clipsToBounds = true
        }
        
        self.users = self.group.members
        
        self.getGroupChores {
            self.getChoreCompletionRequests(completion: {
                DispatchQueue.main.async {
                    self.groupDetailTableView.reloadData()
                    self.sideMenuTableView.reloadData()
                    if self.loaded == false {
                         ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                    }
                   
                }
            })
        }
        sideMenuNewUserButton.configureButton()
        sideMenuNewChoreButton.configureButton()
        sideMenuLeaveButton.configureButton()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toAddNewGroupUser" {
                let addNewGroupUserVC = segue.destination as! AddNewGroupUserViewController
                addNewGroupUserVC.selectedGroup = self.group
            } else if identifier == "toCompletedGroupChores" {
                let CompletedGroupChoresVC = segue.destination as! CompletedGroupChoresViewController
                CompletedGroupChoresVC.group = self.group
            } else if identifier == "userDetail"{
                let user = sender as! User
                let userTaskVC = segue.destination as! UserTasksViewController
                userTaskVC.group = group
                userTaskVC.user = user
            }
        }
    }
    
    // - MARK: OBJC FUNCTIONS
    
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized || recognizer.state == .changed {
            
            let translation = recognizer.translation(in: self.view).x
            let sideMenuWidth = self.view.frame.width * 0.7
            let sideMenuStartingPoint = self.sideMenuView.frame.width * -1
            if translation < 0  { //swipe left
                //if its at the starting position
                if self.sideMenuTrailingConstraint.constant < 0 {
                    self.menuShowing = true
                    UIView.animate(withDuration: 0.3, animations: {
                        //move it left by the width
                        self.sideMenuTrailingConstraint.constant += sideMenuWidth
                        self.view.layoutIfNeeded()
                    })
                    //if its not at the starting position
                } else if self.sideMenuTrailingConstraint.constant > sideMenuStartingPoint {
                    //the menu is not able to come out
                    self.menuShowing = false
                    self.sideMenuTrailingConstraint.constant = 0
                    if darkened == false {
                        let deadlineTime = DispatchTime.now() + .milliseconds(200)
                        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                            self.darkenScreen(darken: .dark)

                        })
                        
                    }
                    
                } else if self.sideMenuTrailingConstraint.constant < -50 {
                    self.menuShowing = true
                    self.sideMenuTrailingConstraint.constant = sideMenuStartingPoint
                    darkenScreen(darken: .normal)

                }
            }
            
        }
    }
    
    @objc func tapToClose(tap: UITapGestureRecognizer) {
        let touchPoint = tap.location(in: self.view).x
        let tappableLocation = view.bounds.width - self.sideMenuView.bounds.width
        if touchPoint < tappableLocation {
            let sideMenuStartingPoint = self.view.frame.width * -0.7
            //if it's not at the starting point
            if self.sideMenuTrailingConstraint.constant > sideMenuStartingPoint {
                self.menuShowing = true
                UIView.animate(withDuration: 0.125, animations: {
                    self.sideMenuTrailingConstraint.constant = sideMenuStartingPoint
                    self.view.layoutIfNeeded()
                })
                darkenScreen(darken: .normal)
                
            }
        }
        
    }
    
    @objc func swipeRight(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction.rawValue {
        case 1:
            let sideMenuStartingPoint = self.view.frame.width * -0.7
            //if it's not at the starting point
            if self.sideMenuTrailingConstraint.constant > sideMenuStartingPoint {
                self.menuShowing = true
                UIView.animate(withDuration: 0.125, animations: {
                    self.sideMenuTrailingConstraint.constant = sideMenuStartingPoint
                    self.view.layoutIfNeeded()
                })
                darkenScreen(darken: .normal)

            }
        default:
            return
        }
    }
    
    
    
    @objc func ButtonClick(_ sender: UIButton){
        self.performSegue(withIdentifier: "toAddNewGroupUser", sender: self)
    }
    
    
    
    
    
    // - MARK: TABLEVIEW DELEGATE FUNCTIONS
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            if self.requests.count != 0 {
                let header = HeaderViewHelper.createTitleHeaderView(title: "Requests", fontSize: 25, frame: CGRect(x: 0,y: 0,width: groupDetailTableView.frame.width, height: 30), color: UIColor.clear)
                return header
            }
            
        } else if section == 2 {
            if self.chores.count != 0 {
                let header = HeaderViewHelper.createTasksTitleHeaderView(title: "Tasks", fontSize: 25, frame: CGRect(x: 0, y: 0, width: groupDetailTableView.frame.width, height: 30), color: UIColor.clear)
                return header
            }
            
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.groupDetailTableView {
            if indexPath.section == 0 {
                return 150
            } else if indexPath.section == 1 {
                return 150
            } else {
                return 80
            }
        } else {
            return 55
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == self.groupDetailTableView {
            if section != 0 {
                if section == 1 {
                    if self.requests.count == 0 {
                        return 0
                    } else {
                        return 65
                    }
                } else {
                    if self.chores.count == 0 {
                        return 0
                    } else {
                        return 65
                    }
                }
            } else {
                return 0
            }
            
        } else {
            return 0
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == groupDetailTableView {
            return 3
        } else {
            return 1
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == groupDetailTableView {
            if section == 0 {
                return 1
            } else if section == 2 {
                return self.chores.count
            } else {
                return self.requests.count
            }
        } else {
            return self.sideMenuCellLabels.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == groupDetailTableView {
            if indexPath.section == 2 {
                let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "groupChoreCell") as! GroupChoreTableViewCell
                cell.chore = self.chores[indexPath.row]
                cell.selectionStyle = .none
                cell.choreNameLabel.text = self.chores[indexPath.row].name
                cell.choreDescriptionLabel.text = self.chores[indexPath.row].description ?? ""
                cell.dueDateLabel.text = self.chores[indexPath.row].getDate()
                cell.currentIndex = indexPath
                cell.delegate = self
                if self.chores[indexPath.row].assigned {

                    cell.assignButton.isUserInteractionEnabled = false
                    cell.buttonWidth.constant = 45
                    cell.buttonHeight.constant = 45
                    if self.chores[indexPath.row].user.image_file != "/image_files/original/missing.png" {
                        let imageURL = URL(string: self.chores[indexPath.row].user.image_file)
                        cell.assignButton.kf.setImage(with: imageURL!, for: .normal)
                        cell.assignButton.layer.cornerRadius = 0.5 * cell.buttonWidth.constant
                        cell.assignButton.clipsToBounds = true
                    } else {
                        cell.assignButton.setImage(UIImage(named: "AccountIcon"), for: .normal)
                        cell.assignButton.layer.cornerRadius = 0.5 * cell.buttonWidth.constant
                        cell.assignButton.clipsToBounds = true
                    }
                    
                   
                    
                } else {
                    cell.buttonHeight.constant = 30
                    cell.buttonWidth.constant = 60
                    cell.assignButton.setImage(nil, for: .normal)
                    cell.assignButton.layer.cornerRadius = 30 * 0.455
                    cell.assignButton.clipsToBounds = true
                    cell.assignButton.isUserInteractionEnabled = true
                }
                cell.layoutIfNeeded()
                return cell
            } else if indexPath.section == 0 {
                let tableViewCell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "profileTableViewCell") as! ProfileTableViewCell
                tableViewCell.selectionStyle = .none
                tableViewCell.layoutMargins = UIEdgeInsets.zero
            tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
                return tableViewCell
            } else {
                let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "choreCompletionRequestCell") as! ChoreCompletionRequestTableViewCell
                cell.selectionStyle = .none
                cell.choreCompletionLabel.text = "\(self.requests[indexPath.row].username!) has finished \(self.requests[indexPath.row].chore_name!) task"
                cell.index = indexPath
                cell.acceptButton.configureButton()
                cell.denyButton.configureButton()
                cell.delegate = self
                return cell
            }
        } else {
            let cell = self.sideMenuTableView.dequeueReusableCell(withIdentifier: "sideMenuCell") as! SideBarMenuTableViewCell
            cell.sideMenuLabel.text = self.sideMenuCellLabels[indexPath.row]
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
         let chore = self.chores[indexPath.row]
        let alert = UIAlertController(title: "Delete Task", message: "Are you sure you want to delete task: \(chore.name)?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .default) { (delete) in
            self.deleteChore(chore: chore)
        }
        alert.addAction(cancel)
        alert.addAction(delete)
        
        if editingStyle == .delete {
           
            self.present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if tableView == groupDetailTableView {
            if indexPath.section == 2 {
                let chore = self.chores[indexPath.row]
                if chore.assigned == false {
                    return true
                }
            }
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == sideMenuTableView {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "toCompletedGroupChores", sender: self)
            }
        }
    }
    
    
    // - MARK: COLLECTIONVIEW DELEGATE FUNCTIONS
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as! ProfileCollectionViewCell
        cell.usernameLabel.text = self.users[indexPath.row].username
       
        let imageURL = URL(string: self.users[indexPath.row].image_file)
        cell.profilePicture.kf.setImage(with: imageURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
        cell.profilePicture.setNeedsDisplay()
        cell.profilePicture.layer.cornerRadius = 0.5 * cell.profilePicture.bounds.size.width
        cell.profilePicture.contentMode = .scaleAspectFill
        cell.profilePicture.clipsToBounds = true
        
//        cell.profilePicture.layer.masksToBounds = false
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 130.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let user = group.members[indexPath.row]
        self.performSegue(withIdentifier: "userDetail", sender: user)
    }
    
    // - MARK: IBACTIONS
    
    @IBAction func categoryButtonTapped(_ sender: Any) {
        if (menuShowing) {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.sideMenuTrailingConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            })
            let deadlineTime = DispatchTime.now() + .milliseconds(200) // 0.3 seconds
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                self.darkenScreen(darken: .dark)
                
            })
            
            
        } else {
            let sideMenuStartingPoint = self.view.frame.width * -0.7
            sideMenuTrailingConstraint.constant = sideMenuStartingPoint
            darkenScreen(darken: .normal)
            UIView.animate(withDuration: 0.125, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
        menuShowing = !menuShowing
    }
    @IBAction func unwindToGroupDetailVC(segue:UIStoryboardSegue) { }
    
    @IBAction func sideMenuButtonTapped(_ sender: Any) {
        if (menuShowing) {
            
            UIView.animate(withDuration: 0.3, animations: {
                self.sideMenuTrailingConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            })
            let deadlineTime = DispatchTime.now() + .milliseconds(200) // 0.3 seconds
            DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                self.darkenScreen(darken: .dark)
                
            })
            
            
        } else {
            let sideMenuStartingPoint = self.view.frame.width * -0.7
            sideMenuTrailingConstraint.constant = sideMenuStartingPoint
            darkenScreen(darken: .normal)
            UIView.animate(withDuration: 0.125, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
        menuShowing = !menuShowing
    }
    
    
    @IBAction func sideMenuProfileButtonTapped(_ sender: Any) {
        photoHelper.presentActionSheet(from: self)
    }
    
    
    @IBAction func NewChoreTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toNewChore", sender: self)
    }
    
    @IBAction func newUserTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toAddNewGroupUser", sender: self)
    }
    
    @IBAction func leaveGroupTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Leave Group", message: "Are you sure you want to leave?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "No", style: .default, handler: nil)
        let logOut = UIAlertAction(title: "Yes", style: .default) { (logout) in
            let currentGroupID = Int(KeychainSwift().get("groupID")!)!
            let userID = Int(KeychainSwift().get("id")!)!
            Network.instance.fetch(route: .removeMember(group_id: currentGroupID, user_id: userID)) { (data, resp) in
                print("Member removed")
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "groupDetailToGroups", sender: self)
                }
            }
            
        }
        alert.addAction(cancel)
        alert.addAction(logOut)
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    

}

enum darkenScreen {
    case dark, normal
}

extension GroupDetailViewController: assignButtonDelegate {
    
    //darken the screen once the hamburger screen is popped out
    func darkenScreen(darken: darkenScreen) {
        let grayView = UIView()
        grayView.tag = 1
        grayView.backgroundColor = UIColor.black
        grayView.alpha = 0.5
        let screenHeight = view.bounds.height
        let width = view.bounds.width - self.sideMenuView.bounds.width
        grayView.frame.size.height = screenHeight
        grayView.frame.size.width = width
        switch darken {
        case .dark:
            if darkened == false {
                self.view.addSubview(grayView)
                darkened = !darkened
            }
        case .normal:
            
            for subview in self.view.subviews {
                if subview.tag == 1 {
                    subview.removeFromSuperview()
                }
            }
            
            darkened = !darkened
            
        }
        
    }
    
    // - MARK: NETWORKING FUNCTIONS
    
    func deleteChore(chore: Chore) {
        let groupID = Int(KeychainSwift().get("groupID")!)!
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        Network.instance.fetch(route: .deleteChore(id: chore.id, group_id: groupID)) { (data, resp) in
            print("deleted chore")
            self.getGroupChores {
                DispatchQueue.main.async {
                    self.groupDetailTableView.reloadData()
                    ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                }
            }
        }
    }
    
    func completeChoreCompletionRequest(index: IndexPath, answer: Bool) {
        let request = self.requests[index.row]
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        Network.instance.fetch(route: .choreRequestResponse(response: answer, chore_id: request.chore_id!, uuid: request.uuid!, request_id: request.id!)) { (data, resp) in
            self.getChoreCompletionRequests {
                self.getGroupChores {
                    DispatchQueue.main.async {
                        ViewControllerUtils().hideActivityIndicator(uiView: self.view)
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
        Network.instance.fetch(route: .takeChore(group_id: self.group.id, chore_id: selectedChore.id, user_id: userID)) { (data, resp) in
            completion()
        }
    }
    
    func assignChore(indexPath: IndexPath) {
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        takeChore(indexPath: indexPath) {
            self.getGroupChores {
                DispatchQueue.main.async {
                    self.groupDetailTableView.reloadData()
                    ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                }
            }
        }
    }
    

    
    func getGroupChores(completion: @escaping ()->()) {
        Network.instance.fetch(route: Route.getGroupChores(chore_type: "group", id: self.group.id)) { (data, resp) in
            let jsonChores = try? JSONDecoder().decode([Chore].self, from: data)
            if let chores = jsonChores {
                self.chores = chores
                completion()
            }
        }
    }
    
    func getChoreCompletionRequests(completion: @escaping ()->()) {
        let currentGroupID = Int(KeychainSwift().get("groupID")!)
        Network.instance.fetch(route: .getChoreRequests(group_id: currentGroupID!)) { (data, resp) in
            let jsonRequests = try? JSONDecoder().decode([Request].self, from: data)
            if let requests = jsonRequests {
                self.requests = requests
                completion()
            }
        }
    }
}
