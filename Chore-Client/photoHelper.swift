//
//  photoHelper.swift
//  Chore-Client
//
//  Created by Sunny Ouyang on 2/26/18.
//  Copyright © 2018 Sunny Ouyang. All rights reserved.
//

import Foundation
import UIKit


class PhotoHelper: NSObject {
    
    var completionHandler: ((UIImage) -> Void)?
    
    
    func presentImagePickerController(with sourceType: UIImagePickerControllerSourceType, from viewController: UIViewController) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = sourceType
        imagePickerController.delegate = self
        
        viewController.present(imagePickerController, animated: true)
    }
    
    func presentActionSheet(from viewController: UIViewController) {
        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture?", preferredStyle: .actionSheet)
        
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            
            let capturePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { action in
                self.presentImagePickerController(with: .camera, from: viewController)
            })
            
            
            alertController.addAction(capturePhotoAction)
        }
        
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let uploadAction = UIAlertAction(title: "Upload from Library", style: .default, handler: { action in
                self.presentImagePickerController(with: .photoLibrary, from: viewController)
            })
            
            alertController.addAction(uploadAction)
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        
        viewController.present(alertController, animated: true)
    }
    
    
    
}

extension PhotoHelper: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            completionHandler?(selectedImage)
        }
        
        
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    
}
