//
//  User.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/6/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation

struct User: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let id: Int
    let chores: [Chore]
    let groups: [Group]
}
