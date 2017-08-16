//
//  Localizable.swift
//  OnMap
//
//  Created by Alex Alexandrovych on 04/05/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import Foundation
import RealmSwift

func localized(_ key: String) -> String {
    #if REMOTE_LOCALIZATION
        return localizedRemote(key)
    #endif
    return localizedLocal(key)
}

func localizedLocal(_ key: String) -> String {
    let localizedString = Bundle.main.localizedString(forKey: key, value: key, table: nil)
    guard localizedString != key && !key.isEmpty else {
        print("We should register this key: \(key)")
        return key
    }
    return Bundle.main.localizedString(forKey: key, value: key, table: nil)
}

func localizedRemote(_ key: String) -> String {
        do {
            let realm = try Realm(configuration: RealmConfig.localization.configuration)
            if let localizedText = realm.object(ofType: LocalizedText.self, forPrimaryKey: key) {
                return localizedText.text
            } else {
                print("There is no translation with key \(key) in realm")
                return key
            }
        } catch {
            print(error.localizedDescription)
            return key
        }
}

func localized(_ key: String, args: [CVarArg]) -> String {
    let format = localized(key)
    return withVaList(args) { arguments -> String in
        return NSString(format: format, locale: Localization.currentLocale, arguments: arguments) as String
    }
}
