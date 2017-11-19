//
//  UIKit+Localization.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 14/11/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import UIKit

private var runtimeLocalizationKey: UInt8 = 0

let separator = "."

enum TextFieldLocalizedProperty: String {
    case text, placeholder
}

enum ButtonLocalizedProperty: String {
    case normal, highlighted, selected, disabled
}

enum NavigationItemLocalizedProperty: String {
    case title, prompt, backButtonTitle
}

enum SearchBarLocalizedProperty: String {
    case text, placeholder, prompt
}

extension UIButton {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            guard let newValue = newValue, !newValue.isEmpty else { return }
            let properties: [(ButtonLocalizedProperty, UIControlState)] = [
                (.normal, .normal),
                (.selected, .selected),
                (.highlighted, .highlighted),
                (.disabled, .disabled)
            ]
            properties.forEach { property, state in
                let key = newValue + separator + property.description
                let text = localized(key)
                if text != key || state == .normal {
                    setTitle(text, for: state)
                }
            }
        }
    }
}

extension UILabel {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            guard let newValue = newValue, !newValue.isEmpty else { return }
            text = localized(newValue)
        }
    }
}

extension UITextField {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            guard let newValue = newValue, !newValue.isEmpty else { return }

            let textKey = newValue + separator + TextFieldLocalizedProperty.text.description
            let text = localized(textKey)
            if text != textKey {
                self.text = text
            }

            let placeholderKey = newValue + separator + TextFieldLocalizedProperty.placeholder.description
            let placeholder = localized(placeholderKey)
            if placeholder != placeholderKey {
                self.placeholder = placeholder
            }
        }
    }
}

extension UITextView {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            guard let newValue = newValue, !newValue.isEmpty else { return }

            let text = localized(newValue)
            if text != newValue {
                self.text = text
            }
        }
    }
}

extension UISearchBar {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            guard let newValue = newValue, !newValue.isEmpty else { return }

            let textKey = newValue + separator + SearchBarLocalizedProperty.text.description
            let text = localized(textKey)
            if text != textKey {
                self.text = text
            }

            let placeholderKey = newValue + separator + SearchBarLocalizedProperty.placeholder.description
            let placeholder = localized(placeholderKey)
            if placeholder != placeholderKey {
                self.placeholder = placeholder
            }

            let promptKey = newValue + separator + SearchBarLocalizedProperty.prompt.description
            let prompt = localized(promptKey)
            if prompt != promptKey {
                self.prompt = prompt
            }
        }
    }
}

extension UISegmentedControl {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            guard let newValue = newValue, !newValue.isEmpty else { return }

            (0..<numberOfSegments).forEach { index in
                let title = localized(newValue + separator + String(index))
                setTitle(title, forSegmentAt: index)
            }
        }
    }
}

extension UINavigationItem {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            guard let newValue = newValue, !newValue.isEmpty else { return }

            title = localized(newValue + separator + NavigationItemLocalizedProperty.title.description)

            let promptKey = newValue + separator + NavigationItemLocalizedProperty.prompt.description
            let prompt = localized(promptKey)
            if prompt != promptKey {
                self.prompt = prompt
            }

            let backButtonTitleKey = newValue + separator + SearchBarLocalizedProperty.prompt.description
            let backButtonTitle = localized(backButtonTitleKey)
            if backButtonTitle != backButtonTitleKey {
                backBarButtonItem?.title = backButtonTitle
            }
        }
    }
}

extension UIBarButtonItem {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            guard let newValue = newValue, !newValue.isEmpty else { return }
            title = localized(newValue)
        }
    }
}

// LocalizedProperty extension

extension TextFieldLocalizedProperty: CustomStringConvertible {
    var description: String {
        return rawValue.capitalized
    }
}

extension SearchBarLocalizedProperty: CustomStringConvertible {
    var description: String {
        return rawValue.capitalized
    }
}

extension ButtonLocalizedProperty: CustomStringConvertible {
    var description: String {
        return rawValue.capitalized
    }
}

extension NavigationItemLocalizedProperty: CustomStringConvertible {
    var description: String {
        return rawValue.capitalized
    }
}
