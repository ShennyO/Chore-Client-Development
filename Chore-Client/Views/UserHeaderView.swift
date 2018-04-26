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

// MARK: Explanation
//This file is to create custom Header Views for the User Profile Screen

class UserHeaderView: UIView {
    //This Delegate is used to establish the connection between the headerview and the UserViewController to handle the edit button response
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
    
    //LayoutViews is used to add any extra views you want on top of the current UIVIew
    func layoutViews() {
        super.layoutSubviews()
        
        // MARK: TITLE LABEL
        titleLabel.clipsToBounds = false
        titleLabel.textColor = UIColor(rgb: 0xEEF0F0)
        titleLabel.text = user.username
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Futura", size: 25)
        titleLabel.bounds.size.width = self.bounds.width / 3
        
        // - MARK: Darkened View
        
        darkVw.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        // - MARK: ImageView
        
        self.imageView.image = userImage
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        
        // - MARK: EDIT BUTTON
        
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
    
    // - MARK: CONSTRAINTS
    
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
