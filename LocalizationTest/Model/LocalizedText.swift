//
//  LocalizedText.swift
//  LocalizationTest
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import Foundation
import RealmSwift

class LocalizedText: Object {

    @objc dynamic var key = ""
    @objc dynamic var text = ""

    convenience init(key: String, text: String) {
        self.init()
        self.key = key
        self.text = text
    }

    override static func primaryKey() -> String? {
        return "key"
    }
}
