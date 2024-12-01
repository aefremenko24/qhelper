//
//  FileView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/22/24.
//

import SwiftUI

struct FilesView: View {
    
    @ObservedObject var files: Files
    @ObservedObject var config: UserConfiguration
    
    var body: some View {
        ScrollView {
            DisclosureGroup(
                content: {
                    if !files.files.isEmpty {
                        ForEach(files.files) { file in
                            FileView(file: file)
                        }
                    }
                },
                label: {
                    Text("Your Excel Files")
                }
            )
            .contextMenu(forSelectionType: String.self) { items in
                Button("Test") {}
            } primaryAction: { items in
                print(items)
            }
        }
        .padding()
        
        Button("Add all to QLab") {
            let client = Client()
            client.update_configuration(config: config)
            client.connect_to_workspace()
            client.parse_cue_dict(cue_tables: files.get_all_cue_tables())
            client.disconnect_from_workspace()
        }
        .buttonStyle(.borderedProminent)
        .padding()
    }
}

#Preview {
    var files: Files = Files()
    var config: UserConfiguration = UserConfiguration()
    FilesView(files: files, config: config)
}
