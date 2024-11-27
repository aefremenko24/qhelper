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
        ScrollView {
            DisclosureGroup(
                content: {
                    if !table.times.isEmpty {
                        ForEach(table.times) { time in
                            Text(String(time.asString))
                        }
                    }
                },
                label: {
                    Text(table.name)
                }
            )
        }
    }
}
