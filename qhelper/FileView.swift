//
//  FileView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/22/24.
//

import SwiftUI

struct FileView: View {

    @ObservedObject var files: Files
    @State private var multiSelection = Set<UUID>()

    var body: some View {
        HStack{
            NavigationView {
                List(files.files, selection: $multiSelection) { file in
                    Text(file.name)
                        .contextMenu {
                            Button(action: {
                                files.delete(uuid: file.id)
                            }){
                                Text("Delete")
                            }
                        }
                }
            }
            Text("\(multiSelection.count) selections")
            
            Button("Process") {
                files.copyToTemp()
            }
        }
    }
}
