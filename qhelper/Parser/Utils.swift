//
//  Utils.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/25/24.
//

import Foundation
import CoreXLSX
import AppKit
import UniformTypeIdentifiers

enum ViewSelection: String, CaseIterable, Hashable, Codable, Identifiable {
    case DropView = "Add Files"
    case FilesView = "Preview Cue Tables"
    case SettingsView = "Settings"
    
    var id: Self { self }
}

class Files: ObservableObject {
    @Published var files: [File] = []
    
    /**
     Adds a file to the list of files.
     
     - Parameter file: File object to be added.
     */
    func add(file: File) {
        files.append(file)
    }
    
    /**
     Deletes a file from the list of files given its UUID.
     
     - Parameter uuid: Unique UUID of the file to be deleted.
     */
    func delete(uuid: UUID) {
        self.files = files.filter {$0.id != uuid}
    }
    
    /**
     Returns all CueTable objects stored by all the files in this Files object.
     
     - Returns: List of all cue tables in this object.
     */
    func get_all_cue_tables() -> [CueTable] {
        var cue_tables: [CueTable] = []
        for file in files {
            cue_tables.append(contentsOf: file.cue_tables)
        }
        return cue_tables
    }
}

class File: Hashable, Identifiable, ObservableObject {
    init(path: String, name: String) {
        self.path = path
        self.name = name
    }
    
    let path: String
    let name: String
    let id = UUID()
    var is_expanded: Bool = false
    @Published var cue_tables: [CueTable] = []
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: File, rhs: File) -> Bool {
        lhs.path == rhs.path
    }
    
    /**
     Deletes a cue group from the list of cue groups given its UUID.
     
     - Parameter uuid: Unique UUID of the group to be deleted.
     */
    func delete(uuid: UUID) {
        self.cue_tables = self.cue_tables.filter {$0.id != uuid}
    }
    
    /**
     Moves a cue group from the given index to the destination index.
     
     - Parameters:
        - source: Index where the cue group is located.
        - destination: Index where the cue group should be placed.
     */
    func move(from source: IndexSet, to destination: Int) {
        self.cue_tables.move(fromOffsets: source, toOffset: destination)
    }
}

struct CueTime: Hashable, Identifiable {
    let asString: String
    let value: Float
    let id = UUID()
}

class CueTable: Hashable, Identifiable, ObservableObject {
    var name: String
    var header_cell: CellReference
    var times: [CueTime]
    @Published var start_at_index: String = ""
    @Published var audio_file: String? = nil
    let id = UUID()
    
    init(name: String, header_cell: CellReference, times: [CueTime]) {
        self.name = name
        self.header_cell = header_cell
        self.times = times
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(header_cell.row.hashValue)
        hasher.combine(header_cell.column.value)
    }

    static func == (lhs: CueTable, rhs: CueTable) -> Bool {
        return lhs.header_cell.row == rhs.header_cell.row
        && lhs.name == rhs.name
    }
    
    static func < (lhs: CueTable, rhs: CueTable) -> Bool {
        if lhs.start_at_index.isEmpty {
            return false
        }
        if let lhs_as_int = Int(lhs.start_at_index), let rhs_as_int = Int(rhs.start_at_index) {
            return lhs_as_int < rhs_as_int
        } else {
            return lhs.start_at_index < rhs.start_at_index
        }
    }
}

enum Errors: Error {
    case runtimeError(String)
}

let time_stamp_regex = /(([0-5]?\d\W){1,3})(\d+(\.\d*)?)/

enum CueType: String, CaseIterable, Hashable, Codable, Identifiable {
    case AUDIO = "audio"
    case MIC = "mic"
    case VIDEO = "video"
    case CAMERA = "camera"
    case TEXT = "text"
    case LIGHT = "light"
    case FADE = "fade"
    case NETWORK = "network"
    case MIDI = "midi"
    case MIDI_FILE = "midi file"
    case TIMECODE = "timecode"
    case GROUP = "group"
    case START = "start"
    case STOP = "stop"
    case PAUSE = "pause"
    case LOAD = "load"
    case RESET = "reset"
    case DEVAMP = "devamp"
    case GOTO = "goto"
    case TARGET = "target"
    case ARM = "arm"
    case DISARM = "disarm"
    case WAIT = "wait"
    case MEMO = "memo"
    case SCRIPT = "script"
    case LIST = "list"
    case CUELIST = "cuelist"
    case CUE_LIST = "cue list"
    case CART = "cart"
    case CUECART = "cuecart"
    case CUE_CART = "cue cart"
    
    var id: Self { self }
}

let WINDOW_WIDTH: CGFloat = 700
let WINDOW_HEIGHT: CGFloat = 500
let PADDING: CGFloat = 30

let CUE_TIME_LABELS = ["Cue Start Time", "QLAB TIMING", "Exact Time", "Time Stamp", "Time *Example MM:SS:MS*"]
let EXAMPLE_LABELS = ["EXAMPLE FORM"]
let EMPTY_TIME_CELL_TOLERANCE: Int = 2
let TYPICAL_CUE_TABLE_LENGTH: Int = 10

let CONNECTION_SUCCESS_MESSAGE = "You are connected to QLab. Host: {host}, Port: {port}"
let CONNECTION_FAILURE_MESSAGE = "Failed to connect to the server using port {port}."
let WRITE_ERROR_MESSAGE = "Failed to communicate with QLab. The command {command} with arguments {args} WAS NOT sent."
let READ_ERROR_MESSAGE = "Failed to receive the response from QLab. The previous command might not have been recorded."
let CONNECTION_NOT_ESTABLISHED_WARNING = "This method should not be called before the connection to QLab is established."

