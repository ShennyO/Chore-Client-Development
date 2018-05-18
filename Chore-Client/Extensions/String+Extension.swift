//
//  String+Extension.swift
//  Chore-Client
//
//  Created by Yveslym on 5/18/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation

extension String {
    
    var isValidEmail: Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
       
        return emailPredicate.evaluate(with: self)
       
    }
    
}
