//
//  UserTableViewCell.swift
//  MessagerOnixApp
//
//  Created by Tania on 31.07.2021.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    func configure() {
        messageView.layer.cornerRadius = 12
    }
}
