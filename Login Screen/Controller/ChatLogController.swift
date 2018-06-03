//
//  ChatLogController.swift
//  Login Screen
//
//  Created by Harrison Leath on 3/19/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate {
    
    var newMessageController: NewMessageController?
    
    var user: myUser? {
        didSet {
            navigationItem.title = user?.name
            
        }
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor.white
        
        setupInputComponets()
        
    }
    
    func setupInputComponets() {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        //Even more constraints: x, y, w, h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        //adds target to button
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        
        containerView.addSubview(sendButton)
        //Constraints: x, y, w, h,
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        
        containerView.addSubview(inputTextField)
        //contraints: x, y, w, h
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let sepLineView = UIView()
        sepLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        sepLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sepLineView)
        //constraints: x, y, w, h
        sepLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        sepLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        sepLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        sepLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    @objc func handleSend() {
        
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        
        let toId = user!.uid!
        let senderId = Auth.auth().currentUser!.uid
        
        let timestamp = (NSDate().timeIntervalSince1970)
//        let timeInterval = timestamp
//        print("time interval is \(timeInterval)")
//        let date = NSDate(timeIntervalSince1970: timeInterval)
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "hh:mm:s a"
//       dateFormatter.dateFormat = "hh:mm:s a MMMM, dd yyyy"
//        dateFormatter.timeZone = NSTimeZone(name: "EST") as TimeZone?
//        let dateString = dateFormatter.string(from: date as Date)
//        print("formatted date is =  \(dateString)")
        
        let values = ["text": inputTextField.text!, "to_Id": toId, "sender_Id": senderId, "timestamp": timestamp] as [String : Any]
        childRef.updateChildValues(values)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
