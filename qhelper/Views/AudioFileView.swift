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
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white.opacity(highlighted ? 0.15 : 0.1))
                .frame(height: 40)
            HStack {
                if (cue_table.audio_file == nil) {
                    Image(systemName: "plus")
                        .font(.system(size: 12))
                    Text("Add or drop an audio file")
                        .font(Font.custom("HelveticaNeue", size: 14))
                }
                else {
                    Image(systemName: "waveform")
                        .font(.system(size: 12))
                    Text("\(get_file_name(file_path: cue_table.audio_file!))")
                        .font(Font.custom("HelveticaNeue", size: 14))
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
            let selected_file = open_file_dialog(allow_multiple_selection: false, can_choose_directories: false)
            if !selected_file.isEmpty {
                cue_table.audio_file = selected_file
            }
        }
    }
}
