//
//  LiveUpdatable.swift
//  LocalizationTest
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift
import RxRealm
import NSObject_Rx

/*
 There are two ways to receive live updates in UIViewController:

 1. Implement protocol LiveUpdatable and write next line in viewDidLoad():

    createLocalizedObjects(from: view, language: currentLanguage)

 2. Inherit from LiveUpdatableViewController, where it's done for you
 */

public protocol LiveUpdatable: class {
    var localizedViews: [String: Localizable] { get set }
    func createLocalizedViews(from view: UIView, language: LocalizedLanguages)
}

public enum LocalizedLanguages {
    case english, hebrew, russian
}

extension LiveUpdatable where Self: NSObject {

    public func createLocalizedViews(from view: UIView, language: LocalizedLanguages) {
        localizedViews = getLocalizedObjects(from: view)
        configureLiveUpdating(for: language)
    }

    private func configureLiveUpdating(for language: LocalizedLanguages) {
        let realmConfig: RealmConfig
        switch language {
        case .english:
            realmConfig = .english
        case .hebrew:
            realmConfig = .hebrew
        case .russian:
            realmConfig = .russian
        }
        do {
            let realm = try Realm(realmConfig: realmConfig)
            let localizedTexts = realm.objects(LocalizedText.self)
            Observable.arrayWithChangeset(from: localizedTexts)
                .subscribe(onNext: { [weak self] array, changes in
                    self?.updateViews(from: array, with: changes)
                })
                .disposed(by: rx.disposeBag)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func getLocalizedObjects(from view: UIView) -> [String: Localizable] {
        if view.subviews.isEmpty {
            if let textLocalizable = view as? TextLocalizable,
                let key = textLocalizable.localizedTextKey {
                return [key: textLocalizable]
            } else {
                return [:]
            }
        }
        var localizedObjects: [String: Localizable] = [:]
        view.subviews.forEach { subview in
            for (key, value) in getLocalizedObjects(from: subview) {
                localizedObjects[key] = value
            }
        }
        return localizedObjects
    }

    private func updateViews(from array: [LocalizedText], with changes: RealmChangeset?) {
        if let changes = changes {
            // Updates
            changes.inserted.forEach { insertedIndex in
                let localizedText = array[insertedIndex]
                updateLocalizables(with: localizedText)
            }
            changes.updated.forEach { updatedIndex in
                let localizedText = array[updatedIndex]
                updateLocalizables(with: localizedText)
            }
            changes.deleted.forEach { _ in
                print("WARNING: LocalizationText was deleted")
            }
        } else {
            // Initial
            array.forEach { localizedText in
                updateLocalizables(with: localizedText)
            }
        }
    }

    private func updateLocalizables(with localizedText: LocalizedText) {
        let view = localizedViews[localizedText.key]
        if let label = view as? UILabel {
            label.text = localizedText.text
        } else {
            print("""
                The key \(localizedText.key) with text \(localizedText.text) exists,
                but there is no such object in the view hierarchy:
                \(localizedViews)
                """
            )
        }
    }
}
