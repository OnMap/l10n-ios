//
//  UILabel+LocalizableTests.swift
//  OML10nTests
//
//  Created by Alex Alexandrovych on 31/01/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import XCTest

class UILabelLocalizableTests: XCTestCase {

    // MARK: Constants (from Localizable.strings)

    let key = "Test.Label"
    let unknownKey = "Test.Unknown"

    enum Strings {
        static let text = "test label text"
    }

    // MARK: Properties

    var label: UILabel!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        label = UILabel()
        label.bundle = Bundle(for: type(of: self))
    }

    // MARK: Tests

    func testTextKey() {
        label.localizationKey = key
        XCTAssertEqual(label.text, Strings.text)
    }

    func testAttributedTextKey() {
        let colorKey: NSAttributedStringKey = .foregroundColor
        let colorAttribute: UIColor = .red
        let fontKey: NSAttributedStringKey = .font
        let fontAttribute: UIFont = UIFont.systemFont(ofSize: 20)
        let attributes = [colorKey: colorAttribute, fontKey: fontAttribute]

        label.attributedText = NSAttributedString(string: "Test", attributes: attributes)
        label.localizationKey = key

        XCTAssertEqual(label.text, Strings.text)

        let newAttributes = label.attributedText?.attributes(at: 0, effectiveRange: nil)

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

    func testWrongKey() {
        label.localizationKey = unknownKey
        XCTAssertEqual(label.text, unknownKey)
    }

    func testEmptyKey() {
        label.localizationKey = ""
        XCTAssertNil(label.text)
    }

    func testEmptyKeyLeavesPreviousValues() {
        label.localizationKey = key
        label.localizationKey = ""
        XCTAssertEqual(label.text, Strings.text)
    }

    func testNilKey() {
        label.localizationKey = nil
        XCTAssertNil(label.text)
    }

    func testNilKeyLeavesPreviousValues() {
        label.localizationKey = key
        label.localizationKey = nil
        XCTAssertEqual(label.text, Strings.text)
    }

    func testLocalizationKeySets() {
        label.localizationKey = key
        XCTAssertEqual(label.localizationKey, key)
    }

}
