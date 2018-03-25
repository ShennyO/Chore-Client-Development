//
//  UserViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/15/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift
import Alamofire
import Kingfisher


class UserViewController: UIViewController, ChoreCompletionDelegate{
    
    //@IBOutlet weak var choreRecordCollectionView: UICollectionViewCell!
    @IBOutlet weak var choreRecordCollectionView: UICollectionView!
    
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
   
    //@IBOutlet weak var choreRecordTableView: UITableView!

    @IBOutlet weak var imageButton: UIButton!
    let photoHelper = PhotoHelper()
    var imageData: NSData?
    var userChores: [Chore] = []
    var currentUser: User!
    var userImage = UIImage()
    var tableViewHeader: UserHeaderView!
    var indexPath = [IndexPath]()
    //This checks if we are opening the view normally, or right after we uploaded an image
    var Uploaded = false
    var loaded = false
    override var additionalSafeAreaInsets: UIEdgeInsets {
        set {
            super.additionalSafeAreaInsets = UIEdgeInsetsMake(-100.0, 100.0, 100.0, 100.0)
        }
        
        get {
            return UIEdgeInsetsMake(-100.0, 0.0, 0.0, 0.0)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        showNavigation()
        navigationItem.largeTitleDisplayMode = .always
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        
        getUser {
            
            self.getUserChores {
                let imageURL = URL(string: self.currentUser.image_file)
                KingfisherManager.shared.retrieveImage(with: imageURL!, options: nil, progressBlock: nil, completionHandler: { (image, _, _, _) in
                    
                    DispatchQueue.main.async {
                        
                        self.profileImage.image = image
                        self.choreRecordCollectionView.reloadData()
                        ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                    }
                })
            }
            
           
            
            self.photoHelper.completionHandler = { (image) in
                self.tableViewHeader.imageView.image = image
                guard let imageData = UIImageJPEGRepresentation(image, 1)
                    else {return}
                Network.instance.imageUpload(route: .userUpload, imageData: imageData)
            }
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        navigationItem.largeTitleDisplayMode = .never
//        hideNavigation(tint: UIColor(rgb: 0xEEF0F0))
//
//        getUserChores {
//            DispatchQueue.main.async {
//                self.choreRecordTableView.reloadData()
//            }
//        }
//
//    }
    /// logout user
    @IBAction func settingsButtonTapped(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "No", style: .default, handler: nil)
        let logOut = UIAlertAction(title: "Yes", style: .default) { (logout) in
            Network.instance.fetch(route: .logoutUser) { (data, resp) in
                UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
                UserDefaults.standard.synchronize()
                DispatchQueue.main.async {
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let loginVC = mainStoryboard.instantiateViewController(withIdentifier: "newLoginVC")
                    self.present(loginVC, animated: true)
                }

            }
        }
        alert.addAction(cancel)
        alert.addAction(logOut)
        self.present(alert, animated: true, completion: nil)
    }
    
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.userChores.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = self.choreRecordTableView.dequeueReusableCell(withIdentifier: "userChoreCell") as! UserChoreTableViewCell
//        cell.choreNameLabel.text = self.userChores[indexPath.row].name
//        cell.choreDescriptionLabel.text = self.userChores[indexPath.row].description
//        let groupImageURL = URL(string: self.userChores[indexPath.row].group_image)
//        cell.choreGroupImage.kf.setImage(with: groupImageURL, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
//        cell.choreGroupImage.contentMode = .scaleAspectFill
//        cell.choreGroupImage.clipsToBounds = true
//        cell.selectionStyle = .none
//        if self.userChores[indexPath.row].pending {
//            cell.completeButton.setTitle("Pending", for: .normal)
//            cell.completeButton.backgroundColor = UIColor(rgb: 0xE0D400)
//            cell.completeButton.isUserInteractionEnabled = false
//
//        } else if self.userChores[indexPath.row].pending == false {
//            cell.completeButton.setTitle("Complete", for: .normal)
//            cell.completeButton.backgroundColor = UIColor(rgb: 0x55C529)
//            cell.completeButton.isUserInteractionEnabled = true
//        }
//        cell.completeButton.configureButton()
//        cell.choreDateLabel.text = self.userChores[indexPath.row].getDate()
//        cell.delegate = self as ChoreCompletionDelegate
//        cell.index = indexPath
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = HeaderViewHelper.createTitleHeaderView(title: "In Progress", fontSize: 25, frame: CGRect(x: 0, y: 0, width: self.choreRecordTableView.frame.width, height: 50), color: UIColor.white)
//        return header
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 70
//    }
    
}

extension UserViewController {
////
////    func editButton() {
////        photoHelper.presentActionSheet(from: self)
////    }
//
//    
    func getUser(completion: @escaping()->()) {
        let username = KeychainSwift().get("username")
        Network.instance.fetch(route: Route.getUser(username: username!)) { (data, resp) in
            let jsonUser = try? JSONDecoder().decode(User.self, from: data)
            if let user = jsonUser {
                self.currentUser = user
                completion()
            }
        }
    }

    func getUserChores(completion: @escaping ()->()) {
        Network.instance.fetch(route: .getUserChores) { (data, resp) in
            let jsonChores = try? JSONDecoder().decode([Chore].self, from: data)
            if let chores = jsonChores {
                self.userChores = chores
                completion()
            }
        }
    }
    func createChoreCompletionRequests(index: IndexPath) {
        Network.instance.fetch(route: .sendChoreCompletionRequest(chore_id: self.userChores[index.row].id)) { (data, resp) in
            print("Requests created")
            self.getUserChores {
                DispatchQueue.main.async {
                    self.choreRecordCollectionView.reloadData()
                }
            }
        }
    }
}

extension UserViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.currentUser != nil) ? 3 : 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! ChoreRecordCollectionViewCell
        
       
        
        switch indexPath.row {
        case 0:
            cell.currentUser = self.currentUser
            cell.userChores = self.userChores.filter{$0.completed == false && $0.pending == false}
           cell.tableViewHeader = self.tableViewHeader
            cell.choreRecordTableViewHeaderTitle = "In Progress"
             //cell.choreRecordTableView.dataSource = self
            //self.choreRecordCollectionView.reloadData()
            
             return cell
        case 2:
            cell.currentUser = self.currentUser
            cell.userChores = self.userChores.filter{$0.completed == true}
            cell.tableViewHeader = self.tableViewHeader
            cell.choreRecordTableViewHeaderTitle = "Completed"
            
            return cell
        case 1:
            cell.tableViewHeader = self.tableViewHeader
            cell.currentUser = self.currentUser
            cell.userChores = self.userChores.filter{$0.pending == true}
            cell.choreRecordTableViewHeaderTitle = "Pending"
            
            return cell
        default:
            
            return cell
        }
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.choreRecordCollectionView.frame.size.height)
    }
}













