//
//  Response.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/17/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation

struct Response: Codable {
    var response: Bool
    var group_id: Int
    
    init(response: Bool, group_id: Int) {
        self.response = response
        self.group_id = group_id
    }
}
