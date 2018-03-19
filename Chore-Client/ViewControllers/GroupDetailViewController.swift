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


class GroupDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CompleteChoreCompletionDelegate{
    
    
    @IBOutlet weak var sideMenuTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var sideMenuGroupLabel: UILabel!
    @IBOutlet weak var sideMenuGroupImageView: UIImageView!
    @IBOutlet weak var sideMenuTableView: UITableView!
    @IBOutlet weak var sideMenuNewChoreButton: UIButton!
    @IBOutlet weak var sideMenuNewUserButton: UIButton!
    @IBOutlet weak var sideMenuLeaveButton: UIButton!
    @IBOutlet weak var sideMenuProfileButton: UIButton!
   
    
    let sideMenuCellLabels = ["Completed Chores"]
    let photoHelper = PhotoHelper()
    var users: [User] = []
    var chores: [Chore] = []
    var group: Group!
    var darkened = false
    var Uploaded = false
    //for chore completion requests
    var requests: [Request] = []
    var menuShowing = true
   
    @IBOutlet weak var groupDetailTableView: UITableView!
    
    @IBAction func unwindToGroupDetailVC(segue:UIStoryboardSegue) { }

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
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
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        sideMenuTableView.dataSource = self
        sideMenuTableView.delegate = self
        if Uploaded == false {
            let groupProfileURL = URL(string: self.group.image_file)
            self.sideMenuGroupImageView.kf.setImage(with: groupProfileURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
            self.sideMenuGroupImageView.contentMode = .scaleAspectFill
            self.sideMenuGroupImageView.clipsToBounds = true
        }
        self.sideMenuGroupLabel.text = self.group.name
        self.users = self.group.members
        
        self.getGroupChores {
            self.getChoreCompletionRequests(completion: {
                DispatchQueue.main.async {
                    self.groupDetailTableView.reloadData()
                    self.sideMenuTableView.reloadData()
                }
            })
        }
        self.setUpSideMenuButton()
        sideMenuNewUserButton.configureButton()
        sideMenuNewChoreButton.configureButton()
        sideMenuLeaveButton.configureButton()
    }
    
