//
//  UIViewController+Extensions.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 3/21/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    //Purpose: HIde NavigationBar
    func hideNavigation(tint: UIColor) {
//        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
//        navigationController?.navigationBar.barStyle = .default
//        navigationController?.navigationBar.barTintColor = UIColor.clear
        navigationController?.navigationBar.tintColor = tint
        navigationController?.navigationBar.isTranslucent = true
    }
    
    
    
    func showNavigation() {
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.shadowImage = nil
        
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black
    }
}
