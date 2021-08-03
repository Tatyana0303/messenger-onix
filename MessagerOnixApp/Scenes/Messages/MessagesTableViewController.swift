//
//  MessagesTableViewController.swift
//  MessagerOnixApp
//
//  Created by Tania on 31.07.2021.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: - Properties
    
    var user: User?
    var companion: User?
    
    private var messages: [Message] = []
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = companion?.name
        observeMessages()
    }
        
    // MARK: - Logic
    
    private func observeMessages() {
        guard let userID = self.user?.id else { return }
        let userMessagesRef = Database.database().reference().child("user-messages").child(userID)
        userMessagesRef.observe(.childAdded, with: { [weak self] (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observe(.value, with: { [weak self] (snap) in
                if let dictionary = snap.value as? [String : AnyObject] {
                    let message = Message(fromId: dictionary["fromId"] as? String,
                                          timestamp: dictionary["timestamp"] as? NSNumber,
                                          text: dictionary["text"] as? String,
                                          toId: dictionary["toId"] as? String)
                    if self?.companion?.id == dictionary["toId"] as? String || self?.companion?.id == dictionary["fromId"] as? String {
                        self?.messages.append(message)
                    }
                    DispatchQueue.global(qos: .userInteractive).async {
                        DispatchQueue.main.async {
                            self?.tableView?.reloadData()
                        }
                    }
                    
                }
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private func handleSend() {
        let mess_ref = Database.database().reference().child("messages")
        let childmess_ref = mess_ref.childByAutoId()
        let toId = companion?.id
        let fromId = user?.id
        let timestamp: NSNumber = NSDate().timeIntervalSince1970 as NSNumber
        let value = ["text": inputTextField.text!, "toId": toId!, "fromId": fromId!, "timestamp": timestamp] as [String : Any]
        childmess_ref.setValue(value) { (error, ref) in
            if let error = error {
                print(error)
                return
            } else {
                let userMessagesRef = Database.database().reference().child("user-messages").child(fromId!)
                userMessagesRef.setValue([childmess_ref.key:1])
                let recipientMessagesRef = Database.database().reference().child("user-messages").child(toId!)
                recipientMessagesRef.setValue([childmess_ref.key:1])
            }
        }
        
        inputTextField.text = ""
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        handleSend()
    }
}

// MARK: - Data source

extension MessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        if message.fromId == user?.id {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: "user", for: indexPath) as? UserTableViewCell else { return UITableViewCell() }
            cell.messageLabel.text = message.text
            cell.configure()
            return cell
        } else {
            guard
                let cell = tableView.dequeueReusableCell(withIdentifier: "companion", for: indexPath) as? CompanionTableViewCell else { return UITableViewCell() }
            cell.messageLabel.text = message.text
            cell.configure()
            return cell
        }
    }
}

// MARK: - UITextFieldDelegate

extension MessagesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}
