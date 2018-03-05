//
//  GroupDetailViewController.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/14/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import FSPagerView
//import AZDropdownMenu

class GroupDetailViewController: UIViewController {
    
    
    // - MARK: Properties
    var users: [User] = []
    var chores: [Chore] = []
    var group: Group!
    var addUserButton = UIButton(type: .custom)
    
    // - MARK: Iboutlet
    @IBOutlet weak var groupDetailTableView: UITableView!
    
    @IBOutlet weak var memberImageView: FSPagerView!{
        didSet {
            self.memberImageView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    
    // - MARK: IBACTION
    
    @IBAction func unwindToGroupDetailVC(segue:UIStoryboardSegue) { }

    // - MARK: METHOD
    
    @objc func ButtonClick(_ sender: UIButton){
        print("button tapped")
        self.performSegue(withIdentifier: "toAddNewGroupUser", sender: self)
        
    }
    
    // - MARK: VIEW CONTROLLER LIFE CYCLE
    
    override func viewDidLoad() {
        
        // configure profile  view
        self.memberImageView.transformer = FSPagerViewTransformer(type: .linear)
        memberImageView.itemSize = CGSize(width: 150, height: 100)
        memberImageView.isInfinite = false
        memberImageView.interitemSpacing = 10
    }
   
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        self.addUserButton.addTarget(self, action: #selector(ButtonClick(_:)), for: UIControlEvents.touchUpInside)
        self.users = self.group.members
        self.getGroupChores {
            DispatchQueue.main.async {
                self.groupDetailTableView.reloadData()
                self.memberImageView.reloadData()
            }
        }
       
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.view.addSubview(addUserButton)
        addUserButton.layer.cornerRadius = addUserButton.layer.frame.size.width/2
        addUserButton.backgroundColor = UIColor(red: 1.0, green: 177/255, blue: 49/255, alpha: 1.0)
        addUserButton.clipsToBounds = true
        addUserButton.setImage(UIImage(named:"PlusButton"), for: .normal)
        addUserButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            addUserButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            addUserButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 90),
            addUserButton.widthAnchor.constraint(equalToConstant: 30),
            addUserButton.heightAnchor.constraint(equalToConstant: 30)])
    }
}
// - MARK: TABLEVIEW LIFE CYCLE

extension GroupDetailViewController: UITableViewDataSource, UITableViewDelegate{

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

            return self.chores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       
            let cell = self.groupDetailTableView.dequeueReusableCell(withIdentifier: "groupChoreCell") as! GroupChoreTableViewCell
            cell.chore = self.chores[indexPath.row]
        
            cell.choreNameLabel.text = self.chores[indexPath.row].name
            cell.dueDateLabel.text = self.chores[indexPath.row].due_date
        
        if chores[indexPath.row].assigned!{
            
            cell.assignedProfileImage.isHidden = false
            cell.assignButton.isHidden = true
            cell.choreOwnerNameLabel.isHidden = false
            // get chore assigned user
            let user = group.members.filter{$0.id == chores[indexPath.row].user_id}
            cell.choreOwnerNameLabel.text = user.first?.first_name
        }
        else{
            cell.assignedProfileImage.isHidden = true
            cell.assignButton.isHidden = false
            cell.choreOwnerNameLabel.isHidden = true
        }
        
        
            return cell
    }
   
}

extension GroupDetailViewController: FSPagerViewDelegate, FSPagerViewDataSource{
    
    // - MARK FPSVIEW LIFE CYCLE
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.users.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        cell.imageView?.image = UIImage(named: "AccountIcon")
        cell.textLabel?.text = ("\(self.users[index].first_name) \(self.users[index].last_name)")
        return cell
    }
    

}

extension GroupDetailViewController {
    
   
    
    func getGroupChores(completion: @escaping ()->()) {
        Network.instance.fetch(route: Route.getGroupChores(chore_type: "group", id: self.group.id)) { (data) in
             if data != nil{
            let jsonChores = try? JSONDecoder().decode([Chore].self, from: data!)
            if let chores = jsonChores {
                self.chores = chores
                completion()
                }
            }
        }
    }
}
