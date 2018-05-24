//
//  Localizable.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 04/05/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import Foundation

/**
 Returns localized text for given key or key if text doesn't exists or is empty
 */
public func localized(_ key: String, bundle: Bundle = Bundle.main) -> String? {
    let localizedString = bundle.localizedString(forKey: key, value: key, table: nil)
    guard localizedString != key && !localizedString.isEmpty else {
        return nil
    }
    return localizedString
}

/**
 Returns localized text for given key in plural form with given count as args
 */
public func localized(_ key: String, args: [CVarArg]) -> String {
    let format = localized(key) ?? key
    return withVaList(args) { arguments -> String in
        return NSString(format: format, locale: Localization.currentLocale, arguments: arguments) as String
    }
}
