//
//  Notification.swift
//  Chore-Client
//
//  Created by Yveslym on 3/18/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation
import UserNotifications
import KeychainSwift

struct Notification{
    // - MARK: Explanation
    //Used to create local notifications in the app delegate
    static func getUserChores(completion: @escaping ([Chore]?)->()) {
        Network.instance.fetch(route: .getUserChores) { (data, resp) in
            let jsonChores = try? JSONDecoder().decode([Chore].self, from: data)
            if let chores = jsonChores {
                
                completion(chores)
            }
        }
    }
    
    static func checkDueDate(completion:@escaping([Chore]?)-> ()){
        let token: String? = KeychainSwift().get("token")
        if token != nil{
        Notification.getUserChores { (chores) in
            
            DispatchQueue.main.async {
                if chores != nil{
                    let dueChores = chores?.filter({ (chore) -> Bool in
                        Date.dayLeft(day: chore.due_date.toDate()!).day == 0
                    })
                    if dueChores != nil{
                    completion(dueChores)
                    }
                }
            }
        }
    
    }
        else{
            completion(nil)
        }
}
    static func generateNotification(){
        
       let center = UNUserNotificationCenter.current()
        
        center.removeAllPendingNotificationRequests()
        
        Notification.checkDueDate {(chores) in
            guard let dueChores = chores else {return}
            let zero: Int = 0
            if dueChores.count > zero {
            // trigger
            var dateComponents = DateComponents()
            
            dateComponents.hour = 10
            
            dateComponents.minute = 30
                
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // content
            
            let content = UNMutableNotificationContent()
            content.title = "Tasks Due"
                
                content.body = ( dueChores.count == 1) ? "Hi, \(dueChores.count) task is due today" : "Hi, \(dueChores.count) tasks are due today"
            content.sound = UNNotificationSound.default()
            content.badge =  chores?.count as NSNumber?
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
            }
        }
    }
}












