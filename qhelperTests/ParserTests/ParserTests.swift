//
//  qhelperTests.swift
//  qhelperTests
//
//  Created by Arthur Efremenko on 11/18/24.
//

import XCTest
@testable import qhelper

final class ParserTests: XCTestCase {
    
    let workbook1 = "/Users/lemanappazov/Desktop/Coding/Swift/qhelper/qhelper/Samples/Aaroh Lighting Cues Form-Fenway.xlsx"
    let workbook2 = "/Users/lemanappazov/Desktop/Coding/Swift/qhelper/qhelper/Samples/Amelia and Emily_Too Sweet.xlsx"
    let workbook3 = "/Users/lemanappazov/Desktop/Coding/Swift/qhelper/qhelper/Samples/Battle Of The ASO's Lighting Cues Form (NASO).xlsx"
    let workbook4 = "/Users/lemanappazov/Desktop/Coding/Swift/qhelper/qhelper/Samples/Candice Cues Fall 2024.xlsx"
    let workbook5 = "/Users/lemanappazov/Desktop/Coding/Swift/qhelper/qhelper/Samples/Lighting Cues Form- NUSANSRITI FASHION TEAM 2024.xlsx"
    let workbook6 = "/Users/lemanappazov/Desktop/Coding/Swift/qhelper/qhelper/Samples/Tyler Cues Fall 23.xlsx"
    
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
    
    func testVerifyTimeString() throws {
        let time_stamps1 = [time_stamp1, time_stamp2, time_stamp3, time_stamp4]
        let time_stamps2 = [time_stamp5, time_stamp6, time_stamp7, time_stamp8, time_stamp9, time_stamp10, time_stamp11]
        let time_stamps3 = [time_stamp12, time_stamp13, time_stamp14]
        let time_stamps4 = [time_stamp15]
        
        let parser = Parser(file_path: workbook1)
        for time_stamp in time_stamps1 {
            print("Testing time stamp \(time_stamp)")
            XCTAssertEqual(parser.verify_time_string(time_string: time_stamp)?.value, 61.34)
            XCTAssertEqual(parser.verify_time_string(time_string: time_stamp)?.asString, "01:01.34")
        }
        for time_stamp in time_stamps2 {
            print("Testing time stamp \(time_stamp)")
            XCTAssertEqual(parser.verify_time_string(time_string: time_stamp)?.value, 444.0)
            XCTAssertEqual(parser.verify_time_string(time_string: time_stamp)?.asString, "07:24.00")
        }
        for time_stamp in time_stamps3 {
            print("Testing time stamp \(time_stamp)")
            XCTAssertEqual(parser.verify_time_string(time_string: time_stamp)?.value, 151.0)
            XCTAssertEqual(parser.verify_time_string(time_string: time_stamp)?.asString, "02:31.00")
        }
        for time_stamp in time_stamps4 {
            print("Testing time stamp \(time_stamp)")
            XCTAssertEqual(parser.verify_time_string(time_string: time_stamp)?.value, 30.0)
            XCTAssertEqual(parser.verify_time_string(time_string: time_stamp)?.asString, "00:30.00")
        }
    }

    func testAarohFenwayGeneral() throws {
        let parser = Parser(file_path: workbook1)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        XCTAssertEqual(cue_tables.count, 6)
    }
    
