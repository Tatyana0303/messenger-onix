//
//  UserProvider.swift
//  MessagerOnixApp
//
//  Created by Tania on 31.07.2021.
//

import UIKit
import Firebase

struct UserProvider {
    
    // MARK: - Creat user
    
    func createUser(with name: String, completion: @escaping (User?) -> Void) {
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let uniqueId = UUID().uuidString
        let usersReference = ref.child("users").child(uniqueId)
        
        usersReference.setValue(["name":name]) { (error, ref) in
            if error == nil {
                completion(User(id: uniqueId, name: name))
            } else {
                completion(nil)
            }
        }
    }
    
    // MARK: - Fetch user
    
    func fetchUser(completion: @escaping (User?) -> Void) {
        Database.database().reference().child("users").child((Auth.auth().currentUser?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(id: snapshot.key, name: dictionary["name"] as? String)
                completion(user)
            } else {
                completion(nil)
            }
        }, withCancel: nil)
    }
    
    // MARK: - Fetch users
    
    func fetchUsers(completion: @escaping ([User]?) -> Void) {
        Database.database().reference().child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String:AnyObject] else {
                completion(nil)
                return
            }
            
            var users: [User] = []
            
            for user in value {
                let createdUser = User(id: user.key, name: user.value["name"] as? String)
                users.append(createdUser)
            }

            completion(users)
        })
    }
}
