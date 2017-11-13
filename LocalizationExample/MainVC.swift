//
//  MainVC.swift
//  LocalizationExample
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import UIKit
import RxSwift
import OMLocalization

class MainVC: UIViewController, LiveUpdatable {

    // MARK: - LiveUpdatable Dictionary

    var localizedViews: [String: Localizable] = [:]

    // MARK: - Properties

    @IBOutlet private weak var storyboardLabel: UILabel!

    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.textKey = "Main.CodeLabel.Text"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(codeLabel)
        NSLayoutConstraint.activate([
            codeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            storyboardLabel.topAnchor.constraint(equalTo: codeLabel.bottomAnchor, constant: 30)
        ])

        // LiveUpdatable configuration
        let language: LocalizedLanguages
        switch Localization.currentLanguage {
        case .english: language = .english
        case .hebrew: language = .hebrew
        case .russian: language = .russian
        }
        configureLocalizedViews(from: view, language: language)
    }
}

