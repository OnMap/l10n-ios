//
//  UITextView+LocalizableTests.swift
//  OML10nTests
//
//  Created by Alex Alexandrovych on 03/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import XCTest

class UITextViewLocalizableTests: XCTestCase {

    // MARK: Constants (from Localizable.strings)

    let key = "Test.TextView"
    let unknownKey = "Test.Unknown"

    enum Strings {
        static let text = "test text view text"
    }

    // MARK: Properties

    var textView: UITextView!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        textView = UITextView()
        textView.bundle = Bundle(for: type(of: self))
    }

    // MARK: Tests

    func testTextKey() {
        textView.localizationKey = key
        XCTAssertEqual(textView.text, Strings.text)
    }

    func testAttributedTextKey() {
        let colorKey: NSAttributedStringKey = .foregroundColor
        let colorAttribute: UIColor = .red
        let fontKey: NSAttributedStringKey = .font
        let fontAttribute: UIFont = UIFont.systemFont(ofSize: 20)
        let attributes = [colorKey: colorAttribute, fontKey: fontAttribute]

        textView.attributedText = NSAttributedString(string: "Test", attributes: attributes)
        textView.localizationKey = key

        XCTAssertEqual(textView.text, Strings.text)

        let newAttributes = textView.attributedText?.attributes(at: 0, effectiveRange: nil)

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
        textView.localizationKey = unknownKey
        XCTAssertEqual(textView.text, "")
    }

    func testWrongKeyLeavesPreviousValues() {
        textView.localizationKey = key
        textView.localizationKey = unknownKey
        XCTAssertEqual(textView.text, Strings.text)
    }

    func testEmptyKey() {
        textView.localizationKey = ""
        XCTAssertEqual(textView.text, "")
    }

    func testEmptyKeyLeavesPreviousValues() {
        textView.localizationKey = key
        textView.localizationKey = ""
        XCTAssertEqual(textView.text, Strings.text)
    }

    func testNilKey() {
        textView.localizationKey = nil
        XCTAssertEqual(textView.text, "")
    }

    func testNilKeyLeavesPreviousValues() {
        textView.localizationKey = key
        textView.localizationKey = nil
        XCTAssertEqual(textView.text, Strings.text)
    }

    func testLocalizationKeySets() {
        textView.localizationKey = key
        XCTAssertEqual(textView.localizationKey, key)
    }

}
