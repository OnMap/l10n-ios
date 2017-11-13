//
//  LiveUpdatable.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import RxRealm
import NSObject_Rx

enum TextFieldLocalizedProperty: String {
    case text, placeholder
}

extension TextFieldLocalizedProperty: CustomStringConvertible {
    var description: String {
        return self.rawValue.capitalized
    }
}

enum SearchBarLocalizedProperty: String {
    case text, placeholder, prompt
}

extension SearchBarLocalizedProperty: CustomStringConvertible {
    var description: String {
        return self.rawValue.capitalized
    }
}

enum ButtonLocalizedTitle: String {
    case normal, highlighted, selected, focused, disabled
}

extension ButtonLocalizedTitle: CustomStringConvertible {
    var description: String {
        return self.rawValue.capitalized
    }
}

/*
 In order to receive live updates to a UIViewController it should implement LiveUpdatable protocol
 and then configureLocalizedViews(from:language:) should be called from viewDidLoad()
 */

public typealias LocalizedLanguages = RealmConfig

public protocol LiveUpdatable: class {
    var localizedViews: [String: Localizable] { get set }
    func configureLocalizedViews(from view: UIView, language: LocalizedLanguages)
}

extension LiveUpdatable where Self: UIViewController {

    public func configureLocalizedViews(from view: UIView, language: LocalizedLanguages) {
        localizedViews = getLocalizedViews(from: view)
        if let key = navigationItem.titleKey {
            localizedViews[key] = navigationItem
        }
        configureLiveUpdating(for: language)
    }

    // MARK: - Private

    private func configureLiveUpdating(for language: LocalizedLanguages) {
        do {
            let realm = try Realm(realmConfig: language)
            let localizedElements = realm.objects(LocalizedElement.self)
            Observable.arrayWithChangeset(from: localizedElements)
                .subscribe(onNext: { [weak self] array, changes in
                    self?.updateViews(from: array, with: changes)
                })
                .disposed(by: rx.disposeBag)
        } catch {
            print(error.localizedDescription)
        }
    }

    // Recursively returns all localizable views from a given view
    private func getLocalizedViews(from view: UIView) -> [String: Localizable] {
        var views: [String: Localizable] = [:]

        // We need to check if the view is UITextField or UITextView or UISearchBar,
        // because it contains more subviews that we don't need to work with
        if view.subviews.isEmpty || view is UITextField || view is UITextView || view is UISearchBar {
            if let textLocalizable = view as? TextLocalizable,
                let key = textLocalizable.textKey {
                views[key] = textLocalizable
            }
            if let titleLocalizable = view as? TitleLocalizable,
                let key = titleLocalizable.titleKey {
                views[key] = titleLocalizable
            }
            if let placeholderLocalizable = view as? PlaceholderLocalizable,
                let key = placeholderLocalizable.placeholderKey {
                views[key] = placeholderLocalizable
            }
            if let promptLocalizable = view as? PromptLocalizable,
                let key = promptLocalizable.promptKey {
                views[key] = promptLocalizable
            }
            if let titlesLocalizable = view as? TitlesLocalizable {
                if let normalKey = titlesLocalizable.normalTitleKey {
                    views[normalKey] = titlesLocalizable
                }
                if let highlightedKey = titlesLocalizable.highlightedTitleKey {
                    views[highlightedKey] = titlesLocalizable
                }
                if let selectedKey = titlesLocalizable.selectedTitleKey {
                    views[selectedKey] = titlesLocalizable
                }
                if let focusedKey = titlesLocalizable.focusedTitleKey {
                    views[focusedKey] = titlesLocalizable
                }
                if let disabledKey = titlesLocalizable.disabledTitleKey {
                    views[disabledKey] = titlesLocalizable
                }
            }
            return views
        }
        view.subviews.forEach { subview in
            for (key, value) in getLocalizedViews(from: subview) {
                views[key] = value
            }
        }
        return views
    }

    private func updateViews(from array: [LocalizedElement], with changes: RealmChangeset?) {
        if let changes = changes {
            // Updates
            [changes.inserted, changes.updated].forEach { changes in
                changes.forEach { index in
                    updateLocalizables(with: array[index])
                }
            }
            changes.deleted.forEach { _ in
                print("LocalizationText was deleted")
            }
        } else {
            // Initial
            array.forEach { localizedElement in
                updateLocalizables(with: localizedElement)
            }
        }
    }

    private func updateLocalizables(with localizedElement: LocalizedElement) {
        let view = localizedViews[localizedElement.key]
        let text = localizedElement.text
        let type = localizedElement.type ?? ""

        switch view {
        case let label as UILabel:
            label.text = text
        case let navigationItem as UINavigationItem:
            navigationItem.title = text
        case let barButtonItem as UIBarButtonItem:
            barButtonItem.title = text
        case let textField as UITextField:
            switch type {
            case TextFieldLocalizedProperty.text.description:
                textField.text = text
            case TextFieldLocalizedProperty.placeholder.description:
                textField.placeholder = text
            default:
                textField.text = text
            }
        case let textView as UITextView:
            textView.text = text
        case let searchBar as UISearchBar:
            switch type {
            case SearchBarLocalizedProperty.text.description:
                searchBar.text = text
            case SearchBarLocalizedProperty.placeholder.description:
                searchBar.placeholder = text
            case SearchBarLocalizedProperty.prompt.description:
                searchBar.prompt = text
            default:
                searchBar.text = text
            }
        case let button as UIButton:
            let state: UIControlState
            switch type {
            case ButtonLocalizedTitle.normal.description:
                state = .normal
            case ButtonLocalizedTitle.highlighted.description:
                state = .highlighted
            case ButtonLocalizedTitle.selected.description:
                state = .selected
            case ButtonLocalizedTitle.focused.description:
                state = .focused
            case ButtonLocalizedTitle.disabled.description:
                state = .disabled
            default:
                state = .normal
            }
            button.setTitle(text, for: state)
        default:
            print("""
                The key \(localizedElement.key) with text \(text) exists, but there is no view:
                \(view.debugDescription)
                in the view hierarchy:
                """
            )
            localizedViews.forEach { print($0) }
        }
    }
}