    func testAarohFenwaySojaSoja() throws {
        let parser = Parser(file_path: workbook1)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_1 = cue_tables[0]
        XCTAssertEqual(cue_table_1.name, "Soja Soja")
        XCTAssertEqual(cue_table_1.times.count, 18)
        XCTAssertEqual(cue_table_1.times[0].value, 0.0)
        XCTAssertEqual(cue_table_1.times[0].asString, "00:00.00")
        XCTAssertEqual(cue_table_1.times[1].value, 30.0)
        XCTAssertEqual(cue_table_1.times[1].asString, "00:30.00")
        XCTAssertEqual(cue_table_1.times[2].value, 60.0)
        XCTAssertEqual(cue_table_1.times[2].asString, "01:00.00")
        XCTAssertEqual(cue_table_1.times[3].value, 65.0)
        XCTAssertEqual(cue_table_1.times[3].asString, "01:05.00")
        XCTAssertEqual(cue_table_1.times[4].value, 70.0)
        XCTAssertEqual(cue_table_1.times[4].asString, "01:10.00")
        XCTAssertEqual(cue_table_1.times[5].value, 80.0)
        XCTAssertEqual(cue_table_1.times[5].asString, "01:20.00")
        XCTAssertEqual(cue_table_1.times[6].value, 81.0)
        XCTAssertEqual(cue_table_1.times[6].asString, "01:21.00")
        XCTAssertEqual(cue_table_1.times[7].value, 82.0)
        XCTAssertEqual(cue_table_1.times[7].asString, "01:22.00")
        XCTAssertEqual(cue_table_1.times[8].value, 83.0)
        XCTAssertEqual(cue_table_1.times[8].asString, "01:23.00")
        XCTAssertEqual(cue_table_1.times[9].value, 110.0)
        XCTAssertEqual(cue_table_1.times[9].asString, "01:50.00")
        XCTAssertEqual(cue_table_1.times[10].value, 150.0)
        XCTAssertEqual(cue_table_1.times[10].asString, "02:30.00")
        XCTAssertEqual(cue_table_1.times[11].value, 210.0)
        XCTAssertEqual(cue_table_1.times[11].asString, "03:30.00")
        XCTAssertEqual(cue_table_1.times[12].value, 220.0)
        XCTAssertEqual(cue_table_1.times[12].asString, "03:40.00")
        XCTAssertEqual(cue_table_1.times[13].value, 221.0)
        XCTAssertEqual(cue_table_1.times[13].asString, "03:41.00")
        XCTAssertEqual(cue_table_1.times[14].value, 222.0)
        XCTAssertEqual(cue_table_1.times[14].asString, "03:42.00")
        XCTAssertEqual(cue_table_1.times[15].value, 223.0)
        XCTAssertEqual(cue_table_1.times[15].asString, "03:43.00")
        XCTAssertEqual(cue_table_1.times[16].value, 240.0)
        XCTAssertEqual(cue_table_1.times[16].asString, "04:00.00")
        XCTAssertEqual(cue_table_1.times[17].value, 300.0)
        XCTAssertEqual(cue_table_1.times[17].asString, "05:00.00")
    }
    
    func testAarohFenwayMalhar1() throws {
        let parser = Parser(file_path: workbook1)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_2 = cue_tables[1]
        XCTAssertEqual(cue_table_2.name, "Malhar 1")
        XCTAssertEqual(cue_table_2.times.count, 2)
        XCTAssertEqual(cue_table_2.times[0].value, 0.0)
        XCTAssertEqual(cue_table_2.times[0].asString, "00:00.00")
        XCTAssertEqual(cue_table_2.times[1].value, 80.0)
        XCTAssertEqual(cue_table_2.times[1].asString, "01:20.00")
    }
    
    func testAarohFenwayMalhar2() throws {
        let parser = Parser(file_path: workbook1)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_3 = cue_tables[2]
        XCTAssertEqual(cue_table_3.name, "Malhar 2")
        XCTAssertEqual(cue_table_3.times.count, 8)
        XCTAssertEqual(cue_table_3.times[0].value, 0.0)
        XCTAssertEqual(cue_table_3.times[0].asString, "00:00.00")
        XCTAssertEqual(cue_table_3.times[1].value, 19.0)
        XCTAssertEqual(cue_table_3.times[1].asString, "00:19.00")
        XCTAssertEqual(cue_table_3.times[2].value, 79.0)
        XCTAssertEqual(cue_table_3.times[2].asString, "01:19.00")
        XCTAssertEqual(cue_table_3.times[3].value, 107.0)
        XCTAssertEqual(cue_table_3.times[3].asString, "01:47.00")
        XCTAssertEqual(cue_table_3.times[4].value, 135.0)
        XCTAssertEqual(cue_table_3.times[4].asString, "02:15.00")
        XCTAssertEqual(cue_table_3.times[5].value, 147.0)
        XCTAssertEqual(cue_table_3.times[5].asString, "02:27.00")
        XCTAssertEqual(cue_table_3.times[6].value, 187.0)
        XCTAssertEqual(cue_table_3.times[6].asString, "03:07.00")
        XCTAssertEqual(cue_table_3.times[7].value, 199.0)
        XCTAssertEqual(cue_table_3.times[7].asString, "03:19.00")
    }
    
