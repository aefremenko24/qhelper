//
//  FileView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/22/24.
//

import SwiftUI

struct CueTableView: View {
    
    @State var table: CueTable
    
    var body: some View {
        DisclosureGroup(
            content: {
                AudioFileView(cue_table: table)
                    .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                        if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                if let url = object {
                                    do {
                                        table.audio_file = url.path(percentEncoded: false)
                                    }
                                    
                                }
                            }
                            return true
                        }
                        return false
                    }
                    .frame(height: 20, alignment: .leading)
                if !table.times.isEmpty {
                    ForEach(table.times) { time in
                        Text(time.asString)
                            .foregroundColor(.primary)
                            .font(.headline)
                            .padding(.leading, 30)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            },
            label: {
                VStack(alignment: .leading, spacing: 3) {
                    Text(table.name)
                        .foregroundColor(.primary)
                        .font(.headline)
                    HStack(spacing: 3) {
                        Label(String(table.times.count) + " cues", systemImage: "list.bullet.indent")
                    }
                    .foregroundColor(.secondary)
                    .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }
}
