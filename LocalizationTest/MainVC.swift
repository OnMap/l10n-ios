//
//  MainVC.swift
//  LocalizationTest
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import UIKit
import RxSwift

class MainVC: UIViewController, LiveUpdatable {

    // MARK: - LiveUpdatable Properties

    var disposeBag = DisposeBag()
    var localizationDictionary: [String : Localizable] = [:]

    // MARK: - Constants

    // Use enum in case of creating views from code
    enum LocalizationKeys {
        private static let title = "Main"
        static let codeLabel = "\(LocalizationKeys.title).СodeLabel"
    }

    // MARK: - Properties

    @IBOutlet private weak var storyboardLabel: UILabel!

    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.text = localized(LocalizationKeys.codeLabel)
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
        localizationDictionary = localizationDictionary(from: view)
        configureLiveUpdating()
    }
}

