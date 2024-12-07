//
//  AudioFileView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 12/7/24.
//

import SwiftUI

struct AudioFileView: View {
    @ObservedObject var cue_table: CueTable
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.gray)
            HStack {
                if (cue_table.audio_file == nil) {
                    Image(systemName: "plus")
                    Text("add audio file")
                }
                else {
                    Image(systemName: "music.note")
                    Text("\(cue_table.audio_file!)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 20)
    }
}
