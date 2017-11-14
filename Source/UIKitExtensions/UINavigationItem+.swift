//
//  UINavigationItem+.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 13/11/2017.
//

import UIKit

private var runtimeLocalizationKey: UInt8 = 0

extension UINavigationItem {

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
