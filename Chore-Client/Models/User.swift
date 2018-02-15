//
//  User.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/6/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation
import UIKit

class User: Codable {
    var first_name: String
    var last_name: String
    var email: String
    var username: String
    var id: Int
    var authentication_token: String!
    var group: Group!

    
    init(firstName: String, lastName: String, email: String, username: String, id: Int, authentication_token: String) {
        self.first_name = firstName
        self.last_name = lastName
        self.email = email
        self.username = username
        self.id = id
        self.authentication_token = authentication_token
    }
    
    
}

