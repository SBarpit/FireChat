//
//  ViewController.swift
//  Fire Chat
//
//  Created by Arpit Srivastava on 04-07-2018
//  Copyright (c) 2018 Arpit Srivastava . All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController , UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    // MARK:- IBOUTLETS
    // ================
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    @IBOutlet weak var launchGiphyVC: UIButton!
    
    var messageArray : [Message] = [Message]()
    
    var keyboardHeight:CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        messageTextfield.delegate = self
        
        self.launchGiphyVC.addTarget(self, action: #selector(launchGiphyVCAction), for: .touchUpInside)
        
        var tapgesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.isUserInteractionEnabled = true
        messageTableView.addGestureRecognizer(tapgesture)
        
        
        messageTableView.register(CustomMessageCell.nib, forCellReuseIdentifier: CustomMessageCell.identifier)
        messageTableView.register(ImageCell.nib, forCellReuseIdentifier: ImageCell.identifier)
        configureTableView()
        retriveMessage()
    }
    
    
    // MARK: - TableView DataSource Methods
    // ====================================
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if messageArray[indexPath.row].type == 0 {
            let cell = messageTableView.dequeueReusableCell(withIdentifier: CustomMessageCell.identifier, for: indexPath) as! CustomMessageCell
            cell.senderUsername.text = messageArray[indexPath.row].sender
            cell.messageBody.text = messageArray[indexPath.row].message
            cell.avatarImageView.image = #imageLiteral(resourceName: "egg")
            if cell.senderUsername.text == Auth.auth().currentUser?.email {
                cell.avatarImageView.backgroundColor = UIColor.flatLime()
                cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            }
            
            return cell
        }else{
            let cell = messageTableView.dequeueReusableCell(withIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell
            let url = URL(string: messageArray[indexPath.row].message)
            if let data = try? Data(contentsOf: url!)
            {
                cell?.gifImageView.image = UIImage.gif(data: data)
            }
            cell?.senderNameLabel.text = messageArray[indexPath.row].sender
            if cell?.senderNameLabel.text == Auth.auth().currentUser?.email {
                cell?.avatarImage.backgroundColor = UIColor.flatLime()
                cell?.messageBackGroundView.backgroundColor = UIColor.flatSkyBlue()
            }
            return cell!
        }
        
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableViewTapped(){
        messageTextfield.endEditing(true)
    }
    
    
    
    func configureTableView(){
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120
    }
    
    ///////////////////////////////////////////
    
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.messageArray.count-1, section: 0)
            self.messageTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    
    // MARK:- TextField Delegate Methods
    // ================================
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50 + LogInViewController.keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5) {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    // MARK: - Send & Recieve from Firebase
    // ====================================
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        //TODO: Send the message to Firebase and save it in our database
        
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let db = Database.database().reference().child("Message")
        let messageDictionary =  ["Sender" : Auth.auth().currentUser?.email,"MessageBody": messageTextfield.text ]
        db.childByAutoId().setValue(messageDictionary){
            (error,result) in
            if error != nil {
                print(error?.localizedDescription)
            }else{
                print("Saved successfully")
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.scrollToBottom()
                self.messageTextfield.text = ""
            }
        }
        
    }
    
    @objc func launchGiphyVCAction(){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "GiphyVC") as? GiphyVC
        vc?.delegate = self
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    func retriveMessage(){
        
        var database = Database.database().reference().child("Message")
        database.observe(.childAdded, with: { (snapshot) in
            let snapValue = snapshot.value as! Dictionary<String,String>
            let text = snapValue["MessageBody"]!
            let sender = snapValue["Sender"]!
            let message = Message()
            message.message = text
            message.sender = sender
            self.messageArray.append(message)
            self.messageTableView.reloadData()
            self.scrollToBottom()
        })
        
        
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        
        do {
            try Auth.auth().signOut()
        }catch{
            print("Error while signout")
        }
        guard(navigationController?.popToRootViewController(animated: true)) != nil
            else{
                return
        }
    }
}

extension ChatViewController:GetGifDelegate{
    func giphy(_ url: String) {
        let obj = Message()
        obj.message = url
        obj.sender = (Auth.auth().currentUser?.email)!
        obj.type = 1
        self.messageArray.append(obj)
        self.messageTableView.reloadData()
    }
}
