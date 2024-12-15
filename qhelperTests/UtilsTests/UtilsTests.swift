//
//  UtilsTests.swift
//  qhelperTests
//
//  Created by Arthur Efremenko on 12/12/24.
//

import XCTest
@testable import qhelper

final class UtilsTests: XCTestCase {
    func testGetFilePath() throws {
        XCTAssertEqual(get_file_path(file_path: Bundle.main.url(forResource: "LX_Cue_Script", withExtension: "scpt")!),
                                    "/Users/lemanappazov/Library/Developer/Xcode/DerivedData/qhelper-bwxvgbcilhfuvcalgezrateikcfn/Build/Products/Debug/qhelper.app/Contents/Resources/LX_Cue_Script.scpt")
    }
}
