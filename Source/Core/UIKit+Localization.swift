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
                var text = localized(key)

                if text == nil && state == .normal {
                    text = key
                }

                if let mutableAttributedText = attributedTitle(for: state)?.mutableCopy() as? NSMutableAttributedString,
                    let text = text {
                    mutableAttributedText.mutableString.setString(text)
                    let attributedText = mutableAttributedText as NSAttributedString
                    setAttributedTitle(attributedText, for: state)
                } else {
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

            let text = localized(newValue) ?? newValue

            if let mutableAttributedText = attributedText?.mutableCopy() as? NSMutableAttributedString {
                mutableAttributedText.mutableString.setString(text)
                attributedText = mutableAttributedText as NSAttributedString
            } else {
                self.text = text
            }
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

            if let text = localized(textKey) {
                if let mutableAttributedText = attributedText?.mutableCopy() as? NSMutableAttributedString {
                    mutableAttributedText.mutableString.setString(text)
                    attributedText = mutableAttributedText as NSAttributedString
                } else {
                    self.text = text
                }
            }

            let placeholderKey = newValue + separator + TextFieldLocalizedProperty.placeholder.description

            if let placeholder = localized(placeholderKey) {
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

            if let text = localized(newValue) {
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
            if let text = localized(textKey) {
                self.text = text
            }

            let placeholderKey = newValue + separator + SearchBarLocalizedProperty.placeholder.description
            if let placeholder = localized(placeholderKey) {
                self.placeholder = placeholder
            }

            let promptKey = newValue + separator + SearchBarLocalizedProperty.prompt.description
            if let prompt = localized(promptKey) {
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

            title = localized(newValue + separator + NavigationItemLocalizedProperty.title.description) ?? newValue

            let promptKey = newValue + separator + NavigationItemLocalizedProperty.prompt.description
            if let prompt = localized(promptKey) {
                self.prompt = prompt
            }

            let backButtonTitleKey = newValue + separator + NavigationItemLocalizedProperty.backButtonTitle.description
            if let backButtonTitle = localized(backButtonTitleKey) {
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
            title = localized(newValue) ?? newValue
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
