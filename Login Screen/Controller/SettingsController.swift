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
    
    let cellId = "settingsCell"
    
    override func viewDidLoad() {
        navigationItem.title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        self.tableView.backgroundColor = UIColor.white
        
    }
    
    let Items = ["This will be populated with user data later","Test 1","Test 2"]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = self.Items[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
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
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
}

