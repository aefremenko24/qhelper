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
    @State private var isSending: Bool = false

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
                isSending = true
                server.resetResponseCollection()
                client.update_configuration(config: config)
                client.connect_to_workspace(passcode_string: config.passcode)
                let cue_groups = client.send_cue_tables(cue_tables: files.get_all_cue_tables())
                let expectedCount = client.num_cues_added

                Task {
                    let responses = await server.waitForResponses(count: expectedCount)

                    for cue_group in cue_groups {
                        cue_group.update_unique_id(qlab_responses: responses)
                        client.move_cue_children(cue: cue_group)
                    }

                    client.num_cues_added = 0
                    client.save_to_disk()
                    isSending = false
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top)
            .disabled(isSending)

            Button("Clear all files") {
                files.files.removeAll()
            }
            .buttonStyle(.borderless)
        }
    }
}