    @IBAction func sideMenuProfileButtonTapped(_ sender: Any) {
        photoHelper.presentActionSheet(from: self)
    }
    
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized || recognizer.state == .changed {
            
            let translation = recognizer.translation(in: self.view).x
            
            if translation < 0  { //swipe left
                if self.sideMenuTrailingConstraint.constant < 0 {
                    self.menuShowing = true
                    UIView.animate(withDuration: 0.3, animations: {
                        self.sideMenuTrailingConstraint.constant -= -100
                        self.view.layoutIfNeeded()
                    })
                    
                } else if self.sideMenuTrailingConstraint.constant > -200 {
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
                    self.sideMenuTrailingConstraint.constant = -200
                    darkenScreen(darken: .normal)

                }
            }
            
        }
    }
    
    @objc func swipeRight(swipe: UISwipeGestureRecognizer) {
        switch swipe.direction.rawValue {
        case 1:
            if self.sideMenuTrailingConstraint.constant > -200 {
                self.menuShowing = true
                UIView.animate(withDuration: 0.125, animations: {
                    self.sideMenuTrailingConstraint.constant = -200
                    self.view.layoutIfNeeded()
                })
                darkenScreen(darken: .normal)

            }
        default:
            return
        }
    }
    
    @IBAction func NewChoreTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toNewChore", sender: self)
    }
    
    @IBAction func newUserTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "toAddNewGroupUser", sender: self)
    }
    
    @IBAction func leaveGroupTapped(_ sender: Any) {
        let currentGroupID = Int(KeychainSwift().get("groupID")!)!
        let userID = Int(KeychainSwift().get("id")!)!
        Network.instance.fetch(route: .removeMember(group_id: currentGroupID, user_id: userID)) { (data) in
            print("Member removed")
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "groupDetailToGroups", sender: self)
            }
        }
        
        
    }
    
    
    @objc func sideMenuButtonTapped() {
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
            sideMenuTrailingConstraint.constant = -200
            darkenScreen(darken: .normal)
            UIView.animate(withDuration: 0.125, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
        menuShowing = !menuShowing
    }
    
    
    
    @objc func ButtonClick(_ sender: UIButton){
        self.performSegue(withIdentifier: "toAddNewGroupUser", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "toAddNewGroupUser" {
                let addNewGroupUserVC = segue.destination as! AddNewGroupUserViewController
                addNewGroupUserVC.selectedGroup = self.group
            } else if identifier == "toCompletedGroupChores" {
                let CompletedGroupChoresVC = segue.destination as! CompletedGroupChoresViewController
                CompletedGroupChoresVC.group = self.group
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.groupDetailTableView {
            if indexPath.section == 0 {
                return 155
            } else if indexPath.section == 1 {
                return 70
            } else {
                return 70
            }
        } else {
            return 55
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
                cell.selectionStyle = .none
                cell.choreNameLabel.text = self.chores[indexPath.row].name
                cell.choreDescriptionLabel.text = self.chores[indexPath.row].description
                cell.dueDateLabel.text = self.chores[indexPath.row].due_date
                cell.currentIndex = indexPath
                cell.delegate = self
                if self.chores[indexPath.row].assigned {
                    cell.assignButtonHeight.constant = 45
                    cell.assignButton.isUserInteractionEnabled = false
                    if self.chores[indexPath.row].user.image_file != "/image_files/original/missing.png" {
                        let imageURL = URL(string: self.chores[indexPath.row].user.image_file)
                        cell.assignButton.kf.setImage(with: imageURL!, for: .normal)
                        cell.assignButton.layer.cornerRadius = 0.5 * cell.assignButton.bounds.width
                        cell.assignButton.clipsToBounds = true
                    } else {
                        cell.assignButton.setImage(UIImage(named: "AccountIcon"), for: .normal)
                        cell.assignButton.layer.cornerRadius = 0.5 * cell.assignButton.bounds.width
                        cell.assignButton.clipsToBounds = true
                    }
                    
                   
                    
                } else {
                    cell.assignButton.setImage(nil, for: .normal)
                    cell.assignButtonHeight.constant = 30
                    cell.assignButton.layer.cornerRadius = 30 * 0.455
                    cell.assignButton.clipsToBounds = true
                    cell.assignButton.isUserInteractionEnabled = true
                }
                return cell
            } else if indexPath.section == 0 {
                let tableViewCell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "profileTableViewCell") as! ProfileTableViewCell
                tableViewCell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
                return tableViewCell
            } else {
                let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "choreCompletionRequestCell") as! ChoreCompletionRequestTableViewCell
                cell.selectionStyle = .none
                cell.choreCompletionLabel.text = "\(self.requests[indexPath.row].username!) has finished \(self.requests[indexPath.row].chore_name!) chore"
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
        let alert = UIAlertController(title: "Delete Chore", message: "Are you sure you want to delete chore: \(chore.name)?", preferredStyle: .alert)
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
        return 25
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 130.0)
    }

}

enum darkenScreen {
    case dark, normal
}

extension GroupDetailViewController: assignButtonDelegate {
    
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
    
    
    func setUpSideMenuButton() {
        let sideMenuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        sideMenuButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        sideMenuButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        let imgURL = URL(string: self.group.image_file)
        if self.group.image_file != "/image_files/original/missing.png" {
            KingfisherManager.shared.retrieveImage(with: imgURL!, options: nil, progressBlock: nil) { (image, _, _, _) in
                DispatchQueue.main.async {
                    sideMenuButton.setBackgroundImage(image!, for: .normal)
                    sideMenuButton.addTarget(self, action: #selector(self.sideMenuButtonTapped), for: .touchUpInside)
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sideMenuButton)
                }
            }
        } else {
            sideMenuButton.setBackgroundImage(UIImage(named: "AccountIcon"), for: .normal)
            sideMenuButton.addTarget(self, action: #selector(self.sideMenuButtonTapped), for: .touchUpInside)
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sideMenuButton)
        }
        
    }
    
    func configureButton(button: UIButton) {
        button.layer.cornerRadius = 0.155 * button.bounds.size.width
        button.clipsToBounds = true
    }
    
    func deleteChore(chore: Chore) {
        let groupID = Int(KeychainSwift().get("groupID")!)!
        
        Network.instance.fetch(route: .deleteChore(id: chore.id, group_id: groupID)) { (data) in
            print("deleted chore")
            self.getGroupChores {
                DispatchQueue.main.async {
                    self.groupDetailTableView.reloadData()
                }
            }
        }
    }
    
    func completeChoreCompletionRequest(index: IndexPath, answer: Bool) {
        let request = self.requests[index.row]
        Network.instance.fetch(route: .choreRequestResponse(response: answer, chore_id: request.chore_id!, uuid: request.uuid!, request_id: request.id!)) { (data) in
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
