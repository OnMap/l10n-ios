//
//  LiveUpdatesService.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 17/08/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import Foundation
import RealmSwift

typealias JSONDictionary = [String: Any]

public protocol LocalizationProvider {
    func localizationsJSON(completion: @escaping ([String: Any]?, Error?) -> Void)
}

public protocol LiveUpdatesProvider {
    func startObservingChanges(parsingBlock: @escaping ([String: Any]) -> Void)
    func stopObservingChanges()
}

public class LiveUpdatesService {

    let localizationProvider: LocalizationProvider
    let liveUpdatesProvider: LiveUpdatesProvider

    public init(localizationProvider: LocalizationProvider, liveUpdatesProvider: LiveUpdatesProvider, clearRun: Bool = true) {
        self.localizationProvider = localizationProvider
        self.liveUpdatesProvider = liveUpdatesProvider

        if clearRun {
            Localization.availableLanguages.forEach(Realm.delete)
        }

        localizationProvider.localizationsJSON { [weak self] json, error in
            if let error = error {
                print(error.localizedDescription)
            }
            if let json = json {
                DispatchQueue.global(qos: .userInitiated).async {
                    self?.parse(json)
                }
            }
        }

        liveUpdatesProvider.startObservingChanges { [weak self] json in
            DispatchQueue.global(qos: .userInitiated).async {
                self?.parse(json)
            }
        }
    }

    // MARK: - Private

    private func parse(_ json: JSONDictionary) {
        json.forEach { key, value in
            if let languageDict = value as? JSONDictionary {
                addLocalizedTexts(json: languageDict, configName: key)
            }
        }
    }

    private func addLocalizedTexts(json: JSONDictionary, configName: String) {
        let localizedElements = json.flatMap { key, value -> LocalizedElement? in
            guard let text = value as? String else { return nil }
            return LocalizedElement(key: key, text: text)
        }
        do {
            let realm = try Realm(configuration: Realm.configuration(name: configName))
            try realm.write { realm.add(localizedElements, update: true) }
        } catch {
            print(error.localizedDescription)
        }
    }
}
