//
//  Localizable.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

public protocol Localizable: class { }

protocol TextLocalizable: Localizable {
    var textKey: String? { get set }
}

protocol PlaceholderLocalizable: Localizable {
    var placeholderKey: String? { get set }
}

protocol PromptLocalizable: Localizable {
    var promptKey: String? { get set }
}

protocol TitleLocalizable: Localizable {
    var titleKey: String? { get set }
}

protocol TitlesLocalizable: Localizable {
    var normalTitleKey: String? { get set }
    var highlightedTitleKey: String? { get set }
    var selectedTitleKey: String? { get set }
    var disabledTitleKey: String? { get set }
}
