//
//  GithubRepoCell.swift
//  ReactorKitTutorial
//
//  Created by Jaedoo Ko on 2020/09/05.
//  Copyright © 2020 jko. All rights reserved.
//

import UIKit
import SnapKit

class GithubRepoCell: UITableViewCell {
    
    private let name: UILabel = UILabel()
    private let star: UILabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpLayout()
        bindStyles()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpLayout() {
        contentView.addSubview(name)
        contentView.addSubview(star)
        
        name.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.trailing.equalTo(star.snp.leading)
        }
        
        star.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.leading.equalTo(name.snp.trailing)
        }
    }
    
    private func bindStyles() {
        name.backgroundColor = .yellow
        name.textAlignment = .center
        
        star.backgroundColor = .cyan
        star.textAlignment = .center
    }
}
