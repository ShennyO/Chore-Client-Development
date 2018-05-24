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
         self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        reminderTableView.dataSource = self
        reminderTableView.delegate = self
        // Do any additional setup after loading the view from its nib.
    }
    override func viewDidAppear(_ animated: Bool) {
        
        DispatchQueue.global().async {
            self.retrieveTasks(completionHandler: { (tasks) in
                DispatchQueue.main.async {
                    var task = tasks
                    task.sort{return self.dueDay($0.due_date) < self.dueDay($1.due_date)}
                    self.self.userTasks = task.filter{$0.pending == false}
                }
            })
        }
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
    
    // function to return how many date left before due date
    func dueDay(_ dueDate: String) -> Int{
        let date = dueDate.toDate()
        let dayLeft = Date.dayLeft(day: date!).day
        return dayLeft!
    }
    // function to animate the view
    func animateView(_ viewToanimate: UIView, _ duration: Double, _ alpha: CGFloat){
        let fadeAnimatrion = {
            viewToanimate.alpha = alpha
        }
       UIView.animate(withDuration: duration, delay: 0, options: [.repeat, .autoreverse], animations: fadeAnimatrion, completion: nil)
       
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
        cell.groupName.text = tasks.name
        cell.taskLabel.text = tasks.groupname
        cell.taskDueDateLabel.text = "Due:"
        let numberOfDayLeft = self.dueDay(tasks.due_date)
        
        switch numberOfDayLeft > 0{
        
        // make animatable view green
        case true: cell.animatedView.backgroundColor = UIColor.init(red: 24/225, green: 118/225, blue: 80/225, alpha: 1)
            self.animateView(cell.animatedView, 3, 0.5)
            
        // make animatable view blue
        case false: switch numberOfDayLeft == 0{
        case true: cell.animatedView.backgroundColor = UIColor.init(red: 44/225, green: 87/225, blue: 80/132, alpha: 1)
            
             self.animateView(cell.animatedView, 2, 0.2)
            
        // make animatable view red
        case false: cell.animatedView.backgroundColor = .red
             self.animateView(cell.animatedView, 0.3, 0.1)
            }
        }
        
        cell.numberOfDayLeft.text = "\(self.dueDay(tasks.due_date))"
        cell.animatedView.layer.masksToBounds = true
        cell.animatedView.layer.cornerRadius = cell.animatedView.frame.width / 2
        
        
        
        
        if tasks.group_image != "/image_files/original/missing.png"{
        DispatchQueue.global().async {
            let imageURL = URL(string: tasks.group_image)
            let imageData = try! Data(contentsOf: imageURL!)
            let image = UIImage(data: imageData)
            DispatchQueue.main.async {
                cell.groupProfileImage.image = image
            }
        }  
    }
        else{
            let image = UIImage(named: "groups")
            cell.groupProfileImage.image = image!
        }
        
        //self.animateView(cell.animatedView)
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // cresize the widget based on the number of row in the table view
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        if activeDisplayMode == .compact {
            self.preferredContentSize = maxSize
        } else if activeDisplayMode == .expanded {
            var tableHeight = CGFloat(70.0 * Double(self.userTasks.count))
            
            switch tableHeight > 440{
            case true: tableHeight = 440
            case false: break
            }
            self.preferredContentSize = CGSize(width: maxSize.width, height: tableHeight)
        }
    }
}












