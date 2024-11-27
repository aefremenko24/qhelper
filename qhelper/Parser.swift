//
//  Parser.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/25/24.
//

import Foundation
import CoreXLSX

/**
 Finds the first occurrences of one of the given labels in the given worksheet and returns their Cell objects.
 
 :param labels: Labels to look for.
 :return: Cell objects representing the first occurrences of one of the given labels.
 */
func find_first_cell_occurrences(worksheet: Worksheet, labels: [String]) -> [Cell] {
    var found_time_cells: [Cell] = []
    for label in labels {
        found_time_cells = find_cell(worksheet: worksheet, value: label)
        if found_time_cells.count > 0 {
            break
        }
    }
    return found_time_cells
}

/**
 Removes any extra characters from a cell, leaving only the time stamp if present.

 :param cell: String representing a cell to be sanitized.
 :return: Sanitized string containing only the time stamp to be used for QLab.
 */
func sanitize_cell(cell: String) -> String {
    var cell_copy = cell
    cell_copy.replace(" ", with: "")
    if (cell_copy.contains("-")) {
        cell_copy = cell_copy.components(separatedBy: "-")[0]
    }
    if (cell_copy.contains(",")) {
        cell_copy = cell_copy.components(separatedBy: ",")[0]
    }
    cell_copy = cell_copy.trimmingCharacters(in: .whitespacesAndNewlines)
    return cell_copy
}

/**
 Converts the given time string in format MM:SS.ff to seconds.

 :param time: Time string in format MM:SS.ff to be converted.
 :return: Number of seconds that the given time string represents.
 */
func convert_to_seconds(time: String) -> Float {
    var reversed_time_chunks: [String] = time.components(separatedBy: ":").reversed()
    var result: Float = 0
    for chunk_index in reversed_time_chunks.count - 1 ... 0 {
        result += Float(reversed_time_chunks[chunk_index])! * Float(exactly: pow(60, chunk_index) as NSNumber)!
    }
    return result
}

/**
 Verifies that the given cell contains a valid time stamp and returns its Float represenation in seconds if so.

 :param time: Cell with the time stamp to be converted.
 :return: Number of seconds that the given cell represents, nil if the cell is not a valid time stamp.
 */
func verify_time_cell(time_cell: Cell) -> Optional<CueTime> {
    if time_cell.value == nil {
        return nil
    }
    var string_representation: String = time_cell.value!
    let time_cell_format = Regex(time_stamp_regex)
    if let match = string_representation.firstMatch(of: time_cell_format) {
        string_representation = String(string_representation[match.range])
        return CueTime(asString: string_representation, value: convert_to_seconds(time: string_representation))
    }
    return nil
}

/**
 Finds the rows and columns of all cells with the specified value.

 :param find_cell: Excel worksheet file to search in.
 :param value: Value to search for (will be cast to string for comparison).
 :return: Cells matching the given value.
 */
func find_cell(worksheet: Worksheet, value: String) -> [Cell] {
    var coordinates: [Cell] = []
    
    for row in worksheet.data?.rows ?? [] {
        for c in row.cells {
            if c.value == value {
                coordinates.append(c)
            }
        }
    }
    return coordinates
}

/**
 Excracts all the time stamps from the given Excel worksheet.
 
 :param worksheet: Excel worksheet.
 :return: list of timestamps in number of seconds
 */
func exctact_times(worksheet: Worksheet) -> [CueTime] {
    var time_stamps: [CueTime] = []
    
    for row in worksheet.data?.rows ?? [] {
        for c in row.cells {
            let time_stamp = verify_time_cell(time_cell: c)
            if time_stamp != nil {
                time_stamps.append(time_stamp!)
            }
        }
    }
    
    return time_stamps
}

/**
 Extract all worksheets from the given Excel file.

 :param excel_file: Excel file path.
 :return: List of tuples, each containing the name of the worksheet and the worksheet itself as a Worksheet object.
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
 Parses the given Excel file and returns a list of cue tables found in the workbook.
 
 :param excel_file: Excel file path.
 :return: List of all cue tables found in the workbook.
 */
func parse_excel_file(excel_file: String) throws -> [CueTable] {
    var result: [CueTable] = []
    
    let worksheets: [(name: String, worksheet: Worksheet)] = try extract_worksheets(excel_file: excel_file)
    for worksheet in worksheets {
        var cueTable = CueTable(name: worksheet.name, times: exctact_times(worksheet: worksheet.worksheet))
        result.append(cueTable)
    }
    
    return result
}