    func testAarohFenwayNaad() throws {
        let parser = Parser(file_path: workbook1)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_4 = cue_tables[3]
        XCTAssertEqual(cue_table_4.name, "NAAD")
        XCTAssertEqual(cue_table_4.times.count, 11)
        XCTAssertEqual(cue_table_4.times[0].value, 0.0)
        XCTAssertEqual(cue_table_4.times[0].asString, "00:00.00")
        XCTAssertEqual(cue_table_4.times[1].value, 45.0)
        XCTAssertEqual(cue_table_4.times[1].asString, "00:45.00")
        XCTAssertEqual(cue_table_4.times[2].value, 60.0)
        XCTAssertEqual(cue_table_4.times[2].asString, "01:00.00")
        XCTAssertEqual(cue_table_4.times[3].value, 80.0)
        XCTAssertEqual(cue_table_4.times[3].asString, "01:20.00")
        XCTAssertEqual(cue_table_4.times[4].value, 120.0)
        XCTAssertEqual(cue_table_4.times[4].asString, "02:00.00")
        XCTAssertEqual(cue_table_4.times[5].value, 145.0)
        XCTAssertEqual(cue_table_4.times[5].asString, "02:25.00")
        XCTAssertEqual(cue_table_4.times[6].value, 0.0)
        XCTAssertEqual(cue_table_4.times[6].asString, "00:00.00")
        XCTAssertEqual(cue_table_4.times[7].value, 42.0)
        XCTAssertEqual(cue_table_4.times[7].asString, "00:42.00")
        XCTAssertEqual(cue_table_4.times[8].value, 60.0)
        XCTAssertEqual(cue_table_4.times[8].asString, "01:00.00")
        XCTAssertEqual(cue_table_4.times[9].value, 90.0)
        XCTAssertEqual(cue_table_4.times[9].asString, "01:30.00")
        XCTAssertEqual(cue_table_4.times[10].value, 120.0)
        XCTAssertEqual(cue_table_4.times[10].asString, "02:00.00")
    }
    
    func testAarohFenwayJiyaJale() throws {
        let parser = Parser(file_path: workbook1)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_5 = cue_tables[4]
        XCTAssertEqual(cue_table_5.name, "Jiya Jale")
        XCTAssertEqual(cue_table_5.times.count, 10)
        XCTAssertEqual(cue_table_5.times[0].value, 0.0)
        XCTAssertEqual(cue_table_5.times[0].asString, "00:00.00")
        XCTAssertEqual(cue_table_5.times[1].value, 30.0)
        XCTAssertEqual(cue_table_5.times[1].asString, "00:30.00")
        XCTAssertEqual(cue_table_5.times[2].value, 60.0)
        XCTAssertEqual(cue_table_5.times[2].asString, "01:00.00")
        XCTAssertEqual(cue_table_5.times[3].value, 105.0)
        XCTAssertEqual(cue_table_5.times[3].asString, "01:45.00")
        XCTAssertEqual(cue_table_5.times[4].value, 150.0)
        XCTAssertEqual(cue_table_5.times[4].asString, "02:30.00")
        XCTAssertEqual(cue_table_5.times[5].value, 195.0)
        XCTAssertEqual(cue_table_5.times[5].asString, "03:15.00")
        XCTAssertEqual(cue_table_5.times[6].value, 240.0)
        XCTAssertEqual(cue_table_5.times[6].asString, "04:00.00")
        XCTAssertEqual(cue_table_5.times[7].value, 285.0)
        XCTAssertEqual(cue_table_5.times[7].asString, "04:45.00")
        XCTAssertEqual(cue_table_5.times[8].value, 315.0)
        XCTAssertEqual(cue_table_5.times[8].asString, "05:15.00")
        XCTAssertEqual(cue_table_5.times[9].value, 330.0)
        XCTAssertEqual(cue_table_5.times[9].asString, "05:30.00")
    }
    
