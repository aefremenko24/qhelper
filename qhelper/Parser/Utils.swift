//
//  Utils.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/25/24.
//

import Foundation
import CoreXLSX

class Files: ObservableObject {
    @Published var files: [File] = []
    
    func add(file: File) {
        files.append(file)
    }
    
    func delete(uuid: UUID) {
        self.files = files.filter {$0.id != uuid}
    }
    
    func get_all_cue_tables() -> [CueTable] {
        var cue_tables: [CueTable] = []
        for file in files {
            cue_tables.append(contentsOf: file.cue_tables)
        }
        return cue_tables
    }
}

class File: Identifiable, ObservableObject {
    init(path: String, name: String) {
        self.path = path
        self.name = name
    }
    
    let path: String
    let name: String
    let id = UUID()
    var is_expanded: Bool = false
    var cue_tables: [CueTable] = []
}

struct CueTime: Hashable, Identifiable {
    let asString: String
    let value: Float
    let id = UUID()
}

struct CueTable: Hashable, Identifiable {
    var name: String
    var times: [CueTime]
    let id = UUID()
}

enum Errors: Error {
    case runtimeError(String)
}

let time_stamp_regex = /(([0-5]\d:){0,3})?(\d+(\.\d*)?)/

enum CueType: String {
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
}

let CUE_TIME_LABELS = ["Cue Start Time", "QLAB TIMING", "Exact Time"]
let EXAMPLE_LABELS = ["EXAMPLE FORM"]
let EMPTY_TIME_CELL_TOLERANCE: Int = 2

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
let DEFAULT_HOST = "192.168.1.152"

// The default port QLab listens for incoming OSC on.
// Should be used for all commands sent through TCP and UDP by default.
let DEFAULT_LISTENING_PORT: UInt16 = 53000

// The default port QLab sends UDP responses to.
// Should be used to receive responses to requests sent to DEFAULT_LISTENING_PORT
let DEFAULT_RESPONSE_PORT: UInt16 = 53001

// The UDP port on which QLab listens to plain text and attempts to interpret it as OSC.
// Should be used as a back-up, when the default port connection fails.
let PLAIN_TEXT_LISTENING_PORT: UInt16 = 53535

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
