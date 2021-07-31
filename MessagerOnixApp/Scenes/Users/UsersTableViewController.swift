//
//  UsersTableViewController.swift
//  MessagerOnixApp
//
//  Created by Tania on 31.07.2021.
//

import UIKit

class UsersTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    private var users: [User] = []
    private var loginProvider = UserProvider()
    
    let customRefreshConrol = UIRefreshControl()
    
    var user: User?
    
    // MARK: - Life cycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUsers()
        prepareUI()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard
            let vc = segue.destination as? MessagesViewController,
            let user = sender as? User else { return }
        vc.user = self.user
        vc.companion = user
    }
    
    private func prepareUI() {
        tableView.refreshControl = customRefreshConrol
        customRefreshConrol.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshData(_ sender: Any) {
        fetchUsers()
        customRefreshConrol.endRefreshing()
    }
    
    private func fetchUsers() {
        loginProvider.fetchUsers(completion: { users in
            if users != nil {
                self.users = self.removeCurrentUser(users: users ?? [])
                self.tableView.reloadData()
            } else {
                self.showErrorAlert(title: "Error")
            }
        })
    }
    
    private func removeCurrentUser(users: [User]) -> [User] {
        guard let user = self.user else { return users }
        return users.filter({ $0.id != user.id })
    }
    
    private func showErrorAlert(title: String? = nil, errorMessage: String? = nil) {
        let alert = UIAlertController(title: title, message: errorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}

// MARK: - Data Source, Delegate

extension UsersTableViewController {
    
    // MARK: - Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let user = self.users[indexPath.row]
        cell.textLabel?.text = user.name
        return cell
    }
    
    // MARK: - Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        performSegue(withIdentifier: "messages", sender: user)
    }
}
