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


class GroupDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CompleteChoreCompletionDelegate, addNewDelegate {
    
    
    @IBOutlet weak var sideMenuTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideMenuView: UIView!
    @IBOutlet weak var sideMenuGroupLabel: UILabel!
    @IBOutlet weak var sideMenuGroupImageView: UIImageView!
    @IBOutlet weak var sideMenuTableView: UITableView!
    
    var blurEffectView: UIVisualEffectView!
    let sideMenuCellLabels = ["Completed Chores"]
    var users: [User] = []
    var chores: [Chore] = []
    var group: Group!
    var blurred = false
    //for chore completion requests
    var requests: [Request] = []
    var menuShowing = true
   
    @IBOutlet weak var groupDetailTableView: UITableView!
    
    @IBAction func unwindToGroupDetailVC(segue:UIStoryboardSegue) { }

    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .right
        view.addGestureRecognizer(edgePan)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeRight(swipe:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        sideMenuTableView.dataSource = self
        sideMenuTableView.delegate = self
        let groupProfileURL = URL(string: self.group.image_file)
        self.sideMenuGroupImageView.kf.setImage(with: groupProfileURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
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
                    if blurred == false {
                        let deadlineTime = DispatchTime.now() + .milliseconds(200) // 0.3 seconds
                        DispatchQueue.main.asyncAfter(deadline: deadlineTime, execute: {
                            self.blurScreen(blur: .blur)

                        })
                        
                    }
                    
                } else if self.sideMenuTrailingConstraint.constant < -50 {
                    self.menuShowing = true
                    self.sideMenuTrailingConstraint.constant = -200
                    blurScreen(blur: .normal)

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
                blurScreen(blur: .normal)

            }
        default:
            return
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
                self.blurScreen(blur: .blur)

            })
            
            
        } else {
            sideMenuTrailingConstraint.constant = -200
            blurScreen(blur: .normal)
            UIView.animate(withDuration: 0.125, animations: {
                self.view.layoutIfNeeded()
            })
            
        }
        menuShowing = !menuShowing
    }
    
    
    func newChore() {
        self.performSegue(withIdentifier: "toNewChore", sender: self)
    }
    
    func newUser() {
        self.performSegue(withIdentifier: "toAddNewGroupUser", sender: self)
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
                return 50
            } else if indexPath.section == 2 {
                return 70
            }
            else {
                return 70
            }
        } else {
            return 55
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == groupDetailTableView {
            return 4
        } else {
            return 1
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == groupDetailTableView {
            if section == 0 {
                return 1
            } else if section == 3 {
                return self.chores.count
            } else if section == 2 {
                return self.requests.count
            } else {
                return 1
            }
        } else {
            return self.sideMenuCellLabels.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == groupDetailTableView {
            if indexPath.section == 3 {
                let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "groupChoreCell") as! GroupChoreTableViewCell
                cell.choreNameLabel.text = self.chores[indexPath.row].name
                cell.dueDateLabel.text = self.chores[indexPath.row].due_date
                cell.currentIndex = indexPath
                cell.delegate = self
                if self.chores[indexPath.row].assigned {
                    if self.chores[indexPath.row].user.image_file != nil {
                        let imageURL = URL(string: self.chores[indexPath.row].user.image_file)
                        cell.assignButton.kf.setImage(with: imageURL!, for: .normal)
                        cell.assignButton.layer.cornerRadius = 0.5 * cell.assignButton.bounds.width
                        cell.assignButton.clipsToBounds = true
                    } else {
                        cell.assignButton.setImage(UIImage(named: "AccountIcon"), for: .normal)
                    }
                    
                    cell.assignButtonHeight.constant = 60
                    cell.assignButton.isUserInteractionEnabled = false
                    
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
            } else if indexPath.section == 2 {
                let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "choreCompletionRequestCell") as! ChoreCompletionRequestTableViewCell
                cell.choreCompletionLabel.text = "\(self.requests[indexPath.row].username!) has finished \(self.requests[indexPath.row].chore_name!)chore"
                cell.index = indexPath
                cell.acceptButton.configureButton()
                cell.denyButton.configureButton()
                cell.delegate = self
                return cell
            } else {
                let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "addNew") as! GroupDetailAddNewTableViewCell
                cell.newUserButton.configureButton()
                cell.newChoreButton.configureButton()
                cell.delegate = self
                return cell
            }
        } else {
            let cell = self.sideMenuTableView.dequeueReusableCell(withIdentifier: "sideMenuCell") as! SideBarMenuTableViewCell
            cell.sideMenuLabel.text = self.sideMenuCellLabels[indexPath.row]
            return cell
        }
        
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
        cell.profilePicture.layer.cornerRadius = 0.5 * cell.profilePicture.bounds.size.width
        cell.profilePicture.clipsToBounds = true
            
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100.0, height: 130.0)
    }

}

enum screenBlur {
    case blur, normal
}

extension GroupDetailViewController: assignButtonDelegate {
    
    func blurScreen(blur: screenBlur) {
        self.blurEffectView = UIVisualEffectView()
        let screenHeight = view.bounds.height
        let width = view.bounds.width - self.sideMenuView.bounds.width
        self.blurEffectView.frame.size.height = screenHeight
        self.blurEffectView.frame.size.width = width
        self.blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        switch blur {
        case .blur:
            if blurred == false {
                
                self.blurEffectView.effect = UIBlurEffect(style: .light)
                self.view.addSubview(self.blurEffectView)
                blurred = !blurred
                
            }
            
            
        case .normal:
            DispatchQueue.main.async {
                for subview in self.view.subviews {
                    if subview is UIVisualEffectView {
                        subview.removeFromSuperview()
                    }
                }
                self.blurred = !self.blurred
            }
            
        }
       
    }
    
    func setUpSideMenuButton() {
        let sideMenuButton = UIButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        sideMenuButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        sideMenuButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        let imgURL = URL(string: self.group.image_file)
        KingfisherManager.shared.retrieveImage(with: imgURL!, options: nil, progressBlock: nil) { (image, _, _, _) in
            DispatchQueue.main.async {
                sideMenuButton.setBackgroundImage(image!, for: .normal)
                sideMenuButton.addTarget(self, action: #selector(self.sideMenuButtonTapped), for: .touchUpInside)
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sideMenuButton)
            }
        }
    }
    
    func configureButton(button: UIButton) {
        button.layer.cornerRadius = 0.155 * button.bounds.size.width
        button.clipsToBounds = true
    }
    
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
