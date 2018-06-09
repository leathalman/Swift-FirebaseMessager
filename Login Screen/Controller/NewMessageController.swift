//
//  NewMessageController.swift
//  Login Screen
//
//  Created by Harrison Leath on 2/21/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {
    
    let cellId = "cellId"
    var users = [myUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        fetchUsers()
        
    }
    
    func fetchUsers() {
        let rootRef = Database.database().reference()
        let query = rootRef.child("users").queryOrdered(byChild: "name")
        query.observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if let value = child.value as? NSDictionary {
                    let user = myUser()
                    let name = value["name"] as? String ?? "Name not found"
                    let email = value["email"] as? String ?? "Email not found"
                    let profileImageUrl = value["profileImageUrl"] as? String ?? "ImageUrl not found"
                    let uid = child.key //the uid of each user
                    user.name = name
                    user.email = email
                    user.profileImageUrl = profileImageUrl
                    user.uid = uid
                    print("Uid key = \(user.uid ?? "uid not fetched")")
                    
                    //did it work?
//                    print("fetched users successfully")
                    self.users.append(user)
                    DispatchQueue.main.async { self.tableView.reloadData() }
                }
            }
        }
        
        //fetchUid()
    }
    
    func fetchUid() {
        let ref = Database.database().reference()
        let usersRef = ref.child("users")
        let queryRef = usersRef.queryOrdered(byChild: "uid")
        
        queryRef.observeSingleEvent(of: .value, with: { (snapshot) in
            for snap in snapshot.children {
                let userSnap = snap as! DataSnapshot
                let user = myUser()
                let uid = userSnap.key //the uid of each user
                user.uid = uid
//                print("uid key = \(uid)")
                self.users.append(user)
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
        })
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        if let imageURL = user.profileImageUrl {
            
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: imageURL)
            
            let url = URL(string: imageURL)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    cell.profileImageView.image = UIImage(data:data!)
                    
                }
            }).resume()
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController: MessagesController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true, completion: nil)
        print("User Selection Menu Dismissed")
        let user = self.users[indexPath.row]
        self.messagesController?.showChatControllerForUser(user: user)
    }
    
}
