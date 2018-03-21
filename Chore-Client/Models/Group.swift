//
//  Group.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/6/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation

struct Groups: Codable {
    let groups: [Group]
}

struct Group: Codable {
    let name: String
    let members: [User]!
    var chores: [Chore]!
    let id: Int
    let image_file: String!
}

extension Group{
    func userCompletedTasks(userId: Int) -> [Chore]{
//        var progressChores: [Chore] = []
//        for chore in chores {
//            if chore.user_id == userId && chore.completed == true {
//                progressChores.append(chore)
//            }
//        }
//        return progressChores
        return self.chores.filter{$0.user_id == userId && $0.completed == true}
    }
    
    func userInProgressTasks(userId: Int) -> [Chore]{
//        var progressChores: [Chore] = []
//        for chore in chores {
//            if chore.user_id == userId && chore.completed == false {
//                progressChores.append(chore)
//            }
//        }
//        return progressChores
        return self.chores.filter{$0.user_id == userId && $0.completed == false}
    }
}
