//
//  UITabBarItem+LocalizableTests.swift
//  OML10nTests
//
//  Created by Alex Alexandrovych on 03/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import XCTest

class UITabBarItemLocalizableTests: XCTestCase {

    // MARK: Constants (from Localizable.strings)

    let key = "Test.TabBarItem"
    let unknownKey = "Test.Unknown"

    enum Strings {
        static let title = "test tab bar item title"
        static let badgeValue = "test tab bar item badge value"
    }

    // MARK: Properties

    var tabBarItem: UITabBarItem!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        tabBarItem = UITabBarItem()
        tabBarItem.bundle = Bundle(for: type(of: self))
    }

    // MARK: Tests

    func testTitleKey() {
        tabBarItem.localizationKey = key
        XCTAssertEqual(tabBarItem.title, Strings.title)
    }

    func testBadgeValueKey() {
        tabBarItem.localizationKey = key
        XCTAssertEqual(tabBarItem.badgeValue, Strings.badgeValue)
    }

    func testWrongKey() {
        tabBarItem.localizationKey = unknownKey
        XCTAssertEqual(tabBarItem.title, unknownKey)
        XCTAssertNil(tabBarItem.badgeValue)
    }

    func testEmptyKey() {
        tabBarItem.localizationKey = ""
        assertAllPropertiesNil()
    }

    func testEmptyKeyLeavesPreviousValues() {
        tabBarItem.localizationKey = key
        tabBarItem.localizationKey = ""
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testNilKey() {
        tabBarItem.localizationKey = nil
        assertAllPropertiesNil()
    }

    func testNilKeyLeavesPreviousValues() {
        tabBarItem.localizationKey = key
        tabBarItem.localizationKey = nil
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testLocalizationKeySets() {
        tabBarItem.localizationKey = key
        XCTAssertEqual(tabBarItem.localizationKey, key)
    }

    // MARK: Private

    private func assertAllPropertiesNil() {
        XCTAssertNil(tabBarItem.title)
        XCTAssertNil(tabBarItem.badgeValue)
    }

    private func assertAllPropertiesWithCorrespondingStrings() {
        XCTAssertEqual(tabBarItem.title, Strings.title)
        XCTAssertEqual(tabBarItem.badgeValue, Strings.badgeValue)
    }

}
