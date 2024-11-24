//
//  ParserLogic.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/19/24.
//

import Foundation
import PythonKit

class Files: ObservableObject {
    @Published var files: [File] = []
    
    func add(file: File) {
        files.append(file)
    }
    
    func delete(uuid: UUID) {
        self.files = files.filter {$0.id != uuid}
    }
    
    func parseAll() {
        files.forEach {
            parseSheet(filename: $0.path)
        }
    }
}

struct File: Identifiable, Hashable {
    let path: String
    let name: String
    let id = UUID()
}

@discardableResult
func safeShell(_ command: String) throws -> String {
    let task = Process()
    let pipe = Pipe()
    
    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.executableURL = URL(fileURLWithPath: "/bin/zsh")
    task.standardInput = nil

    try task.run()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}
    
func parseSheet(filename: String) {
    
    do {
        try print(safeShell("cd /Users/lemanappazov/Desktop/Coding/Swift/qhelper/qhelper/Driver"))
    } catch {
        print("Cannot navigate to the Parser directory")
    }
    
    do {
        try print(safeShell("make"))
    } catch {
        print("Cannot make the Parser")
    }
    
    
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/local/bin/python3.11")
    guard let script = Bundle.main.path(forResource: "driver", ofType: "py") else {
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
