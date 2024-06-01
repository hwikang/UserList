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
    public let selectedType = BehaviorRelay<TabButtonType>(value: .api)
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
        bindView()
    }
    
    private func addButtons(typeList: [TabButtonType]) {
        typeList.forEach { type in
            let tabButton = TabButton(type: type)
            addArrangedSubview(tabButton)
            tabButton.rx.tap.bind { [weak self] in
                guard let self = self, !tabButton.isSelected else { return }
                selectedType.accept(type)
            }.disposed(by: disposeBag)
        }
    }
    
    private func bindView() {
        selectedType.bind { [weak self] type in
            self?.arrangedSubviews.compactMap { $0 as? TabButton }.forEach { $0.isSelected = $0.type == type ? true : false }
        }.disposed(by: disposeBag)
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
