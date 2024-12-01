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
    @Environment(\.scenePhase) private var scenePhase
    let saveAction: ()->Void
    
    var body: some View {
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
                text: $config.port,
                prompt: Text("Required")
            ) {
                Text("Port")
            }
            .onSubmit {
                if validatePort(port: config.port) {
                    saveAction()
                } else {
                    self.config.port = DEFAULT_LISTENING_PORT
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
            
            Picker("Timed Cue Type", selection: $config.cue_type) {
                ForEach(CueType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .onChange(of: config.cue_type) {
                saveAction()
            }
            .padding()
        }
        .onChange(of: scenePhase) {
            if scenePhase == .inactive { saveAction() }
        }
        
        Text("Your changes are saved automatically!")
            .padding()
    }
}

#Preview {
    var config = UserConfiguration()
    SettingsView(config: config, saveAction: {})
}
