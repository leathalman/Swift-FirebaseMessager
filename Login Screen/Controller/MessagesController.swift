//
//  ViewController.swift
//  Login Screen
//
//  Created by Harrison Leath on 2/20/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "newMessageIcon"), style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismiss))
        
        checkIfUserIsLoggedIn()
        
        observeMessages()
    }
    
    var messages = [Message]()
    
    func observeMessages() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message()
                message.text = dictionary["text"] as? String ?? "Text not found"
                message.senderId = dictionary["sender_Id"] as? String ?? "Sender not found"
                message.toId = dictionary["to_Id"] as? String ?? "Reciever not found"
                message.timestamp = dictionary["timestamp"] as? String ?? "Text not found"
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
            
        }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell (style: .subtitle, reuseIdentifier: "cellId")
        
        let message = messages[indexPath.row]
        cell.textLabel?.text = message.toId
        cell.detailTextLabel?.text = message.text
        
        return cell
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        checkIfUserIsLoggedIn()
    }
    
    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        //user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
            
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with:  { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.navigationItem.title = dictionary["name"] as? String
                
                //                let navButton =  UIButton(type: .custom)
                //                navButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
                //                //used for showing area of box
                //                navButton.backgroundColor = UIColor.clear
                //                navButton.setTitleColor(UIColor.black, for: .normal)
                //                navButton.setTitle(dictionary["name"] as? String, for: .normal)
                //                navButton.addTarget(self, action: #selector(self.showChatController), for: .touchUpInside)
                //                self.navigationItem.titleView = navButton
                
            }
        }, withCancel: nil)
        
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
    }
    
}
