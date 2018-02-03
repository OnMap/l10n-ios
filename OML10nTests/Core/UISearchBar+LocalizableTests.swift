//
//  UISearchBar+LocalizableTests.swift
//  OML10nTests
//
//  Created by Alex Alexandrovych on 03/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import XCTest

class UISearchBarLocalizableTests: XCTestCase {

    // MARK: Constants (from Localizable.strings)

    let key = "Test.SearchBar"
    let unknownKey = "Test.Unknown"

    enum Strings {
        static let text = "test search bar text"
        static let placeholder = "test search bar placeholder"
        static let prompt = "test search bar prompt"
    }

    // MARK: Properties

    var searchBar: UISearchBar!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        searchBar = UISearchBar()
        searchBar.bundle = Bundle(for: type(of: self))
    }

    // MARK: Tests

    func testTextKey() {
        searchBar.localizationKey = key
        XCTAssertEqual(searchBar.text, Strings.text)
    }

    func testPlaceholderKey() {
        searchBar.localizationKey = key
        XCTAssertEqual(searchBar.placeholder, Strings.placeholder)
    }

    func testPromptKey() {
        searchBar.localizationKey = key
        XCTAssertEqual(searchBar.prompt, Strings.prompt)
    }

    func testWrongKey() {
        searchBar.localizationKey = unknownKey
        assertAllPropertiesNil()
    }

    func testWrongKeyLeavesPreviousValues() {
        searchBar.localizationKey = key
        searchBar.localizationKey = unknownKey
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testEmptyKey() {
        searchBar.localizationKey = ""
        assertAllPropertiesNil()
    }

    func testEmptyKeyLeavesPreviousValues() {
        searchBar.localizationKey = key
        searchBar.localizationKey = ""
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testNilKey() {
        searchBar.localizationKey = nil
        assertAllPropertiesNil()
    }

    func testNilKeyLeavesPreviousValues() {
        searchBar.localizationKey = key
        searchBar.localizationKey = nil
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testLocalizationKeySets() {
        searchBar.localizationKey = key
        XCTAssertEqual(searchBar.localizationKey, key)
    }

    // MARK: Private

    private func assertAllPropertiesNil() {
        // Initial text property of UISearchBar is not nil, but ""
        XCTAssertEqual(searchBar.text, "")
        XCTAssertNil(searchBar.placeholder)
        XCTAssertNil(searchBar.prompt)
    }

    private func assertAllPropertiesWithCorrespondingStrings() {
        XCTAssertEqual(searchBar.text, Strings.text)
        XCTAssertEqual(searchBar.placeholder, Strings.placeholder)
        XCTAssertEqual(searchBar.prompt, Strings.prompt)
    }

}
