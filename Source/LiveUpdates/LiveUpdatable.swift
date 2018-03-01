//
//  LiveUpdatable.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 17/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

public protocol LiveUpdatable: Localizable {
    func subscribeToUpdates(from provider: LocalizedTextProvider) -> Disposable?
}

extension LiveUpdatable {
    func observeAttributedText(_ attributedText: NSMutableAttributedString,
                               for key: String,
                               from provider: LocalizedTextProvider) -> Observable<NSAttributedString> {
        return provider.observeText(for: key)
            .do(onNext: attributedText.mutableString.setString)
            .map { _ in attributedText }
    }
}

extension UIButton: LiveUpdatable {
    public func subscribeToUpdates(from provider: LocalizedTextProvider) -> Disposable? {
        guard let key = localizationKey else { return nil }

        var disposables: [Disposable] = []

        let properties: [(ButtonLocalizedProperty, UIControlState)] = [
            (.normal, .normal),
            (.selected, .selected),
            (.highlighted, .highlighted),
            (.disabled, .disabled)
        ]

        properties.forEach { property, state in
            let propertyKey = key + separator + property.description
            if let attributedText = attributedTitle(for: state)?.mutableCopy() as? NSMutableAttributedString {
                let defaultObservable = state == .normal ?
                    observeAttributedText(attributedText, for: key, from: provider) :
                    .empty()
                let propertyKeyDisposable = Observable
                    .merge(defaultObservable, observeAttributedText(attributedText, for: propertyKey, from: provider))
                    .takeUntil(rx.deallocated)
                    .observeOn(MainScheduler.instance)
                    .bind(to: rx.attributedTitle(for: state))
                disposables.append(propertyKeyDisposable)
            } else {
                let defaultObservable = state == .normal ? provider.observeText(for: key) : .empty()
                let propertyKeyDisposable = Observable
                    .merge(defaultObservable, provider.observeText(for: propertyKey))
                    .takeUntil(rx.deallocated)
                    .observeOn(MainScheduler.instance)
                    .bind(to: rx.title(for: state))
                disposables.append(propertyKeyDisposable)
            }
        }

        return Disposables.create(disposables)
    }
}

extension UILabel: LiveUpdatable {
    public func subscribeToUpdates(from provider: LocalizedTextProvider) -> Disposable? {
        guard let key = localizationKey else { return nil }

        if let attributedText = attributedText?.mutableCopy() as? NSMutableAttributedString {
            return observeAttributedText(attributedText, for: key, from: provider)
                .takeUntil(rx.deallocated)
                .observeOn(MainScheduler.instance)
                .bind(to: rx.attributedText)
        } else {
            return provider.observeText(for: key)
                .takeUntil(rx.deallocated)
                .observeOn(MainScheduler.instance)
                .bind(to: rx.text)
        }
    }
}

extension UITextField: LiveUpdatable {
    public func subscribeToUpdates(from provider: LocalizedTextProvider) -> Disposable? {
        guard let key = localizationKey else { return nil }

        var disposables: [Disposable] = []

        let textKey = key + separator + TextFieldLocalizedProperty.text.description
        if let attributedText = attributedText?.mutableCopy() as? NSMutableAttributedString {
            let textKeyDisposable = observeAttributedText(attributedText, for: textKey, from: provider)
                .takeUntil(rx.deallocated)
                .observeOn(MainScheduler.instance)
                .bind(to: rx.attributedText)
            disposables.append(textKeyDisposable)
        } else {
            let textKeyDisposable = provider.observeText(for: textKey)
                .takeUntil(rx.deallocated)
                .observeOn(MainScheduler.instance)
                .bind(to: rx.text)
            disposables.append(textKeyDisposable)
        }

        let placeholderKey = key + separator + TextFieldLocalizedProperty.placeholder.description
        if let attributedText = attributedText?.mutableCopy() as? NSMutableAttributedString {
            let placeholderKeyDisposable = observeAttributedText(attributedText, for: placeholderKey, from: provider)
                .takeUntil(rx.deallocated)
                .observeOn(MainScheduler.instance)
                .bind(to: rx.attributedPlaceholder)
            disposables.append(placeholderKeyDisposable)
        } else {
            let placeholderKeyDisposable = provider.observeText(for: placeholderKey)
                .takeUntil(rx.deallocated)
                .observeOn(MainScheduler.instance)
                .bind(to: rx.placeholder)
            disposables.append(placeholderKeyDisposable)
        }

        return Disposables.create(disposables)
    }
}

