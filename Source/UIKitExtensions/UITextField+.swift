//
//  UITextField+.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 13/11/2017.
//

import UIKit

private var runtimeTextKey: UInt8 = 0
private var runtimePlaceholderKey: UInt8 = 0

extension UITextField: TextLocalizable {

    @IBInspectable
    public var textKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeTextKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeTextKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            text = newValue
        }
    }
}

extension UITextField: PlaceholderLocalizable {

    @IBInspectable
    public var placeholderKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimePlaceholderKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimePlaceholderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            placeholder = newValue
        }
    }
}
