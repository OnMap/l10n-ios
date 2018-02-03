//
//  LocalizedTests.swift
//  OML10nTests
//
//  Created by Alex Alexandrovych on 31/01/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import XCTest
@testable import OML10n

class LocalizedTests: XCTestCase {

    func testLocalizableStrings() {
        let bundle = Bundle(for: type(of: self))
        XCTAssertNil(localized("", bundle: bundle))
        XCTAssertNil(localized("Wrong key", bundle: bundle))
        XCTAssertEqual(localized("Test", bundle: bundle), "test")
    }
}
