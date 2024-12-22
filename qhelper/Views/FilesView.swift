//
//  FileView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/22/24.
//

import SwiftUI

@MainActor
struct FilesView: View {
    @ObservedObject var files: Files
    @ObservedObject var config: UserConfiguration
    var client: Client
    var server: Server
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach($files.files) { $file in
                    FileView(file: file)
                        .contextMenu {
                            Button(action: {
                                files.delete(uuid: file.id)
                            }){
                                Text("Delete File")
                            }
                        }
                    Divider()
                }

                Text("Add more sheets by dragging them here")
                    .font(.headline)
                    .foregroundColor(Color.gray)
                    .fontWeight(.medium)
            }
            .padding()
            
            Button("Add all to QLab") {
                client.update_configuration(config: config)
                client.connect_to_workspace(passcode_string: config.passcode)
                let cue_groups = client.send_cue_tables(cue_tables: files.get_all_cue_tables())
                client.disconnect_from_workspace()
                
                let qlab_responses = server.messagesReceived
                client.move_cues_to_groups(cue_groups: cue_groups, qlab_responses: qlab_responses)
                server.messagesReceived.removeAll()
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

#Preview {
    let files: Files = Files()
    let config: UserConfiguration = UserConfiguration()
    FilesView(files: files, config: config, client: Client(), server: Server(port: DEFAULT_RESPONSE_PORT))
}
