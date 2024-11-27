//
//  FileView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/22/24.
//

import SwiftUI

struct FilesView: View {
    
    @ObservedObject var files: Files
    
    var body: some View {
        ScrollView {
            DisclosureGroup(
                content: {
                    if !files.files.isEmpty {
                        ForEach(files.files) { file in
                            FileView(file: file)
                        }
                    }
                },
                label: {
                    Text("Your Excel Files")
                }
            )
        }
    }
}
