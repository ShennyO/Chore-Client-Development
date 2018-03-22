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


class UserViewController: UIViewController, ChoreCompletionDelegate, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
   
    @IBOutlet weak var choreRecordTableView: UITableView!

    @IBOutlet weak var imageButton: UIButton!
    let photoHelper = PhotoHelper()
    var imageData: NSData?
    var userChores: [Chore] = []
    var currentUser: User!
    //This checks if we are opening the view normally, or right after we uploaded an image
    var Uploaded = false
    var loaded = false
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.loaded = true
        showNavigation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigation(tint: UIColor.black)
    navigationController?.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
    navigationController?.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        if loaded == false {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        
        self.navigationController?.navigationBar.tintAdjustmentMode = .normal
        self.navigationController?.navigationBar.tintAdjustmentMode = .automatic
        
        getUser() {
            self.getUserChores {
                DispatchQueue.main.async {
                    let imageUrl = URL(string: self.currentUser.image_file)
                    if self.Uploaded == false {
                    self.profileImage.kf.setImage(with: imageUrl!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
                    }
                    self.profileImage.contentMode = .scaleAspectFill
                    self.profileImage.layer.cornerRadius = 0.5 * self.imageButton.bounds.size.width
                    self.profileImage.clipsToBounds = true
                    self.userNameLabel.text = self.currentUser.username
                    self.choreRecordTableView.reloadData()
                    if self.loaded == false {
                    ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                    }
                }
            }
        }
        
        photoHelper.completionHandler = { (image) in
            guard let imageData = UIImageJPEGRepresentation(image, 1)
                else {return}
            DispatchQueue.main.async {
                self.Uploaded = true
                self.profileImage.image = image
                self.profileImage.setNeedsDisplay()
            }
            Network.instance.imageUpload(route: .userUpload, imageData: imageData)

        }
        
    }
    /// logout user
    @IBAction func settingsButtonTapped(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.synchronize()

        
        let alert = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "No", style: .default, handler: nil)
        let logOut = UIAlertAction(title: "Yes", style: .default) { (logout) in
            Network.instance.fetch(route: .logoutUser) { (data, resp) in
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
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userChores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.choreRecordTableView.dequeueReusableCell(withIdentifier: "userChoreCell") as! UserChoreTableViewCell
        cell.choreNameLabel.text = self.userChores[indexPath.row].name
        cell.choreDescriptionLabel.text = self.userChores[indexPath.row].description
        let groupImageURL = URL(string: self.userChores[indexPath.row].group_image)
        cell.choreGroupImage.kf.setImage(with: groupImageURL, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
        cell.choreGroupImage.contentMode = .scaleAspectFill
        cell.choreGroupImage.clipsToBounds = true
        cell.selectionStyle = .none
        if self.userChores[indexPath.row].pending {
            cell.completeButton.setTitle("Pending", for: .normal)
            cell.completeButton.backgroundColor = UIColor(rgb: 0xEDE041)
            cell.completeButton.isUserInteractionEnabled = false
            
        } else if self.userChores[indexPath.row].pending == false {
            cell.completeButton.setTitle("Complete", for: .normal)
            cell.completeButton.backgroundColor = UIColor(rgb: 0x55C529)
            cell.completeButton.isUserInteractionEnabled = true
        }
        cell.completeButton.configureButton()
        cell.choreDateLabel.text = self.userChores[indexPath.row].due_date
        cell.delegate = self as ChoreCompletionDelegate
        cell.index = indexPath
        return cell
    }
    


    @IBAction func imageButtonTapped(_ sender: Any) {
        
        photoHelper.presentActionSheet(from: self)
        
    }

}

extension UserViewController {
    
    
    
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
                    self.choreRecordTableView.reloadData()
                }
            }
        }
    }
}

