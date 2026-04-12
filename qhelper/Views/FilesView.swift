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
    var connection: QLAbConnection
    @State private var isSending: Bool = false

    var body: some View {
        ZStack {
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
                    let cueTables = files.get_all_cue_tables()

                    Task.detached { [client, server, config, connection] in
                        client.update_configuration(config: config)

                        // Establish the TCP connection to QLab
                        do {
                            try await connection.connect(
                                host: config.host,
                                port: UInt16(config.send_port) ?? 53000
                            )
                        } catch {
                            print("TCP connection error: \(error)")
                            await MainActor.run { isSending = false }
                            return
                        }

                        client.connect_to_workspace(passcode_string: config.passcode)
                        let cue_groups = client.send_cue_tables(cue_tables: cueTables)
                        let expectedCount = client.num_cues_added

                        let responses = await server.waitForResponses(count: expectedCount)

                        for cue_group in cue_groups {
                            cue_group.update_unique_id(qlab_responses: responses)
                            client.move_cue_children(cue: cue_group)
                        }

                        client.num_cues_added = 0
                        client.save_to_disk()
                        client.disconnect_from_workspace()
                        connection.disconnect()

                        await MainActor.run {
                            isSending = false
                        }
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

            if isSending {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                ProgressView("Adding cues to QLab...")
                    .controlSize(.large)
                    .padding(24)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}
