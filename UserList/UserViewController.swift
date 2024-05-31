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
                .debounce(.milliseconds(200), scheduler: MainScheduler.instance)))
        
        output.fetchUserList.observe(on: MainScheduler.instance)
            .bind { [weak self] users in
            
            var snapshot = NSDiffableDataSourceSnapshot<Section,Item>()
            let items: [Item] = users.map { Item.list(user: $0) }
            let section = Section.api
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
            self?.fetchUserListViewController.applyData(snapshot: snapshot)
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

public enum Section {
    case api
    case favorite
}

public enum Item: Hashable {
    case list(user: User)
}

final public class UserListViewController: UIViewController {
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    public let textfield = SearchUserTextField()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    public func applyData(snapshot: NSDiffableDataSourceSnapshot<Section, Item>) {
        dataSource?.apply(snapshot)
    }
    
    private func setUI() {
        view.addSubview(textfield)
        view.addSubview(collectionView)
        textfield.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(44)
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(textfield.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        setDataSource()
    }
    
    private func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: Item) -> UICollectionViewCell? in
            
            if case let .list(user) = item {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.id, for: indexPath) as? ListCollectionViewCell
                cell?.apply(user: user)
                return cell
            }
            
            return nil
        }
        
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            let section = self?.dataSource?.snapshot().sectionIdentifiers[sectionIndex]
            return self?.createListSection()
        }
    }
    
    private func createListSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        return section
    }
    
}
