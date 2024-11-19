//
//  ContentView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/18/24.
//

import SwiftUI

func parseSheet(filename: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/local/bin/python3.11")
    guard let script = Bundle.main.path(forResource: "parser", ofType: "py") else {
        fatalError("Couldn't find script")
    }
    task.arguments = [script, filename]
    let outputPipe = Pipe()
    task.standardOutput = outputPipe
    
       do{
           try task.run()
       } catch {
           print("Error running the task:", error)
       }
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(decoding: outputData, as: UTF8.self)
    print(output)
   }

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
