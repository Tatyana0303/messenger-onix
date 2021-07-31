//
//  Message.swift
//  MessagerOnixApp
//
//  Created by Tania on 31.07.2021.
//

import Firebase

struct Message {
    var fromId: String?
    var timestamp: NSNumber?
    var text: String?
    var toId: String?
    
    func chatPartnerId() -> String? {
        if self.fromId == Auth.auth().currentUser?.uid {
            return toId
        } else {
            return fromId
        }
    }
}

