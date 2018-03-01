//
//  LocalizedTextProvider.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 18/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import RxSwift
import RealmSwift

public protocol LocalizedTextProvider {
    func observeText(for key: String) -> Observable<String>
}

class RealmTextProvider {

    private let realm: Realm
    private let localizedElementInsertions: Observable<[LocalizedElement]>

    init(configuration: Realm.Configuration = .defaultConfiguration) throws {
        realm = try Realm(configuration: configuration)

        let localizedElements = realm.objects(LocalizedElement.self)
        localizedElementInsertions = Observable.arrayWithChangeset(from: localizedElements, synchronousStart: false)
            .flatMap { array, changes -> Observable<[LocalizedElement]> in
                guard let changes = changes, !changes.inserted.isEmpty else {
                    return .empty()
                }
                return .just(changes.inserted.map { array[$0] })
            }
            .share(replay: 1, scope: .whileConnected)
    }
}

extension RealmTextProvider: LocalizedTextProvider {
    func observeText(for key: String) -> Observable<String> {
        guard let localizedElement = realm.object(ofType: LocalizedElement.self, forPrimaryKey: key) else {
            return localizedElementInsertions
                .map { $0.first(where: { $0.key == key }) }
                .flatMap { $0 != nil ? Observable.from(object: $0!) : .empty() }
                .map { $0.text }
        }
        return Observable.from(object: localizedElement).map { $0.text }
    }
}
