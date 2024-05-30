//
//  UserViewModel.swift
//  UserList
//
//  Created by paytalab on 5/29/24.
//

import Foundation
import RxSwift

final class UserViewModel {
    private let repository: UserRepository
    private let disposeBag = DisposeBag()
    private var page = 0
    init(repository: UserRepository) {
        self.repository = repository
    }
    struct Input {
        public let fetchUserQuery: Observable<String>
        public let favoriteUserQuery: Observable<String>
    }
    struct Output {
//        public let fetchUserList: Observable<[User]>
//        public let favoriteUserList: Observable<[String:[User]]>
    }
    
    public func transform(input: Input) -> Output {
        input.fetchUserQuery.bind { [weak self] query in
            guard let self = self else { return }
            fetchUsers(query: query, page: page)
        }.disposed(by: DisposeBag())
        
        return Output()
    }
    
    private func fetchUsers(query: String, page: Int) {
        Task {
            await repository.fetchUsers(query: query, page: page)
            
        }
    }
}

