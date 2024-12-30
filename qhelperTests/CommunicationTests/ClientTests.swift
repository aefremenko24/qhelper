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
        
        let client_silent = Client(keep_trace: false)
        #expect(client_silent.command_trace == nil)
        client_silent.send_command(command: "/connect/to/workspace", args: ["ID", "NAME"])
        #expect(client_silent.command_trace == nil)
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
    
    @Test func testSetNetworkCueNumberPatch() throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        client.set_network_cue_number_patch(patch_value: "100")
        #expect(client.command_trace!.count == 1)
        #expect(client.command_trace!.last!.0 == String(format: SET_CUE_PARAMETER, CUE_NUMBER_NETWORK_KEY))
        #expect(client.command_trace!.last!.1.count == 1)
    }
    
    @Test func testSetMidiCueNumberPatch() throws {
        let client = Client()
        client.set_midi_cue_number_patch()
    }
    
    @Test func testMakeLxCue() throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        
        client.config.set_cue_type(CueType.MIDI)
        client.make_lx_cue(cue_number: "100")
        #expect(client.command_trace!.isEmpty)
        
        client.config.set_cue_type(CueType.NETWORK)
        client.make_lx_cue(cue_number: "100")
        #expect(client.command_trace!.count == 1)
        #expect(client.command_trace!.last!.0 == String(format: SET_CUE_PARAMETER, CUE_NUMBER_NETWORK_KEY))
        #expect(client.command_trace!.last!.1.count == 1)
    }
    
    @Test func testAttachFileTarget() throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        client.attach_file_target(file_path: "/path/to/file")
        #expect(client.command_trace!.count == 1)
        #expect(client.command_trace!.last!.0 == SET_CUE_FILE_TARGET)
        #expect(client.command_trace!.last!.1.count == 1)
    }
    
    @Test func testSetCueNumber() throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        client.set_cue_number(cue_number: "100")
        #expect(client.command_trace!.count == 1)
        #expect(client.command_trace!.last!.0 == SET_CUE_NUMBER)
        #expect(client.command_trace!.last!.1.count == 1)
    }
    
    @Test func testAddCue() async throws {
        let client = Client(keep_trace: true)
        #expect(client.command_trace!.isEmpty)
        
        let cue_basic = Cue(is_lx_cue: false, type: CueType.MIDI)
        client.add_cue(cue_basic)
        #expect(client.command_trace!.count == 2)
        client.command_trace?.removeAll()
        
        let cue_with_prewait = Cue(pre_wait_time: 100, is_lx_cue: false, type: CueType.MIDI)
        client.add_cue(cue_with_prewait)
        #expect(client.command_trace!.count == 3)
        client.command_trace?.removeAll()
        
        let cue_with_name = Cue(name: "cue_name", is_lx_cue: false, type: CueType.MIDI)
        client.add_cue(cue_with_name)
        #expect(client.command_trace!.count == 3)
        client.command_trace?.removeAll()
        
        let cue_with_file_path = Cue(is_lx_cue: false, file_path: "/path/to/file", type: CueType.MIDI)
        client.add_cue(cue_with_file_path)
        #expect(client.command_trace!.count == 3)
        client.command_trace?.removeAll()
        
        let cue_lx_midi = Cue(is_lx_cue: true, type: CueType.MIDI)
        client.config.cue_type = CueType.MIDI
        client.add_cue(cue_lx_midi)
        #expect(client.command_trace!.count == 2)
        client.command_trace?.removeAll()
        
        let cue_lx_network = Cue(is_lx_cue: true, type: CueType.NETWORK)
        client.config.cue_type = CueType.NETWORK
        client.add_cue(cue_lx_network)
        #expect(client.command_trace!.count == 3)
        client.command_trace?.removeAll()
        
        let cue_all = Cue(name: "cue_name", pre_wait_time: 100, is_lx_cue: true, file_path: "/path/to/file", type: CueType.NETWORK)
        client.config.cue_type = CueType.NETWORK
        client.add_cue(cue_all)
        #expect(client.command_trace!.count == 6)
    }
}
