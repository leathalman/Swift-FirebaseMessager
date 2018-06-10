//
//  SettingsController.swift
//  Login Screen
//
//  Created by Harrison Leath on 6/9/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit
import Firebase

class SettingsController: UITableViewController {
    
    override func viewDidLoad() {
        navigationItem.title = "Settings"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch _ {
            print("Logout Error!")
            
        }
        
        let loginController = LoginController()
        dismiss(animated: true, completion: nil)
        present(loginController, animated: true, completion: nil)
    }
}

