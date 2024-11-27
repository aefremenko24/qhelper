//
//  FileView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/22/24.
//

import SwiftUI

struct FileView: View {
    
    @State var file: File
    
    var body: some View {
        DisclosureGroup(
            content: {
                if !file.cue_tables.isEmpty {
                    ForEach(file.cue_tables) { table in
                        CueTableView(table: table)
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
