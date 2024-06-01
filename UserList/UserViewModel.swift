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
    private var page = 0
    private let fetchUserList = BehaviorRelay<[User]>(value: [])
    private let favoriteUserList = BehaviorRelay<[String:[User]]>(value: [:])
    
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
        public let fetchUserList: Observable<[User]>
        public let favoriteUserList: Observable<[String:[User]]>
    }
    
    public func transform(input: Input) -> Output {
        input.fetchUserQuery.bind { [weak self] query in
            guard let self = self else { return }
            fetchUsers(query: query, page: page)
        }.disposed(by: disposeBag)
        input.favoriteUserQuery.bind { [weak self] query in
            guard let self = self else { return }
            //TODO: 즐겨찾기
        }.disposed(by: disposeBag)
        input.saveFavorite.bind { [weak self] user in
            self?.saveFavoriteUser(user: user)
        }.disposed(by: disposeBag)
        input.deleteFavorite.bind { [weak self] userID in
            self?.deleteFavoriteUser(userID: userID)
        }.disposed(by: disposeBag)
        
        let fetchUserList = Observable.combineLatest(fetchUserList, favoriteUserList).map { fetchUsers, favoriteUsers in
            let userSet = Set(favoriteUsers.values.flatMap { $0 })
            return fetchUsers.map { user in
                var user = user
                if userSet.contains(user) { user.favorite = true }
                return user
            }
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
        guard !query.isEmpty, let urlAllowedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard nameValidation(query: query) else {
            //TODO - 에러 표시
            print("유효하지 않은 이름")
            return
        }
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
    
    private func nameValidation(query: String) -> Bool {
        let nameRegex = "^[\\p{L} .'-]+$"
        let nameTest = NSPredicate(format:"SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: query)
    }
    
}

