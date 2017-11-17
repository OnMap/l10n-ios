//
//  MainVC.swift
//  LocalizationExample
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import UIKit
import RxSwift
import OML10n

class MainVC: UIViewController {

    // MARK: - Properties

    @IBOutlet private weak var storyboardLabel: UILabel!

    private lazy var codeLabel: UILabel = {
        let label = UILabel()
        label.text = "I'm a button created programmatically"
        label.localizationKey = "Main.CodeLabel"
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
            codeLabel.topAnchor.constraint(equalTo: storyboardLabel.bottomAnchor, constant: 50)
        ])

        LiveUpdates.listenUpdates(for: self)
    }

}

