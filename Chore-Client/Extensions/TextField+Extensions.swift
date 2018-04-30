//
//  TextField+Extensions.swift
//  Chore-Client
//
//  Created by Yveslym on 3/26/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation
import UIKit
extension UITextField{
    func deactivateAutoCorrectAndCap(){
        self.autocorrectionType = .no
       
        self.autocapitalizationType = .none
       
    }
}