    func testAarohFenwayAasaKooda() throws {
        let parser = Parser(file_path: workbook1)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_6 = cue_tables[5]
        XCTAssertEqual(cue_table_6.name, "Jiya Jale")
        XCTAssertEqual(cue_table_6.times.count, 10)
        XCTAssertEqual(cue_table_6.times[0].value, 0.0)
        XCTAssertEqual(cue_table_6.times[0].asString, "00:00.00")
        XCTAssertEqual(cue_table_6.times[1].value, 45.0)
        XCTAssertEqual(cue_table_6.times[1].asString, "00:45.00")
        XCTAssertEqual(cue_table_6.times[2].value, 90.0)
        XCTAssertEqual(cue_table_6.times[2].asString, "01:30.00")
        XCTAssertEqual(cue_table_6.times[3].value, 120.0)
        XCTAssertEqual(cue_table_6.times[3].asString, "02:00.00")
        XCTAssertEqual(cue_table_6.times[4].value, 165.0)
        XCTAssertEqual(cue_table_6.times[4].asString, "02:45.00")
        XCTAssertEqual(cue_table_6.times[5].value, 195.0)
        XCTAssertEqual(cue_table_6.times[5].asString, "03:15.00")
        XCTAssertEqual(cue_table_6.times[6].value, 225.0)
        XCTAssertEqual(cue_table_6.times[6].asString, "03:45.00")
        XCTAssertEqual(cue_table_6.times[7].value, 255.0)
        XCTAssertEqual(cue_table_6.times[7].asString, "04:15.00")
        XCTAssertEqual(cue_table_6.times[8].value, 285.0)
        XCTAssertEqual(cue_table_6.times[8].asString, "04:45.00")
        XCTAssertEqual(cue_table_6.times[9].value, 300.0)
        XCTAssertEqual(cue_table_6.times[9].asString, "05:00.00")
    }
    
    func testAmeliaAndEmilyGeneral() throws {
        let parser = Parser(file_path: workbook2)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        XCTAssertEqual(cue_tables.count, 1)
    }
    
    func testAmeliaAndEmily() throws {
        let parser = Parser(file_path: workbook2)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table = cue_tables[0]
        XCTAssertEqual(cue_table.name, "Sheet1")
        XCTAssertEqual(cue_table.times.count, 12)
        XCTAssertEqual(cue_table.times[0].value, 0.0)
        XCTAssertEqual(cue_table.times[0].asString, "00:00.00")
        XCTAssertEqual(cue_table.times[1].value, 16.95)
        XCTAssertEqual(cue_table.times[1].asString, "00:16.95")
        XCTAssertEqual(cue_table.times[2].value, 25.04)
        XCTAssertEqual(cue_table.times[2].asString, "00:25.04")
        XCTAssertEqual(cue_table.times[3].value, 64.0)
        XCTAssertEqual(cue_table.times[3].asString, "01:04.00")
        XCTAssertEqual(cue_table.times[4].value, 94.86)
        XCTAssertEqual(cue_table.times[4].asString, "01:34.86")
        XCTAssertEqual(cue_table.times[5].value, 110.54)
        XCTAssertEqual(cue_table.times[5].asString, "01:50.54")
        XCTAssertEqual(cue_table.times[6].value, 114.59)
        XCTAssertEqual(cue_table.times[6].asString, "01:54.59")
        XCTAssertEqual(cue_table.times[7].value, 146.46)
        XCTAssertEqual(cue_table.times[7].asString, "02:26.46")
        XCTAssertEqual(cue_table.times[8].value, 162.40)
        XCTAssertEqual(cue_table.times[8].asString, "02:42.40")
        XCTAssertEqual(cue_table.times[9].value, 196.29)
        XCTAssertEqual(cue_table.times[9].asString, "03:16.29")
        XCTAssertEqual(cue_table.times[10].value, 227.66)
        XCTAssertEqual(cue_table.times[10].asString, "03:47.66")
        XCTAssertEqual(cue_table.times[11].value, 246.38)
        XCTAssertEqual(cue_table.times[11].asString, "04:06.38")
    }
    
