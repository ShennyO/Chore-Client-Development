//
//  Chore.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/6/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation

struct Chore: Codable {
    let name: String
    let id: Int
    let user_id: String
    let due_date: String
    let penalty: String
    let reward: String
    let assigned: Bool
    let completed: Bool
    let group_id: String
}
