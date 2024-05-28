//
//  UserListCoreData.swift
//  UserList
//
//  Created by paytalab on 5/28/24.
//

import Foundation
import CoreData

final class UserListCoreData {
    private let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    public func saveFavoriteUsers(user: User) -> Result<[String: [User]], Error> {
        guard let entity = NSEntityDescription.entity(forEntityName: "FavoriteUser", in: viewContext) else {
            return .failure(CoreDataError.entityNotFound)}
        
        let userObject = NSManagedObject(entity: entity, insertInto: viewContext)
        userObject.setValue(user.id, forKey: "id")
        userObject.setValue(user.login, forKey: "login")
        userObject.setValue(user.imageURL, forKey: "imageURL")
        do {
            try viewContext.save()
        } catch let error {
            return .failure(CoreDataError.saveError(error.localizedDescription))
            
        }
        return getFavoriteUsers()
    }
    
    public func getFavoriteUsers() -> Result<[String: [User]], Error>  {
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        do {
            let result = try viewContext.fetch(fetchRequest)
            let user: [User] = result.compactMap { user in
                guard let login = user.value(forKey: "login") as? String,
                      let imageURL = user.value(forKey: "imageURL") as? String,
                      let id = user.value(forKey: "id") as? Int else { return nil }
                return User(id: id, login: login, imageURL: imageURL)
            }
            
            let userData = convertListToDictionary(users: user)
            print("userData \(userData)")
            return .success(userData)
        } catch let error {
            return .failure(CoreDataError.readError(error.localizedDescription))
        }
    }
    
    private func convertListToDictionary(users: [User]) -> [String: [User]] {
        let groupedUsers = users.reduce(into: [String: [User]]()) { (dict, user) in
            let index = user.login.index(user.login.startIndex, offsetBy: 1)
            let key = String(user.login[..<index]).uppercased()
            dict[key, default: []].append(user)
        }
        return groupedUsers
    }
}


