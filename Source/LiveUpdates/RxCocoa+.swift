//
//  RxCocoa+.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 17/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import RxSwift
import RxCocoa

// Supported properties that are missing in RxCocoa

extension Reactive where Base: UITabBarItem {
    var title: Binder<String?> {
        return Binder(self.base) { tabBarItem, title in
            tabBarItem.title = title
        }
    }
}

extension Reactive where Base: UINavigationItem {
    var prompt: Binder<String?> {
        return Binder(self.base) { navigationItem, prompt in
            navigationItem.prompt = prompt
        }
    }
}

extension Reactive where Base: UITextField {
    var placeholder: Binder<String?> {
        return Binder(self.base) { textField, placeholder in
            textField.placeholder = placeholder
        }
    }
    var attributedPlaceholder: Binder<NSAttributedString?> {
        return Binder(self.base) { textField, attributedPlaceholder in
            textField.attributedPlaceholder = attributedPlaceholder
        }
    }
}

extension Reactive where Base: UISearchBar {
    var placeholder: Binder<String?> {
        return Binder(self.base) { searchBar, placeholder in
            searchBar.placeholder = placeholder
        }
    }
    var prompt: Binder<String?> {
        return Binder(self.base) { searchBar, prompt in
            searchBar.prompt = prompt
        }
    }
}

extension Reactive where Base: UISegmentedControl {
    func setTitle(forSegmentAtIndex index: Int) -> Binder<String?> {
        return Binder(self.base) { segmentedControl, title in
            segmentedControl.setTitle(title, forSegmentAt: index)
        }
    }
}
