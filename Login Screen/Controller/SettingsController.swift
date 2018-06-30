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
    
    private let sections: NSArray = ["General", "Appearance"]
    private let general: NSArray = ["Account", "orange", "banana", "strawberry", "lemon"]
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
    
    override func viewDidAppear(_ animated: Bool) {
        detectDarkMode()
    }
    
    func detectDarkMode() {
        let darkModeEnabled = defaults.bool(forKey: "DarkDefault")
        
        if darkModeEnabled {
            //dark mode enabled "DarkDefault"
            
        } else {
            //light mode enabled "LightDefault"
            
        }
        
    }
    
    func setupNotificationsForDarkTheme() {
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeEnabled(_:)), name: .darkModeEnabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(darkModeDisabled(_:)), name: .darkModeDisabled, object: nil)
    }
    
    @objc private func darkModeEnabled(_ notification: Notification) {
        // Write your dark mode code here
        print("dark - on")
        tableView.backgroundColor = UIColor.black
    }
    
    @objc private func darkModeDisabled(_ notification: Notification) {
        // Write your non-dark mode code here
        print("light - off")
        tableView.backgroundColor = UIColor.white
    }
    
    @objc func darkModeSwitched(_ sender: UISwitch) {

        if sender.isOn == true {

            print("dark enabled")

            DarkisOn = true

            defaults.set(true, forKey: "DarkDefault")
            defaults.set(false, forKey: "LightDefault")

            NotificationCenter.default.post(name: .darkModeEnabled, object: nil)

        } else {

            print("light enabled")

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
                
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
            
            cell.labelText.text = "\(general[indexPath.row])"
            
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSwitchCell", for: indexPath) as! SettingsSwitchCell

            cell.labelText.text = "\(other[indexPath.row])"
            cell.selectionStyle =  UITableViewCell.SelectionStyle.none
            cell.switchButton.addTarget(self, action: #selector(darkModeSwitched(_:)), for: .touchUpInside)
            
            let darkModeEnabled = defaults.bool(forKey: "DarkDefault")
            
            if darkModeEnabled {
                cell.switchButton.setOn(true, animated: true)
            } else {
                cell.switchButton.setOn(false, animated: true)
            }
                        
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell

            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
