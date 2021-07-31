//
//  InitialViewController.swift
//  MessagerOnixApp
//
//  Created by Tania on 31.07.2021.
//

import UIKit

class InitialViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: - Properties
    
    let userProvider = UserProvider()
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "users_id",
              let vc = segue.destination as? UsersTableViewController,
              let user = sender as? User else { return }
        vc.user = user
    }
    
    private func prepareUI() {
        startButton.layer.cornerRadius = 12
    }
    
    private func showErrorAlert(title: String? = nil, errorMessage: String? = nil) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBOutlets
    
    @IBAction func startTapped(_ sender: UIButton) {
        userProvider.createUser(with: nameTextField.text!) { user in
            if user != nil {
                self.performSegue(withIdentifier: "users_id", sender: user)
            } else {
                self.showErrorAlert(title: "Error")
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension InitialViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        startButton.isEnabled = nameTextField.text?.count ?? 0 > 0
    }
}

