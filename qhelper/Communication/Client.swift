//
//  Client.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/25/24.
//

import Foundation
import OSCKit

/**
 UDP client responsible for senting OSC messages to QLab workspaces.
 */
class Client {
    let oscClient: OSCClient = OSCClient()
    var config: UserConfiguration
    var lx_script: URL? = Bundle.main.url(forResource: "LX_Cue_Script", withExtension: "scpt")
    
    init() {
        self.config = UserConfiguration()
    }
    
    /**
     Updates the user configuration saved in this Client object to the one provided.
     */
    func update_configuration(config: UserConfiguration) {
        self.config = config
    }

    /**
     Sends the given command to QLab for a maximum number of tries of MAX_NUM_TRIES.
     
     - Parameters:
        - command: Command to send.
        - args: Command arguments.
     */
    func send_command(command: String, args: OSCValues = []) {
        let msg = OSCMessage(command, values: args)
        do {
            try self.oscClient.send(msg, to: self.config.host, port: UInt16(self.config.send_port)!)
        } catch let err {
            print("error: \(err)")
        }
    }
    
    /**
     Establishes a connection to the QLab workspace.
     If the workspace has a passcode, you MUST supply it before any other commands will be accepted by the workspace.
     If the workspace does not have a passcode set, establish_connection() call is optional.

     - Parameters:
        - passcode_string: Optional passcode string for the workspace.
     */
    func connect_to_workspace(passcode_string: String = "") {
        let method_call = String(format: CONNECT_TO_WORKSPACE, config.workspace)
        let args = [passcode_string]
        self.send_command(command: method_call, args: args)
    }
    
    /**
     Disconnect from QLab.
     Should be invoked when no more messages will be sent to QLab.
     */
    func disconnect_from_workspace() {
        let method_call = DISCONNECT
        self.send_command(command: method_call)
    }

    /**
     Tells this workspace to save itself to disk.
     */
    func save_to_disk() {
        let method_call = String(format: SAVE_TO_DISK, config.workspace)
        self.send_command(command: method_call)
    }
    
    /**
     Creates a cue of a given type.

     - Parameters:
        - cue_type: Cue type (see CueType enum in Utils.swift).
     */
    func create_cue(cue_type: CueType) {
        let method_call = String(format: CREATE_CUE, config.workspace)
        let args = [cue_type.rawValue]
        self.send_command(command: method_call, args: args)
    }
    
    /**
     Sets the pre-wait time for the currently selected cue.

     - Parameters:
        - time_stamp: Time stamp of the cue pre-wait time in the format MM:SS.ms
     */
    func set_cue_prewait(time_stamp: Float) {
        let time_stamp = time_stamp == 0 ? 0.02 : time_stamp
        let method_call = SET_CUE_PREWAIT
        let args = [time_stamp]
        self.send_command(command: method_call, args: args)
    }

    /**
     Sets the name for the currently selected cue.
     
     - Parameters:
        - name: Name of the cue as a string.
     */
    func set_cue_name(name: String) {
        let method_call = SET_CUE_NAME
        let args = [name]
        self.send_command(command: method_call, args: args)
    }
    
    /**
     Creates a cue group in the given workspace.

     - Parameters:
        - group_name: Name of the cue group.
     */
    func create_group(group_name: String) {
        self.create_cue(cue_type: CueType.GROUP)
        self.set_cue_name(name: group_name)
    }
    
    /**
     Creates a midi cue with the given pre-wait time in the given workspace.

     - Parameters:
        - pre_wait: Pre-wait time for the cue in seconds.
     */
    func create_timed_cue(pre_wait: Float) {
        self.create_cue(cue_type: config.cue_type)
        self.set_cue_prewait(time_stamp: pre_wait)
    }
    
    /**
     Makes the selected cues in QLab LX cues by running `LX_Cue_Script.scpt`.
     */
    func make_lx_cue() {
        if lx_script != nil && config.cue_type == CueType.MIDI {
            execute_apple_script(script_path: lx_script!)
        }
    }
    
