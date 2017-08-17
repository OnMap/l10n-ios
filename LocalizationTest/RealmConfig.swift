//
//  RealmConfig.swift
//  OnMap
//
//  Created by Alex Alexandrovych on 20/07/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import Foundation
import RealmSwift

enum RealmConfig {

    case currentLocalization
    case englishLocalization
    case hebrewLocalization
    case russianLocalization

    // MARK: - Private configurations
    private static let englishLocalizationConfig = Realm.Configuration(
        fileURL: URL.inDocumentsFolder(fileName: "englishLocalization.realm")
    )

    private static let hebrewLocalizationConfig = Realm.Configuration(
        fileURL: URL.inDocumentsFolder(fileName: "hebrewLocalization.realm")
    )

    private static let russianLocalizationConfig = Realm.Configuration(
        fileURL: URL.inDocumentsFolder(fileName: "russianLocalization.realm")
    )

    // MARK: - Current configuration
    var configuration: Realm.Configuration {
        switch self {
        case .currentLocalization:
            switch Localization.currentLanguage {
                case .english: return RealmConfig.englishLocalizationConfig
                case .hebrew: return RealmConfig.hebrewLocalizationConfig
                case .russian: return RealmConfig.russianLocalizationConfig
            }
        case .englishLocalization: return RealmConfig.englishLocalizationConfig
        case .hebrewLocalization: return RealmConfig.hebrewLocalizationConfig
        case .russianLocalization: return RealmConfig.russianLocalizationConfig
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

