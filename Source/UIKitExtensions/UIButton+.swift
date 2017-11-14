//
//  UIButton+.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 13/11/2017.
//

import UIKit

private var runtimeNormalTitleKey: UInt8 = 0
private var runtimeHighlightedTitleKey: UInt8 = 0
private var runtimeSelectedTitleKey: UInt8 = 0
private var runtimeDisabledTitleKey: UInt8 = 0

extension UIButton: TitlesLocalizable {

    @IBInspectable
    public var normalTitleKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeNormalTitleKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeNormalTitleKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            setTitle(newValue, for: .normal)
        }
    }

    @IBInspectable
    public var highlightedTitleKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeHighlightedTitleKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeHighlightedTitleKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            setTitle(newValue, for: .highlighted)
        }
    }

    @IBInspectable
    public var selectedTitleKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeSelectedTitleKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeSelectedTitleKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            setTitle(newValue, for: .selected)
        }
    }

    @IBInspectable
    public var disabledTitleKey: String? {
        get {
            return objc_getAssociatedObject(self, &runtimeDisabledTitleKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &runtimeDisabledTitleKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            setTitle(newValue, for: .disabled)
        }
    }
}
