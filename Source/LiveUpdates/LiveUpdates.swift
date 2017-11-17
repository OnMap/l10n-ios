//
//  LiveUpdates.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import RxRealm
import NSObject_Rx

let separator = "."

enum TextFieldLocalizedProperty: String {
    case text, placeholder
}

extension TextFieldLocalizedProperty: CustomStringConvertible {
    var description: String {
        return rawValue.capitalized
    }
}

enum SearchBarLocalizedProperty: String {
    case text, placeholder, prompt
}

extension SearchBarLocalizedProperty: CustomStringConvertible {
    var description: String {
        return rawValue.capitalized
    }
}

enum ButtonLocalizedProperty: String {
    case normal, highlighted, selected, disabled
}

extension ButtonLocalizedProperty: CustomStringConvertible {
    var description: String {
        return rawValue.capitalized
    }
}

enum NavigationItemLocalizedProperty: String {
    case text, prompt, backButtonTitle
}

extension NavigationItemLocalizedProperty: CustomStringConvertible {
    var description: String {
        return rawValue.capitalized
    }
}

private var runtimeLocalizationKey: UInt8 = 0

private extension UIViewController {

    var liveUpdates: LiveUpdates? {
        get {
            return objc_getAssociatedObject(self, &runtimeLocalizationKey) as? LiveUpdates
        }
        set {
            objc_setAssociatedObject(self, &runtimeLocalizationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public class LiveUpdates {

    /**
     Created for keeping references to all objects, that should be updated on-the-fly
     */
    private var localizedObjects: [String: AnyObject] = [:]

    private weak var viewController: UIViewController!

    // MARK: Public API

    public static func listenUpdates(for viewController: UIViewController) {
        viewController.liveUpdates = LiveUpdates(viewController: viewController)
    }

    public static func stopListenUpdates(for viewController: UIViewController) {
        viewController.liveUpdates?.stopListenUpdates()
    }

    // MARK: - Private

    /**
     Appends all localized objects to the dictionary and configures live updating
     */
    private init(viewController: UIViewController) {
        self.viewController = viewController

        // Populate objects that shoud be updated live
        localizedObjects = getLocalizedViews(from: viewController.view)

        // Adding NavigationItem and BarButtonItems because they are not in view hierarchy
        let navigationItem = viewController.navigationItem
        if let key = navigationItem.localizationKey {
            let properties: [NavigationItemLocalizedProperty] = [.text, .prompt, .backButtonTitle]
            properties.forEach {
                localizedObjects[key + separator + $0.description] = navigationItem
            }
        }
        let barButtonItems = [navigationItem.leftBarButtonItems ?? [], navigationItem.rightBarButtonItems ?? []]
        barButtonItems.forEach { buttons in
            buttons.forEach { button in
                if let key = button.localizationKey {
                    localizedObjects[key] = button
                }
            }
        }

        // Start observing changes
        configureObservingChanges()
    }

    private func stopListenUpdates() {
        viewController.rx.disposeBag = DisposeBag()
    }

    /**
     Observes changes in Realm for given languge and updates views
     */
    private func configureObservingChanges() {
        let language: RealmConfig
        switch Localization.currentLanguage {
        case .english: language = .english
        case .hebrew: language = .hebrew
        case .russian: language = .russian
        }
        do {
            let realm = try Realm(realmConfig: language)
            let localizedElements = realm.objects(LocalizedElement.self)
            Observable.arrayWithChangeset(from: localizedElements)
                .subscribe(onNext: { [weak self] array, changes in
                    self?.updateViews(from: array, with: changes)
                })
                .disposed(by: viewController.rx.disposeBag)
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

            switch view {
            case let label as UILabel:
                if let key = label.localizationKey {
                    views[key] = label
                }
            case let textView as UITextView:
                if let key = textView.localizationKey {
                    views[key] = textView
                }
            case let textField as UITextField:
                if let key = textField.localizationKey {
                    let properties: [TextFieldLocalizedProperty] = [.text, .placeholder]
                    properties.forEach {
                        views[key + separator + $0.description] = view
                    }
                }
            case let button as UIButton:
                if let key = button.localizationKey {
                    let properties: [ButtonLocalizedProperty] = [.normal, .selected, .highlighted, .disabled]
                    properties.forEach {
                        views[key + separator + $0.description] = view
                    }
                }
            case let searchBar as UISearchBar:
                if let key = searchBar.localizationKey {
                    let properties: [SearchBarLocalizedProperty] = [.text, .placeholder, .prompt]
                    properties.forEach {
                        views[key + separator + $0.description] = view
                    }
                }
            case let segmentedControl as UISegmentedControl:
                if let key = segmentedControl.localizationKey {
                    (0..<segmentedControl.numberOfSegments).forEach { index in
                        views[key + separator + String(index)] = segmentedControl
                    }
                }
            default:
                print("View has unsupported type \(view)")
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
            switch type {
            case NavigationItemLocalizedProperty.prompt.description:
                navigationItem.prompt = text
            case NavigationItemLocalizedProperty.backButtonTitle.description:
                navigationItem.backBarButtonItem?.title = text
            default:
                navigationItem.title = text
            }
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
            print("Object \(object) has unsupported type")
        }
    }
}
