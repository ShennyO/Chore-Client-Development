//
//  Chore.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/6/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation

struct Chore: Codable {
    let id: Int
    let name: String
    let penalty: String
    let due_date: String
    let reward: String
    let completed: Bool
    let assigned: Bool
    let user_id: Int!
    
}
