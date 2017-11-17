//
//  LocalizedElement.swift
//  OML10n
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 OnMap LTD. All rights reserved.
//

import Foundation
import RealmSwift

class LocalizedElement: Object {

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
