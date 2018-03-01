//
//  UIViewController+RxLiveUpdates.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 17/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import UIKit
import RxSwift
import RealmSwift

extension Reactive where Base: UIViewController {

    public func startLiveUpdates(language: String = Localization.currentLanguage, config: Realm.Configuration? = nil) -> Disposable? {
        let configuration = config ?? Realm.configuration(name: language)

        let textProvider: LocalizedTextProvider!
        do {
            textProvider = try RealmTextProvider(configuration: configuration)
        } catch {
            #if DEBUG
                print("Could not start live updating.", error)
            #endif
            return nil
        }

        var disposables: [Disposable] = []

        if let disposable = base.navigationItem.subscribeToUpdates(from: textProvider) {
            disposables.append(disposable)
        }

        let barButtonItems = [
            base.navigationItem.leftBarButtonItems ?? [],
            base.navigationItem.rightBarButtonItems ?? [],
        ]

        barButtonItems.forEach { buttons in
            buttons.forEach { button in
                if let disposable = button.subscribeToUpdates(from: textProvider) {
                    disposables.append(disposable)
                }
            }
        }

        if let tabBarItem = base.tabBarItem, let disposable = tabBarItem.subscribeToUpdates(from: textProvider) {
            disposables.append(disposable)
        }

        if let disposable = startUpdatingViews(for: base.view, from: textProvider) {
            disposables.append(disposable)
        }

        return disposables.isEmpty ? nil : Disposables.create(disposables)
    }

    func startUpdatingViews(for view: UIView, from provider: LocalizedTextProvider) -> Disposable? {
        // We need to check if the view is UITextField or UITextView or UISearchBar or UISegmentedControl,
        // because it contains more subviews that we don't need to work with
        let shouldContainSubviews = view is UITextField || view is UITextView || view is UISearchBar || view is UISegmentedControl

        guard view.subviews.isEmpty || shouldContainSubviews else {
            let disposables = view.subviews.flatMap { startUpdatingViews(for: $0, from: provider) }
            return disposables.isEmpty ? nil : Disposables.create(disposables)
        }

        return (view as? LiveUpdatable)?.subscribeToUpdates(from: provider) ?? nil
    }
}
