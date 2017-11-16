//
//  UIKit+Localization.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 14/11/2017.
//

import UIKit

private var runtimeLocalizationKey: UInt8 = 0

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
            text = localized(newValue + separator + TextFieldLocalizedProperty.text.description)

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
            text = localized(newValue)
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
            text = localized(newValue + separator + SearchBarLocalizedProperty.text.description)

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

            title = localized(newValue + separator + NavigationItemLocalizedProperty.text.description)

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
