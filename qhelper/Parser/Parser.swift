//
//  Parser.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/25/24.
//

import Foundation
import CoreXLSX

/**
 An object that should be initialized for every XLSX file being parsed. contains the absolute path to the file and its shared strings.
 */
class Parser {
    let file_path: String
    let file_name: String
    var shared_strings: SharedStrings? = nil
    var current_cue_times_label: String? = nil
    var current_table_name_label: String? = nil
    
    init(file_path: String, file_name: String) {
        self.file_path = file_path
        self.file_name = file_name
    }
    
    /**
     Computes the shared strings in this XLSX file and sets them in the self.shared_strings field.
     
     - Mutates: self.shared_strings.
     */
    func set_shared_strings() throws {
        self.shared_strings = try self.get_shared_strings(excel_file: self.file_path)
    }
    
    /**
     Finds the rows and columns of all cells with the value equal to the specified value.
     `self.set_shared_strings` should be called before this function.

     - Parameters:
        - find_cell: Excel worksheet file to search in.
        - value: Value to search for.
     - Returns: Cells with the value equal to the given value.
     */
    func find_cell(worksheet: Worksheet, value: String) -> [Cell] {
        var found: [Cell] = []
        
        if self.shared_strings == nil {
            do {
                try self.set_shared_strings()
            } catch {
                print(error)
            }
        }
        
        for row in worksheet.data?.rows ?? [] {
            for c in row.cells {
                let string_value: String? = c.stringValue(shared_strings!)
                if string_value == nil { continue }
                if c.stringValue(shared_strings!)!.compare(value, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame {
                    found.append(c)
                }
            }
        }
        return found
    }
    
    /**
     Finds the first occurrences of one of the given labels in the given worksheet and returns their Cell objects.
     
     - Parameters:
         - worksheet: Worksheet to use for searching.
         - labels: Labels to look for.
     - Returns:
        - The label first found in the sheet and Cell objects representing the first occurrences of that label; nil and empty list if none were found.
     */
    func find_first_cell_occurrences(worksheet: Worksheet, labels: [String]) -> (label: String?, cells: [Cell]) {
        var found_label: String? = nil
        var found_time_cells: [Cell] = []
        for label in labels {
            found_time_cells = find_cell(worksheet: worksheet, value: label)
            if found_time_cells.count > 0 {
                found_label = label
                break
            }
        }
        return (found_label, found_time_cells)
    }
    
    /**
     Removes any extra characters from a cell, leaving only the time stamp if present.
     
     - Parameters:
        - cell: String representing a cell to be sanitized.
     - Returns: Pre-sanitized string containing only the time stamp to be used for QLab.
     */
    func pre_sanitize_cell(cell: String) -> String {
        var cell_copy = cell
        
        cell_copy = cell_copy.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)
        
        if (cell_copy.contains(" ")) {
            cell_copy = cell_copy.components(separatedBy: " ")[0]
        }
        if (cell_copy.contains(",")) {
            cell_copy = cell_copy.components(separatedBy: ",")[0]
        }
        
        cell_copy = cell_copy.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cell_copy
    }
    
    /**
     Replaces characters between digits, like -, with : to match the QLab display format.
     
     - Parameters:
        - cell: String representing a cell to be sanitized.
     - Returns: Post-sanitized string containing only the time stamp to be used for QLab.
     */
    func post_sanitize_cell(cell: String) -> String {
        var cell_copy = cell
        cell_copy = cell_copy.replacingOccurrences(of: "[^0123456789.:]", with: ":", options: .regularExpression)
        return cell_copy
    }
    
    /**
     Verifies that the given string is a float number in a format 123.345.
        
     - Parameters:
        - time_cell: Cell string containing a float in a format 123.345
     - Returns:CueTime object containing information about the number of seconds that the given cell represents, nil if the cell is not a valid time stamp. If the time stamp is negative, it will be counted as 0.
     */
    func verify_float_string(time_cell: String) -> Optional<CueTime> {
        if var mFloat = Float(time_cell) {
            mFloat = mFloat <= 0 ? 0 : mFloat
            return CueTime(asString: mFloat.toTimeElapsed(), value: mFloat)
        } else {
            return nil
        }
    }
    
