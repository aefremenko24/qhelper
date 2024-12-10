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
}

#Preview {
    var files: Files = Files()
    var config: UserConfiguration = UserConfiguration()
    FilesView(files: files, config: config)
}
