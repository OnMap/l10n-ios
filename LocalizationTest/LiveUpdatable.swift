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

/*
 There are two ways to receive live updates in UIViewController:

 1. Implement protocol LiveUpdatable and write next two lines in viewDidLoad():

    localizationDictionary = localizationDictionary(from: view)
    configureLiveUpdating()

 2. Inherit from LiveUpdatableViewController
 */

protocol LiveUpdatable {
    var disposeBag: DisposeBag { get }
    var localizationDictionary: [String: Localizable] { get set }
}

extension LiveUpdatable {

    func localizationDictionary(from view: UIView) -> [String: Localizable] {
        if view.subviews.isEmpty {
            if let textLocalizable = view as? TextLocalizable,
                let key = textLocalizable.localizedTextKey {
                return [key: textLocalizable]
            }
        }
        var localizationDict: [String: Localizable] = [:]
        view.subviews.forEach { subview in
            for (key, value) in localizationDictionary(from: subview) {
                localizationDict[key] = value
            }
        }
        return localizationDict
    }

    func configureLiveUpdating() {
        do {
            let realm = try Realm(configuration: RealmConfig.currentLocalization.configuration)
            let localizedTexts = realm.objects(LocalizedText.self)
            Observable.arrayWithChangeset(from: localizedTexts)
                .subscribe(onNext: { array, changes in
                    self.updateViews(from: array, with: changes)
                })
                .disposed(by: disposeBag)
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

    // MARK: - Properties

    var disposeBag = DisposeBag()
    var localizationDictionary: [String: Localizable] = [:]

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        localizationDictionary = localizationDictionary(from: view)
        configureLiveUpdating()
    }
}
