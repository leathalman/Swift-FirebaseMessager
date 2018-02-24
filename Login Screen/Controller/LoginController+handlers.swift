//
//  LoginController+handlers.swift
//  Login Screen
//
//  Created by Harrison Leath on 2/23/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func handleSelectProfileImageView(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
//        var selectedImageFromPicker: UIImage?
//
//        if let editedImage = info["UIImagePickerControllerEditedImage"] {
//            selectedImageFromPicker = editedImage
//
//        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] {
//
//            selectedImageFromPicker = originalImage
//            
//
//    }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("cancelled picker")
        dismiss(animated: true, completion: nil)
    }
    
}
