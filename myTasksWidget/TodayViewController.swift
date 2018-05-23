//
//  TodayViewController.swift
//  myTasks
//
//  Created by Yveslym on 5/21/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding {
    
    // - MARK: IBOUTLETS
    @IBOutlet weak var reminderTableView: UITableView!
    
    // - MARK: PROPERTIES
    var userTasks = [Chore](){
        didSet{
            DispatchQueue.main.async {
                self.reminderTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
    }
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global().async {
            self.retrieveTasks(completionHandler: { (tasks) in
                DispatchQueue.main.async {
                    self.self.userTasks = tasks
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func retrieveTasks(completionHandler:@escaping([Chore])->()){
        Network.instance.fetch(route: .getUserChores) { (data, resp) in
            do{
            let tasks = try JSONDecoder().decode([Chore].self, from: data)
            completionHandler(tasks)
            }
            catch{}
        }
    }
    
}

// - MARK: TABLE VIEW LIFE CYCLE

extension TodayViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = reminderTableView.dequeueReusableCell(withIdentifier: "cell") as! MyTasksReminderTableViewCell
        let tasks = self.userTasks[indexPath.row]
        cell.groupName.text = tasks.groupname
        cell.taskLabel.text = tasks.description
        //cell.taskDueDateLabel.text =
        DispatchQueue.global().async {
            let imageURL = URL(string: tasks.group_image)
            let imageData = try! Data(contentsOf: imageURL!)
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                cell.groupProfileImage.image = image
            }
        }
       
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}












