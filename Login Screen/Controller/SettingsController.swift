//
//  TempSetting.swift
//  Login Screen
//
//  Created by Harrison Leath on 6/29/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit
import Firebase

class SettingsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var DarkisOn = Bool()
    let defaults = UserDefaults.standard
    
    private var tableView: UITableView!
    
    private let sections: NSArray = ["Account", "Appearance"]
    private let general: NSArray = ["Profile Image", "Setting 2", "Setting 3", "Setting 4", "Setting 5"]
    private let other: NSArray = ["Dark Mode"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Settings"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        view.backgroundColor = UIColor.white
        
        tableView = UITableView(frame: CGRect(x: 0, y: barHeight+navigationBarHeight, width: displayWidth, height: displayHeight - (barHeight+navigationBarHeight)))
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.register(SettingsSwitchCell.self, forCellReuseIdentifier: "SettingsSwitchCell")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.view.addSubview(tableView)
        
        setupNotificationsForDarkTheme()
        detectDarkMode()
    }
    
    func detectDarkMode() {
        let darkModeEnabled = defaults.bool(forKey: "DarkDefault")
        
        if darkModeEnabled {
            darkTheme(tableView: tableView)
        } else {
            lightTheme(tableView: tableView)
        }
    }
    
    func setupNotificationsForDarkTheme() {
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        // Write your dark mode code here
        print("dark")
        
        darkTheme(tableView: tableView)
        detectDarkMode()
        
        tableView.reloadData()
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        // Write your non-dark mode code here
        print("light")
        
        lightTheme(tableView: tableView)
        detectDarkMode()
        
        tableView.reloadData()
    }
    
    @objc func darkModeSwitched(_ sender: UISwitch) {
        
        if sender.isOn == true {
            
            DarkisOn = true
            defaults.set(true, forKey: "DarkDefault")
            defaults.set(false, forKey: "LightDefault")
            
            NotificationCenter.default.post(name: .darkModeEnabled, object: nil)
                        
        } else {
            
            DarkisOn = false
            defaults.set(false, forKey: "DarkDefault")
            defaults.set(true, forKey: "LightDefault")
            
            NotificationCenter.default.post(name: .darkModeDisabled, object: nil)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("Num: \(indexPath.row)")
//        if indexPath.section == 0 {
//            print("Value: \(general[indexPath.row])")
//        } else if indexPath.section == 1 {
//            print("Value: \(other[indexPath.row])")
//        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return general.count
        } else if section == 1 {
            return other.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let darkModeEnabled = defaults.bool(forKey: "DarkDefault")
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
            
            cell.labelText.text = "\(general[indexPath.row])"
            
            if darkModeEnabled {
                cell.backgroundColor = Colors.lighterDarkBlue
                cell.labelText.textColor = UIColor.white
                
            } else {
                cell.backgroundColor = UIColor.white
                cell.labelText.textColor = UIColor.black
            }
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchCell", for: indexPath) as! SettingsSwitchCell
            
            cell.labelText.text = "\(other[indexPath.row])"
            cell.selectionStyle =  UITableViewCell.SelectionStyle.none
            cell.switchButton.addTarget(self, action: #selector(darkModeSwitched(_:)), for: .touchUpInside)
            
            if darkModeEnabled {
                cell.switchButton.setOn(true, animated: true)
                cell.backgroundColor = Colors.lighterDarkBlue
                cell.labelText.textColor = UIColor.white
                
            } else {
                cell.switchButton.setOn(false, animated: true)
                cell.backgroundColor = UIColor.white
                cell.labelText.textColor = UIColor.black
            }
            
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
            
            if darkModeEnabled {
                cell.backgroundColor = Colors.lighterDarkBlue
                cell.labelText.textColor = UIColor.white
                
            } else {
                cell.backgroundColor = UIColor.white
                cell.labelText.textColor = UIColor.black
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        
        let darkModeEnabled = defaults.bool(forKey: "DarkDefault")
        
        if darkModeEnabled {
            view.tintColor = Colors.gray
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.white
        } else {
            //light mode enabled "LightDefault"
            view.tintColor = Colors.offWhite
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.textColor = UIColor.black
        }
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
        let messagesController = MessagesController()
        messagesController.detectDarkMode()
//        messagesController.handleReloadTable()
        dismiss(animated: true, completion: nil)
    }
    
    func changeProfileImage() {
        
        print("profile image prompted")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
