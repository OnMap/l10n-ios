//
//  UIBarButtonItem+LocalizableTests.swift
//  OML10nTests
//
//  Created by Alex Alexandrovych on 03/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import XCTest

class UIBarButtonItemLocalizableTests: XCTestCase {

    // MARK: Constants (from Localizable.strings)

    let key = "Test.BarButtonItem"
    let unknownKey = "Test.Unknown"

    enum Strings {
        static let title = "test bar button item text"
    }

    // MARK: Properties

    var barButtonItem: UIBarButtonItem!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        barButtonItem = UIBarButtonItem()
        barButtonItem.bundle = Bundle(for: type(of: self))
    }

    // MARK: Tests

    func testTitleKey() {
        barButtonItem.localizationKey = key
        XCTAssertEqual(barButtonItem.title, Strings.title)
    }

    func testWrongKey() {
        barButtonItem.localizationKey = unknownKey
        XCTAssertEqual(barButtonItem.title, unknownKey)
    }

    func testEmptyKey() {
        barButtonItem.localizationKey = ""
        XCTAssertNil(barButtonItem.title)
    }

    func testEmptyKeyLeavesPreviousValues() {
        barButtonItem.localizationKey = key
        barButtonItem.localizationKey = ""
        XCTAssertEqual(barButtonItem.title, Strings.title)
    }

    func testNilKey() {
        barButtonItem.localizationKey = nil
        XCTAssertNil(barButtonItem.title)
    }

    func testNilKeyLeavesPreviousValues() {
        barButtonItem.localizationKey = key
        barButtonItem.localizationKey = nil
        XCTAssertEqual(barButtonItem.title, Strings.title)
    }

    func testLocalizationKeySets() {
        barButtonItem.localizationKey = key
        XCTAssertEqual(barButtonItem.localizationKey, key)
    }

}
