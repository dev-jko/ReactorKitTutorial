//
//  GithubSearchViewReactor.swift
//  ReactorKitTutorial
//
//  Created by Jaedoo Ko on 2020/09/03.
//  Copyright © 2020 jko. All rights reserved.
//

import Foundation
import ReactorKit
import RxCocoa

final class GithubSearchViewReactor: Reactor {
    enum Action {
        case updateQuery(String?)
        case loadNextPage
    }
    
    enum Mutation {
        case setRepos([GithubRepo], nextPage: Int?)
        case setQuery(String?)
        case appendRepos([GithubRepo], nextPage: Int?)
        case setLoadingNextPage(Bool)
    }
    
    struct State {
        var repos: [GithubRepo] = []
        var query: String?
        var nextPage: Int?
        var isLoadingNextPage: Bool = false
    }
    
    let initialState: State = State(repos: [])
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateQuery(let query):
            return Observable.concat([
                Observable.just(Mutation.setQuery(query)),
                
                self.search(query: query, page: 1)
                    .takeUntil(self.action.filter(Action.isUpdateQueryAction))
                    .map { Mutation.setRepos($0, nextPage: $1)}
            ])
            
        case .loadNextPage:
            guard
                !self.currentState.isLoadingNextPage,
                let page = self.currentState.nextPage
            else { return Observable.empty() }
            
            return Observable.concat([
                Observable.just(Mutation.setLoadingNextPage(true)),
                
                self.search(query: self.currentState.query, page: page)
                    .takeUntil(self.action.filter(Action.isUpdateQueryAction(_:)))
                    .map { Mutation.appendRepos($0, nextPage: $1) },
                
                Observable.just(Mutation.setLoadingNextPage(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        switch mutation {
        case let .setQuery(query):
            var newState = state
            newState.query = query
            return newState
            
        case let .setRepos(repos, nextPage):
            var newState = state
            newState.repos = repos
            newState.nextPage = nextPage
            return newState
            
        case let .appendRepos(repos, nextPage):
            var newState = state
            newState.repos.append(contentsOf: repos)
            newState.nextPage = nextPage
            return newState
            
        case let .setLoadingNextPage(isLoadingNextPage):
            var newState = state
            newState.isLoadingNextPage = isLoadingNextPage
            return newState
        }
    }
    
    private func url(query: String?, page: Int) -> URL? {
        guard let query = query, !query.isEmpty else { return nil }
        return URL(string: "https://api.github.com/search/repositories?q=\(query)&page=\(page)")
    }
    
    private func search(query: String?, page: Int) -> Observable<(repos: [GithubRepo], nextPage: Int?)> {
        let emptyResult: ([GithubRepo], Int?) = ([], nil)
        
        guard let url = url(query: query, page: page) else {
            return Observable.just(emptyResult)
        }
        
        return URLSession.shared.rx.json(url: url)
            .map({ json -> ([GithubRepo], Int?) in
                guard
                    let dict = json as? [String: Any],
                    let items = dict["items"] as? [[String: Any]]
                else { return emptyResult }
                let repos = items.compactMap { item -> GithubRepo? in
                    guard
                        let name = item["full_name"] as? String,
                        let star = item["stargazers_count"] as? Int
                    else { return nil }
                    return GithubRepo(name: name, stargazersCount: star)
                }
                let nextPage = repos.isEmpty ? nil : page + 1
                return (repos, nextPage)
            })
            .do(onError: { error in
                if case let .some(.httpRequestFailed(response, _)) = error as? RxCocoaURLError, response.statusCode == 403 {
                    print("github API rate limit exceeded.")
                }
            })
            .catchErrorJustReturn(emptyResult)
    }
}

extension GithubSearchViewReactor.Action {
    static func isUpdateQueryAction(_ action: GithubSearchViewReactor.Action) -> Bool {
        if case .updateQuery = action {
            return true
        } else {
            return false
        }
    }
}
