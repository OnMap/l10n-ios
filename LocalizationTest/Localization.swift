//
//  Localization.swift
//  OnMap
//
//  Created by Philip Kramer on 08/01/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import UIKit

enum Language: String {
    case english = "en"
    case hebrew = "he"
    case russian = "ru"
}

class Localization: NSObject {

    fileprivate enum Keys {
        static let userLanguageSavedKey = "UserLanguageSavedKey"
        static let defaultLanguage: Language = .hebrew
    }

    public class func setupCurrentLanguage() {
        Bundle.update(language: currentLanguage)
    }

    public class var availableLanguages: [Language] {
        // Don't include "Base" in available languages
        let localizations = Bundle.main.localizations.filter { $0 != "Base" }
        return localizations.flatMap { Language(rawValue: $0) }
    }

    public class var currentLocale: Locale {
        return Locale(identifier: currentLanguage.rawValue)
    }

    public class var currentLanguage: Language {
        get {
            guard let currentLanguage = UserDefaults.standard.object(forKey: Keys.userLanguageSavedKey)
                as? String else {
                    if let preferredLanguageValue = Bundle.main.preferredLocalizations.first,
                        let preferredLanguage = Language(rawValue: preferredLanguageValue),
                        availableLanguages.contains(preferredLanguage) {
                        // Change back to preferredLanguage for supporting other languages
                        return Keys.defaultLanguage
                    } else {
                        return Keys.defaultLanguage
                    }
            }
            return Language(rawValue: currentLanguage) ?? Keys.defaultLanguage
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.userLanguageSavedKey)
            UserDefaults.standard.synchronize()
            Bundle.update(language: newValue)
        }
    }

    public class var isRTL: Bool {
        return Locale.characterDirection(forLanguage: currentLanguage.rawValue) == .rightToLeft
    }

    class func displayNameForLanguage(_ language: Language, inLanguge: Language) -> String {
        let locale = NSLocale(localeIdentifier: inLanguge.rawValue)
        return locale.displayName(forKey: NSLocale.Key.identifier, value: language.rawValue) ?? ""
    }

}

// MARK: Bundle Handling

var bundleKey = 0

class BundleEx: Bundle {

    override func localizedString(forKey key: String,
                                  value: String?,
                                  table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }

        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }

}

extension Bundle {

    class func update(language: Language) {

        DispatchQueue.once(sender: self) {
            object_setClass(self.main, BundleEx.self)
        }

        UIView.appearance().semanticContentAttribute =
            Localization.isRTL ? .forceRightToLeft : .forceLeftToRight
        UINavigationBar.appearance().semanticContentAttribute =
            Localization.isRTL ? .forceRightToLeft : .forceLeftToRight

        UserDefaults.standard.set(Localization.isRTL, forKey: "AppleTextDirection")
        UserDefaults.standard.set(Localization.isRTL, forKey: "NSForceRightToLeftWritingDirection")
        UserDefaults.standard.synchronize()

        let bundlePath = Bundle.init(path: Bundle.main.path(forResource: language.rawValue, ofType: "lproj")!)

        objc_setAssociatedObject(Bundle.main, &bundleKey, bundlePath,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

}

public extension DispatchQueue {

    private static var _onceTracker = [String]()

    public class func once(sender: AnyObject, _ block: () -> Void) {
        objc_sync_enter(self); defer { objc_sync_exit(self) }

        func address<T: AnyObject>(object: T) -> String {
            let addr = unsafeBitCast(object, to: Int.self)
            return NSString(format: "%p", addr) as String
        }

        let senderPointer = address(object: sender)
        if _onceTracker.contains(senderPointer) {
            return
        }

        _onceTracker.append(senderPointer)
        block()
    }

}
