//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self;
        navigationItem.hidesBackButton = true;
        
        tableView.register(UINib(nibName: K.cellNiBName, bundle: nil), forCellReuseIdentifier: K.reusableCell)
        
        loadMessages()
    }
    
    
    func loadMessages(){
        
        
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener {
            (querySnapshot, error) in
            if let e = error{
                print("hubo un error optieniendo los datos: \(e)")
                
            }
            else{
                self.messages = [];

                if let snapShotDocument = querySnapshot?.documents {
                    for doc in snapShotDocument{
                        let data = doc.data()
                        if let sender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String{
                            let newMessage = Message(sender: sender, body: messageBody);
                            self.messages.append(newMessage);
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexpath = IndexPath(row: self.messages.count-1, section: 0)
                                
                                self.tableView.scrollToRow(at: indexpath, at: .top, animated: true)
                            }
                            
                        }
                    }
                }
                    
                
            }
        }
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextfield.text,
           let messageSender = Auth.auth().currentUser?.email{
            
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender, K.FStore.bodyField: messageBody, K.FStore.dateField: Date().timeIntervalSince1970]) { error in
                if let e = error{
                    print ("Error adding document: \(e)");
                }
                else{
                    print ("dato agregado")
                    DispatchQueue.main.async{
                        self.messageTextfield.text = ""
                    }
                }
            }
        }
        
        
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
    }
    
}


extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.messageBubble.backgroundColor = UIColor(named: "BrandLightPurple")
            cell.rightImageView.isHidden = false
            cell.leftImageView.isHidden = true
            cell.label.textColor = UIColor(named: "BrandPurple")
        } else {
            cell.messageBubble.backgroundColor = UIColor(named: "BrandPurple")
            cell.rightImageView.isHidden = true
            cell.leftImageView.isHidden = false
            cell.label.textColor = UIColor(named: "BrandLightPurple")
        }
        

        return cell;
    }
}
