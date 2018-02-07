//
//  Group.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/6/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation

struct Group: Codable {
    let name: String
    let users: [User]
    let chores: [Chore]?
    let id: Int
    
}
