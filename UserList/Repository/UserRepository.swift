//
//  UserRepository.swift
//  UserList
//
//  Created by paytalab on 5/28/24.
//

import Foundation
import CoreData

final class UserRepository {
    private let coreData: UserCoreData
    private let network: UserNetwork

    init(coreData: UserCoreData, network: UserNetwork) {
        self.coreData = coreData
        self.network = network
    }
    
    public func fetchUsers(query: String, page: Int) async -> Result<[User], Error> {
        let result = await network.getUsers(query: query, page: page)
        switch result {
        case .success(let result):
            return .success(result.items)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func saveFavoriteUser(user: User) -> Result<[String : [User]], Error> {
        return coreData.saveFavoriteUsers(user: user)
    }
    public func deleteFavoriteUser(userID: Int) -> Result<[String : [User]], Error> {
        return coreData.deleteFavoriteUser(userID: userID)
    }
    public func getFavoriteUsers() -> Result<[String : [User]], Error> {
        return coreData.getFavoriteUsers()
    }
    
}
