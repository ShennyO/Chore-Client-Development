//
//  CompletedGroupChoresViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 3/13/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import Kingfisher

class CompletedGroupChoresViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var completedGroupChoresTableView: UITableView!
    var chores: [Chore] = []
    var group: Group!
    var loaded: Bool = false
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.loaded = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getCompletedGroupChores {
            DispatchQueue.main.async {
                if self.loaded == false {
                ViewControllerUtils().hideActivityIndicator(uiView: self.view)
                }
                self.completedGroupChoresTableView.reloadData()
            }
        }
        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.completedGroupChoresTableView.dequeueReusableCell(withIdentifier: "completedGroupChoreCell") as! CompletedGroupChoreCell
        cell.choreNameLabel.text = self.chores[indexPath.row].name
        cell.dateLabel.text = self.chores[indexPath.row].due_date
        let imageURL = URL(string: self.chores[indexPath.row].user.image_file)
        cell.userImageView.kf.setImage(with: imageURL!, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
        cell.userImageView.layer.cornerRadius = 0.5 * cell.userImageView.bounds.size.width
        cell.userImageView.clipsToBounds = true
        return cell
    }
    
}

extension CompletedGroupChoresViewController {
    func getCompletedGroupChores(completion: @escaping ()->()) {
        if loaded == false {
            ViewControllerUtils().showActivityIndicator(uiView: self.view)
        }
        Network.instance.fetch(route: Route.getCompletedGroupChores(chore_type: "group", id: self.group.id)) { (data, resp) in
            let jsonChores = try? JSONDecoder().decode([Chore].self, from: data)
            if let chores = jsonChores {
                self.chores = chores
                completion()
            }
        }
    }
}
