//
//  UISegmentedControl+LocalizableTests.swift
//  OML10nTests
//
//  Created by Alex Alexandrovych on 03/02/2018.
//  Copyright © 2018 OnMap. All rights reserved.
//

import XCTest

class UISegmentedControlLocalizableTests: XCTestCase {

    // MARK: Constants (from Localizable.strings)

    let key = "Test.SegmentedControl"
    let unknownKey = "Test.Unknown"

    enum Strings {
        static let first = "test segmented control first title"
        static let second = "test segmented control second title"
    }

    // MARK: Properties

    var segmentedControl: UISegmentedControl!

    // MARK: Setup

    override func setUp() {
        super.setUp()
        segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: nil, at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: nil, at: 1, animated: false)
        segmentedControl.bundle = Bundle(for: type(of: self))
    }

    // MARK: Tests

    func testTitles() {
        segmentedControl.localizationKey = key
        XCTAssertEqual(segmentedControl.titleForSegment(at: 0), Strings.first)
    }

    func testWrongKey() {
        segmentedControl.localizationKey = unknownKey
        (0..<segmentedControl.numberOfSegments).forEach { segmentIndex in
            let segmentTitle = unknownKey + segmentedControl.separator + String(segmentIndex)
            XCTAssertEqual(segmentedControl.titleForSegment(at: segmentIndex), segmentTitle)
        }
    }

    func testEmptyKey() {
        segmentedControl.localizationKey = ""
        assertAllPropertiesNil()
    }

    func testEmptyKeyLeavesPreviousValues() {
        segmentedControl.localizationKey = key
        segmentedControl.localizationKey = ""
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testNilKey() {
        segmentedControl.localizationKey = nil
        assertAllPropertiesNil()
    }

    func testNilKeyLeavesPreviousValues() {
        segmentedControl.localizationKey = key
        segmentedControl.localizationKey = nil
        assertAllPropertiesWithCorrespondingStrings()
    }

    func testLocalizationKeySets() {
        segmentedControl.localizationKey = key
        XCTAssertEqual(segmentedControl.localizationKey, key)
    }

    // MARK: Private

    private func assertAllPropertiesNil() {
        (0..<segmentedControl.numberOfSegments).forEach { segmentIndex in
            XCTAssertNil(segmentedControl.titleForSegment(at: segmentIndex))
        }
    }

    private func assertAllPropertiesWithCorrespondingStrings() {
        XCTAssertEqual(segmentedControl.titleForSegment(at: 0), Strings.first)
        XCTAssertEqual(segmentedControl.titleForSegment(at: 1), Strings.second)
    }

}
