//
//  GroupsViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/8/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit

class GroupsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    
    

    @IBOutlet weak var groupsTableView: UITableView!
    
    var groups: [Group]!
    var requests: [Request]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.requests.count
        } else {
            return self.groups.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell!
        if indexPath.section == 0 {
            cell = self.groupsTableView.dequeueReusableCell(withIdentifier: "requestCell")
        } else {
            cell = self.groupsTableView.dequeueReusableCell(withIdentifier: "groupCell")
        }
        return cell
    }
    
   

}
