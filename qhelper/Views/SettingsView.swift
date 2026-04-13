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
    
    @State var presentWorkspaceNamePopover = false
    @State var presentCueTypePopover = false
    @State var presentBlackoutCuesPopover = false
    @State var presentAdvancedSettingsPopover = false
    
    var body: some View {
        VStack {
            Text("QLab Parameters")
                .font(.system(size: 20, weight: .bold))
                .padding()
            
            Form {
                HStack (spacing: 0) {
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
                    
                    Button {
                        presentWorkspaceNamePopover = true
                    }
                    label: {
                        Image(systemName: "questionmark.circle")
                            .popover(
                                isPresented: $presentWorkspaceNamePopover, arrowEdge: .leading
                            ) {
                                Text("""
                                     Workspace name may be either the 
                                     display name of the workspace, such as 
                                     'NUDANCO_Showcase', or the unique ID of 
                                     the workspace, which can be found in the 
                                     Info tab of the Workspace Status Window.
                                    """)
                                .padding()
                            }
                    }
                    .buttonStyle(.borderless)
                }
                
                HStack (spacing: 0) {
                    Picker("Timed Cue Type", selection: $config.cue_type) {
                        Text("MIDI")
                            .tag(CueType.MIDI)
                        Text("Network")
                            .tag(CueType.NETWORK)
                    }
                    .onChange(of: config.cue_type) { _ in
                        saveAction()
                    }
                    .padding()
                    .pickerStyle(.segmented)
                    
                    Button {
                        presentCueTypePopover = true
                    }
                    label: {
                        Image(systemName: "questionmark.circle")
                            .popover(
                                isPresented: $presentCueTypePopover, arrowEdge: .leading
                            ) {
                                Text("""
                                     Use MIDI in Blackman Auditorium
                                     and Network in Fenway Center.
                                    """)
                                    .padding()
                            }
                    }
                    .buttonStyle(.borderless)
                }
                
                HStack {
                    Toggle(isOn: $config.bring_out_blackout) {
                        Text("Blackout cues before cue groups")
                        if config.bring_out_blackout {
                            Text("Will include a blackout cue before each cue group")
                        } else {
                            Text("Will include a blackout cue inside each cue group")
                        }
                        
                    }
                    .padding()
                    .onChange(of: config.bring_out_blackout) { _ in
                        saveAction()
                    }
                    
                    Button {
                        presentBlackoutCuesPopover = true
                    }
                    label: {
                        Image(systemName: "questionmark.circle")
                            .popover(
                                isPresented: $presentBlackoutCuesPopover, arrowEdge: .top
                            ) {
                                Text("""
                                     Ask the ligting person working the shift!
                                     If checked, the blackout cue will be added
                                     before each cue group and will not be timed.
                                     If not checked, the blackout cue will be 
                                     included in the beginning of each group and 
                                     will have a default time of 0.01s.
                                    """)
                                    .padding()
                            }
                    }
                    .buttonStyle(.borderless)
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
                        HStack {
                            Text("Advanced Settings")

                            Button {
                                presentAdvancedSettingsPopover = true
                            }
                            label: {
                                Image(systemName: "questionmark.circle")
                                    .popover(
                                        isPresented: $presentAdvancedSettingsPopover, arrowEdge: .trailing
                                    ) {
                                        Text("""
                                            If cues don't get added to QLab,
                                            make sure these settings match
                                            the parameters set in the Network
                                            tab in the QLab Settings.
                                            """)
                                            .padding()
                                    }
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                )
                .padding()
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .onChange(of: scenePhase) { phase in
                if phase == .inactive { saveAction() }
            }
            
            Text("Your changes are saved automatically!")
                .padding()
        }
    }
}

#Preview {
    SettingsView(config: UserConfiguration()) {
        Task {}
    }
    .frame(width: WINDOW_WIDTH - PADDING, height: WINDOW_HEIGHT - PADDING)
}
