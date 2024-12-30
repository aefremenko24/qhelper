//
//  qhelperTests.swift
//  qhelperTests
//
//  Created by Arthur Efremenko on 11/18/24.
//

import Testing
@testable import qhelper

struct IntegrationParserTests {
    
    let workbook1 = "/Users/lemanappazov/Desktop/Coding/Swift/QHelper_All/qhelper/qhelperTests/IntegrationTests/Aaroh Lighting Cues Form-Fenway.xlsx"
    let workbook2 = "/Users/lemanappazov/Desktop/Coding/Swift/QHelper_All/qhelper/qhelperTests/IntegrationTests/Amelia and Emily_Too Sweet.xlsx"
    let workbook3 = "/Users/lemanappazov/Desktop/Coding/Swift/QHelper_All/qhelper/qhelperTests/IntegrationTests/Battle Of The ASO's Lighting Cues Form (NASO).xlsx"
    let workbook4 = "/Users/lemanappazov/Desktop/Coding/Swift/QHelper_All/qhelper/qhelperTests/IntegrationTests/Candice Cues Fall 2024.xlsx"
    let workbook5 = "/Users/lemanappazov/Desktop/Coding/Swift/QHelper_All/qhelper/qhelperTests/IntegrationTests/Lighting Cues Form- NUSANSRITI FASHION TEAM 2024.xlsx"
    let workbook6 = "/Users/lemanappazov/Desktop/Coding/Swift/QHelper_All/qhelper/qhelperTests/IntegrationTests/Tyler Cues Fall 23.xlsx"

