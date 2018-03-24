//
//  UserChoresViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/13/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class UserChoresViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var choresTableView: UITableView!
    var userChores: [Chore] = []
    var loaded: Bool = false
   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideNavigation(tint: UIColor.black)
        self.loaded = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        if loaded == false {
        ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        getUserCompletedChores {
            DispatchQueue.main.async {
                self.choresTableView.reloadData()
                if self.loaded == false {
                ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userChores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.choresTableView.dequeueReusableCell(withIdentifier: "completedChoreCell") as! UserCompletedChoreTableViewCell
        let task = self.userChores[indexPath.row]
        cell.choreNameLabel.text = task.name
        let groupProfileURL = URL(string: task.group_image)
        cell.groupProfileImageView.kf.setImage(with: groupProfileURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
        cell.choreDescriptionLabel.text = task.description
        cell.choreDateLabel.text = task.getDate()
        return cell
    }
    

    
}

extension UserChoresViewController {
    func getUserCompletedChores(completion: @escaping ()->()) {
        Network.instance.fetch(route: .getUserCompletedChores) { (data, resp) in
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
        }
    }
}
