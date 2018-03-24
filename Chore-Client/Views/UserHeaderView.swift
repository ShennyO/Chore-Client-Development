//
//  UserHeaderView.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 3/23/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

protocol UserHeaderDelegate {
    func editButton()
}

class UserHeaderView: UIView {
    
    var userHeaderDelegate : UserHeaderDelegate?
    var user: User!
    var editButton = UIButton()
    var userImage = UIImage()
    var imageView = UIImageView()
    let titleLabel = UILabel()
    var darkVw = UIView()
    
    init(frame: CGRect, user: User, userImage: UIImage) {
        super.init(frame: frame)
        self.user = user
        self.userImage = userImage
        
        layoutViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutViews() {
        super.layoutSubviews()
        
        
        titleLabel.clipsToBounds = false
        titleLabel.textColor = UIColor(rgb: 0xEEF0F0)
        titleLabel.text = user.username
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Futura", size: 25)
        titleLabel.bounds.size.width = self.bounds.width / 3
        darkVw.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        self.imageView.image = userImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        editButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        editButton.addTarget(self, action: #selector(editButtonPressed), for: .touchUpInside)
        editButton.setTitle("Edit", for: .normal)
        editButton.tintColor = UIColor(rgb: 0xEEF0F0)
        self.addSubview(imageView)
        imageView.addSubview(darkVw)
        imageView.addSubview(editButton)
        imageView.addSubview(titleLabel)
       
        self.setupConstraints()
    }
    
    // CONSTRAINTS
    
    func setupConstraints() {
        
        imageView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
            
        }
        
        editButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-15)
            make.right.equalToSuperview().offset(-15)
        }
        
        darkVw.snp.makeConstraints({ (make) in
            make.right.equalToSuperview().offset(0)
            make.left.equalToSuperview().offset(0)
            make.bottom.equalToSuperview().offset(0)
            make.top.equalToSuperview().offset(0)
        })
        
        titleLabel.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-20)
        })
        
       
    }
    
    // MARK: USERHEADER DELEGATE
    
    @objc func editButtonPressed() {
        userHeaderDelegate?.editButton()
    }
}
