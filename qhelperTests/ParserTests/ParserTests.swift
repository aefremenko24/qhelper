//
//  qhelperTests.swift
//  qhelperTests
//
//  Created by Arthur Efremenko on 11/18/24.
//

import Testing
import Foundation
import CoreXLSX
@testable import qhelper

struct ParserTests {
    
    let NICKI_SHOW_FILE: URL = URL(fileURLWithPath: "/Users/afrmnk/Desktop/Coding/Swift/QHelper_All/qhelper/qhelperTests/ParserTests/9. Sarah - The Nicki Show.xlsx")
    
    let NUMALHAR_FILE: URL = URL(fileURLWithPath: "/Users/afrmnk/Desktop/Coding/Swift/QHelper_All/qhelper/qhelperTests/ParserTests/NUMalhar Lighting Cues D4ME 2024.xlsx")
    
    @Test func testSetSharedStrings() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)
        
        #expect(parser.shared_strings == nil)
        
        try parser.set_shared_strings()
        
        #expect(parser.shared_strings != nil)
        #expect(parser.shared_strings!.items.count > 0)
    }
    
    @Test func testExtractWorksheets() throws {
        // NICKI SHOW
        let parser1 = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)
        
        let worksheets1 = try parser1.extract_worksheets(excel_file:  parser1.file_path)
        
        try #require(worksheets1.count == 1)
        #expect(worksheets1[0].name == "Lighting Cue Template")
        
        // NUMALHAR
        let parser2 = Parser(file_path: NUMALHAR_FILE.path, file_name: NUMALHAR_FILE.lastPathComponent)
        
        let worksheets2 = try parser2.extract_worksheets(excel_file:  parser2.file_path)
        
        try #require(worksheets2.count == 2)
        #expect(worksheets2[0].name == "Revised Cues")
        #expect(worksheets2[1].name == "Blackman")
    }
    
    @Test func testFindCell() throws {
        let parser1 = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)
        
        let worksheets1 = try parser1.extract_worksheets(excel_file:  parser1.file_path)
        
        try #require(worksheets1.count == 1)
        
        let time_cell_1 = parser1.find_cell(worksheet: worksheets1[0].worksheet, value: "Time *Example MM:SS:MS*")
        
        #expect(time_cell_1.count == 1)
        #expect(time_cell_1[0].reference.row == 6)
        #expect(time_cell_1[0].reference.column.value == "C")
        
        let time_cell_2 = parser1.find_cell(worksheet: worksheets1[0].worksheet, value: "full")
        
        #expect(time_cell_2.count == 2)
        #expect(time_cell_2[0].reference.row == 15)
        #expect(time_cell_2[0].reference.column.value == "D")
        #expect(time_cell_2[1].reference.row == 15)
        #expect(time_cell_2[1].reference.column.value == "E")
        
        let time_cell_3 = parser1.find_cell(worksheet: worksheets1[0].worksheet, value: "NON_EXISTENT_CELL")
        
        #expect(time_cell_3.count == 0)
    }
    
    @Test func testFindFirstCellOccurences() throws {
        let parser1 = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)
        
        let worksheets1 = try parser1.extract_worksheets(excel_file:  parser1.file_path)
        
        try #require(worksheets1.count == 1)
        
        let cell_search_1 = ["Cue Number", "Fade Time", "NU Event Management"]
        
        let time_cells_1 = parser1.find_first_cell_occurrences(worksheet: worksheets1[0].worksheet, labels: cell_search_1)
        
        #expect(time_cells_1.label == "Cue Number")
        #expect(time_cells_1.cells.count == 1)
        #expect(time_cells_1.cells == parser1.find_cell(worksheet: worksheets1[0].worksheet, value: "Cue Number"))
        
        let cell_search_2 = ["NON", "EXISTENT", "LABELS"]
        
        let time_cells_2 = parser1.find_first_cell_occurrences(worksheet: worksheets1[0].worksheet, labels: cell_search_2)
        
        #expect(time_cells_2.label == nil)
        #expect(time_cells_2.cells == [])
        
        let cell_search_3 = ["QLAB TIMES", "Timings (Seconds)", "Time *Example MM:SS:MS*"]
        
        let time_cells_3 = parser1.find_first_cell_occurrences(worksheet: worksheets1[0].worksheet, labels: cell_search_3)
        
        #expect(time_cells_3.label == "Time *Example MM:SS:MS*")
        #expect(time_cells_3.cells.count == 1)
        #expect(time_cells_3.cells == parser1.find_cell(worksheet: worksheets1[0].worksheet, value: "Time *Example MM:SS:MS*"))
    }
    
    
    @Test func testPreSanitizeCell() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)
        
        #expect(parser.pre_sanitize_cell(cell: "(3:04)") == "3:04")
        #expect(parser.pre_sanitize_cell(cell: "3:04.03 - 04:05") == "3:04.03")
        #expect(parser.pre_sanitize_cell(cell: "2:03,2:04, 2:05") == "2:03")
        #expect(parser.pre_sanitize_cell(cell: "") == "")
        #expect(parser.pre_sanitize_cell(cell: " ") == "")
        #expect(parser.pre_sanitize_cell(cell: "2:03 \n") == "2:03")
        #expect(parser.pre_sanitize_cell(cell: "2:03") == "2:03")
    }
    
    @Test func testPostSanitizeCell() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)
        
        #expect(parser.post_sanitize_cell(cell: "3:04") == "3:04")
        #expect(parser.post_sanitize_cell(cell: "3-04.05") == "3:04.05")
        #expect(parser.post_sanitize_cell(cell: "3 04 05") == "3:04:05")
        #expect(parser.post_sanitize_cell(cell: "3+04.05") == "3:04.05")
        #expect(parser.post_sanitize_cell(cell: " ") == ":")
        #expect(parser.post_sanitize_cell(cell: "") == "")
    }
    
    @Test func testVerifyFloatString() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)
        
        #expect(parser.verify_float_string(time_cell: "304.5") == CueTime(asString: "05:04.50", value: 304.5))
        
        #expect(parser.verify_float_string(time_cell: "invalid") == nil)
        
        #expect(parser.verify_float_string(time_cell: "0") == CueTime(asString: "00:00.00", value: 0))
        
        #expect(parser.verify_float_string(time_cell: "~454.4") == nil)
        
        #expect(parser.verify_float_string(time_cell: "3:04.5") == nil)
        
        #expect(parser.verify_float_string(time_cell: "60.01") == CueTime(asString: "01:00.01", value: 60.01))
        
        #expect(parser.verify_float_string(time_cell: "-120") == CueTime(asString: "00:00.00", value: 0))
        
        #expect(parser.verify_float_string(time_cell: "-0") == CueTime(asString: "00:00.00", value: 0.0))
    }
    
    @Test func testVerifyTimeString() throws {
        let time_stamp1 = "1:01.34"
        let time_stamp2 = "61.34"
        let time_stamp3 = "1-01.34"
        let time_stamp4 = "00:01:01.34"
        
        let time_stamp5 = "07:24"
        let time_stamp6 = "07:24.00"
        let time_stamp7 = "7-24"
        let time_stamp8 = "7-24.00"
        let time_stamp9 = "07-24.00"
        let time_stamp10 = "07;24.00"
        let time_stamp11 = "7'24"
        
        let time_stamp12 = "2:31, 2:32, 2:34"
        let time_stamp13 = "02:31 - 02:32"
        let time_stamp14 = "2-31 - 2-32"
        
        let time_stamp15 = "00:30:00"
        
        let time_stamps1 = [time_stamp1, time_stamp2, time_stamp3, time_stamp4]
        let time_stamps2 = [time_stamp5, time_stamp6, time_stamp7, time_stamp8, time_stamp9, time_stamp10, time_stamp11]
        let time_stamps3 = [time_stamp12, time_stamp13, time_stamp14]
        let time_stamps4 = [time_stamp15]
        
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)
        for time_stamp in time_stamps1 {
            print("Testing time stamp \(time_stamp)")
            #expect(parser.verify_time_string(time_string: time_stamp)?.value == 61.34)
            #expect(parser.verify_time_string(time_string: time_stamp)?.asString == "01:01.34")
        }
        for time_stamp in time_stamps2 {
            print("Testing time stamp \(time_stamp)")
            #expect(parser.verify_time_string(time_string: time_stamp)?.value == 444.0)
            #expect(parser.verify_time_string(time_string: time_stamp)?.asString == "07:24.00")
        }
        for time_stamp in time_stamps3 {
            print("Testing time stamp \(time_stamp)")
            #expect(parser.verify_time_string(time_string: time_stamp)?.value == 151.0)
            #expect(parser.verify_time_string(time_string: time_stamp)?.asString == "02:31.00")
        }
        for time_stamp in time_stamps4 {
            print("Testing time stamp \(time_stamp)")
            #expect(parser.verify_time_string(time_string: time_stamp)?.value == 30.0)
            #expect(parser.verify_time_string(time_string: time_stamp)?.asString == "00:30.00")
        }
    }

    @Test func testVerifyTimeStringBareNumbers() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)

        // Bare "0" should parse as 0 seconds
        #expect(parser.verify_time_string(time_string: "0")?.value == 0.0)
        #expect(parser.verify_time_string(time_string: "0")?.asString == "00:00.00")

        // Bare integers should parse as raw seconds
        #expect(parser.verify_time_string(time_string: "5")?.value == 5.0)
        #expect(parser.verify_time_string(time_string: "5")?.asString == "00:05.00")

        #expect(parser.verify_time_string(time_string: "30")?.value == 30.0)
        #expect(parser.verify_time_string(time_string: "30")?.asString == "00:30.00")
    }

    @Test func testVerifyTimeStringRawFloats() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)

        // Decimal floats without separators should parse as raw seconds
        #expect(parser.verify_time_string(time_string: "5.085")?.value == 5.085)
        #expect(parser.verify_time_string(time_string: "5.085")?.asString == "00:05.09")

        #expect(parser.verify_time_string(time_string: "55.939")?.value == 55.939)
        #expect(parser.verify_time_string(time_string: "55.939")?.asString == "00:55.94")

        #expect(parser.verify_time_string(time_string: "1.5")?.value == 1.5)
        #expect(parser.verify_time_string(time_string: "1.5")?.asString == "00:01.50")
    }

    @Test func testVerifyTimeStringThreeDigitMilliseconds() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)

        // M:SS.mmm format (3-digit milliseconds after dot)
        #expect(parser.verify_time_string(time_string: "1:17.878")?.value == 77.878)
        #expect(parser.verify_time_string(time_string: "1:17.878")?.asString == "01:17.88")

        #expect(parser.verify_time_string(time_string: "2:33.287")?.value == 153.287)
        #expect(parser.verify_time_string(time_string: "2:33.287")?.asString == "02:33.29")

        #expect(parser.verify_time_string(time_string: "3:09.029")?.value == 189.029)
        #expect(parser.verify_time_string(time_string: "3:09.029")?.asString == "03:09.03")

        // M:SS:mmm format (3-digit milliseconds with colon separator)
        #expect(parser.verify_time_string(time_string: "1:17:878")?.value == 77.878)
        #expect(parser.verify_time_string(time_string: "1:17:878")?.asString == "01:17.88")
    }

    // MARK: - Cue sheet image formats

    @Test func testVerifyTimeStringImageFormats() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)

        // Exact formats from the cue sheet image: M:SS.mmm with 3-digit milliseconds
        #expect(parser.verify_time_string(time_string: "1:50.860")?.value == 110.86)
        #expect(parser.verify_time_string(time_string: "1:50.860")?.asString == "01:50.86")

        #expect(parser.verify_time_string(time_string: "2:11.202")?.value == 131.202)
        #expect(parser.verify_time_string(time_string: "2:11.202")?.asString == "02:11.20")

        #expect(parser.verify_time_string(time_string: "2:43.457")?.value == 163.457)
        #expect(parser.verify_time_string(time_string: "2:43.457")?.asString == "02:43.46")

        #expect(parser.verify_time_string(time_string: "3:02.055")?.value == 182.055)
        #expect(parser.verify_time_string(time_string: "3:02.055")?.asString == "03:02.05")
    }

    // MARK: - Separator variety

    @Test func testVerifyTimeStringSeparatorVariety() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)

        // All separator types should produce the same result: 3m 4s = 184s
        for ts in ["3:04", "3-04", "3'04", "3;04"] {
            #expect(parser.verify_time_string(time_string: ts)?.value == 184.0,
                    "Failed for \(ts)")
            #expect(parser.verify_time_string(time_string: ts)?.asString == "03:04.00",
                    "Failed for \(ts)")
        }

        // All separator types with decimal seconds: 3m 4.5s = 184.5s
        for ts in ["3:04.5", "3-04.5", "3'04.5", "3;04.5"] {
            #expect(parser.verify_time_string(time_string: ts)?.value == 184.5,
                    "Failed for \(ts)")
            #expect(parser.verify_time_string(time_string: ts)?.asString == "03:04.50",
                    "Failed for \(ts)")
        }

        // Single-digit seconds with various separators: 1m 5s = 65s
        for ts in ["1:5", "1-5", "1'5", "1;5"] {
            #expect(parser.verify_time_string(time_string: ts)?.value == 65.0,
                    "Failed for \(ts)")
        }
    }

    // MARK: - Wrapped and decorated formats

    @Test func testVerifyTimeStringWrappedFormats() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)

        // Parentheses stripped by pre_sanitize
        #expect(parser.verify_time_string(time_string: "(3:04)")?.value == 184.0)
        #expect(parser.verify_time_string(time_string: "(3:04)")?.asString == "03:04.00")

        // Square brackets stripped
        #expect(parser.verify_time_string(time_string: "[2:30]")?.value == 150.0)

        // Tildes stripped
        #expect(parser.verify_time_string(time_string: "~1:30")?.value == 90.0)
        #expect(parser.verify_time_string(time_string: "~2:30~")?.value == 150.0)

        // Leading whitespace and trailing newlines
        #expect(parser.verify_time_string(time_string: "  1:30  ")?.value == 90.0)
        #expect(parser.verify_time_string(time_string: "1:30\n")?.value == 90.0)
    }

    // MARK: - Range extraction

    @Test func testVerifyTimeStringRangeExtraction() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)

        // Ranges with space-dash-space: pre_sanitize splits on space, takes first
        #expect(parser.verify_time_string(time_string: "0:00 - 0:26")?.value == 0.0)
        #expect(parser.verify_time_string(time_string: "1:29 - 2:52")?.value == 89.0)
        #expect(parser.verify_time_string(time_string: "3:45 - 3:49")?.value == 225.0)

        // Comma-separated lists: takes the first value
        #expect(parser.verify_time_string(time_string: "3:01, 3:02, 3:03")?.value == 181.0)

        // Range with mixed separators
        #expect(parser.verify_time_string(time_string: "2-14 - 2-30")?.value == 134.0)
    }

    // MARK: - Invalid inputs

    @Test func testVerifyTimeStringRejectsInvalid() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)

        #expect(parser.verify_time_string(time_string: "") == nil)
        #expect(parser.verify_time_string(time_string: "abc") == nil)
        #expect(parser.verify_time_string(time_string: "BLACKOUT") == nil)
        #expect(parser.verify_time_string(time_string: "N/A") == nil)
        #expect(parser.verify_time_string(time_string: "none") == nil)
        #expect(parser.verify_time_string(time_string: "TBD") == nil)
        #expect(parser.verify_time_string(time_string: " ") == nil)
        #expect(parser.verify_time_string(time_string: "---") == nil)
    }

    // MARK: - Large values (>= 10 minutes)

    @Test func testVerifyTimeStringLargeValues() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)

        #expect(parser.verify_time_string(time_string: "10:00")?.value == 600.0)
        #expect(parser.verify_time_string(time_string: "10:00")?.asString == "10:00.00")

        #expect(parser.verify_time_string(time_string: "15:30.5")?.value == 930.5)
        #expect(parser.verify_time_string(time_string: "15:30.5")?.asString == "15:30.50")

        #expect(parser.verify_time_string(time_string: "28:11.03")?.value == 1691.03)
        #expect(parser.verify_time_string(time_string: "28:11.03")?.asString == "28:11.03")

        // Large bare float (e.g. raw seconds for a long piece)
        #expect(parser.verify_time_string(time_string: "304.5")?.value == 304.5)
        #expect(parser.verify_time_string(time_string: "304.5")?.asString == "05:04.50")
    }

    // MARK: - Three-segment formats (M:S:cs centisecond interpretation)

    @Test func testVerifyTimeStringThreeSegments() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)

        // M:SS:cs — last integer segment is centiseconds (/100)
        #expect(parser.verify_time_string(time_string: "0:05:50")?.value == 5.5)
        #expect(parser.verify_time_string(time_string: "0:05:50")?.asString == "00:05.50")

        #expect(parser.verify_time_string(time_string: "1:30:50")?.value == 90.5)
        #expect(parser.verify_time_string(time_string: "1:30:50")?.asString == "01:30.50")

        // Zero centiseconds
        #expect(parser.verify_time_string(time_string: "0:05:00")?.value == 5.0)
        #expect(parser.verify_time_string(time_string: "0:05:00")?.asString == "00:05.00")

        #expect(parser.verify_time_string(time_string: "1:30:00")?.value == 90.0)
        #expect(parser.verify_time_string(time_string: "1:30:00")?.asString == "01:30.00")

        // Apostrophe as third separator
        #expect(parser.verify_time_string(time_string: "0:05'50")?.value == 5.5)
        #expect(parser.verify_time_string(time_string: "0:05'50")?.asString == "00:05.50")

        // Three segments with decimal last part — NOT centisecond, treated as H:M:S.f
        #expect(parser.verify_time_string(time_string: "0:01:01.34")?.value == 61.34)
        #expect(parser.verify_time_string(time_string: "0:01:01.34")?.asString == "01:01.34")

        // Three-digit millisecond segment (/1000)
        #expect(parser.verify_time_string(time_string: "0:59:999")?.value == 59.999)
        #expect(parser.verify_time_string(time_string: "0:59:999")?.asString == "01:00.00")
    }

    // MARK: - Edge cases and zero formats

    @Test func testVerifyTimeStringEdgeCases() throws {
        let parser = Parser(file_path: NICKI_SHOW_FILE.path, file_name: NICKI_SHOW_FILE.lastPathComponent)

        // Zero in various formats
        #expect(parser.verify_time_string(time_string: "0:00")?.value == 0.0)
        #expect(parser.verify_time_string(time_string: "0:00")?.asString == "00:00.00")

        #expect(parser.verify_time_string(time_string: "00:00")?.value == 0.0)
        #expect(parser.verify_time_string(time_string: "00:00.00")?.value == 0.0)
        #expect(parser.verify_time_string(time_string: "0.0")?.value == 0.0)

        // Leading zeros don't change the value
        #expect(parser.verify_time_string(time_string: "01:05")?.value == 65.0)
        #expect(parser.verify_time_string(time_string: "01:05")?.asString == "01:05.00")
        #expect(parser.verify_time_string(time_string: "01:05.00")?.value == 65.0)

        // The specific ambiguous case from the user: 5:05 = 5min 5sec = 305s
        #expect(parser.verify_time_string(time_string: "5:05")?.value == 305.0)
        #expect(parser.verify_time_string(time_string: "5:05")?.asString == "05:05.00")

        // Pre-sanitize strips leading non-digits (e.g., negative sign)
        #expect(parser.verify_time_string(time_string: "-5")?.value == 5.0)
        #expect(parser.verify_time_string(time_string: "-1:30")?.value == 90.0)

        // Boundary: just under and at 1 minute
        #expect(parser.verify_time_string(time_string: "0:59")?.value == 59.0)
        #expect(parser.verify_time_string(time_string: "1:00")?.value == 60.0)

        // Boundary: max two-digit seconds
        #expect(parser.verify_time_string(time_string: "9:59.999")?.value == 599.999)
    }
}
