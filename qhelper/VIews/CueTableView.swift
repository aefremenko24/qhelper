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
    }
}
