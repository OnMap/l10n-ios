//
//  UIBarButtonItem+.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 13/11/2017.
//

import UIKit

private var runtimeTitleKey: UInt8 = 0

extension UIBarButtonItem: TitleLocalizable {

    @IBInspectable
    public var titleKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeTitleKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeTitleKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            title = newValue
        }
    }
}
