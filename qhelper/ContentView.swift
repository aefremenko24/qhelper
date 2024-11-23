//
//  ContentView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/18/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var files: Files
    
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
                        files.add(file: File(path: url.absoluteString, name: url.lastPathComponent))
                    }
                }
                return true
            }
            return false
        }
    }
}
