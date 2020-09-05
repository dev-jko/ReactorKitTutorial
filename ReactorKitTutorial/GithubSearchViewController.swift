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
import RxCocoa

class GithubSearchViewController: UIViewController, View {

    private let searchBar: UISearchBar = UISearchBar()
    private let tableView: UITableView = UITableView()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLayout()
        bindStyles()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor = GithubSearchViewReactor()
    }

    private func setUpLayout() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        searchBar.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(searchBar.snp.bottom)
        }
    }
    
    private func bindStyles() {
        tableView.backgroundColor = .white
    }
    
    func bind(reactor: GithubSearchViewReactor) {
        searchBar.rx.text
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateQuery($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .filter ({ [weak self] offset in
                guard
                    let `self` = self,
                    self.tableView.frame.height > 0
                else { return false }
                
                return offset.y + self.tableView.frame.height >= self.tableView.contentSize.height - 100
            })
            .map { _ in Reactor.Action.loadNextPage }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.repos }
            .bind(to: tableView.rx.items(cellIdentifier: "cell"), curriedArgument: { indexPath, repo, cell in
                cell.textLabel?.text = repo
            })
            .disposed(by: disposeBag)
    }
}

