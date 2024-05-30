//
//  UserViewController.swift
//  UserListtt
//
//  Created by paytalab on 5/27/24.
//

import UIKit
import SnapKit
import RxSwift

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
        tabButtonView.select(index: 0)
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

final public class UserListViewController: UIViewController {
    public let textfield = SearchUserTextField()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        view.backgroundColor = .red
    }
    
    private func setUI() {
        view.addSubview(textfield)
        textfield.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
    }
}
