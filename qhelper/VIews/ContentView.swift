//
//  ContentView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/18/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var files: Files
    @State var isDisplayingAlert: Bool = false
    
    var body: some View {
        @State var dropping: Bool = false
        
        VStack {
            Image(systemName: "lightbulb")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Drop the cue sheet here!")
        }
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                let _ = provider.loadObject(ofClass: URL.self) { object, error in
                    if let url = object {
                        var newFile = File(path: url.path(percentEncoded: false), name: url.lastPathComponent)
                        if url.pathExtension != "xlsx" {
                            isDisplayingAlert = true
                            return
                        }
                        do {
                            newFile.cue_tables = try parse_excel_file(excel_file: newFile.path)
                            files.add(file: newFile)
                        } catch {
                            isDisplayingAlert = true
                        }
                        
                    }
                }
                return true
            }
            return false
        }
        .alert(isPresented: $isDisplayingAlert) { () -> Alert in
            Alert(title: Text("Error Processing File"), message: Text("An error occurred while processing the file, make sure it is a valid and not corrupted cue sheet."), dismissButton: .cancel())
        }
    }
}