    @Test func testAarohFenwayGeneral() throws {
        let parser = Parser(file_path: workbook1, file_name: String(workbook1.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        #expect(cue_tables.count == 6)
    }
    
    @Test func testAarohFenwaySojaSoja() throws {
        let parser = Parser(file_path: workbook1, file_name: String(workbook1.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_1 = cue_tables[0]
        #expect(cue_table_1.name == "Aaroh Lighting Cues Form-Fenway")
        #expect(cue_table_1.times.count == 18)
        #expect(cue_table_1.times[0].value == 0.0)
        #expect(cue_table_1.times[0].asString == "00:00.00")
        #expect(cue_table_1.times[1].value == 30.0)
        #expect(cue_table_1.times[1].asString == "00:30.00")
        #expect(cue_table_1.times[2].value == 60.0)
        #expect(cue_table_1.times[2].asString == "01:00.00")
        #expect(cue_table_1.times[3].value == 65.0)
        #expect(cue_table_1.times[3].asString == "01:05.00")
        #expect(cue_table_1.times[4].value == 70.0)
        #expect(cue_table_1.times[4].asString == "01:10.00")
        #expect(cue_table_1.times[5].value == 80.0)
        #expect(cue_table_1.times[5].asString == "01:20.00")
        #expect(cue_table_1.times[6].value == 81.0)
        #expect(cue_table_1.times[6].asString == "01:21.00")
        #expect(cue_table_1.times[7].value == 82.0)
        #expect(cue_table_1.times[7].asString == "01:22.00")
        #expect(cue_table_1.times[8].value == 83.0)
        #expect(cue_table_1.times[8].asString == "01:23.00")
        #expect(cue_table_1.times[9].value == 110.0)
        #expect(cue_table_1.times[9].asString == "01:50.00")
        #expect(cue_table_1.times[10].value == 150.0)
        #expect(cue_table_1.times[10].asString == "02:30.00")
        #expect(cue_table_1.times[11].value == 210.0)
        #expect(cue_table_1.times[11].asString == "03:30.00")
        #expect(cue_table_1.times[12].value == 220.0)
        #expect(cue_table_1.times[12].asString == "03:40.00")
        #expect(cue_table_1.times[13].value == 221.0)
        #expect(cue_table_1.times[13].asString == "03:41.00")
        #expect(cue_table_1.times[14].value == 222.0)
        #expect(cue_table_1.times[14].asString == "03:42.00")
        #expect(cue_table_1.times[15].value == 223.0)
        #expect(cue_table_1.times[15].asString == "03:43.00")
        #expect(cue_table_1.times[16].value == 240.0)
        #expect(cue_table_1.times[16].asString == "04:00.00")
        #expect(cue_table_1.times[17].value == 300.0)
        #expect(cue_table_1.times[17].asString == "05:00.00")
    }
    
    @Test func testAarohFenwayMalhar1() throws {
        let parser = Parser(file_path: workbook1, file_name: String(workbook1.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_2 = cue_tables[1]
        #expect(cue_table_2.name == "Aaroh Lighting Cues Form-Fenway")
        #expect(cue_table_2.times.count == 2)
        #expect(cue_table_2.times[0].value == 0.0)
        #expect(cue_table_2.times[0].asString == "00:00.00")
        #expect(cue_table_2.times[1].value == 80.0)
        #expect(cue_table_2.times[1].asString == "01:20.00")
    }
    
    @Test func testAarohFenwayMalhar2() throws {
        let parser = Parser(file_path: workbook1, file_name: String(workbook1.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_3 = cue_tables[2]
        #expect(cue_table_3.name == "Aaroh Lighting Cues Form-Fenway")
        #expect(cue_table_3.times.count == 8)
        #expect(cue_table_3.times[0].value == 0.0)
        #expect(cue_table_3.times[0].asString == "00:00.00")
        #expect(cue_table_3.times[1].value == 19.0)
        #expect(cue_table_3.times[1].asString == "00:19.00")
        #expect(cue_table_3.times[2].value == 79.0)
        #expect(cue_table_3.times[2].asString == "01:19.00")
        #expect(cue_table_3.times[3].value == 107.0)
        #expect(cue_table_3.times[3].asString == "01:47.00")
        #expect(cue_table_3.times[4].value == 135.0)
        #expect(cue_table_3.times[4].asString == "02:15.00")
        #expect(cue_table_3.times[5].value == 147.0)
        #expect(cue_table_3.times[5].asString == "02:27.00")
        #expect(cue_table_3.times[6].value == 187.0)
        #expect(cue_table_3.times[6].asString == "03:07.00")
        #expect(cue_table_3.times[7].value == 199.0)
        #expect(cue_table_3.times[7].asString == "03:19.00")
    }
    
    @Test func testAarohFenwayNaad() throws {
        let parser = Parser(file_path: workbook1, file_name: String(workbook1.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_4 = cue_tables[3]
        #expect(cue_table_4.name == "Aaroh Lighting Cues Form-Fenway")
        #expect(cue_table_4.times.count == 11)
        #expect(cue_table_4.times[0].value == 0.0)
        #expect(cue_table_4.times[0].asString == "00:00.00")
        #expect(cue_table_4.times[1].value == 45.0)
        #expect(cue_table_4.times[1].asString == "00:45.00")
        #expect(cue_table_4.times[2].value == 60.0)
        #expect(cue_table_4.times[2].asString == "01:00.00")
        #expect(cue_table_4.times[3].value == 80.0)
        #expect(cue_table_4.times[3].asString == "01:20.00")
        #expect(cue_table_4.times[4].value == 120.0)
        #expect(cue_table_4.times[4].asString == "02:00.00")
        #expect(cue_table_4.times[5].value == 145.0)
        #expect(cue_table_4.times[5].asString == "02:25.00")
        #expect(cue_table_4.times[6].value == 0.0)
        #expect(cue_table_4.times[6].asString == "00:00.00")
        #expect(cue_table_4.times[7].value == 42.0)
        #expect(cue_table_4.times[7].asString == "00:42.00")
        #expect(cue_table_4.times[8].value == 60.0)
        #expect(cue_table_4.times[8].asString == "01:00.00")
        #expect(cue_table_4.times[9].value == 90.0)
        #expect(cue_table_4.times[9].asString == "01:30.00")
        #expect(cue_table_4.times[10].value == 120.0)
        #expect(cue_table_4.times[10].asString == "02:00.00")
    }
    
    @Test func testAarohFenwayJiyaJale() throws {
        let parser = Parser(file_path: workbook1, file_name: String(workbook1.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_5 = cue_tables[4]
        #expect(cue_table_5.name == "Aaroh Lighting Cues Form-Fenway")
        #expect(cue_table_5.times.count == 10)
        #expect(cue_table_5.times[0].value == 0.0)
        #expect(cue_table_5.times[0].asString == "00:00.00")
        #expect(cue_table_5.times[1].value == 30.0)
        #expect(cue_table_5.times[1].asString == "00:30.00")
        #expect(cue_table_5.times[2].value == 60.0)
        #expect(cue_table_5.times[2].asString == "01:00.00")
        #expect(cue_table_5.times[3].value == 105.0)
        #expect(cue_table_5.times[3].asString == "01:45.00")
        #expect(cue_table_5.times[4].value == 150.0)
        #expect(cue_table_5.times[4].asString == "02:30.00")
        #expect(cue_table_5.times[5].value == 195.0)
        #expect(cue_table_5.times[5].asString == "03:15.00")
        #expect(cue_table_5.times[6].value == 240.0)
        #expect(cue_table_5.times[6].asString == "04:00.00")
        #expect(cue_table_5.times[7].value == 285.0)
        #expect(cue_table_5.times[7].asString == "04:45.00")
        #expect(cue_table_5.times[8].value == 315.0)
        #expect(cue_table_5.times[8].asString == "05:15.00")
        #expect(cue_table_5.times[9].value == 330.0)
        #expect(cue_table_5.times[9].asString == "05:30.00")
    }
    
    @Test func testAarohFenwayAasaKooda() throws {
        let parser = Parser(file_path: workbook1, file_name: String(workbook1.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table_6 = cue_tables[5]
        #expect(cue_table_6.name == "Aaroh Lighting Cues Form-Fenway")
        #expect(cue_table_6.times.count == 10)
        #expect(cue_table_6.times[0].value == 0.0)
        #expect(cue_table_6.times[0].asString == "00:00.00")
        #expect(cue_table_6.times[1].value == 45.0)
        #expect(cue_table_6.times[1].asString == "00:45.00")
        #expect(cue_table_6.times[2].value == 90.0)
        #expect(cue_table_6.times[2].asString == "01:30.00")
        #expect(cue_table_6.times[3].value == 120.0)
        #expect(cue_table_6.times[3].asString == "02:00.00")
        #expect(cue_table_6.times[4].value == 165.0)
        #expect(cue_table_6.times[4].asString == "02:45.00")
        #expect(cue_table_6.times[5].value == 195.0)
        #expect(cue_table_6.times[5].asString == "03:15.00")
        #expect(cue_table_6.times[6].value == 225.0)
        #expect(cue_table_6.times[6].asString == "03:45.00")
        #expect(cue_table_6.times[7].value == 255.0)
        #expect(cue_table_6.times[7].asString == "04:15.00")
        #expect(cue_table_6.times[8].value == 285.0)
        #expect(cue_table_6.times[8].asString == "04:45.00")
        #expect(cue_table_6.times[9].value == 300.0)
        #expect(cue_table_6.times[9].asString == "05:00.00")
    }
    
    @Test func testAmeliaAndEmilyGeneral() throws {
        let parser = Parser(file_path: workbook2, file_name: String(workbook2.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        #expect(cue_tables.count == 1)
    }
    
    @Test func testAmeliaAndEmily() throws {
        let parser = Parser(file_path: workbook2, file_name: String(workbook2.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table = cue_tables[0]
        #expect(cue_table.name == "Amelia and Emily_Too Sweet")
        #expect(cue_table.times.count == 12)
        #expect(cue_table.times[0].value == 0.0)
        #expect(cue_table.times[0].asString == "00:00.00")
        #expect(cue_table.times[1].value == 16.95)
        #expect(cue_table.times[1].asString == "00:16.95")
        #expect(cue_table.times[2].value == 25.04)
        #expect(cue_table.times[2].asString == "00:25.04")
        #expect(cue_table.times[3].value == 64.0)
        #expect(cue_table.times[3].asString == "01:04.00")
        #expect(cue_table.times[4].value == 94.86)
        #expect(cue_table.times[4].asString == "01:34.86")
        #expect(cue_table.times[5].value == 110.54)
        #expect(cue_table.times[5].asString == "01:50.54")
        #expect(cue_table.times[6].value == 114.59)
        #expect(cue_table.times[6].asString == "01:54.59")
        #expect(cue_table.times[7].value == 146.46)
        #expect(cue_table.times[7].asString == "02:26.46")
        #expect(cue_table.times[8].value == 162.40)
        #expect(cue_table.times[8].asString == "02:42.40")
        #expect(cue_table.times[9].value == 196.29)
        #expect(cue_table.times[9].asString == "03:16.29")
        #expect(cue_table.times[10].value == 227.66)
        #expect(cue_table.times[10].asString == "03:47.66")
        #expect(cue_table.times[11].value == 246.38)
        #expect(cue_table.times[11].asString == "04:06.38")
    }
    
    @Test func testBattleOfTheASOSGeneral() throws {
        let parser = Parser(file_path: workbook3, file_name: String(workbook3.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        #expect(cue_tables.count == 8)
        for cue_table in cue_tables {
            print(cue_table.name)
        }
    }
    
    @Test func testBattleOfTheASOSBU() throws {
        let parser = Parser(file_path: workbook3, file_name: String(workbook3.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table = cue_tables[0]
        #expect(cue_table.name == "Boston University (Afrithims)")
        #expect(cue_table.times.count == 6)
        #expect(cue_table.times[0].value == 0.0)
        #expect(cue_table.times[0].asString == "00:00.00")
        #expect(cue_table.times[1].value == 27.0)
        #expect(cue_table.times[1].asString == "00:27.00")
        #expect(cue_table.times[2].value == 89.0)
        #expect(cue_table.times[2].asString == "01:29.00")
        #expect(cue_table.times[3].value == 173.0)
        #expect(cue_table.times[3].asString == "02:53.00")
        #expect(cue_table.times[4].value == 225.0)
        #expect(cue_table.times[4].asString == "03:45.00")
        #expect(cue_table.times[5].value == 230.0)
        #expect(cue_table.times[5].asString == "03:50.00")
    }
    
    @Test func testBattleOfTheASOSTufts() throws {
        let parser = Parser(file_path: workbook3, file_name: String(workbook3.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table = cue_tables[4]
        #expect(cue_table.name == "Tuft University (COCOA)")
        #expect(cue_table.times.count == 7)
        #expect(cue_table.times[0].value == 10.0)
        #expect(cue_table.times[0].asString == "00:10.00")
        #expect(cue_table.times[1].value == 30.0)
        #expect(cue_table.times[1].asString == "00:30.00")
        #expect(cue_table.times[2].value == 98.0)
        #expect(cue_table.times[2].asString == "01:38.00")
        #expect(cue_table.times[3].value == 161.0)
        #expect(cue_table.times[3].asString == "02:41.00")
        #expect(cue_table.times[4].value == 230.0)
        #expect(cue_table.times[4].asString == "03:50.00")
        #expect(cue_table.times[5].value == 366.0)
        #expect(cue_table.times[5].asString == "06:06.00")
        #expect(cue_table.times[6].value == 412.0)
        #expect(cue_table.times[6].asString == "06:52.00")
    }
    
    @Test func testCandiceCuesGeneral() throws {
        let parser = Parser(file_path: workbook4, file_name: String(workbook4.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        #expect(cue_tables.count == 3)
    }
    
    @Test func testSanskritiFashionGeneral() throws {
        let parser = Parser(file_path: workbook5, file_name: String(workbook5.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        #expect(cue_tables.count == 1)
    }
    
    @Test func testSanskritiFashion() throws {
        let parser = Parser(file_path: workbook5, file_name: String(workbook5.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        
        let cue_table = cue_tables[0]
        #expect(cue_table.name == "Blackman")
        #expect(cue_table.times.count != 19)
        #expect(cue_table.times.count == 16)
        
        #expect(cue_table.times[0].value == 0.0)
        #expect(cue_table.times[0].asString == "00:00.00")
        #expect(cue_table.times[1].value == 11.57)
        #expect(cue_table.times[1].asString == "00:11.57")
        #expect(cue_table.times[2].value == 17.0)
        #expect(cue_table.times[2].asString == "00:17.00")
        #expect(cue_table.times[3].value == 39.22)
        #expect(cue_table.times[3].asString == "00:39.22")
        #expect(cue_table.times[4].value == 57.99)
        #expect(cue_table.times[4].asString == "00:57.99")
        #expect(cue_table.times[5].value == 75.01)
        #expect(cue_table.times[5].asString == "01:15.01")
        #expect(cue_table.times[6].value == 450.0)
        #expect(cue_table.times[6].asString == "07:30.00")
        #expect(cue_table.times[7].value == 480.0)
        #expect(cue_table.times[7].asString == "08:00.00")
        #expect(cue_table.times[8].value == 490.0)
        #expect(cue_table.times[8].asString == "08:10.00")
        #expect(cue_table.times[9].value == 500.23)
        #expect(cue_table.times[9].asString == "08:20.23")
        #expect(cue_table.times[10].value == 574.22)
        #expect(cue_table.times[10].asString == "09:34.22")
        #expect(cue_table.times[11].value == 648.21)
        #expect(cue_table.times[11].asString == "10:48.21")
        #expect(cue_table.times[12].value != 751.99)
        #expect(cue_table.times[12].asString != "11:91.99")
        #expect(cue_table.times[12].value == 842.10)
        #expect(cue_table.times[12].asString == "14:02.10")
        #expect(cue_table.times[13].value != 1223.29)
        #expect(cue_table.times[13].asString != "19:83.29")
        #expect(cue_table.times[13].value == 1224.03)
        #expect(cue_table.times[13].asString == "20:24.03")
        #expect(cue_table.times[14].value == 1239.03)
        #expect(cue_table.times[14].asString == "20:39.03")
        #expect(cue_table.times[15].value != 1341.03)
        #expect(cue_table.times[15].asString != "21:81.03")
        #expect(cue_table.times[15].value == 1691.03)
        #expect(cue_table.times[15].asString == "28:11.03")
    }
    
    @Test func testTylerCuesGeneral() throws {
        let parser = Parser(file_path: workbook6, file_name: String(workbook6.split(separator: "/").last!))
        try parser.set_shared_strings()
        let cue_tables = try parser.parse_excel_file()
        #expect(cue_tables.count == 4)
    }

}
