//
//  ListCollectionViewCell.swift
//  UserList
//
//  Created by paytalab on 5/31/24.
//

import UIKit
import Kingfisher
import RxSwift

final public class ListCollectionViewCell: UICollectionViewCell {
    static let id = "ListCollectionViewCell"
    public var disposeBag = DisposeBag()
    private let imageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.systemGray.cgColor
        return imageView
    }()
    private let nameLabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    public let favoriteButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        return button
    }()
    public override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        addSubview(imageView)
        addSubview(favoriteButton)
        addSubview(nameLabel)
        imageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(10)
            make.width.equalTo(100)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalTo(imageView)
            make.trailing.equalToSuperview().inset(10)
            make.width.height.equalTo(44)
        }
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.top.trailing.equalToSuperview().inset(10)
        }
       
    }
    
    public func apply(user: User, hideButton: Bool) {
        imageView.kf.setImage(with: URL(string: user.imageURL))
        nameLabel.text = user.login
        favoriteButton.isSelected = user.favorite
        favoriteButton.isHidden = hideButton
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


