//
//  ClientTests.swift
//  qhelperTests
//
//  Created by Arthur Efremenko on 12/30/24.
//

import Testing
@testable import qhelper

struct ClientTests {
    
    @Test func testUpdateConfiguration() throws {
        let client = Client(keep_trace: true)
        let config = UserConfiguration()
        client.update_configuration(config: config)
        #expect(client.config == config)
    }
    
    @Test func testSendCommand() throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        client.send_command(command: "/connect/to/workspace", args: ["ID", "NAME"])
        #expect(client.command_trace!.count == 1)
        #expect(client.command_trace!.last!.0 == "/connect/to/workspace")
        #expect(client.command_trace!.last!.1.count == 2)
        
        client.send_command(command: "/disconnect/from/workspace")
        #expect(client.command_trace!.count == 2)
        #expect(client.command_trace!.last!.0 == "/disconnect/from/workspace")
        #expect(client.command_trace!.last!.1.isEmpty)
    }
    
    @Test func testConnectToWorkspace() throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        client.connect_to_workspace()
        #expect(client.command_trace!.count == 1)
        #expect(client.command_trace!.last!.0 == String(format: CONNECT_TO_WORKSPACE, ""))
        #expect(client.command_trace!.last!.1.count == 1)
        
        client.connect_to_workspace(passcode_string: "1234")
        #expect(client.command_trace!.count == 2)
        #expect(client.command_trace!.last!.0 == String(format: CONNECT_TO_WORKSPACE, ""))
        #expect(client.command_trace!.last!.1.count == 1)
        
        client.config.workspace = "qhelper_test"
        client.connect_to_workspace(passcode_string: "1234")
        #expect(client.command_trace!.count == 3)
        #expect(client.command_trace!.last!.0 == String(format: CONNECT_TO_WORKSPACE, "qhelper_test"))
        #expect(client.command_trace!.last!.1.count == 1)
    }
    
    @Test func testDisconnectFromWorkspace() throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        client.disconnect_from_workspace()
        #expect(client.command_trace!.count == 1)
        #expect(client.command_trace!.last!.0 == DISCONNECT)
    }
    
    @Test func testSaveToDisk() throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        client.save_to_disk()
        #expect(client.command_trace!.count == 1)
        #expect(client.command_trace!.last!.0 == String(format: SAVE_TO_DISK, client.config.workspace))
    }
        
    @Test func testCreateCue() throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        #expect(client.num_cues_added == 0)
        #expect(client.create_cue(cue_type: CueType.MIDI) == 0)
        #expect(client.num_cues_added == 1)
        #expect(client.command_trace!.count == 1)
        #expect(client.command_trace!.last!.0 == String(format: CREATE_CUE, client.config.workspace))
        #expect(client.command_trace!.last!.1.count == 1)
    }
    
    @Test func testSetCuePreWait() throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        #expect(client.num_cues_added == 0)
        client.set_cue_prewait(time_stamp: 100)
        #expect(client.command_trace!.count == 1)
        #expect(client.command_trace!.last!.0 == SET_CUE_PREWAIT)
        #expect(client.command_trace!.last!.1.count == 1)
    }
    
    @Test func testSetCueName() throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        #expect(client.num_cues_added == 0)
        client.set_cue_name(name: "test")
        #expect(client.command_trace!.count == 1)
        #expect(client.command_trace!.last!.0 == SET_CUE_NAME)
        #expect(client.command_trace!.last!.1.count == 1)
    }
    
    
}
