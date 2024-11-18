//
//  ContentView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/18/24.
//

import SwiftUI

func parseSheet(filename: String) {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/python")
    let script = Bundle.main.path(forResource: "eject", ofType: "py")
    task.arguments = [script!, filename]
    let outputPipe = Pipe()
    task.standardOutput = outputPipe
    
       do{
           try task.run()
       } catch {
           print("error")
       }
    
    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(decoding: outputData, as: UTF8.self)
    print(output)
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
                        parseSheet(filename: url)
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
