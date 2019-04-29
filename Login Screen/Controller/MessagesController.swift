//
//  ViewController.swift
//  Login Screen
//
//  Created by Harrison Leath on 2/20/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit
import Firebase

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class MessagesController: UITableViewController {
    
    let cellId = "cellId"
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menuIcon"), style: .plain, target: self, action: #selector(handleSettings))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "newMessageIcon"), style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(dismiss))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        setupSwipeLeft()
        setupSwipeRight()
        
        checkIfUserIsLoggedIn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        detectDarkMode()
    }
    
    func detectDarkMode() {
        let darkModeEnabled = defaults.bool(forKey: "DarkDefault")
        
        if darkModeEnabled {
            //dark mode enabled "DarkDefault"
            darkTheme(tableView: tableView)
            
        } else {
            //light mode enabled "LightDefault"
            lightTheme(tableView: tableView)
        }
    }
    
    func setupSwipeLeft() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeLeft(_:)))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        view.isUserInteractionEnabled = true
    }
    
    func setupSwipeRight() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.handleSwipeRight(_:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        view.isUserInteractionEnabled = true
    }
    
    @objc func handleSwipeLeft(_ sender: UITapGestureRecognizer) {
        handleNewMessage()
        print("left swipe activated")
    }
    
    @objc func handleSwipeRight(_ sender: UITapGestureRecognizer) {
        handleSettings()
        print("right swipe activated")
    }
    
    @objc func handleSettings() {
        let settingsController = SettingsController()
        let navController = UINavigationController(rootViewController: settingsController)
        present(navController, animated: true, completion: nil)
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (DataSnapshot) in
                
                let messageId = DataSnapshot.key
                let messagesReference = Database.database().reference().child("messages").child(messageId)
                
                messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    if let dictionary = snapshot.value as? [String: AnyObject] {
                        let message = Message()
                        message.text = dictionary["text"] as? String 
                        message.senderId = dictionary["sender_Id"] as? String ?? "Sender not found"
                        message.toId = dictionary["to_Id"] as? String ?? "Reciever not found"
                        message.timestamp = dictionary["timestamp"] as? NSNumber
                        
                        if let chatPartnerId = message.chatPartnerId() {
                            self.messagesDictionary[chatPartnerId] = message                            
                        }
                        self.attemptReloadofTable()
                    }
                }, withCancel: nil)
        
            }, withCancel: { (nil) in
                
            })
            
        }, withCancel: nil)
    }
    
    private func attemptReloadofTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    @objc func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return message1.timestamp?.int32Value > message2.timestamp?.int32Value
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        //        print("table reloaded")
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let darkModeEnabled = defaults.bool(forKey: "DarkDefault")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        if darkModeEnabled {
            cell.backgroundColor = Colors.lighterDarkBlue
            cell.textLabel?.textColor = UIColor.white
            cell.timeLabel.textColor = UIColor.white
            cell.detailTextLabel?.textColor = UIColor.white
            
        } else {
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = UIColor.black
            cell.timeLabel.textColor = UIColor.black
            cell.detailTextLabel?.textColor = UIColor.black
        }
        
        let message = messages[indexPath.row]
        cell.message = message
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (DataSnapshot) in
            
            guard let dictionary = DataSnapshot.value as? [String: AnyObject]
                else {
                    return
            }
            
            let user = myUser()
            user.uid = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        checkIfUserIsLoggedIn()
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
//        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)

//        let darkModeEnabled = defaults.bool(forKey: "DarkDefault")
//
//        if darkModeEnabled {
//            //dark mode enabled "DarkDefault"
//            navController.navigationBar.barTintColor = Colors.lighterDarkBlue
//
//        } else {
//            //light mode enabled "LightDefault"
//            navController.navigationBar.barTintColor = UIColor.white
//        }
//
        
//        let settingsController = SettingsController()
//        let navController = UINavigationController(rootViewController: settingsController)
//        present(navController, animated: true, completion: nil)
//
//        navigationController?.pushViewController(newMessageController, animated: true)

        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        //user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
            
        } else {
            observeUserMessages()
            setupNavBarWithUser()
        }
    }
    
    func setupNavBarWithUser() {
//        commented section to improve speed
//        messages.removeAll()
//        messagesDictionary.removeAll()
//        tableView.reloadData()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (DataSnapshot) in
            
            if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                let name = dictionary["name"] as? String ?? "Name not found"
                let profileImageUrl = dictionary["profileImageUrl"] as? String ?? "Name not found"
                
                let titleView = UIView()
                titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
                
                let containerView = UIView()
                containerView.translatesAutoresizingMaskIntoConstraints = false
                
                let nameLabel = UILabel()
                
                let darkModeEnabled = self.defaults.bool(forKey: "DarkDefault")
                
                if darkModeEnabled {
                    //print("dark mode is enabled")
                    nameLabel.textColor = UIColor.white
                    
                } else {
                    //print("light mode is enabled")
                    nameLabel.textColor = UIColor.black

                }
                
                nameLabel.text = name
                nameLabel.translatesAutoresizingMaskIntoConstraints = false
                
                let profileImageView = UIImageView()
                profileImageView.translatesAutoresizingMaskIntoConstraints = false
                profileImageView.contentMode = .scaleAspectFill
                profileImageView.layer.cornerRadius = 17
                profileImageView.clipsToBounds = true
                profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                
                titleView.addSubview(containerView)
                containerView.addSubview(profileImageView)
                containerView.addSubview(nameLabel)
                
                //contraints for navBar
                profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
                profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
                profileImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
                profileImageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
                
                nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
                nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
                nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
                nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
                
                containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
                containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
                
                self.navigationItem.titleView = titleView
            }
        }
    }
    
    @objc func showChatControllerForUser(user: myUser) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch _ {
            print("Logout Error!")
            
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
    }
}
