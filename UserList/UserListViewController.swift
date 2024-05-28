//
//  UserListViewController.swift
//  UserList
//
//  Created by paytalab on 5/27/24.
//

import UIKit

class UserListViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let network = UserNetwork(manager: NetworkManager())
        Task {
             await network.getUsers(query: "test", page: 1)
        }
    }


}

