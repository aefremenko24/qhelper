//
//  ParserLogic.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/19/24.
//

import Foundation

func secureCopyItem(at srcURL: URL, to dstURL: URL) -> Bool {
    do {
        if FileManager.default.fileExists(atPath: dstURL.path) {
            try FileManager.default.removeItem(at: dstURL)
        }
        try FileManager.default.copyItem(at: srcURL, to: dstURL)
    } catch (let error) {
        print("Cannot copy item at \(srcURL) to \(dstURL): \(error)")
        return false
    }
    return true
}

class Files: ObservableObject {
    @Published var files: [File] = []
    
    func add(file: File) {
        files.append(file)
    }
    
    func delete(uuid: UUID) {
        self.files = files.filter {$0.id != uuid}
    }
    
    func copyToTemp() {
        for file in files {
            let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(file.name)
            secureCopyItem(at: URL(fileURLWithPath: file.path), to: tempURL)
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
        try print(safeShell("cd /Users/lemanappazov/Desktop/Coding/Swift/qhelper/qhelper/Parser"))
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
