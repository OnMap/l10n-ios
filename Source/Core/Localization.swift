//
//  Localization.swift
//  OML10n
//
//  Created by Philip Kramer on 08/01/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import UIKit

public enum Language: String {
    case english = "en"
    case hebrew = "he"
    case russian = "ru"
}

public class Localization: NSObject {

    private enum Constants {
        static let userLanguageSavedKey = "UserLanguageSavedKey"
        static let defaultLanguage: Language = .hebrew
    }

    public static func setupCurrentLanguage() {
        Bundle.update(language: currentLanguage)
    }

    public static var availableLanguages: [Language] {
        // Don't include "Base" in available languages
        let localizations = Bundle.main.localizations.filter { $0 != "Base" }
        return localizations.flatMap { Language(rawValue: $0) }
    }

    public static var currentLocale: Locale {
        return Locale(identifier: currentLanguage.rawValue)
    }

    public static var currentLanguage: Language {
        get {
            if let currentLanguage = UserDefaults.standard.object(forKey: Constants.userLanguageSavedKey) as? String {
                return Language(rawValue: currentLanguage) ?? Constants.defaultLanguage
            } else if let preferredLanguageValue = Bundle.main.preferredLocalizations.first,
                let preferredLanguage = Language(rawValue: preferredLanguageValue),
                availableLanguages.contains(preferredLanguage) {
                // Change back to preferredLanguage for supporting other languages
                return Constants.defaultLanguage
            } else {
                return Constants.defaultLanguage
            }
        }
        set {
            UserDefaults.standard.setValue(newValue.rawValue, forKey: Constants.userLanguageSavedKey)
            UserDefaults.standard.synchronize()
            Bundle.update(language: newValue)
        }
    }

    public static var isRTL: Bool {
        return Locale.characterDirection(forLanguage: currentLanguage.rawValue) == .rightToLeft
    }

    public static func displayNameForLanguage(_ language: Language, inLanguge: Language) -> String {
        let locale = NSLocale(localeIdentifier: inLanguge.rawValue)
        return locale.displayName(forKey: NSLocale.Key.identifier, value: language.rawValue) ?? ""
    }

}

// MARK: Bundle Handling

var bundleKey = 0

public class BundleEx: Bundle {

    public override func localizedString(forKey key: String,
                                         value: String?,
                                         table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }

        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }

}

extension Bundle {

    static func update(language: Language) {

        DispatchQueue.once(sender: self) {
            object_setClass(main, BundleEx.self)
        }

        updateLocalizationAttributes()

        let bundlePath = Bundle(path: Bundle.main.path(forResource: language.rawValue, ofType: "lproj")!)

        objc_setAssociatedObject(Bundle.main, &bundleKey, bundlePath,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    static func updateLocalizationAttributes() {
        let semanticContentAttribute: UISemanticContentAttribute = Localization.isRTL ? .forceRightToLeft : .forceLeftToRight

        UIView.appearance().semanticContentAttribute = semanticContentAttribute
        UINavigationBar.appearance().semanticContentAttribute = semanticContentAttribute

        UserDefaults.standard.set(Localization.isRTL, forKey: "AppleTextDirection")
        UserDefaults.standard.set(Localization.isRTL, forKey: "NSForceRightToLeftWritingDirection")
        UserDefaults.standard.synchronize()
    }
}

public extension DispatchQueue {

    private static var _onceTracker = [String]()

    static func once(sender: AnyObject, _ block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

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
