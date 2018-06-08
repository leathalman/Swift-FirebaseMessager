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
    
    var senderId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?
    
    func chatPartnerId() -> String? {
        if senderId == Auth.auth().currentUser?.uid {
            return toId
        } else {
            return senderId
        }
    }
}
