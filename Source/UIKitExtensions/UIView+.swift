//
//  UIView+.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 14/11/2017.
//

import UIKit

private var runtimeLocalizationKey: UInt8 = 0

extension UIView {

    @IBInspectable
    public var localizationKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
