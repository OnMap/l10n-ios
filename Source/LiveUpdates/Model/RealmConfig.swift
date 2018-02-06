//
//  RealmConfig.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 20/07/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import RealmSwift

extension Realm {

    static func configuration(language: String) -> Realm.Configuration {
        return Realm.Configuration(fileURL: URL.inDocumentsFolder(fileName: language + "Localization.realm"))
    }

    static func delete(language: String) {
        guard let url = configuration(language: language).fileURL else { return }
        let realmURLsToDelete = [
            url,
            url.appendingPathExtension("lock"),
            url.appendingPathExtension("note"),
            url.appendingPathExtension("management")
        ]
        for url in realmURLsToDelete where FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension URL {

    /// returns an absolute URL to the desired file in documents folder
    static func inDocumentsFolder(fileName: String) -> URL {
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true)[0], isDirectory: true)
            .appendingPathComponent(fileName)
    }
}

