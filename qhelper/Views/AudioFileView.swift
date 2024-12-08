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
                .border(Color.green, width: highlighted ? 2 : 0)
            HStack {
                if (cue_table.audio_file == nil) {
                    Image(systemName: "plus")
                    Text("add audio file")
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
        .frame(height: 30)
    }
}
