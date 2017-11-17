//
//  RealmConfig.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 20/07/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import Foundation
import RealmSwift

enum RealmConfig {

    case english, hebrew, russian

    // MARK: - Private configurations
    private static let englishConfig = Realm.Configuration(
        fileURL: URL.inDocumentsFolder(fileName: "englishLocalization.realm")
    )

    private static let hebrewConfig = Realm.Configuration(
        fileURL: URL.inDocumentsFolder(fileName: "hebrewLocalization.realm")
    )

    private static let russianConfig = Realm.Configuration(
        fileURL: URL.inDocumentsFolder(fileName: "russianLocalization.realm")
    )

    // MARK: - Current configuration

    var configuration: Realm.Configuration {
        switch self {
        case .english: return RealmConfig.englishConfig
        case .hebrew: return RealmConfig.hebrewConfig
        case .russian: return RealmConfig.russianConfig
        }
    }

    func delete() {
        guard let url = configuration.fileURL else { return }
        let realmURLsToDelete = [
            url,
            url.appendingPathExtension("lock"),
            url.appendingPathExtension("note"),
            url.appendingPathExtension("management")
        ]
        realmURLsToDelete.forEach { url in
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

extension Realm {
    convenience init(realmConfig: RealmConfig) throws {
        try self.init(configuration: realmConfig.configuration)
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

