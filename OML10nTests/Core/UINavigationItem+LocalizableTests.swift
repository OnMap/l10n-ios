//
//  UINavigationItem+LocalizableTests.swift
//  OML10nTests
//
//  Created by Alex Alexandrovych on 03/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import XCTest

class UINavigationItemLocalizableTests: XCTestCase {

    // MARK: Constants (from Localizable.strings)

    let key = "Test.NavigationItem"
    let unknownKey = "Test.Unknown"

    enum Strings {
        static let title = "test navigation item title"
        static let prompt = "test navigation item prompt"
        static let backButtonTitle = "test navigation item back button title"
    }

    // MARK: Properties

    var navigationItem: UINavigationItem!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        navigationItem = UINavigationItem()
        navigationItem.backBarButtonItem = UIBarButtonItem()
        navigationItem.bundle = Bundle(for: type(of: self))
    }

    // MARK: Tests

    func testTitleKey() {
        navigationItem.localizationKey = key
        XCTAssertEqual(navigationItem.title, Strings.title)
    }

    func testPromptKey() {
        navigationItem.localizationKey = key
        XCTAssertEqual(navigationItem.prompt, Strings.prompt)
    }

    func testBackButtonTitleKey() {
        navigationItem.localizationKey = key
        XCTAssertEqual(navigationItem.backBarButtonItem?.title, Strings.backButtonTitle)
    }

    func testWrongKey() {
        navigationItem.localizationKey = unknownKey
        XCTAssertEqual(navigationItem.title, unknownKey)
        XCTAssertNil(navigationItem.prompt)
        XCTAssertNil(navigationItem.backBarButtonItem?.title)
    }

    func testEmptyKey() {
        navigationItem.localizationKey = ""
        assertAllPropertiesNil()
    }

    func testEmptyKeyLeavesPreviousValues() {
        navigationItem.localizationKey = key
        navigationItem.localizationKey = ""
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testNilKey() {
        navigationItem.localizationKey = nil
        assertAllPropertiesNil()
    }

    func testNilKeyLeavesPreviousValues() {
        navigationItem.localizationKey = key
        navigationItem.localizationKey = nil
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testLocalizationKeySets() {
        navigationItem.localizationKey = key
        XCTAssertEqual(navigationItem.localizationKey, key)
    }

    // MARK: Private

    private func assertAllPropertiesNil() {
        XCTAssertNil(navigationItem.title)
        XCTAssertNil(navigationItem.prompt)
        XCTAssertNil(navigationItem.backBarButtonItem?.title)
    }

    private func assertAllPropertiesWithCorrespondingStrings() {
        XCTAssertEqual(navigationItem.title, Strings.title)
        XCTAssertEqual(navigationItem.prompt, Strings.prompt)
        XCTAssertEqual(navigationItem.backBarButtonItem?.title, Strings.backButtonTitle)
    }

}
