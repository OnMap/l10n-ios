//
//  UIButton+LocalizableTests.swift
//  OML10nTests
//
//  Created by Alex Alexandrovych on 31/01/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import XCTest

class UIButtonLocalizableTests: XCTestCase {

    // MARK: Constants (from Localizable.strings)

    let key = "Test.Button"
    let unknownKey = "Test.Unknown"

    enum Strings {
        static let normal = "test button normal"
        static let highlighted = "test button highlighted"
        static let selected = "test button selected"
        static let disabled = "test button disabled"
    }

    // MARK: Properties

    var button: UIButton!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        button = UIButton()
        button.bundle = Bundle(for: type(of: self))
    }

    // MARK: Title tests

    func testNormalKey() {
        button.localizationKey = key
        XCTAssertEqual(button.title(for: .normal), Strings.normal)
    }

    func testHighlightedKey() {
        button.localizationKey = key
        XCTAssertEqual(button.title(for: .highlighted), Strings.highlighted)
    }

    func testSelectedKey() {
        button.localizationKey = key
        XCTAssertEqual(button.title(for: .selected), Strings.selected)
    }

    func testDisabledKey() {
        button.localizationKey = key
        XCTAssertEqual(button.title(for: .disabled), Strings.disabled)
    }

    // MARK: Attributed title tests

    func testNormalKeyAttributedTitle() {
        button.localizationKey = key
        assertAttributedTitle(Strings.normal, for: .normal)
    }

    func testHighlightedKeyAttributedTitle() {
        button.localizationKey = key
        assertAttributedTitle(Strings.highlighted, for: .highlighted)
    }

    func testSelectedKeyAttributedTitle() {
        button.localizationKey = key
        assertAttributedTitle(Strings.selected, for: .selected)
    }

    func testDisabledKeyAttributedTitle() {
        button.localizationKey = key
        assertAttributedTitle(Strings.disabled, for: .disabled)
    }

    // MARK: Wrong keys tests

    func testWrongKey() {
        button.localizationKey = unknownKey
        let states: [UIControlState] = [.normal, .highlighted, .selected, .disabled]
        states.forEach { state in
            XCTAssertEqual(button.title(for: state), unknownKey)
        }
    }

    func testEmptyKey() {
        button.localizationKey = ""
        assertAllStatesNil()
    }

    func testEmptyKeyLeavesPreviousState() {
        button.localizationKey = key
        button.localizationKey = ""
        assertAllStatesWithCorrespondingStrings()
    }

    func testNilKey() {
        button.localizationKey = nil
        assertAllStatesNil()
    }

    func testNilKeyLeavesPreviousState() {
        button.localizationKey = key
        button.localizationKey = nil
        assertAllStatesWithCorrespondingStrings()
    }

    // MARK: Localization key test

    func testLocalizationKeySets() {
        button.localizationKey = key
        XCTAssertEqual(button.localizationKey, key)
    }

    // MARK: Private

    private func assertAttributedTitle(_ title: String, for state: UIControlState) {
        let colorKey: NSAttributedStringKey = .foregroundColor
        let colorAttribute: UIColor = .red
        let fontKey: NSAttributedStringKey = .font
        let fontAttribute: UIFont = UIFont.systemFont(ofSize: 20)
        let attributes = [colorKey: colorAttribute, fontKey: fontAttribute]

        button.setAttributedTitle(NSAttributedString(string: "Test", attributes: attributes), for: state)
        button.localizationKey = key

        XCTAssertEqual(button.title(for: state), title)

        let newAttributes = button.attributedTitle(for: state)?.attributes(at: 0, effectiveRange: nil)

        if let newAttributes = newAttributes,
            let color = newAttributes[colorKey] as? UIColor,
            let font = newAttributes[fontKey] as? UIFont {
            XCTAssertEqual(newAttributes.count, attributes.count)
            XCTAssertEqual(color, colorAttribute)
            XCTAssertEqual(font, fontAttribute)
        } else {
            XCTFail("Assert attributes failure")
        }
    }

    private func assertAllStatesNil() {
        let states: [UIControlState] = [.normal, .highlighted, .selected, .disabled]
        states.forEach { state in
            XCTAssertNil(button.title(for: state))
        }
    }

    private func assertAllStatesWithCorrespondingStrings() {
        XCTAssertEqual(button.title(for: .normal), Strings.normal)
        XCTAssertEqual(button.title(for: .highlighted), Strings.highlighted)
        XCTAssertEqual(button.title(for: .selected), Strings.selected)
        XCTAssertEqual(button.title(for: .disabled), Strings.disabled)
    }

}
