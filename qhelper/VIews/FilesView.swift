//
//  FileView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/22/24.
//

import SwiftUI

struct FilesView: View {
    
    @ObservedObject var files: Files
    
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
        }
        .padding()
        
        Button("Add all to QLab") {
            let client = Client(port: DEFAULT_LISTENING_PORT, host: DEFAULT_HOST)
            client.connect_to_workspace(workspace: "3F05D2F2-7182-4A4F-8EA7-8754F46CB1AF")
            client.parse_cue_dict(cue_tables: files.get_all_cue_tables(), workspace: "3F05D2F2-7182-4A4F-8EA7-8754F46CB1AF")
            client.disconnect_from_workspace()
        }
        .padding()
    }
}
