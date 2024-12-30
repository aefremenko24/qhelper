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
    
    let NICKI_SHOW_FILE: URL = URL(fileURLWithPath: "/Users/lemanappazov/Desktop/Coding/Swift/QHelper_All/qhelper/qhelperTests/ParserTests/9. Sarah - The Nicki Show.xlsx")
    
    let NUMALHAR_FILE: URL = URL(fileURLWithPath: "/Users/lemanappazov/Desktop/Coding/Swift/QHelper_All/qhelper/qhelperTests/ParserTests/NUMalhar Lighting Cues D4ME 2024.xlsx")
    
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
        let time_stamp11 = "00:7:24"
        
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
}
