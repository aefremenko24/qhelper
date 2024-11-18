//
//  ContentView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/18/24.
//

import SwiftUI

func shellEnv(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-cl", command]
    task.launchPath = "/bin/zsh"
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}

struct ContentView: View {
    var body: some View {
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
                        print("url: \(url)")
                        let url = String(url.absoluteString)
                        print(shellEnv(String(format: "qhelper/Parser/parser.py %s", url)))
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
