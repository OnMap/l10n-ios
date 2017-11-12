//
//  UIKit+.swift
//  LocalizationTest
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import UIKit

public typealias Localizable = TextLocalizable

public protocol TextLocalizable: class {
    var localizedTextKey: String? { get set }
}

private var localizationTextKey: UInt8 = 0

extension UILabel: TextLocalizable {

    @IBInspectable
    public var localizedTextKey: String? {
        get {
            return objc_getAssociatedObject(self, &localizationTextKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &localizationTextKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
}