extension UITextView: LiveUpdatable {
    public func subscribeToUpdates(from provider: LocalizedTextProvider) -> Disposable? {
        guard let key = localizationKey else { return nil }

        if let attributedText = attributedText?.mutableCopy() as? NSMutableAttributedString {
            return observeAttributedText(attributedText, for: key, from: provider)
                .takeUntil(rx.deallocated)
                .observeOn(MainScheduler.instance)
                .bind(to: rx.attributedText)
        } else {
            return provider.observeText(for: key)
                .takeUntil(rx.deallocated)
                .observeOn(MainScheduler.instance)
                .bind(to: rx.text)
        }
    }
}

extension UISearchBar: LiveUpdatable {
    public func subscribeToUpdates(from provider: LocalizedTextProvider) -> Disposable? {
        guard let key = localizationKey else { return nil }

        var disposables: [Disposable] = []

        let textKey = key + separator + SearchBarLocalizedProperty.text.description
        let textKeyDisposable = provider.observeText(for: textKey)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .bind(to: rx.text)
        disposables.append(textKeyDisposable)

        let placeholderKey = key + separator + SearchBarLocalizedProperty.placeholder.description
        let placeholderKeyDisposable = provider.observeText(for: placeholderKey)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .bind(to: rx.placeholder)
        disposables.append(placeholderKeyDisposable)

        let promptKey = key + separator + SearchBarLocalizedProperty.prompt.description
        let promptKeyDisposable = provider.observeText(for: promptKey)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .bind(to: rx.prompt)
        disposables.append(promptKeyDisposable)

        return Disposables.create(disposables)
    }
}

extension UISegmentedControl: LiveUpdatable {
    public func subscribeToUpdates(from provider: LocalizedTextProvider) -> Disposable? {
        guard let key = localizationKey else { return nil }

        var disposables: [Disposable] = []

        (0..<numberOfSegments).forEach { index in
            let indexKey = key + separator + String(index)
            let indexKeyDisposable = provider.observeText(for: indexKey)
                .takeUntil(rx.deallocated)
                .observeOn(MainScheduler.instance)
                .bind(to: rx.setTitle(forSegmentAtIndex: index))
            disposables.append(indexKeyDisposable)
        }

        return Disposables.create(disposables)
    }
}

extension UINavigationItem: LiveUpdatable {
    public func subscribeToUpdates(from provider: LocalizedTextProvider) -> Disposable? {
        guard let key = localizationKey else { return nil }

        var disposables: [Disposable] = []

        let titleKey = key + separator + NavigationItemLocalizedProperty.title.description
        let titleKeyDisposable = Observable
            .merge(provider.observeText(for: key), provider.observeText(for: titleKey))
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .bind(to: rx.title)
        disposables.append(titleKeyDisposable)

        let promptKey = key + separator + NavigationItemLocalizedProperty.prompt.description
        let promptKeyDisposable = provider.observeText(for: promptKey)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .bind(to: rx.prompt)
        disposables.append(promptKeyDisposable)

        if let backButtonItem = backBarButtonItem {
            let backButtonTitleKey = key + separator + NavigationItemLocalizedProperty.backButtonTitle.description
            let backButtonTitleKeyDisposable = provider.observeText(for: backButtonTitleKey)
                .takeUntil(backButtonItem.rx.deallocated)
                .observeOn(MainScheduler.instance)
                .bind(to: backButtonItem.rx.title)
            disposables.append(backButtonTitleKeyDisposable)
        }

        return Disposables.create(disposables)
    }
}

extension UIBarButtonItem: LiveUpdatable {
    public func subscribeToUpdates(from provider: LocalizedTextProvider) -> Disposable? {
        guard let key = localizationKey else { return nil }
        return provider.observeText(for: key)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .bind(to: rx.title)
    }
}

extension UITabBarItem: LiveUpdatable {
    public func subscribeToUpdates(from provider: LocalizedTextProvider) -> Disposable? {
        guard let key = localizationKey else { return nil }

        var disposables: [Disposable] = []

        let titleKey = key + separator + TabBarItemLocalizedProperty.title.description
        let titleKeyDisposable = Observable
            .merge(provider.observeText(for: key), provider.observeText(for: titleKey))
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .bind(to: rx.title)
        disposables.append(titleKeyDisposable)

        let badgeKey = key + separator + TabBarItemLocalizedProperty.badgeValue.description
        let badgeKeyDisposable = provider.observeText(for: badgeKey)
            .takeUntil(rx.deallocated)
            .observeOn(MainScheduler.instance)
            .bind(to: rx.badgeValue)
        disposables.append(badgeKeyDisposable)

        return Disposables.create(disposables)
    }
}
