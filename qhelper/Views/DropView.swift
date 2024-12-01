//
//  DropView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/18/24.
//

import SwiftUI

struct DropView: View {
    @ObservedObject var files: Files
    @State var isDisplayingAlert: Bool = false
    
    var body: some View {
        @State var dropping: Bool = false
        
        VStack {
            Image(systemName: "lightbulb")
                .font(.system(size: 20))
                .foregroundStyle(.tint)
            Text("Drop your cue sheets here!")
                .font(.system(size: 16, weight: .bold))
            Text("\(files.files.count) sheets successfully added")
                .padding()
                .foregroundColor(.gray)
        }
        .padding()
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                let _ = provider.loadObject(ofClass: URL.self) { object, error in
                    if let url = object {
                        let newFile = File(path: url.path(percentEncoded: false), name: url.lastPathComponent)
                        if url.pathExtension != "xlsx" {
                            isDisplayingAlert = true
                            return
                        }
                        do {
                            var parser = Parser(file_path: newFile.path)
                            try parser.set_shared_strings()
                            newFile.cue_tables = try parser.parse_excel_file()
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

#Preview {
    DropView(files: Files(), isDisplayingAlert: false)
}
