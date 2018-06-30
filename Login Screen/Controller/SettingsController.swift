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
    
    var DarkisOn = Bool()
    let defaults = UserDefaults.standard
    
    let cellId = "settingsCell"
    
    override func viewDidLoad() {
        navigationItem.title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        self.tableView.backgroundColor = UIColor.white
        
        setupNotificationsForDarkTheme()
        setupDetectButtonPosition()
        darkModeSwitched(darkModeSwitch)
    }
    
    let darkModeSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.addTarget(self, action: #selector(darkModeSwitched(_:)), for: .touchUpInside)
        
        return toggle
    }()
    
    private func setupDetectButtonPosition() {
        let darkModeEnabled = defaults.bool(forKey: "DarkDefault")
        
        if darkModeEnabled {
            darkModeSwitch.setOn(true, animated: true)
        } else {
            darkModeSwitch.setOn(false, animated: true)
        }
    }
    
    func setupNotificationsForDarkTheme() {
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        // Write your dark mode code here
        tableView.backgroundColor = Colors.lighterDarkBlue
        
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        // Write your non-dark mode code here
        tableView.backgroundColor = Colors.white

    }
    
    @objc func darkModeSwitched(_ sender: Any) {
        
        if darkModeSwitch.isOn == true {
            
            //enable dark mode
            print("switched to dark")
            
            DarkisOn = true
            
            defaults.set(true, forKey: "DarkDefault")
            defaults.set(false, forKey: "LightDefault")
            
            // Post the notification to let all current view controllers that the app has changed to dark mode, and they should theme themselves to reflect this change.
            NotificationCenter.default.post(name: .darkModeEnabled, object: nil)
            
        } else {
            
            //enable light mode
            print("switched to light")
            
            DarkisOn = false
            
            defaults.set(false, forKey: "DarkDefault")
            defaults.set(true, forKey: "LightDefault")

            // Post the notification to let all current view controllers that the app has changed to non-dark mode, and they should theme themselves to reflect this change.
            NotificationCenter.default.post(name: .darkModeDisabled, object: nil)
        }
        
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    let Items = ["This will be populated with user data later","Test 1","Test 2"]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.Items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        cell.textLabel?.text = self.Items[indexPath.row]
        
        cell.addSubview(darkModeSwitch)
        
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

