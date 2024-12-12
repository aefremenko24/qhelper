//
//  SettingsView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/30/24.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var config: UserConfiguration
    @State private var selectedCueType: CueType = .MIDI
    @State private var showAdvancedSettings: Bool = false
    @Environment(\.scenePhase) private var scenePhase
    let saveAction: ()->Void
    
    var body: some View {
        VStack {
            Text("QLab Parameters")
                .font(.system(size: 20, weight: .bold))
                .padding()
            
            Form {
                TextField(
                    text: $config.workspace,
                    prompt: Text("Required")
                ) {
                    Text("Workspace Name")
                }
                .onSubmit {
                    if validateWorkspace(workspace: config.workspace) {
                        saveAction()
                    } else {
                        self.config.workspace = ""
                    }
                }
                .disableAutocorrection(true)
                .padding()
                
                Picker("Timed Cue Type", selection: $config.cue_type) {
                    ForEach(CueType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .onChange(of: config.cue_type) { _ in
                    saveAction()
                }
                .padding()
                
                Toggle(isOn: $config.include_blackout_cue) {
                    Text("Blackout cues before cue groups")
                    if config.include_blackout_cue {
                        Text("Will include a blackout cue before each cue group")
                    } else {
                        Text("Will include a blackout cue inside each cue group")
                    }
                    
                }
                .onChange(of: config.include_blackout_cue) { _ in
                    saveAction()
                }
                
                DisclosureGroup(
                    isExpanded: $showAdvancedSettings,
                    content: {
                        TextField(
                            text: $config.host,
                            prompt: Text("Required")
                        ) {
                            Text("Host")
                        }
                        .onSubmit {
                            if validateHost(host: config.host) {
                                saveAction()
                            } else {
                                self.config.host = DEFAULT_HOST
                            }
                        }
                        .disableAutocorrection(true)
                        .padding()
                        
                        TextField(
                            text: $config.send_port,
                            prompt: Text("Required")
                        ) {
                            Text("Port")
                        }
                        .onSubmit {
                            if validatePort(port: config.send_port) {
                                saveAction()
                            } else {
                                self.config.send_port = DEFAULT_LISTENING_PORT
                            }
                        }
                        .disableAutocorrection(true)
                        .padding()
                        
                        SecureField(
                            text: $config.passcode,
                            prompt: Text("Optional")
                        ) {
                            Text("Passcode")
                        }
                        .onSubmit {
                            if validatePassCode(passcode: config.passcode) {
                                saveAction()
                            } else {
                                self.config.passcode = ""
                            }
                        }
                        .disableAutocorrection(true)
                        .padding()
                    },
                    label: {
                        Text("Advanced Settings")
                    }
                )
            }
            .onChange(of: scenePhase) { phase in
                if phase == .inactive { saveAction() }
            }
            
            Text("Your changes are saved automatically!")
                .padding()
        }
    }
}

#Preview {
    var config = UserConfiguration()
    SettingsView(config: config, saveAction: {})
}
