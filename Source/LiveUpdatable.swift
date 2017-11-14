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

private let separator = "."

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

enum ButtonLocalizedProperty: String {
    case normal, highlighted, selected, disabled
}

extension ButtonLocalizedProperty: CustomStringConvertible {
    var description: String {
        return self.rawValue.capitalized
    }
}

/*
 In order to receive live updates to a UIViewController it should implement LiveUpdatable protocol
 and then call startLiveUpdates(for: LocalizedLanguages) after all views were added to the view hierarchy
 */

public typealias LocalizedLanguages = RealmConfig

private var runtimeLocalizedViewsKey: UInt8 = 0

public protocol LiveUpdatable: class {
    func startLiveUpdates(for language: LocalizedLanguages)
}

extension LiveUpdatable where Self: UIViewController {

    /**
     Appends localized objects to dictionary and configures live updating
     */
    public func startLiveUpdates(for language: LocalizedLanguages) {
        localizedObjects = getLocalizedViews(from: view)
        if let key = navigationItem.localizationKey {
            localizedObjects[key] = navigationItem
        }
        configureLiveUpdating(for: language)
    }

    // MARK: - Private

    /**
     Localized objects dictionary, created in runtime for keeping
     references to all objects, that should be updated on-the-fly
     */
    private var localizedObjects: [String: AnyObject] {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizedViewsKey) as! [String: AnyObject]
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizedViewsKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    /**
     Observes changes in Realm for given languge and updates views
     */
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

    /**
     Recursively returns all localizable subviews from a given view
     */
    private func getLocalizedViews(from view: UIView) -> [String: UIView] {
        var views: [String: UIView] = [:]

        // We need to check if the view is UITextField or UITextView or UISearchBar or UISegmentedControl,
        // because it contains more subviews that we don't need to work with
        if view.subviews.isEmpty ||
            view is UITextField ||
            view is UITextView ||
            view is UISearchBar ||
            view is UISegmentedControl {

            guard let key = view.localizationKey else { return views }
            views[key] = view

            switch view {
            case is UITextField:
                let properties: [TextFieldLocalizedProperty] = [.text, .placeholder]
                properties.forEach {
                    views[key + separator + $0.description] = view
                }
            case is UIButton:
                let properties: [ButtonLocalizedProperty] = [.normal, .selected, .highlighted, .disabled]
                properties.forEach {
                    views[key + separator + $0.description] = view
                }
            case is UISearchBar:
                let properties: [SearchBarLocalizedProperty] = [.text, .placeholder, .prompt]
                properties.forEach {
                    views[key + separator + $0.description] = view
                }
            case let segmentedControl as UISegmentedControl:
                (0..<segmentedControl.numberOfSegments).forEach { index in
                    views[key + separator + String(index)] = segmentedControl
                }
            default:
                break
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
                    updateLocalizedObject(with: array[index])
                }
            }
            changes.deleted.forEach { _ in
                print("LocalizedElement was deleted")
            }
        } else {
            // Initial
            array.forEach { localizedElement in
                updateLocalizedObject(with: localizedElement)
            }
        }
    }

    private func updateLocalizedObject(with localizedElement: LocalizedElement) {
        let text = localizedElement.text
        let type = localizedElement.key.components(separatedBy: separator).last ?? ""

        guard let object = localizedObjects[localizedElement.key] else {
            print("""
                An element with key \(localizedElement.key) and text \(text) exists,
                but there is no such view in the view hierarchy:
                """
            )
            localizedObjects.forEach { print($0) }
            return
        }

        switch object {
        case let label as UILabel:
            label.text = text
        case let navigationItem as UINavigationItem:
            navigationItem.title = text
        case let barButtonItem as UIBarButtonItem:
            barButtonItem.title = text
        case let textView as UITextView:
            textView.text = text
        case let textField as UITextField:
            switch type {
            case TextFieldLocalizedProperty.placeholder.description:
                textField.placeholder = text
            default:
                textField.text = text
            }
        case let searchBar as UISearchBar:
            switch type {
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
            case ButtonLocalizedProperty.highlighted.description:
                state = .highlighted
            case ButtonLocalizedProperty.selected.description:
                state = .selected
            case ButtonLocalizedProperty.disabled.description:
                state = .disabled
            default:
                state = .normal
            }
            button.setTitle(text, for: state)
        case let segmentedControl as UISegmentedControl:
            segmentedControl.setTitle(text, forSegmentAt: Int(type) ?? 0)
        default:
            print("View \(view) has unsupported type")
        }
    }
}
