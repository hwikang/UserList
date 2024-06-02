//
//  UserListCoreData.swift
//  UserList
//
//  Created by paytalab on 5/28/24.
//

import Foundation
import CoreData

final class UserCoreData {
    private let viewContext: NSManagedObjectContext

    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    public func saveFavoriteUsers(user: User) -> Result<[User], CoreDataError> {
        guard let entity = NSEntityDescription.entity(forEntityName: "FavoriteUser", in: viewContext) else {
            return .failure(CoreDataError.entityNotFound("FavoriteUser"))}
        
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
    
    public func deleteFavoriteUser(userID: Int) -> Result<[User], CoreDataError> {
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", userID)
        do {
            let favoriteUsers = try viewContext.fetch(fetchRequest)
            favoriteUsers.forEach {  viewContext.delete($0) }
            try viewContext.save()
        } catch let error {
            return .failure(CoreDataError.deleteError(error.localizedDescription))
            
        }
        return getFavoriteUsers()
    }
    
    public func getFavoriteUsers() -> Result<[User], CoreDataError>  {
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        do {
            let result = try viewContext.fetch(fetchRequest)
            let userSet = Set<User>(result.compactMap { user in
                guard let login = user.value(forKey: "login") as? String,
                      let imageURL = user.value(forKey: "imageURL") as? String,
                      let id = user.value(forKey: "id") as? Int else { return nil }
                return User(id: id, login: login, imageURL: imageURL)
            })
            let users = Array(userSet)
            return .success(users)
        } catch let error {
            return .failure(CoreDataError.readError(error.localizedDescription))
        }
    }

}


