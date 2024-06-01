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
            deleteFavorite: fetchUserListViewController.deleteFavorite.asObservable()
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

public enum Section: Hashable {
    case api
    case favorite(initial: String)
}

public enum Item: Hashable {
    case list(user: User, isFavorite: Bool)
}

final public class UserListViewController: UIViewController {
    let saveFavorite = PublishRelay<User>()
    let deleteFavorite = PublishRelay<Int>()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
    public let textfield = SearchUserTextField()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(ListCollectionViewCell.self, forCellWithReuseIdentifier: ListCollectionViewCell.id)
        collectionView.register(UserCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: UserCollectionViewHeader.id)
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
        self.dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { [weak self] collectionView, indexPath, item -> UICollectionViewCell? in
            guard let section = self?.dataSource?.snapshot().sectionIdentifier(containingItem: item),
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ListCollectionViewCell.id, for: indexPath) as? ListCollectionViewCell,
                  case let .list(user, isFavorite) = item else { return nil }
            
            switch section {
            case .api:
                cell.apply(user: user, isFavoriteUser: isFavorite)
                cell.favoriteButton.rx.tap.bind(onNext: { [weak self] in
                    if isFavorite {
                        self?.deleteFavorite.accept(user.id)
                    } else {
                        self?.saveFavorite.accept(user)
                    }
                }).disposed(by: cell.disposeBag)
            case .favorite(let initial):
                cell.apply(user: user, isFavoriteUser: true)
            }
           
            return cell
        }
        
        dataSource?.supplementaryViewProvider = {[weak self] collectionView, kind, indexPath -> UICollectionReusableView in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UserCollectionViewHeader.id, for: indexPath)
            let section = self?.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
            
            switch section {
            case .favorite(let initial):
                (header as? UserCollectionViewHeader)?.configure(title: initial)
                return header
            default:
                return header
            }
        }
    }
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let section = self?.dataSource?.snapshot().sectionIdentifiers[sectionIndex] else { return nil }

            switch section {
            case .api:
                return self?.createListSection(showHeader: false)
            case .favorite:
                return self?.createListSection(showHeader: true)
            }
            
        }
    }
    
    private func createListSection(showHeader: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        if showHeader {
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
            section.boundarySupplementaryItems = [header]
        }

        return section
    }
    
}
