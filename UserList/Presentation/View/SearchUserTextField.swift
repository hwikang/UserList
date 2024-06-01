//
//  SearchUserTextField.swift
//  UserList
//
//  Created by paytalab on 5/30/24.
//

import UIKit

final public class SearchUserTextField: UITextField {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 1
        layer.borderColor = UIColor.gray.cgColor
        layer.cornerRadius = 5
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .black
        imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        leftView = imageView
        leftViewMode = .always
        textColor = .black
        placeholder = "검색어를 입력해 주세요"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
