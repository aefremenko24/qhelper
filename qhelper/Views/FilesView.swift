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
    @State private var server_responses: [QLabResponse] = []
    
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
                
                Task {
                    for cue_group in cue_groups {
                        cue_group.update_unique_id(qlab_responses: self.server_responses)
                        client.move_cue_children(cue: cue_group)
                    }
                }
                
                self.server_responses.removeAll()
                client.num_cues_added = 0
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
        .onReceive(server.$messageReceived, perform: { message in
            if message != nil {
                self.server_responses.append(message!)
            }
        })
    }
}
