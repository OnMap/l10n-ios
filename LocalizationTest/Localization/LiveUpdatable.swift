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

    createLocalizationDictionary(from: view)

 2. Inherit from LiveUpdatableViewController, where it's done for you
 */

protocol LiveUpdatable: class {
    var localizationDictionary: [String: Localizable] { get set }
    func createLocalizationDictionary(from view: UIView) -> [String: Localizable]
    func configureLiveUpdating()
}

extension LiveUpdatable where Self: NSObject {

    @discardableResult
    func createLocalizationDictionary(from view: UIView) -> [String: Localizable] {
        if view.subviews.isEmpty {
            if let textLocalizable = view as? TextLocalizable,
                let key = textLocalizable.localizedTextKey {
                return [key: textLocalizable]
            }
        }
        var localizationDict: [String: Localizable] = [:]
        view.subviews.forEach { subview in
            for (key, value) in createLocalizationDictionary(from: subview) {
                localizationDict[key] = value
            }
        }
        self.localizationDictionary = localizationDict
        configureLiveUpdating()
        return localizationDict
    }

    func configureLiveUpdating() {
        do {
            let realm = try Realm(realmConfig: .current)
            let localizedTexts = realm.objects(LocalizedText.self)
            Observable.arrayWithChangeset(from: localizedTexts)
                .subscribe(onNext: { array, changes in
                    self.updateViews(from: array, with: changes)
                })
                .disposed(by: rx.disposeBag)
        } catch {
            print(error.localizedDescription)
        }
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
        if let label = localizationDictionary[localizedText.key] as? UILabel {
            label.text = localizedText.text
        }
    }
}

class LiveUpdatableViewController: UIViewController, LiveUpdatable {

    var localizationDictionary: [String: Localizable] = [:]

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        createLocalizationDictionary(from: view)
    }
}
