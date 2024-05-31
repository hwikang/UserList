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
    init(repository: UserRepository) {
        self.repository = repository
    }
    struct Input {
        public let fetchUserQuery: Observable<String>
        public let favoriteUserQuery: Observable<String>
    }
    struct Output {
        public let fetchUserList: Observable<[User]>
//        public let favoriteUserList: Observable<[String:[User]]>
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
        return Output(fetchUserList: fetchUserList.asObservable())
    }
    
    private func fetchUsers(query: String, page: Int) {
        guard !query.isEmpty, let urlAllowedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }

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
}

