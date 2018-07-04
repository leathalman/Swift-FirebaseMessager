//
//  Extensions.swift
//  Login Screen
//
//  Created by Harrison Leath on 3/17/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {

    func loadImageUsingCacheWithUrlString(urlString: String) {
    
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                }
            }
        }).resume() }
}

extension UICollectionView {
    func scrollToLast() {
        guard numberOfSections > 0 else {
            return
        }
        
        let lastSection = numberOfSections - 1
        
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1,
                                          section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: true)
        print("scrolled to bottom called")
    }
}

extension String {
    func trunc(length: Int, trailing: String = "…") -> String {
        return (self.count > length) ? self.prefix(length) + trailing : self
    }
}

extension NewMessageController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension Notification.Name {
    static let darkModeEnabled = Notification.Name("com.chat.notifications.darkModeEnabled")
    static let darkModeDisabled = Notification.Name("com.chat.notifications.darkModeDisabled")
}

extension UIViewController {
    func darkTheme(tableView: UITableView) {
        view.backgroundColor = Colors.lighterDarkBlue
        tableView.backgroundColor = Colors.lighterDarkBlue
        navigationController?.navigationBar.barTintColor = Colors.lighterDarkBlue
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: true)
    }
    
    func lightTheme(tableView: UITableView) {
        view.backgroundColor = UIColor.white
        tableView.backgroundColor = UIColor.white
        navigationController?.navigationBar.barTintColor = Colors.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.default, animated: true)

    }
}
