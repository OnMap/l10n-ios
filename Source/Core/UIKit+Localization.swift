//
//  UIKit+Localization.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 14/11/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import UIKit

private var runtimeLocalizationKey: UInt8 = 0
private var runtimeBundleKey: UInt8 = 0

public protocol Localizable {
    var localizationKey: String? { get set }
    var separator: String { get }
}

extension Localizable {

    public var separator: String {
        return "."
    }

    public var bundle: Bundle {
        get {
            let bundle = objc_getAssociatedObject(self, &runtimeBundleKey) as? Bundle
            return bundle ?? Bundle.main
        }
        set {
            objc_setAssociatedObject(self, &runtimeBundleKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

extension UIButton: Localizable {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            guard let key = newValue, !key.isEmpty else { return }

            let properties: [(ButtonLocalizedProperty, UIControlState)] = [
                (.normal, .normal),
                (.selected, .selected),
                (.highlighted, .highlighted),
                (.disabled, .disabled)
            ]

            properties.forEach { property, state in
                let propertyKey = key + separator + property.description
                var newTitle = localized(propertyKey, bundle: bundle)

                // Make possible to not specify "*.Normal" in Localizable.strings
                // for setting title with .normal state.
                // If not found set key as a title
                if newTitle == nil && state == .normal {
                    newTitle = localized(key, bundle: bundle) ?? key
                }

                if let mutableAttributedText = attributedTitle(for: state)?.mutableCopy() as? NSMutableAttributedString,
                    let title = newTitle {
                    mutableAttributedText.mutableString.setString(title)
                    let attributedText = mutableAttributedText as NSAttributedString
                    setAttributedTitle(attributedText, for: state)
                } else {
                    setTitle(newTitle, for: state)
                }
            }
        }
    }
}

extension UILabel: Localizable {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            guard let key = newValue, !key.isEmpty else { return }

            let text = localized(key, bundle: bundle) ?? key

            if let mutableAttributedText = attributedText?.mutableCopy() as? NSMutableAttributedString {
                mutableAttributedText.mutableString.setString(text)
                attributedText = mutableAttributedText as NSAttributedString
            } else {
                self.text = text
            }
        }
    }
}

extension UITextField: Localizable {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            guard let key = newValue, !key.isEmpty else { return }

            let textKey = key + separator + TextFieldLocalizedProperty.text.description

            if let text = localized(textKey, bundle: bundle) {
                if let mutableAttributedText = attributedText?.mutableCopy() as? NSMutableAttributedString {
                    mutableAttributedText.mutableString.setString(text)
                    attributedText = mutableAttributedText as NSAttributedString
                } else {
                    self.text = text
                }
            }

            let placeholderKey = key + separator + TextFieldLocalizedProperty.placeholder.description

            if let placeholder = localized(placeholderKey, bundle: bundle) {
                self.placeholder = placeholder
            }
        }
    }
}

extension UITextView: Localizable {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            guard let key = newValue, !key.isEmpty else { return }

            if let text = localized(key, bundle: bundle) {
                if let mutableAttributedText = attributedText?.mutableCopy() as? NSMutableAttributedString {
                    mutableAttributedText.mutableString.setString(text)
                    attributedText = mutableAttributedText as NSAttributedString
                } else {
                    self.text = text
                }
            }
        }
    }
}

extension UISearchBar: Localizable {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            guard let key = newValue, !key.isEmpty else { return }

            let textKey = key + separator + SearchBarLocalizedProperty.text.description
            if let text = localized(textKey, bundle: bundle) {
                self.text = text
            }

            let placeholderKey = key + separator + SearchBarLocalizedProperty.placeholder.description
            if let placeholder = localized(placeholderKey, bundle: bundle) {
                self.placeholder = placeholder
            }

            let promptKey = key + separator + SearchBarLocalizedProperty.prompt.description
            if let prompt = localized(promptKey, bundle: bundle) {
                self.prompt = prompt
            }
        }
    }
}

extension UISegmentedControl: Localizable {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            guard let key = newValue, !key.isEmpty else { return }

            (0..<numberOfSegments).forEach { index in
                let titleKey = key + separator + String(index)
                let title = localized(titleKey, bundle: bundle)
                setTitle(title, forSegmentAt: index)
            }
        }
    }
}

extension UINavigationItem: Localizable {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            guard let key = newValue, !key.isEmpty else { return }

            let titleKey = key + separator + NavigationItemLocalizedProperty.title.description

            if let title = localized(titleKey, bundle: bundle) {
                self.title = title
            } else {
                // Make possible to not specify "*.Title" in Localizable.strings for setting .title
                self.title = localized(key, bundle: bundle) ?? key
            }

            let promptKey = key + separator + NavigationItemLocalizedProperty.prompt.description
            if let prompt = localized(promptKey, bundle: bundle) {
                self.prompt = prompt
            }

            let backButtonTitleKey = key + separator + NavigationItemLocalizedProperty.backButtonTitle.description
            if let backButtonTitle = localized(backButtonTitleKey, bundle: bundle) {
                backBarButtonItem?.title = backButtonTitle
            }
        }
    }
}

extension UIBarButtonItem: Localizable {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            guard let key = newValue, !key.isEmpty else { return }

            title = localized(key, bundle: bundle) ?? key
        }
    }
}

// MARK: LocalizedProperties

enum TextFieldLocalizedProperty: String, CustomStringConvertible {
    case text, placeholder
}

enum ButtonLocalizedProperty: String, CustomStringConvertible {
    case normal, highlighted, selected, disabled
}

enum NavigationItemLocalizedProperty: String, CustomStringConvertible {
    case title, prompt, backButtonTitle
}

enum SearchBarLocalizedProperty: String, CustomStringConvertible {
    case text, placeholder, prompt
}

extension CustomStringConvertible where Self: RawRepresentable, Self.RawValue == String {
    var description: String {
        return rawValue.capitalized
    }
}
