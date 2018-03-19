//
//  HeaderHelper.swift
//  Chore-Client
//
//  Created by Yveslym on 3/18/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

struct HeaderViewHelper
{
    static  func createTitleHeaderView(title: String, fontSize: CGFloat, frame: CGRect) -> UIView
    {
        let vw = UIView(frame:frame)
        vw.backgroundColor = UIColor(red:0.99, green:0.69, blue:0.19, alpha:1.0)
        let titleLabel = UILabel()
        titleLabel.clipsToBounds = false
        titleLabel.textColor = .white
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Futura", size: fontSize)
        titleLabel.bounds.size.width = vw.bounds.width / 3
        
        
        vw.addSubview(titleLabel)
        // Constraints
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            //            make.centerX.equalTo(vw)
            make.centerY.equalTo(vw)
        }
        
//        titleLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
//
//        }
        
        
        return vw
    }
}
