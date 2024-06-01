//
//  UserViewModel.swift
//  UserList
//
//  Created by paytalab on 5/29/24.
//

import Foundation
import RxSwift
import RxCocoa

final class UserViewModel {
    private let repository: UserRepository
    private let disposeBag = DisposeBag()
    private var page = 1
    private let fetchUserList = BehaviorRelay<[User]>(value: [])
    private let favoriteUserList = BehaviorRelay<[User]>(value: [])
    
    init(repository: UserRepository) {
        self.repository = repository
        getFavoriteUsers()
    }
    
    struct Input {
        public let fetchUserQuery: Observable<String>
        public let favoriteUserQuery: Observable<String>
        public let saveFavorite: Observable<User>
        public let deleteFavorite: Observable<Int>
    }
    struct Output {
        public let fetchUserList: Observable<[(user: User, isFavorite: Bool)]>
        public let favoriteUserList: Observable<[String:[User]]>
    }
    
    public func transform(input: Input) -> Output {
        input.fetchUserQuery
            .filter({ [weak self] query in
                return self?.filterQuery(query: query) == true
            })
            .bind { [weak self] query in
                guard let self = self else { return }
                page = 1
                self.fetchUserList.accept([])
                fetchUsers(query: query, page: page)
            }.disposed(by: disposeBag)
        
        input.saveFavorite.bind { [weak self] user in
            self?.saveFavoriteUser(user: user)
        }.disposed(by: disposeBag)
        
        input.deleteFavorite.bind { [weak self] userID in
            self?.deleteFavoriteUser(userID: userID)
        }.disposed(by: disposeBag)
        
        let fetchUserList = Observable.combineLatest(fetchUserList, favoriteUserList).map { fetchUsers, favoriteUsers in
            let userSet = Set(favoriteUsers)
            return fetchUsers.map { user in
                
                if userSet.contains(user) { 
                    return (user: user, isFavorite: true)
                } else {
                    return (user: user, isFavorite: false)
                }
                
            }
        }
        
        let favoriteUserList = Observable.combineLatest(favoriteUserList, input.favoriteUserQuery)
            .compactMap { [weak self] favoriteUsers, query in
                if self?.filterQuery(query: query) == false { return self?.convertListToDictionary(users: favoriteUsers) }
                let filteredUsers = favoriteUsers.filter { user in
                    user.login.lowercased().contains(query.lowercased())
                }
                return self?.convertListToDictionary(users: filteredUsers)
            }
        return Output(fetchUserList: fetchUserList, favoriteUserList: favoriteUserList.asObservable())
    }
    
    private func getFavoriteUsers() {
        let result = repository.getFavoriteUsers()
        switch result {
        case .success(let favoriteUsers):
            favoriteUserList.accept(favoriteUsers)
        case .failure(let error):
            print(error)
        }
    }
    
    private func saveFavoriteUser(user: User) {
        
        let result = repository.saveFavoriteUser(user: user)
        switch result {
        case .success(let favoriteUsers):
            favoriteUserList.accept(favoriteUsers)
        case .failure(let error):
            print(error)
        }
    }
    
    private func deleteFavoriteUser(userID: Int) {
        let result = repository.deleteFavoriteUser(userID: userID)
        switch result {
        case .success(let favoriteUsers):
            favoriteUserList.accept(favoriteUsers)
        case .failure(let error):
            print(error)
        }
    }
    
    private func fetchUsers(query: String, page: Int) {
        guard let urlAllowedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
       
        Task {
            let resut = await repository.fetchUsers(query: urlAllowedQuery, page: page)
            switch resut {
            case .success(let users):
                fetchUserList.accept(fetchUserList.value + users)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func filterQuery(query: String) -> Bool {
        if query.isEmpty { 
            return false
        } else if nameValidation(query: query) == false {
            //TODO - 에러 표시
            print("유효하지 않은 이름")
            return false
        } else {
            return true
        }
       
    }
    
    private func nameValidation(query: String) -> Bool {
        let nameRegex = "^[\\p{L} .'-]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: query)
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

