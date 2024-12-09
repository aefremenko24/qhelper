//
//  AudioFileView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 12/7/24.
//

import SwiftUI

struct AudioFileView: View {
    @ObservedObject var cue_table: CueTable
    @State var highlighted: Bool = false
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 0.3245, green: 0.3245, blue: 0.3245))
                .border(Color(red: 0.45, green: 0.45, blue: 0.45), width: self.highlighted ? 4 : 2)
                .frame(height: 40)
            HStack {
                if (cue_table.audio_file == nil) {
                    Image(systemName: "plus")
                    Text("add or drop an audio file")
                        .font(.system(size: 15))
                }
                else {
                    Image(systemName: "music.note")
                    Text("\(get_file_name(file_path: cue_table.audio_file!))")
                        .font(.system(size: 15))
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 40, alignment: .leading)
        .onHover {
            self.highlighted = $0
        }
        .onTapGesture {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            if panel.runModal() == .OK {
                self.cue_table.audio_file = panel.url?.path(percentEncoded: false)
            }
        }
    }
}
