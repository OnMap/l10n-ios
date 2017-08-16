//
//  UIKit+.swift
//  LocalizationTest
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import UIKit

protocol Localizable: class {
    var localizedKey: String? { get set }
}

protocol TextLocalizable: Localizable {
    var localizedTextKey: String? { get set }
}

extension TextLocalizable {
    var localizedKey: String? {
        get { return localizedTextKey }
        set { localizedTextKey = newValue }
    }
}

extension UILabel: TextLocalizable {

    @IBInspectable public var localizedTextKey: String? {
        get {
            return text
        }

        set {
            guard let newValue = newValue else { return }
            text = localized(newValue)
        }
    }
}
