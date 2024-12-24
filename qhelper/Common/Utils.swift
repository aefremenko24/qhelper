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
import OSCKit

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
        DispatchQueue.main.async {
            self.files.append(file)
        }
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

let TIME_STAMP_REGEX = /(([0-5]?\d\W){1,3})(\d+(\.\d*)?)/

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
let EXAMPLE_LABELS = ["EXAMPLE FORM", "EXAMPLE", "SEE EXAMPLE BELOW"]
let EMPTY_TIME_CELL_TOLERANCE: Int = 4

// Default host used to connect to QLab workspaces
let DEFAULT_HOST = "localhost"

// The default port QLab listens for incoming OSC on.
// Should be used for all commands sent through TCP and UDP by default.
let DEFAULT_LISTENING_PORT: String = "53000"

// The default port QLab sends UDP responses to.
// Should be used to receive responses to requests sent to DEFAULT_LISTENING_PORT
let DEFAULT_RESPONSE_PORT: Int = 53001

// Default passcode to the QLab workspace
let DEFAULT_PASSCODE = ""

// Default QLab workspace name
let DEFAULT_WORKSPACE_NAME = ""

// Maximum number of seconds the client will try to execute the LX_MIDI_SCRIPT if it fails the first time.
let MAX_NUMBER_TRIES_FOR_LX_SCRIPT: Int = 2

/*
 These are QLab application methods used to communicate with workspaces.
 */

// Command to connect to the workspace.
// The format argument is the workspace ID. No OSC arguments required.
let CONNECT_TO_WORKSPACE = "/workspace/%@/connect"

// Command to disconnect from QLab. Should be used when no more commands will be sent over.
// No format or OSC arguments required.
let DISCONNECT = "/disconnect"

// Command to save the workspace to disk.
// The format argument is the workspace ID. No OSC arguments required.
let SAVE_TO_DISK = "/workspace/%@/save"

// Command to create a new cue in the given workspace.
// The format argument is the workspace ID.
// One OSC argument required — cue type, which is one of CueType enum strings.
// Optional OSC argument {cue_ID} may be supplied. This will create a new cue right after the cue with the {cue_ID}.
let CREATE_CUE = "/workspace/%@/new"

// Command to set the name of the selected cue to a given string.
// No format arguments required. One OSC argument requires — desired name of the cue as a string.
let SET_CUE_NAME = "/cue/selected/name"

// Command to set the pre-wait of the selected cue to the given number of seconds.
// No format arguments required. One OSC argument required — desired pre-wait time as a Float.
let SET_CUE_PREWAIT = "/cue/selected/preWait"

// Command to set the file target of the selected cue. Most useful for Audio and Video cues.
// No format arguments required. One OSC argument required — path to the desired file as a string.
let SET_CUE_FILE_TARGET = "/cue/selected/fileTarget"

// Command to set the cue number (ID).
// No format arguments required. One OSC argument required — desired cue number as a string.
let SET_CUE_NUMBER = "/cue/selected/number"

// Command to move the specified cue from its current position to the given new_index position within the Group,
// Cart, or List whose unique ID is new_parent_cue_id.
// The format argument is the workspace ID.
// Two OSC arguments required — new_index and new_parent_cue_id.
let MOVE_CUE = "/workspace/%@/move/%@"

// If the specified Group cue is expanded, displaying its children, collapse it.
// One format argument is the cue number or id.
let COLLAPSE_GROUP = "/cue_id/%@/collapse"

// Command to set the cue parameter specified as a string key to a given value.
// The format argument is the key of the parameter to be set.
// One OSC argument required - value of the key to be set.
let SET_CUE_PARAMETER = "/cue/selected/parameterValue/%@"

// Key used to specify the cue number for the network cue.
let CUE_NUMBER_NETWORK_KEY = "cueNumber"

// Key used to specify the cue number for the MIDI cue.
let CUE_NUMBER_MIDI_KEY = "MSC Q number"

let LX_MIDI_SCRIPT: URL? = Bundle.main.url(forResource: "LX_Cue_Script", withExtension: "scpt")

/*
 These are common QLab responses sent over UDP.
 */

// The supplied passcode matches a passcode entry in the workspace and connection was successful.
let CONNECTED_SUCCESS = "ok"

// The passcode does not match any passcode entries in the workspace.
let CONNECTED_BADPASS = "badpass"

// The specified workspace does not exist or is not open.
let CONNECTED_ERROR = "error"

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
 Decodes JSON data into a QLab reponse struct.
 
 - Parameters:
    - data: Bytes to be decoded.
 - Returns: The QLabResponse obkect decoded from the data.
 */
func decode_qlab_response(data: Data?) -> QLabResponse? {
    if data == nil { return nil }
    do {
        let as_string = String(data: data!, encoding: .utf8)!
        let startIndex = as_string.firstIndex(of: "{")!
        let endIndex = as_string.lastIndex(of: "}")!
        var newStr = String(as_string[startIndex...endIndex])
        let decoded = try JSONDecoder().decode(QLabResponse.self, from: Data(newStr.utf8))
        return decoded
    } catch {
        print(error)
        return nil
    }
}

/**
 Executes an Apple String written in a file.
 
 - Parameter script_path: Apple Script file path URL.
 */
func execute_apple_script(script_path: URL) {
    var num_tries_left: Int = MAX_NUMBER_TRIES_FOR_LX_SCRIPT
    
    var error: NSDictionary? = nil
    let script_executer = NSAppleScript(contentsOf: script_path, error: &error)
    
    while num_tries_left > 0 {
        script_executer?.executeAndReturnError(&error)
        if error == nil { break }
        num_tries_left -= 1
    }
}

/**
 Executes an Apple String from the given string.
 
 - Parameter script: Apple Script as a string.
 */
func execute_apple_script(script: String) {
    var error: NSDictionary? = nil
    let script_executer = NSAppleScript(source: script)
    script_executer?.executeAndReturnError(&error)
}

func is_new_cue_response(response: Data) -> Bool {
    let str = String(data: response, encoding: .utf8)
    if str == nil { return false }
    return str!.contains("/new")
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
    if dialog.runModal() == .OK {
        return dialog.url!.path
    } else {
        return ""
    }
}

/**
 Executes a simple Apple Script to request user permission to Apple System Events if not already granted.
 */
func request_apple_events_permission() {
    execute_apple_script(script: "osascript -e 'tell application \"System Events\" to keystroke \"a\"'")
}
