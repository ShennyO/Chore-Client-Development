//
//  Request.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/6/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation


struct Request: Codable {
    let receiver_id: Int?
    let sender_id: Int?
    let group_id: Int?
    let chore_id: Int?
    let request_type: String
    
}
