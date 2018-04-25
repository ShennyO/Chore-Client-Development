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
import Kingfisher



//MARK: PURPOSE
// The headerview that's used in the GroupDetail User page
struct HeaderViewHelper
{
    //In Progress Title Header
    //TODO: create enum so we only need one titleHeaderView
    static  func createTasksTitleHeaderView(title: String, fontSize: CGFloat, frame: CGRect, color: UIColor) -> UIView
    {
        let vw = UIView(frame:frame)
        vw.backgroundColor = color
        let titleLabel = UILabel()
        titleLabel.clipsToBounds = false
        titleLabel.textColor = UIColor.black
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "System", size: fontSize)
        titleLabel.bounds.size.width = vw.bounds.width / 3
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        
        
        vw.addSubview(titleLabel)
        // Constraints
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview().offset(-13)
        }
        
        
        return vw
    }
    //for Completed Title Header
    static  func createTitleHeaderView(title: String, fontSize: CGFloat, frame: CGRect, color: UIColor) -> UIView
    {
        let vw = UIView(frame:frame)
        vw.backgroundColor = color
        let titleLabel = UILabel()
        titleLabel.clipsToBounds = false
        titleLabel.textColor = UIColor.black
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "System", size: fontSize)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.bounds.size.width = vw.bounds.width / 3
        
        
        vw.addSubview(titleLabel)
        // Constraints
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalTo(vw)
        }
        
        
        return vw
    }
    
    //For the imageView in the tableviewheader
    static  func createTitleImageHeaderView(title: String, fontSize: CGFloat, frame: CGRect, imageURL: String, vw: UIViewController? = nil) -> UIView
    {
        
        
        
        let myCustomView = UIImageView()
        let vw = UIView(frame:frame)
        let darkVw = UIView(frame:frame)
        let titleLabel = UILabel()
        titleLabel.clipsToBounds = false
        titleLabel.textColor = UIColor.white
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont(name: "Futura", size: fontSize)
        titleLabel.bounds.size.width = vw.bounds.width / 3
        darkVw.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        vw.backgroundColor = UIColor.white
        
        
        if imageURL != "/image_files/original/missing.png" {
            let imgURL = URL(string: imageURL)
            KingfisherManager.shared.retrieveImage(with: imgURL!, options: nil, progressBlock: nil) { (image, _, _, _) in
                DispatchQueue.main.async {
                   myCustomView.image = image
                
                vw.addSubview(myCustomView)
                vw.addSubview(darkVw)
                vw.addSubview(titleLabel)
                
                darkVw.snp.makeConstraints({ (make) in
                    make.right.equalToSuperview()
                    make.left.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.top.equalToSuperview()
                })
                    
                myCustomView.snp.makeConstraints { (make) in
//                make.height.equalTo(100)
//                make.width.equalTo(100)
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.top.equalToSuperview()
               
                    }
                    
                    titleLabel.snp.makeConstraints({ (make) in
                        make.left.equalToSuperview().offset(15)
                        make.bottom.equalToSuperview().offset(-20)
                    })
                    
                myCustomView.contentMode = UIViewContentMode.scaleAspectFill
                    myCustomView.clipsToBounds = true
                }
            }
        } else {
            
            myCustomView.image = UIImage(named: "AccountIcon")
            vw.addSubview(myCustomView)
            vw.addSubview(darkVw)
            vw.addSubview(titleLabel)
            myCustomView.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(15)
                //            make.centerX.equalTo(vw)
                make.centerY.equalTo(vw)
        }
            darkVw.snp.makeConstraints({ (make) in
                make.right.equalToSuperview()
                make.left.equalToSuperview()
                make.bottom.equalToSuperview()
                make.top.equalToSuperview()
            })
            
            myCustomView.snp.makeConstraints { (make) in
                
                make.right.equalToSuperview()
                make.bottom.equalToSuperview()
                make.left.equalToSuperview()
                make.top.equalToSuperview()
                
            }
            titleLabel.snp.makeConstraints({ (make) in
                make.left.equalToSuperview().offset(15)
                make.bottom.equalToSuperview().offset(-20)
            })
            
            myCustomView.contentMode = UIViewContentMode.scaleAspectFill
            myCustomView.clipsToBounds = true
        }
       return vw
        
        // Constraints
        
    }

}
