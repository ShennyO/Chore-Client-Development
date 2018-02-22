//
//  RequestEncodeObject.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/22/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation

struct RequestEncodable: Codable {
    let receiver_id: Int
    let group_id: Int
    let request_type: Int
    let group_name: String
    
}
