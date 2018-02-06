//
//  Localization.swift
//  OML10n
//
//  Created by Philip Kramer on 08/01/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import UIKit

public class Localization: NSObject {

    private enum Constants {
        static let userLanguageSavedKey = "UserLanguageSavedKey"
    }

    private static var usePreferredLanguage: Bool!

    public static func setup(usePreferredLanguage: Bool = true) {
        Localization.usePreferredLanguage = usePreferredLanguage
        Bundle.update(language: currentLanguage)
    }

    public static var availableLanguages: [String] {
        // Don't include "Base" in available languages
        return Bundle.main.localizations.filter { $0 != "Base" }
    }

    public static var currentLocale: Locale {
        return Locale(identifier: currentLanguage)
    }

    public static var currentLanguage: String {
        get {
            if let currentLanguage = UserDefaults.standard.string(forKey: Constants.userLanguageSavedKey) {
                return currentLanguage
            } else if usePreferredLanguage,
                let preferredLanguage = Bundle.main.preferredLocalizations.first,
                availableLanguages.contains(preferredLanguage) {
                return preferredLanguage
            } else {
                return "Base"
            }
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Constants.userLanguageSavedKey)
            UserDefaults.standard.synchronize()
            Bundle.update(language: newValue)
        }
    }

    public static var isRTL: Bool {
        return Locale.characterDirection(forLanguage: currentLanguage) == .rightToLeft
    }

    public static func displayName(for language: String, inLanguge: String? = nil) -> String? {
        let locale = NSLocale(localeIdentifier: inLanguge ?? language)
        return locale.displayName(forKey: NSLocale.Key.identifier, value: language)
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

    static func update(language: String) {

        DispatchQueue.once(sender: self) {
            object_setClass(main, BundleEx.self)
        }

        updateLocalizationAttributes()

        let bundlePath = Bundle(path: Bundle.main.path(forResource: language, ofType: "lproj")!)

        objc_setAssociatedObject(Bundle.main, &bundleKey, bundlePath,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    static func updateLocalizationAttributes() {
        let isRTL = Localization.isRTL
        let semanticContentAttribute: UISemanticContentAttribute = isRTL ? .forceRightToLeft : .forceLeftToRight

        UIView.appearance().semanticContentAttribute = semanticContentAttribute
        UINavigationBar.appearance().semanticContentAttribute = semanticContentAttribute

        UserDefaults.standard.set(isRTL, forKey: "AppleTextDirection")
        UserDefaults.standard.set(isRTL, forKey: "NSForceRightToLeftWritingDirection")
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
