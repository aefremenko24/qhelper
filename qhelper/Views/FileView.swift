//
//  FileView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/22/24.
//

import SwiftUI

struct FileView: View {
    
    @ObservedObject var file: File
    @State var isExpanded: Bool = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                ForEach($file.cue_tables, id: \.self) { $table in
                    HStack {
                        CueTableView(table: table)
                            .padding(.leading, 20)
                            .contextMenu {
                                Button(action: {
                                    file.delete(uuid: table.id)
                                }){
                                    Text("Delete Cue Group")
                                }
                            }
                    }
                }
            },
            label: {
                VStack(alignment: .leading, spacing: 3) {
                    Text(file.name)
                        .foregroundColor(.primary)
                        .font(.headline)
                    HStack(spacing: 3) {
                        Label("Number of cue groups: " + String(file.cue_tables.count), systemImage: "list.bullet.indent")
                    }
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                }
            }
        )
    }
}
