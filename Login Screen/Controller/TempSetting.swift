//
//  TempSetting.swift
//  Login Screen
//
//  Created by Harrison Leath on 6/29/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit


class TempSetting: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var myTableView: UITableView!
    
    private let sections: NSArray = ["General", "Other"]
    private let general: NSArray = ["apple", "orange", "banana", "strawberry", "lemon"]
    private let other: NSArray = ["carrots", "avocado", "potato", "onion"]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // get width and height of View
        let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let navigationBarHeight: CGFloat = self.navigationController!.navigationBar.frame.size.height
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        
        myTableView = UITableView(frame: CGRect(x: 0, y: barHeight+navigationBarHeight, width: displayWidth, height: displayHeight - (barHeight+navigationBarHeight)))
        myTableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        
        myTableView.dataSource = self
        myTableView.delegate = self
        
        self.view.addSubview(myTableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int{
        return sections.count
    }
    
    
    
    // return the title of sections
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section] as? String
    }
    
    
    // called when the cell is selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("Num: \(indexPath.row)")
        if indexPath.section == 0 {
            print("Value: \(general[indexPath.row])")
        } else if indexPath.section == 1 {
            print("Value: \(other[indexPath.row])")
        }
    }
    
    // return the number of cells each section.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return general.count
        } else if section == 1 {
            return other.count
        } else {
            return 0
        }
    }
    
    // return cells
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        
        if indexPath.section == 0 {
            
            cell.labelText.text = "\(general[indexPath.row])"
            
            
        } else if indexPath.section == 1 {
            
            cell.labelText.text = "\(other[indexPath.row])"
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}
