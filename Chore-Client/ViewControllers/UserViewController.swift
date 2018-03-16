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
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        getUser() {
            self.getUserChores {
                DispatchQueue.main.async {
                    let imageUrl = URL(string: self.currentUser.image_file)
                    if self.Uploaded == false {
                    self.profileImage.kf.setImage(with: imageUrl!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
                    }
                    self.profileImage.layer.cornerRadius = 0.5 * self.imageButton.bounds.size.width
                    self.profileImage.contentMode = .scaleAspectFill
                    self.profileImage.clipsToBounds = true
                    self.userNameLabel.text = self.currentUser.username
                    self.choreRecordTableView.reloadData()
                    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userChores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.choreRecordTableView.dequeueReusableCell(withIdentifier: "userChoreCell") as! UserChoreTableViewCell
        cell.choreNameLabel.text = self.userChores[indexPath.row].name
        cell.choreGroupLabel.text = self.userChores[indexPath.row].groupname
        cell.selectionStyle = .none
        if self.userChores[indexPath.row].pending {
            cell.completeButton.setTitle("Pending", for: .normal)
            cell.completeButton.isUserInteractionEnabled = false
            
        } else if self.userChores[indexPath.row].pending == false {
            cell.completeButton.setTitle("Complete", for: .normal)
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
        Network.instance.fetch(route: Route.getUser(username: username!)) { (data) in
            let jsonUser = try? JSONDecoder().decode(User.self, from: data)
            if let user = jsonUser {
                self.currentUser = user
                completion()
            }
        }
    }
    
    func getUserChores(completion: @escaping ()->()) {
        Network.instance.fetch(route: .getUserChores) { (data) in
            let jsonChores = try? JSONDecoder().decode([Chore].self, from: data)
            if let chores = jsonChores {
                self.userChores = chores
                completion()
            }
        }
    }
    func createChoreCompletionRequests(index: IndexPath) {
        Network.instance.fetch(route: .sendChoreCompletionRequest(chore_id: self.userChores[index.row].id)) { (data) in
            print("Requests created")
            self.getUserChores {
                DispatchQueue.main.async {
                    self.choreRecordTableView.reloadData()
                }
            }
        }
    }
    
    
}

extension UIButton {
    func configureButton() {
        self.layer.cornerRadius = 0.455 * self.bounds.height
        self.clipsToBounds = true
    }
}
