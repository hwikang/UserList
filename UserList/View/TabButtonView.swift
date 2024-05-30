//
//  TabButtonView.swift
//  UserList
//
//  Created by paytalab on 5/30/24.
//

import Foundation
import RxSwift
import RxCocoa

public enum TabButtonType: String {
    case api = "API"
    case favorite = "즐겨찾기"
}

final public class TabButtonView: UIStackView {

    private let disposeBag = DisposeBag()
    public let selectedType = PublishRelay<TabButtonType>()
    private let tabButtonStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    public init(typeList: [TabButtonType]) {
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .fill
        distribution = .fillEqually
        addButtons(typeList: typeList)
    }
    
    private func addButtons(typeList: [TabButtonType]) {
        typeList.forEach { type in
            let tabButton = TabButton(type: type)
            addArrangedSubview(tabButton)
            tabButton.rx.tap.bind { [weak self] in
                guard let self = self, !tabButton.isSelected else { return }
                self.arrangedSubviews.compactMap { $0 as? TabButton }.forEach { $0.isSelected = false }
                tabButton.isSelected = true
                selectedType.accept(type)
            }.disposed(by: disposeBag)
        }

    }
    
    public func select(index: Int) {
        guard arrangedSubviews.indices.contains(index),
            let selectedButton = arrangedSubviews[index] as? TabButton else { return }
        arrangedSubviews.compactMap { $0 as? TabButton }.forEach { $0.isSelected = false }
        selectedButton.isSelected = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

final fileprivate class TabButton: UIButton {
    public let type: TabButtonType
    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = .systemBlue
            } else {
                backgroundColor = .white
            }
        }
    }
    init(type: TabButtonType) {
        self.type = type
        super.init(frame: .zero)
        setTitle(type.rawValue, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        setTitleColor(.black, for: .normal)
        setTitleColor(.white, for: .selected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