let EXIT_SUCCESS_MESSAGE = "Program run finished successfully. Your cues were written to your QLab workspace."
let EXIT_FAILURE_MESSAGE = ("Something went wrong during the execution of the program. " +
                        "Your cues might have been written to the QLab workspace partially.")

let WORKSPACE_NAME_PROMPT = "Please enter the name of the QLab workspace you would like to write cues to: "
let INVALID_WORKSPACE_NAME_PROMPT = "The workspace name must not be empty. Try again: "
let WORKSPACE_PASSCODE_PROMPT = "Please enter the passcode to your workspace. Press ENTER if no passcode is set: "

// Default host used to connect to QLab workspaces
let DEFAULT_HOST = "localhost"

// The default port QLab listens for incoming OSC on.
// Should be used for all commands sent through TCP and UDP by default.
let DEFAULT_LISTENING_PORT: String = "53000"

// The default port QLab sends UDP responses to.
// Should be used to receive responses to requests sent to DEFAULT_LISTENING_PORT
let DEFAULT_RESPONSE_PORT: String = "53001"

// The UDP port on which QLab listens to plain text and attempts to interpret it as OSC.
// Should be used as a back-up, when the default port connection fails.
let PLAIN_TEXT_LISTENING_PORT: String = "53535"

// Default passcode to the QLab workspace
let DEFAULT_PASSCODE = ""

// Default QLab workspace name
let DEFAULT_WORKSPACE_NAME = ""

// Maximum number of seconds the client will wait for a response from QLab.
let MAX_RESPONSE_TIME = 2.0

// Maximum number of tries to send/receive a request/response
let MAX_NUM_TRIES = 3

// These are QLab application methods used to communicate with workspaces.
let CONNECT_TO_WORKSPACE = "/workspace/%@/connect"
let DISCONNECT = "/disconnect"
let SAVE_TO_DISK = "/workspace/%@/save"
let CREATE_CUE = "/workspace/%@/new"
let SET_CUE_NAME = "/cue/selected/name"
let SET_CUE_PREWAIT = "/cue/selected/preWait"
let SET_CUE_FILE_TARGET = "/cue/selected/fileTarget"
let SET_CUE_NUMBER = "/cue/selected/number"

extension String {
    /**
     Converts this String in a format HH:MM:SS.ff to a number of seconds as a Float that this String represents.
     */
    func convertToTimeInterval() -> Float {
        guard self != "" else {
            return 0
        }

        var interval: Float = 0

        var parts = self.components(separatedBy: ":")
        let smallest_divison: Float = Float(parts.last!) ?? 0
        if parts.count > 2 && smallest_divison == floor(smallest_divison) {
            parts.removeLast()
            parts[parts.count - 1] = String(Float(parts[parts.count - 1])! + smallest_divison / 100)
        }
        for (index, part) in parts.reversed().enumerated() {
            interval += (Float(part) ?? 0) * pow(Float(60), Float(index))
        }
        
        return Float(round(100 * interval) / 100)
    }
}

extension Float {
    /**
     Converts the Float representing the time in seconds to its string representation in the format MM:SS.ff.
     */
    func toTimeElapsed() -> String {
        let decimal: Float = self - floor(self)
        let copy = Int(floor(self))
        let minutes = (copy % 3600) / 60
        let seconds = Float((copy % 3600) % 60) + decimal
        return String(format: "%02d:%05.2f", minutes, seconds)
    }
}

extension Date {
    /**
     Converts a CSV-standard DateTime object into a proper string representation. Here, 1899-12-30 00:00:00 is taken as a reference time.
     
     - Returns: Standard QLab String representation in format 00:00.00
     */
    func toTimeElapsed() -> String {
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current
        dateFormatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        let reference = dateFormatter.date(from: "1899-12-30 00:00:00")!
        let referenceComponents = calendar.dateComponents([.hour, .minute, .second], from: reference)
        let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: self)

        let difference = calendar.dateComponents([.hour, .minute, .second], from: referenceComponents, to: timeComponents)
        
        return "\(difference.hour!):\(difference.minute!):\(difference.second!)"
    }
}

/**
 Gets the file name from the file path.
 
 - Parameters:
    - file_path: Path to the file.
 */
func get_file_name(file_path: String) -> String {
    let file_name = file_path.contains("/") ? String(file_path.split(separator: "/").last!) : file_path
    return file_name
}

/**
 Opens the file dialog window and lets the user select a file or a directory.
 
 - Parameters:
    - allow_multiple_selection: True if the user is allowed to select multiple files, False otherwise.
    - can_choose_directories: True if the user is allowed to choose directories, False otherwise.
    - allowed_file_types: List of allowed file types. If left empty, any file type is allowed.
 - Returns: String containing the path of the file selected. If no file is selected, empty string is returned.
 */
func open_file_dialog(allow_multiple_selection: Bool = false,
                      can_choose_directories: Bool = false,
                      allowed_file_types: [UTType] = []) -> String {
    let dialog = NSOpenPanel()
    dialog.allowsMultipleSelection = allow_multiple_selection
    dialog.canChooseDirectories = can_choose_directories
    if !allowed_file_types.isEmpty {
        dialog.allowedContentTypes = allowed_file_types
    }
    if dialog.runModal() == .continue {
        return dialog.url!.path
    } else {
        return ""
    }
}
