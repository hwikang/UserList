//
//  UserViewController.swift
//  UserListtt
//
//  Created by paytalab on 5/27/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class UserViewController: UIViewController {
    private let viewModel: UserViewModel
    private let disposeBag = DisposeBag()
    private let tabButtonView = TabButtonView(typeList: [.api, .favorite])
    
    private let fetchUserListViewController = UserListViewController()
    private let favoriteUserListViewController = UserListViewController()
    init(viewModel: UserViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        bindView()
        bindViewModel()
    }
    
    private func setUI() {
        view.addSubview(tabButtonView)
        view.addSubview(fetchUserListViewController.view)
        view.addSubview(favoriteUserListViewController.view)
        tabButtonView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        fetchUserListViewController.view.snp.makeConstraints { make in
            make.top.equalTo(tabButtonView.snp.bottom)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        favoriteUserListViewController.view.snp.makeConstraints { make in
            make.top.equalTo(tabButtonView.snp.bottom)
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
    private func bindViewModel() {
     
        let output = viewModel.transform(input: UserViewModel.Input(
            fetchUserQuery: fetchUserListViewController.textfield.rx.text.orEmpty.distinctUntilChanged()
                .debounce(.milliseconds(200), scheduler: MainScheduler.instance),
            favoriteUserQuery: favoriteUserListViewController.textfield.rx.text.orEmpty.distinctUntilChanged()
                .debounce(.milliseconds(200), scheduler: MainScheduler.instance),
            saveFavorite: fetchUserListViewController.saveFavorite.asObservable(),
            deleteFavorite: fetchUserListViewController.deleteFavorite.asObservable(),
            fetchMore: fetchUserListViewController.fetchMore.asObservable()
        ))
        
        output.fetchUserList
            .map({ users in
                var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
                let items: [Item] = users.map { Item.list(user: $0, isFavorite: $1) }
                let section = Section.api
                snapshot.appendSections([section])
                snapshot.appendItems(items, toSection: section)
                return snapshot
            })
            .observe(on: MainScheduler.instance)
            .bind { [weak self] snapshot in
                self?.fetchUserListViewController.applyData(snapshot: snapshot)
            }.disposed(by: disposeBag)
        
        output.favoriteUserList
            .map({ favoriteUsers in
                let keys = favoriteUsers.keys.sorted()
                var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
                keys.forEach { key in
                    let section = Section.favorite(initial: key)
                    snapshot.appendSections([section])
                    
                    if let users = favoriteUsers[key] {
                        let items = users.map { Item.list(user: $0, isFavorite: true) }
                        snapshot.appendItems(items, toSection: section)
                    }
                }
                return snapshot
            })
            .observe(on: MainScheduler.instance)
            .bind { [weak self] snapshot in
                self?.favoriteUserListViewController.applyData(snapshot: snapshot)
            }.disposed(by: disposeBag)
        
        output.error
            .observe(on: MainScheduler.instance)
            .bind { [weak self] errorMessage in
                let alert = UIAlertController(title: "에러", message: errorMessage, preferredStyle: .alert)
                alert.addAction(.init(title: "확인", style: .default))
                self?.present(alert, animated: true)
            }.disposed(by: disposeBag)
    }
    
    private func bindView() {
        tabButtonView.selectedType.bind { [weak self] type in
            guard let self = self else { return }
            switch type {
            case .api:
                fetchUserListViewController.view.isHidden = false
                favoriteUserListViewController.view.isHidden = true
            case .favorite:
                fetchUserListViewController.view.isHidden = true
                favoriteUserListViewController.view.isHidden = false

            }
        }.disposed(by: disposeBag)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
