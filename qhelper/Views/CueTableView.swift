//
//  FileView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/22/24.
//

import SwiftUI
import CoreXLSX

struct CueTableView: View {
    
    @State var table: CueTable
    @State var isDroppingFile: Bool = false
    @State var isExpanded: Bool = false
    
    var body: some View {
        ZStack {
            DisclosureGroup(
                isExpanded: $isExpanded,
                content: {
                    AudioFileView(cue_table: table)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 7)
                    if !table.times.isEmpty {
                        ForEach(table.times) { time in
                            Text(time.asString)
                                .foregroundColor(.primary)
                                .font(.headline)
                                .padding(.leading, 20)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                },
                label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(table.name)
                                .foregroundColor(.primary)
                                .font(.headline)
                            HStack(spacing: 6) {
                                let num_cues = table.times.count
                                Label(String(num_cues) + (num_cues == 1 ? " cue" : " cues"), systemImage: "list.bullet.indent")
                                if !isExpanded {
                                    Text("[" + (table.audio_file == nil ? "No audio file" : get_file_name(file_path: table.audio_file!)) + "]")
                                }
                            }
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        TextField("Start at #", text: $table.start_at_index)
                            .frame(width: 70)
                            .padding(.horizontal, 20)
                    }
                }
            )
            
            if isDroppingFile {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.20))
                    .background(.ultraThinMaterial.opacity(0.80))
                    .border(Color.primary, width: 1)
                Text("Add audio file")
                    .bold()
            }
        }
        .frame(maxWidth: .infinity)
        .onDrop(of: [.fileURL], isTargeted: $isDroppingFile) { providers in
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
    }
}
