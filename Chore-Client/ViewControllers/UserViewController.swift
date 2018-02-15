//
//  UserViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/15/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift

class UserViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var choreRecordTableView: UITableView!
    
    var currentUser: Member!
    override func viewDidLoad() {
        super.viewDidLoad()

        getUser() {
            DispatchQueue.main.async {
                self.userNameLabel.text = self.currentUser.username
            }
        }
    }

    

}

extension UserViewController {
    func getUser(completion: @escaping()->()) {
        let username = KeychainSwift().get("username")
        Network.instance.fetch(route: Route.getUser(username: username!)) { (data) in
            let jsonUser = try? JSONDecoder().decode(Member.self, from: data)
            if let user = jsonUser {
                self.currentUser = user
                completion()
            }
        }
    }
}
