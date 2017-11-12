//
//  LiveUpdatableViewController.swift
//  LocalizationTest
//
//  Created by Alex Alexandrovych on 08/11/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import UIKit

class LiveUpdatableViewController: UIViewController, LiveUpdatable {

    var localizedViews: [String: Localizable] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        createLocalizedViews(from: view, language: .english)
    }
}
