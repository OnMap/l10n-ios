//
//  Localizable.swift
//  LocalizationExample
//
//  Created by Alex Alexandrovych on 04/05/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import Foundation
import RealmSwift

func localized(_ key: String) -> String {
    let localizedString = Bundle.main.localizedString(forKey: key, value: key, table: nil)
    guard localizedString != key && !localizedString.isEmpty else {
        print("We should register this key: \(key)")
        return key
    }
    return Bundle.main.localizedString(forKey: key, value: key, table: nil)
}

func localized(_ key: String, args: [CVarArg]) -> String {
    let format = localized(key)
    return withVaList(args) { arguments -> String in
        return NSString(format: format, locale: Localization.currentLocale, arguments: arguments) as String
    }
}