    /**
     Converts the DateTime formatted cell to a proper CueTime representation.
     
     - Parameters:
        - date_cell: Cell containing a dateValue.
     - Returns:CueTime object containing information about the number of seconds that the given cell represents, nil if the cell is not a valid time stamp.
     */
    func verify_date_cell(date_cell: Cell) -> Optional<CueTime> {
        if date_cell.value == nil {
            return nil
        }
        let string_representation = date_cell.dateValue?.toTimeElapsed()
        if string_representation == nil {
            return nil
        }
        
        return verify_time_string(time_string: string_representation!)
    }
    
    /**
     Verifies that the given string contains a valid time stamp and returns its Float represenation in seconds if so.
     
     - Parameters:
     - time: String with the time stamp to be converted.
     - Returns: Number of seconds that the given cell represents, nil if the cell is not a valid time stamp.
     */
    func verify_time_string(time_string: String) -> Optional<CueTime> {
        let string_representation: String = self.pre_sanitize_cell(cell: time_string)
        let time_cell_format = Regex(TIME_STAMP_REGEX)
        if let match = string_representation.firstMatch(of: time_cell_format) {
            var matched_string_representation = String(string_representation[match.range])
            if string_representation != matched_string_representation {
                return verify_float_string(time_cell: string_representation)
            } else {
                matched_string_representation = self.post_sanitize_cell(cell: matched_string_representation)
            }
            let time_interval = matched_string_representation.convertToTimeInterval()
            return CueTime(asString: time_interval.toTimeElapsed(), value: time_interval)
        }
        return verify_float_string(time_cell: string_representation)
    }
    
    /**
     Verifies that the given cell contains a valid time stamp and returns its Float represenation in seconds if so.
     
     - Parameters:
        - time: Cell with the time stamp to be converted.
     - Returns:CueTime object containing information about the number of seconds that the given cell represents, nil if the cell is not a valid time stamp.
     */
    func verify_time_cell(time_cell: Cell) -> Optional<CueTime> {
        if time_cell.value == nil {
            return nil
        }
        // Only use the date path for values < 1.0 (fractions of a day).
        // CoreXLSX returns a non-nil dateValue for ALL numeric cells regardless of format,
        // so raw second values like 5.085 would be misinterpreted as Excel serial dates.
        // Since 1.0 = 24 hours, no song timestamp stored as a date can have a value >= 1.0.
        if time_cell.dateValue != nil,
           let rawValue = time_cell.value.flatMap(Double.init),
           rawValue < 1.0 {
            return self.verify_date_cell(date_cell: time_cell)
        }
        if let string_value = time_cell.stringValue(shared_strings!) {
            return self.verify_time_string(time_string: string_value)
        }
        return self.verify_float_string(time_cell: time_cell.value!)
    }

    /**
     Excracts the time stamps corresponding to the given reference "Cue Start Time" cell.
     
     - Parameters:
        - worksheet: Excel worksheet.
     - Returns: list of timestamps in number of seconds
     */
    func exctact_times(worksheet: Worksheet, reference: CellReference) -> [CueTime] {
        var time_stamps: [CueTime] = []
        var last_found_row: UInt = reference.row
        var remaining_tolerance = EMPTY_TIME_CELL_TOLERANCE
        
        for row in worksheet.data?.rows ?? [] {
            for c in row.cells {
                if c.reference.column.value == reference.column.value
                    && c.reference.row > reference.row {
                    let time_stamp = verify_time_cell(time_cell: c)
                    if time_stamp != nil {
                        time_stamps.append(time_stamp!)
                        remaining_tolerance = EMPTY_TIME_CELL_TOLERANCE
                        last_found_row = c.reference.row
                    } else if remaining_tolerance > 0 {
                        remaining_tolerance -= Int(c.reference.row - last_found_row)
                    }
                    if remaining_tolerance <= 0 {
                        return time_stamps
                    }
                }
            }
        }
        
        return time_stamps
    }

