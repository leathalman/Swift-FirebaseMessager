//
//  Message.swift
//  Login Screen
//
//  Created by Harrison Leath on 6/2/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    @objc var senderId: String?
    @objc var toId: String?
    @objc var text: String?
    @objc var timestamp: NSNumber?
    
    @objc var imageUrl: String?
    @objc var imageHeight: NSNumber?
    @objc var imageWidth: NSNumber?
    
    func chatPartnerId() -> String? {
        if senderId == Auth.auth().currentUser?.uid {
            return toId
        } else {
            return senderId
        }
    }
}
