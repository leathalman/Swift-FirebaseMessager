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
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid).child(toId)
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
                    
                    self.messages.append(message)
                    DispatchQueue.main.async(execute: {
                        self.collectionView?.reloadData()
                    })
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
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor.white
        collectionView.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.keyboardDismissMode = .interactive
        
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = UIColor.white
        
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
        
        
        containerView.addSubview(self.inputTextField)
        //contraints: x, y, w, h
        self.inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let sepLineView = UIView()
        sepLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        sepLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sepLineView)
        //constraints: x, y, w, h
        sepLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        sepLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        sepLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        sepLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool { return true }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        containerViewBottomAnchor?.constant = 0
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keyboardDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setupCell(cell: cell, message: message)
        
        cell.bubbleWidthAnchor?.constant = estimateFrameforText(text: message.text!).width + 32
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        
        if let profileImageUrl = self.user?.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.senderId == Auth.auth().currentUser?.uid {
            //outgoing blue bubbles
            cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
            cell.textView.textColor = UIColor.white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
            
        } else {
            //omcoming grey
            cell.bubbleView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
            cell.textView.textColor = UIColor.black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        //get estimated height
        if let text = messages[indexPath.item].text {
            height = estimateFrameforText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
        
    }
    
    private func estimateFrameforText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    func setupInputComponets() {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.layoutIfNeeded()
        
        view.addSubview(containerView)
        
        //Even more constraints: x, y, w, h
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

        containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        containerViewBottomAnchor?.isActive = true
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
            
            self.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(senderId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toId).child(senderId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
