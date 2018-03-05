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

class UserViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var choreRecordTableView: UITableView!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var imageButton: UIButton!
    let photoHelper = PhotoHelper()
    var imageData: NSData!
    
    var currentUser: User!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        photoHelper.completionHandler = { (image) in
            guard let imageData = UIImageJPEGRepresentation(image, 1)
                else {return}
            
            self.imageData = imageData as NSData
            
            DispatchQueue.main.async {
                self.profilePic.image = image
            }
        }
        getUser() {
            DispatchQueue.main.async {
                self.userNameLabel.text = self.currentUser.username
            }
        }
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
    
    
}
