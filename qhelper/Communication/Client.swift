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
    var num_cues_added: Int = 0
    var command_trace: [(String, OSCValues)]?
    
    init(keep_trace: Bool = false) {
        self.config = UserConfiguration()
        if keep_trace {
            self.command_trace = []
        }
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
        - command_buffer: Optional trace buffer to which to write the commands sent (used for testing).
     */
    func send_command(command: String, args: OSCValues = []) {
        let msg = OSCMessage(command, values: args)
        do {
            try self.oscClient.send(msg, to: self.config.host, port: UInt16(self.config.send_port)!)
            
            command_trace?.append((command, args))
        } catch let err {
            print("error: \(err)")
        }
    }
    
    /**
     Adds a cue with parameters specified as fields to QLab.
     */
    func add_cue(_ cue: Cue) {
        cue.unique_id = String(create_cue(cue_type: cue.type))
        Thread.sleep(forTimeInterval: 0.01)
        
        set_cue_number(cue_number: cue.number)
        if cue.pre_wait_time != nil {
            self.set_cue_prewait(time_stamp: cue.pre_wait_time!)
        }
        if cue.name != nil {
            self.set_cue_name(name: cue.name!)
        }
        if cue.file_path != nil {
            self.attach_file_target(file_path: cue.file_path!)
        }
        if cue.is_lx_cue {
            Thread.sleep(forTimeInterval: 0.04)
            self.make_lx_cue(cue_number: cue.number)
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
     - Returns: The index at which the cue was added. (For example, first added cue for the given call will be 0).
     */
    func create_cue(cue_type: CueType) -> Int {
        let method_call = String(format: CREATE_CUE, config.workspace)
        let args = [cue_type.rawValue]
        self.send_command(command: method_call, args: args)
        
        let cue_index = self.num_cues_added
        self.num_cues_added += 1
        
        return cue_index
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
     For the given patch value, set it as the value for the cue number parameter of the selected network cue.
     
     - Parameters:
        - patch_value: Value to be set as a cue number of the network cue.
     */
    func set_network_cue_number_patch(patch_value: String) {
        let method_call = String(format: SET_CUE_PARAMETER, CUE_NUMBER_NETWORK_KEY)
        let args = [patch_value]
        self.send_command(command: method_call, args: args)
    }
    
    /**
     For the given patch value, set it as the value for the cue number parameter of the selected MIDI cue.
     */
    func set_midi_cue_number_patch() {
        if LX_MIDI_SCRIPT != nil {
            execute_apple_script(script_path: LX_MIDI_SCRIPT!)
        }
    }
    
    /**
     Makes the selected cues in QLab LX cues by running `LX_Cue_Script.scpt`.
     */
    func make_lx_cue(cue_number: String) {
        if config.cue_type == CueType.MIDI {
            self.set_midi_cue_number_patch()
        } else if config.cue_type == CueType.NETWORK {
            self.set_network_cue_number_patch(patch_value: cue_number)
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
     Sends the commands to move all children of the given cue into the cue.
     Also moves children of all children cues into their parent cues reccursively.
     
     - Parameter cue: Parent cue to process children of.
     */
    func move_cue_children(cue: Cue) {
        if cue.children.isEmpty || cue.unique_id == nil { return }
        for (child_index, child) in cue.children.enumerated() {
            if child.unique_id == nil { continue }
            let method_call = String(format: MOVE_CUE, self.config.workspace, child.unique_id!)
            let args: Array<any OSCValue> = [child_index, cue.unique_id!]
            self.send_command(command: method_call, args: args)
            
            self.move_cue_children(cue: child)
        }
        self.send_command(command: String(format: COLLAPSE_GROUP, cue.unique_id!))
    }
    
    /**
     Sends all cues in the given cue table to QLab.
     
     - Parameter cue_table: cue table to be added.
     */
    func send_cue_table(cue_table: CueTable, startIndex: Int) -> Cue {
        var current_cue_index: Int = startIndex
        
        let group = Cue(name: cue_table.name, is_lx_cue: false, type: CueType.GROUP)
        
        let blackout_cue = Cue(number: String(current_cue_index), type: config.cue_type)
        if config.bring_out_blackout { self.add_cue(blackout_cue) }
        current_cue_index += 1
        
        self.add_cue(group)
        
        if cue_table.audio_file != nil {
            let audio_cue = Cue(is_lx_cue: false, file_path: cue_table.audio_file, type: CueType.AUDIO)
            self.add_cue(audio_cue)
            group.add_child(audio_cue)
        }
        
        if !config.bring_out_blackout {
            self.add_cue(blackout_cue)
            group.add_child(blackout_cue)
        }
        
        for pre_wait_time in cue_table.times {
            let timed_cue = Cue(pre_wait_time: pre_wait_time.value, number: String(current_cue_index), type: config.cue_type)
            self.add_cue(timed_cue)
            group.add_child(timed_cue)
            current_cue_index += 1
        }
        
        return group
    }
    
    /**
     Parses the dictionary containing QLab cue information and adds the cues to the given QLab workspace.
     For the dictionary to be parsed properly, the keys must represent group names
     and values must represent subgroups or cue pre-wait times.

     - Parameters:
        - cue_tables: List containing QLab cue information.
     - Returns: Dictionary with cue group assignments, where keys are group indeces and their values are arrays of cue indeces in that group.
     */
    func send_cue_tables(cue_tables: [CueTable]) -> [Cue] {
        // Determine increment: 100 normally, 1000 if any group needs > 100 cue numbers
        let maxCuesInGroup = cue_tables.map { $0.times.count + 1 }.max() ?? 0
        let increment = maxCuesInGroup > 100 ? 1000 : 100

        // Resolve start indices: auto-assign for tables without an explicit "Start at #"
        var nextAutoStart = increment
        var resolvedIndices: [UUID: Int] = [:]
        for cue_table in cue_tables {
            if cue_table.start_at_index.isEmpty {
                resolvedIndices[cue_table.id] = nextAutoStart
                nextAutoStart += increment
            } else {
                resolvedIndices[cue_table.id] = Int(cue_table.start_at_index)!
            }
        }

        // Sort by resolved start index
        let sorted = cue_tables.sorted { resolvedIndices[$0.id]! < resolvedIndices[$1.id]! }

        var cue_groups: [Cue] = []
        for cue_table in sorted {
            let cue_group = send_cue_table(cue_table: cue_table, startIndex: resolvedIndices[cue_table.id]!)
            cue_groups.append(cue_group)
        }

        return cue_groups
    }
}
