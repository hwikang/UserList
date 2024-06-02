//
//  UserCollectionViewHeader.swift
//  UserList
//
//  Created by paytalab on 6/1/24.
//

import UIKit

final class UserCollectionViewHeader: UICollectionReusableView {
    static let id = "UserCollectionViewHeader"
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview().inset(10)
        }
    }
    public func configure(title: String) {
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
