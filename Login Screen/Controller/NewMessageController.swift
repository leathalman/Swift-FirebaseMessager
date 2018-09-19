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
    var filteredUsers = [myUser]()
    
    let defaults = UserDefaults.standard
    
    override func viewDidAppear(_ animated: Bool) {
        detectDarkMode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.title = "New Message"
        navigationController?.navigationBar.isTranslucent = false
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        backButton.target = self
        backButton.action = #selector(handleCancel)
        navigationItem.backBarButtonItem = backButton
        
        setupSearchBar()
        fetchUsers()
        
    }
    
    func detectDarkMode() {
        let darkModeEnabled = defaults.bool(forKey: "DarkDefault")
        
        if darkModeEnabled {
            //dark mode enabled "DarkDefault"
            darkTheme(tableView: tableView)
            navigationController?.navigationBar.barTintColor = Colors.gray
            view.backgroundColor = Colors.lighterDarkBlue

        } else {
            //light mode enabled "LightDefault"
            lightTheme(tableView: tableView)
        }
    }

    let searchController = UISearchController(searchResultsController: nil)

    func setupSearchBar() {
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Users"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredUsers = users.filter({( user : myUser) -> Bool in
            return user.name!.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
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
                    
                    self.users.append(user)
                    DispatchQueue.main.async { self.tableView.reloadData() }
                }
            }
        }
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
                self.users.append(user)
                DispatchQueue.main.async { self.tableView.reloadData() }
            }
        })
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredUsers.count
        }
        
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        
        let user: myUser
        
        if isFiltering() {
            user = filteredUsers[indexPath.row]
        } else {
            user = users[indexPath.row]
        }
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
        let darkModeEnabled = defaults.bool(forKey: "DarkDefault")
        
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
        
        if isFiltering() {
            
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            chatLogController.user = self.filteredUsers[indexPath.row]
            navigationController?.pushViewController(chatLogController, animated: true)

        } else {
            
//            dismiss(animated: true, completion: nil)
//            let user = self.users[indexPath.row]
//            self.messagesController?.showChatControllerForUser(user: user)
            
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            chatLogController.user = self.users[indexPath.row]
            navigationController?.pushViewController(chatLogController, animated: true)
        }

    }
    
}
