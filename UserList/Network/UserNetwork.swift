//
//  UserNetwork.swift
//  UserList
//
//  Created by paytalab on 5/27/24.
//

import Foundation

final class UserNetwork {
    private let manager: NetworkManager
    init(manager: NetworkManager) {
        self.manager = manager
    }
    
    public func getUsers(query: String, page: Int) async -> Result<UserResult, NetworkError> {
        let url = "https://api.github.com/search/users?q=\(query)&page=\(page)"
        return await manager.fetchData(url: url, method: .get, dataType: UserResult.self)
    }
}
