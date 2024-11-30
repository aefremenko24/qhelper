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
    var port: UInt16
    var host: String
    
    init(port: UInt16, host: String) {
        self.port = port
        self.host = host
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
            try self.oscClient.send(msg, to: self.host, port: self.port)
        } catch let err {
            print("error: \(err)")
        }
    }
    
    /**
     Establishes a connection to the QLab workspace.
     If the workspace has a passcode, you MUST supply it before any other commands will be accepted by the workspace.
     If the workspace does not have a passcode set, establish_connection() call is optional.

     - Parameters:
        - workspace: The name of the QLab workspace.
        - passcode_string: Optional passcode string for the workspace.
     */
    func connect_to_workspace(workspace: String, passcode_string: String = "") {
        
        let method_call = String(format: CONNECT_TO_WORKSPACE, workspace)
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
     Tells the given workspace to save itself to disk.

     - Parameters:
        - workspace: Name of the QLab workspace.
     */
    func save_to_disk(workspace: String) {
        let method_call = String(format: SAVE_TO_DISK, workspace)
        self.send_command(command: method_call)
    }
    
    /**
     Creates a cue of a given type.

     - Parameters:
        - workspace: Name of the QLab workspace.
        - cue_type: Cue type (see CueType enum in utils.py).
     */
    func create_cue(workspace: String, cue_type: CueType) {
        let method_call = String(format: CREATE_CUE, workspace)
        let args = [cue_type.rawValue]
        self.send_command(command: method_call, args: args)
    }
    
    /**
     Sets the pre-wait time for the currently selected cue.

     - Parameters:
        - time_stamp: Time stamp of the cue pre-wait time in the format MM:SS.ms
     */
    func set_cue_prewait(time_stamp: Float) {
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
        - workspace: Name of the QLab workspace.
        - group_name: Name of the cue group.
     */
    func create_group(workspace: String, group_name: String) {
        self.create_cue(workspace: workspace, cue_type: CueType.GROUP)
        self.set_cue_name(name: group_name)
    }
    
    /**
     Creates a midi cue with the given pre-wait time in the given workspace.

     - Parameters:
        - workspace: Name of the QLab workspace.
        - pre_wait: Pre-wait time for the cue in seconds.
     */
    func create_midi_cue(workspace: String, pre_wait: Float) {
        self.create_cue(workspace: workspace, cue_type: CueType.MIDI)
        self.set_cue_prewait(time_stamp: pre_wait)
    }
    
    /**
     Parses the dictionary containing QLab cue information and adds the cues to the given QLab workspace.
     For the dictionary to be parsed properly, the keys must represent group names
     and values must represent subgroups or cue pre-wait times.

     - Parameters:
        - cue_tables: List containing QLab cue information.
        - workspace: Name of the QLab workspace.
     */
    func parse_cue_dict(cue_tables: [CueTable], workspace: String) {
        for cue_table in cue_tables {
            self.create_group(workspace: workspace, group_name: cue_table.name)
            for cue in cue_table.times {
                self.create_midi_cue(workspace: workspace, pre_wait: cue.value)
            }
        }
    }

}