    /**
     Attaches an file at a specified path to the currently selected cue.
     
     - Parameters:
        - file_path: File path and name in any of the following three forms:
            - Full paths, e.g. /Volumes/MyDisk/path/to/some/file.wav
            - Paths beginning with a tilde, e.g. ~/path/to some/file.mov
            - Relative paths, e.g. this/is/a/relative/path.mid
    
     Paths beginning with a tilde (~) will be expanded; the tilde signifies “relative to the user’s home directory”.
     Relative paths will be interpreted according to the current working directory. Use the /workingDirectory application message to set or get the current working directory.
     */
    func attach_file_target(file_path: String) {
        let method_call = SET_CUE_FILE_TARGET
        let args = [file_path]
        self.send_command(command: method_call, args: args)
    }
    
    /**
     Creates an audio cue with the specified audio file attached to it.
     
     - Parameters:
        - file_path: File path and name (see attach_file_target for notes on supported inputs.)
     */
    func create_audio_cue(file_path: String) {
        self.create_cue(cue_type: CueType.AUDIO)
        self.attach_file_target(file_path: file_path)
        self.set_cue_number(cue_number: "")
    }
    
    /**
     Sets the number of the selected cue to the given number.
     
     - Parameters:
        - cue_number: Desired number of the cue as a string.
     */
    func set_cue_number(cue_number: String) {
        let method_call = SET_CUE_NUMBER
        let args = [cue_number]
        self.send_command(command: method_call, args: args)
    }
    
    /**
     Creates a cue of a given type with a given number (meant to be used as a blackout, non-timed cue.
     
     - Parameters:
        - cue_type: Cue type (see CueType enum in Utils.swift).
        - cue_number: Optional, desired number of the cue as a string.
     */
    func create_blackout_cue(cue_type: CueType, cue_number: String? = nil) {
        self.create_cue(cue_type: cue_type)
        if cue_number != nil {
            self.set_cue_number(cue_number: cue_number!)
        }
    }
    
    /**
     Moves the selected cue to the given group.
     
     - Parameters:
        - group_id: ID of the group to move the selected cue to.
     */
    func move_cue_to_group(group_id: String) {
        let method_call = String(format: MOVE_CUE, group_id)
        self.send_command(command: method_call)
    }
    
    /**
     Parses the dictionary containing QLab cue information and adds the cues to the given QLab workspace.
     For the dictionary to be parsed properly, the keys must represent group names
     and values must represent subgroups or cue pre-wait times.

     - Parameters:
        - cue_tables: List containing QLab cue information.
     */
    func parse_cue_dict(cue_tables: [CueTable]) {
        let cue_tables = cue_tables.sorted(by: { $0 < $1})
        for (cue_table_index, cue_table) in cue_tables.enumerated() {
            var current_cue_index: Int? = nil
            if !cue_table.start_at_index.isEmpty {
                current_cue_index = Int(cue_table.start_at_index)
            }
            
            if config.include_blackout_cue {
                self.create_blackout_cue(cue_type: config.cue_type, cue_number: current_cue_index == nil ? nil : String(current_cue_index!))
                self.make_lx_cue()
                if current_cue_index != nil {
                    current_cue_index! += 1
                }
            }
            
            self.create_group(group_name: cue_table.name)
            let group_id = current_cue_index == nil ? "G\(cue_table_index)" : "G\(current_cue_index!)"
            self.set_cue_number(cue_number: group_id)
            
            if cue_table.audio_file != nil {
                let file_path = cue_table.audio_file!
                self.create_audio_cue(file_path: file_path)
            }
            
            if !config.include_blackout_cue {
                self.create_timed_cue(pre_wait: 0.01)
                if current_cue_index != nil {
                    self.set_cue_number(cue_number: String(current_cue_index!))
                    current_cue_index! += 1
                }
                self.make_lx_cue()
            }
            
            for cue in cue_table.times {
                self.create_timed_cue(pre_wait: cue.value)
                
                if current_cue_index != nil {
                    self.set_cue_number(cue_number: String(current_cue_index!))
                    current_cue_index! += 1
                }
                
                self.make_lx_cue()
                
                self.move_cue_to_group(group_id: group_id)
            }
            self.save_to_disk()
        }
    }
}

