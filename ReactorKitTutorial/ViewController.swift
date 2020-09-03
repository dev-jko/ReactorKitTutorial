//
//  ViewController.swift
//  ReactorKitTutorial
//
//  Created by Jaedoo Ko on 2020/09/03.
//  Copyright © 2020 jko. All rights reserved.
//

import UIKit
import SnapKit
import ReactorKit

class GithubSearchViewController: UIViewController {

    private let searchBar: UISearchBar = UISearchBar()
    private let tableView: UITableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLayout()
        bindStyles()
    }

    private func setUpLayout() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        searchBar.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
        }
    }
    
    private func bindStyles() {
        tableView.backgroundColor = .white
    }
}