    func testBattleOfTheASOSGeneral() throws {
        let parser = Parser(file_path: workbook3)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        XCTAssertEqual(cue_tables.count, 9)
    }
    
    func testCandiceCuesGeneral() throws {
        let parser = Parser(file_path: workbook4)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        XCTAssertEqual(cue_tables.count, 3)
    }
    
    func testSanskritiFashionGeneral() throws {
        let parser = Parser(file_path: workbook5)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        XCTAssertEqual(cue_tables.count, 1)
    }
    
    func testSanskritiFashion() throws {
        let parser = Parser(file_path: workbook5)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table = cue_tables[0]
        XCTAssertEqual(cue_table.name, "FASHION TEAM")
        XCTAssertNotEqual(cue_table.times.count, 19)
        XCTAssertEqual(cue_table.times.count, 16)
        
        XCTAssertEqual(cue_table.times[0].value, 0.0)
        XCTAssertEqual(cue_table.times[0].asString, "00:00.00")
        XCTAssertEqual(cue_table.times[1].value, 11.57)
        XCTAssertEqual(cue_table.times[1].asString, "00:11.57")
        XCTAssertEqual(cue_table.times[2].value, 17.0)
        XCTAssertEqual(cue_table.times[2].asString, "00:17.00")
        XCTAssertEqual(cue_table.times[3].value, 39.22)
        XCTAssertEqual(cue_table.times[3].asString, "00:39.22")
        XCTAssertEqual(cue_table.times[4].value, 57.99)
        XCTAssertEqual(cue_table.times[4].asString, "00:57.99")
        XCTAssertEqual(cue_table.times[5].value, 75.01)
        XCTAssertEqual(cue_table.times[5].asString, "01:15.01")
        XCTAssertEqual(cue_table.times[6].value, 450.0)
        XCTAssertEqual(cue_table.times[6].asString, "07:30.00")
        XCTAssertEqual(cue_table.times[7].value, 480.0)
        XCTAssertEqual(cue_table.times[7].asString, "08:00.00")
        XCTAssertEqual(cue_table.times[8].value, 490.0)
        XCTAssertEqual(cue_table.times[8].asString, "08:10.00")
        XCTAssertEqual(cue_table.times[9].value, 500.23)
        XCTAssertEqual(cue_table.times[9].asString, "08:20.23")
        XCTAssertEqual(cue_table.times[10].value, 574.22)
        XCTAssertEqual(cue_table.times[10].asString, "09:34.22")
        XCTAssertEqual(cue_table.times[11].value, 648.21)
        XCTAssertEqual(cue_table.times[11].asString, "10:48.21")
        XCTAssertNotEqual(cue_table.times[12].value, 751.99)
        XCTAssertNotEqual(cue_table.times[12].asString, "11:91.99")
        XCTAssertEqual(cue_table.times[12].value, 842.10)
        XCTAssertEqual(cue_table.times[12].asString, "14:02.10")
        XCTAssertNotEqual(cue_table.times[13].value, 1223.29)
        XCTAssertNotEqual(cue_table.times[13].asString, "19:83.29")
        XCTAssertEqual(cue_table.times[13].value, 1224.03)
        XCTAssertEqual(cue_table.times[13].asString, "20:24.03")
        XCTAssertEqual(cue_table.times[14].value, 1239.03)
        XCTAssertEqual(cue_table.times[14].asString, "20:39.03")
        XCTAssertNotEqual(cue_table.times[15].value, 1341.03)
        XCTAssertNotEqual(cue_table.times[15].asString, "21:81.03")
        XCTAssertEqual(cue_table.times[15].value, 1691.03)
        XCTAssertEqual(cue_table.times[15].asString, "28:11.03")
    }
    
    func testTylerCuesGeneral() throws {
        let parser = Parser(file_path: workbook6)
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        XCTAssertEqual(cue_tables.count, 4)
    }

}
