//
//  ChoreRecordCollectionViewCell.swift
//  Chore-Client
//
//  Created by Yveslym on 3/25/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import UIKit
import KeychainSwift
import Alamofire
import Kingfisher

class ChoreRecordCollectionViewCell: UICollectionViewCell, UserHeaderDelegate, ChoreCompletionDelegate {
    @IBOutlet weak var choreRecordTableView: UITableView!
    let photoHelper = PhotoHelper()
    var imageData: NSData?
    var userChores: [Chore]? = []
    var currentUser: User!
    var userImage = UIImage()
    var tableViewHeader: UserHeaderView!
    var choreRecordTableViewHeaderTitle: String!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        ViewControllerUtils().showActivityIndicator(uiView: self)
        
        self.choreRecordTableView.delegate = self
        self.choreRecordTableView.dataSource = self
        
        
        if currentUser != nil && self.userChores != nil{
            
            
                DispatchQueue.main.async {
                    self.choreRecordTableView.reloadData()
                   
                   // ViewControllerUtils().activityIndicator.alpha =
                }
        }
    }
    func editButton() {
        photoHelper.presentActionSheet(from: (self.viewController()?.parent)!)
    }
}


extension ChoreRecordCollectionViewCell: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userChores!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.choreRecordTableView.dequeueReusableCell(withIdentifier: "userChoreCell") as! UserChoreTableViewCell
        
        cell.choreNameLabel.text = self.userChores![indexPath.row].name
        cell.choreDescriptionLabel.text = self.userChores![indexPath.row].description
        let groupImageURL = URL(string: self.userChores![indexPath.row].group_image)
        cell.choreGroupImage.kf.setImage(with: groupImageURL, placeholder: UIImage(named: "AccountIcon"), options: nil, progressBlock: nil, completionHandler: nil)
        cell.choreGroupImage.contentMode = .scaleAspectFill
        cell.choreGroupImage.clipsToBounds = true
        cell.selectionStyle = .none
        if self.userChores![indexPath.row].pending {
            cell.completeButton.setTitle("Pending", for: .normal)
            cell.completeButton.backgroundColor = UIColor(rgb: 0xE0D400)
            cell.completeButton.isUserInteractionEnabled = false
            
        } else if self.userChores![indexPath.row].pending == false {
            cell.completeButton.setTitle("Complete", for: .normal)
            cell.completeButton.backgroundColor = UIColor(rgb: 0x55C529)
            cell.completeButton.isUserInteractionEnabled = true
        }
        cell.completeButton.configureButton()
        cell.choreDateLabel.text = self.userChores![indexPath.row].getDate()
        cell.delegate = self
        cell.index = indexPath
         ViewControllerUtils().hideActivityIndicator(uiView: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HeaderViewHelper.createTitleHeaderView(title: self.choreRecordTableViewHeaderTitle, fontSize: 25, frame: CGRect(x: 0, y: 0, width: self.choreRecordTableView.frame.width, height: 50), color: UIColor.white)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
}

extension ChoreRecordCollectionViewCell{
    
    func createChoreCompletionRequests(index: IndexPath) {
        Network.instance.fetch(route: .sendChoreCompletionRequest(chore_id: self.userChores![index.row].id)) { (data, resp) in
            print("Requests created")
            // self.getUserChores {
            DispatchQueue.main.async {
                self.choreRecordTableView.reloadData()
            }
            //}
        }
    }
}

