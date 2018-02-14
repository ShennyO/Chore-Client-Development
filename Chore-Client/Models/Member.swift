//
//  Member.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/13/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation

struct Member: Codable {
    var first_name: String
    var last_name: String
    var email: String
    var username: String
    var id: Int
}
