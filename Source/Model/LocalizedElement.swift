//
//  LocalizedElement.swift
//  OMLocalization
//
//  Created by Alex Alexandrovych on 16/08/2017.
//  Copyright © 2017 Alex Alexandrovych. All rights reserved.
//

import Foundation
import RealmSwift

class LocalizedElement: Object {

    @objc dynamic var key = ""
    @objc dynamic var text = ""
    @objc dynamic var type: String?

    convenience init(key: String, text: String, type: String? = nil) {
        self.init()
        self.key = key
        self.text = text
        self.type = type
    }

    override static func primaryKey() -> String? {
        return "key"
    }
}
