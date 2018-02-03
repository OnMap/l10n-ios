//
//  UITextField+LocalizableTests.swift
//  OML10nTests
//
//  Created by Alex Alexandrovych on 02/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import XCTest

class UITextFieldLocalizableTests: XCTestCase {

    // MARK: Constants (from Localizable.strings)

    let key = "Test.TextField"
    let unknownKey = "Test.Unknown"

    enum Strings {
        static let text = "test text field text"
        static let placeholder = "test text field placeholder"
    }

    // MARK: Properties

    var textField: UITextField!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        textField = UITextField()
        textField.bundle = Bundle(for: type(of: self))
    }

    // MARK: Tests

    func testTextKey() {
        textField.localizationKey = key
        XCTAssertEqual(textField.text, Strings.text)
    }

    func testAttributedTextKey() {
        let colorKey: NSAttributedStringKey = .foregroundColor
        let colorAttribute: UIColor = .red
        let fontKey: NSAttributedStringKey = .font
        let fontAttribute: UIFont = UIFont.systemFont(ofSize: 20)
        let attributes = [colorKey: colorAttribute, fontKey: fontAttribute]

        textField.attributedText = NSAttributedString(string: "Test", attributes: attributes)
        textField.localizationKey = key

        XCTAssertEqual(textField.text, Strings.text)

        let newAttributes = textField.attributedText?.attributes(at: 0, effectiveRange: nil)

        if let newAttributes = newAttributes,
            let color = newAttributes[colorKey] as? UIColor,
            let font = newAttributes[fontKey] as? UIFont {
            // UITextFiled has 2 default attributes
            XCTAssertEqual(newAttributes.count - 2, attributes.count)
            XCTAssertEqual(color, colorAttribute)
            XCTAssertEqual(font, fontAttribute)
        } else {
            XCTFail("Assert attributes failure")
        }
    }

    func testPlaceholderKey() {
        textField.localizationKey = key
        XCTAssertEqual(textField.placeholder, Strings.placeholder)
    }

    func testWrongKey() {
        textField.localizationKey = unknownKey
        assertAllPropertiesNil()
    }

    func testWrongKeyLeavesPreviousValues() {
        textField.localizationKey = key
        textField.localizationKey = unknownKey
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testEmptyKey() {
        textField.localizationKey = ""
        assertAllPropertiesNil()
    }

    func testEmptyKeyLeavesPreviousValues() {
        textField.localizationKey = key
        textField.localizationKey = ""
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testNilKey() {
        textField.localizationKey = nil
        assertAllPropertiesNil()
    }

    func testNilKeyLeavesPreviousValues() {
        textField.localizationKey = key
        textField.localizationKey = nil
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testLocalizationKeySets() {
        textField.localizationKey = key
        XCTAssertEqual(textField.localizationKey, key)
    }

    // MARK: Private

    private func assertAllPropertiesNil() {
        // Initial text property of UITextField is not nil, but ""
        XCTAssertEqual(textField.text, "")
        XCTAssertNil(textField.placeholder)
    }

    private func assertAllPropertiesWithCorrespondingStrings() {
        XCTAssertEqual(textField.text, Strings.text)
        XCTAssertEqual(textField.placeholder, Strings.placeholder)
    }

}
