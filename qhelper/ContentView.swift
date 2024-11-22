//
//  ContentView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/18/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        @State var dropping: Bool = false
        @State var files: [String] = []
        VStack {
            Image(systemName: "lightbulb")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Drop the cue sheet here!")
        }
        .padding()
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                let _ = provider.loadObject(ofClass: URL.self) { object, error in
                    if let url = object {
                        print("url: \(url.absoluteString)")
                        parseSheet(filename: url.absoluteString)
                    }
                }
                return true
            }
            return false
        }
    }
}

#Preview {
    ContentView()
}
