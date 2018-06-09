//
//  ChatLogController.swift
//  Login Screen
//
//  Created by Harrison Leath on 3/19/18.
//  Copyright © 2018 Harrison Leath. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout {
    
    var newMessageController: NewMessageController?
    
    var user: myUser? {
        didSet {
            navigationItem.title = user?.name
            
            //actual functions to observe messages not called because of fatal error mismatched keys
            observeUserMessages()
            
        }
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesReference = Database.database().reference().child("messages").child(messageId)
            
            messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message()
                    message.text = dictionary["text"] as? String ?? "Text not found"
                    message.senderId = dictionary["sender_Id"] as? String ?? "Sender not found"
                    message.toId = dictionary["to_Id"] as? String ?? "Reciever not found"
                    message.timestamp = dictionary["timestamp"] as? NSNumber
                    
                    if message.chatPartnerId() == self.user?.uid {
                        self.messages.append(message)
                        DispatchQueue.main.async(execute: {
                            self.collectionView?.reloadData()
                        })
                    }
                }
                
            }, withCancel: { (nil) in
                
            })
            
        }, withCancel: nil)
        
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        setupInputComponets()
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        
        cell.textView.text = message.text
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
    
    func setupInputComponets() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        //Even more constraints: x, y, w, h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: UIControl.State.normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        //adds target to button
        sendButton.addTarget(self, action: #selector(handleSend), for: UIControl.Event.touchUpInside)
        
        
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

        let values = ["text": inputTextField.text!, "to_Id": toId, "sender_Id": senderId, "timestamp": timestamp] as [String : Any]
        
        childRef.updateChildValues(values) { (error, ref ) in
            if error != nil {
                print(error ?? "error updating child values")
                return
            }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(senderId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
