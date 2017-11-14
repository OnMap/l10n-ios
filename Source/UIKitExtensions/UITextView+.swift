//
//  UITextView+.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 13/11/2017.
//

import UIKit

private var runtimeTextKey: UInt8 = 0

extension UITextView: TextLocalizable {

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
