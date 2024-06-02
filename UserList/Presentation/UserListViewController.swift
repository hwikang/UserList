//
//  UserListViewController.swift
//  UserList
//
//  Created by paytalab on 6/2/24.
//

import UIKit
import RxSwift
import RxCocoa

public enum Section: Hashable {
    case api
    case favorite(initial: String)
}

public enum Item: Hashable {
    case list(user: User, isFavorite: Bool)
}

final public class UserListViewController: UIViewController {
    public let saveFavorite = PublishRelay<User>()
    public let deleteFavorite = PublishRelay<Int>()
    public let fetchMore = PublishRelay<Void>()
    public let textfield = SearchUserTextField()

    private let disposeBag = DisposeBag()
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>?
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
        bindView()
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
    
    private func bindView() {
        collectionView.rx.prefetchItems.bind { [weak self] indexPath in
            let snapshot = self?.dataSource?.snapshot()
            guard let lastIndexPath = indexPath.last,
                  let section = snapshot?.sectionIdentifiers[lastIndexPath.section],
//                  let section = self?.dataSource?.sectionIdentifier(for: lastIndexPath.section),
                  let numberOfItems = snapshot?.numberOfItems(inSection: section) else { return }
            
            if lastIndexPath.row > numberOfItems - 2 {
                print("Fetch@")
                self?.fetchMore.accept(())
            }
        }.disposed(by: disposeBag)
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
            case .favorite:
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