    /**
     Extract all worksheets from the given Excel file.

     - Parameters:
        - excel_file: Excel file path.
     - Returns: List of tuples, each containing the name of the worksheet and the worksheet itself as a Worksheet object.
     */
    func extract_worksheets(excel_file: String) throws -> [(name: String, worksheet: Worksheet)] {
        
        guard let file = XLSXFile(filepath: excel_file) else {
            throw Errors.runtimeError("XLSX file at \(excel_file) is corrupted or does not exist")
        }
        
        var worksheets: [(String, Worksheet)] = []
        
        do {
            for wbk in try file.parseWorkbooks() {
                for (name, path) in try file.parseWorksheetPathsAndNames(workbook: wbk) {
                    let worksheetName = name
                    let worksheet = try file.parseWorksheet(at: path)
                    worksheets.append((worksheetName!, worksheet))
                }
            }
        } catch {
            fatalError("Error parsing Excel file: \(error)")
        }
        
        return worksheets
    }


    /**
     Returns the shared strings for the given Excel file.
     
     - Parameters:
        - excel_file: Absolute path to the Excel file.
     - Returns: SharedStrings object containing the shared strings in the file.
     */
    func get_shared_strings(excel_file: String) throws -> SharedStrings {
        guard let file = XLSXFile(filepath: excel_file) else {
            throw Errors.runtimeError("XLSX file at \(excel_file) is corrupted or does not exist")
        }
        
        guard let shared_strings = try file.parseSharedStrings() else {
            throw Errors.runtimeError("XLSX file at \(excel_file) is corrupted or does not exist")
        }
        
        return shared_strings
    }
    
    /**
     Removes the example cue tables by cross-checking the rows and columns for the example label position and cue times position.

     - Parameters:
        - header_cells: All "Cue Start Time" cells.
        - example_headers: All "EXAMPLE FORM" cells.
     - Returns: Filtered header cells.
     */
    func remove_example_headers(header_cells: [Cell], example_headers: [Cell]) -> [Cell] {
        var final_cue_headers: [Cell] = header_cells
        
        for example_cell in example_headers {
            for (cue_time_cell_index, cue_time_cell) in final_cue_headers.enumerated() {
                if cue_time_cell.reference.row > example_cell.reference.row {
                    final_cue_headers.remove(at: cue_time_cell_index)
                    break
                }
            }
        }
        
        return final_cue_headers
    }
    
    /**
     Parses the given Excel file and returns a list of cue tables found in the workbook.
     
     - Parameters:
        - excel_file: Excel file path.
     - Returns: List of all cue tables found in the workbook.
     */
    func parse_excel_file() throws -> [CueTable] {
        var result: [CueTable] = []
        
        let worksheets: [(name: String, worksheet: Worksheet)] = try extract_worksheets(excel_file: self.file_path)
        for worksheet in worksheets {
            let initial_header_cells = find_first_cell_occurrences(worksheet: worksheet.worksheet, labels: CUE_TIME_LABELS)
            let example_headers = find_first_cell_occurrences(worksheet: worksheet.worksheet, labels: EXAMPLE_LABELS)
            
            self.current_cue_times_label = initial_header_cells.label
            
            let header_cells = remove_example_headers(header_cells: initial_header_cells.cells, example_headers: example_headers.cells)
            for header_cell in header_cells {
                let extracted_times = exctact_times(worksheet: worksheet.worksheet, reference: header_cell.reference)
                if extracted_times.isEmpty { continue }
                let cue_table_name = self.file_name.replacingOccurrences(of: ".xlsx", with: "")
                let cueTable = CueTable(name: cue_table_name, header_cell: header_cell.reference, times: extracted_times)
                result.append(cueTable)
            }
        }
        
        return result
    }
}
