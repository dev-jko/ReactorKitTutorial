//
//  GithubSearchViewReactor.swift
//  ReactorKitTutorial
//
//  Created by Jaedoo Ko on 2020/09/03.
//  Copyright © 2020 jko. All rights reserved.
//

import Foundation
import ReactorKit

final class GithubSearchViewReactor: Reactor {
    enum Action {
        case updateQuery(String?)
    }
    
    enum Mutation {
        case setRepos([String])
    }
    
    struct State {
        var repos: [String]
    }
    
    let initialState: State = State(repos: [])
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateQuery(let query):
            guard let url = url(query: query) else {
                return Observable.just(Mutation.setRepos([]))
            }
            return URLSession.shared.rx.json(url: url)
                .map({ json in
                    guard
                        let dict = json as? [String: Any],
                        let items = dict["items"] as? [[String: Any]]
                    else { return [] }
                    return items.compactMap { $0["full_name"] as? String }
                })
                .catchErrorJustReturn([])
                .map { Mutation.setRepos($0) }
                .takeUntil(self.action.filter {
                    if case .updateQuery = $0 {
                        return true
                    } else {
                        return false
                    }
                })
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case .setRepos(let repos):
            return State(repos: repos)
        }
    }
    
    private func url(query: String?) -> URL? {
        guard let query = query, !query.isEmpty else { return nil }
        return URL(string: "https://api.github.com/search/repositories?q=\(query)")
    }
}
