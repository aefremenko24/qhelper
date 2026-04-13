//
//  qhelperApp.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/18/24.
//

import SwiftUI
import UniformTypeIdentifiers

@main
struct qhelperApp: App {
    @State var files: Files = Files()
    @State var invalidFileAlert: Bool = false
    @State var failedConfigLoadAlert: Bool = false
    @State var isDroppingFile: Bool = false
    @StateObject private var store: QHelperStore = QHelperStore()
    let connection: QLAbConnection = QLAbConnection()
    let client: Client
    let server: Server = Server()

    init() {
        client = Client(connection: connection)
        server.bind(to: connection)
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                MainView(files: files, config: store.config, client: client, server: server, connection: connection)
                    .tabItem {
                        HStack {
                            Image(systemName: "folder")
                            Text("Add Files")
                        }
                    }
                    .task {
                        do {
                            try await store.load()
                        } catch {
                            invalidFileAlert = true
                            store.config = UserConfiguration()
                        }
                    }
                    .frame(width: WINDOW_WIDTH - PADDING, height: WINDOW_HEIGHT - PADDING)
                    .border(Color.accentColor, width: isDroppingFile ? 1 : 0)
                    .background(Color.white.opacity(isDroppingFile ? 0.1 : 0))
                    .onDrop(of: [.fileURL], isTargeted: $isDroppingFile) { providers in
                        for provider in providers {
                            guard provider.canLoadObject(ofClass: URL.self) else { return false }
                        }

                        let group = DispatchGroup()
                        var droppedURLs: [URL] = []
                        let lock = NSLock()

                        for provider in providers {
                            group.enter()
                            let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                defer { group.leave() }
                                if let url = object {
                                    lock.lock()
                                    droppedURLs.append(url)
                                    lock.unlock()
                                }
                            }
                        }

                        group.notify(queue: .main) {
                            var xlsxURLs: [URL] = []
                            var audioURLs: [URL] = []
                            var hadInvalidFile = false
                            let fm = FileManager.default

                            for url in droppedURLs {
                                var isDir: ObjCBool = false
                                if fm.fileExists(atPath: url.path(percentEncoded: false), isDirectory: &isDir),
                                   isDir.boolValue {
                                    // Scan directory for xlsx and audio files
                                    if let enumerator = fm.enumerator(at: url, includingPropertiesForKeys: nil) {
                                        for case let fileURL as URL in enumerator {
                                            if fileURL.pathExtension.lowercased() == "xlsx" {
                                                xlsxURLs.append(fileURL)
                                            } else if let utType = UTType(filenameExtension: fileURL.pathExtension),
                                                      utType.conforms(to: .audio) {
                                                audioURLs.append(fileURL)
                                            }
                                        }
                                    }
                                } else if url.pathExtension.lowercased() == "xlsx" {
                                    xlsxURLs.append(url)
                                } else if let utType = UTType(filenameExtension: url.pathExtension),
                                          utType.conforms(to: .audio) {
                                    audioURLs.append(url)
                                } else {
                                    hadInvalidFile = true
                                }
                            }

                            for url in xlsxURLs {
                                let newFile = File(path: url.path(percentEncoded: false), name: url.lastPathComponent)
                                do {
                                    let parser = Parser(file_path: newFile.path, file_name: newFile.name)
                                    try parser.set_shared_strings()
                                    newFile.cue_tables = try parser.parse_excel_file()
                                    files.files.append(newFile)
                                } catch {
                                    hadInvalidFile = true
                                }
                            }

                            if !audioURLs.isEmpty {
                                let sorted = audioURLs.sorted {
                                    $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedAscending
                                }
                                let allCueTables = files.get_all_cue_tables()
                                for (index, audioURL) in sorted.enumerated() {
                                    if index >= allCueTables.count { break }
                                    allCueTables[index].audio_file = audioURL.path(percentEncoded: false)
                                }
                            }

                            if hadInvalidFile {
                                invalidFileAlert = true
                            }
                        }

                        return true
                    }
                    .alert(isPresented: $invalidFileAlert) { () -> Alert in
                        Alert(title: Text("Error Processing File"), message: Text("An error occurred while processing the file, make sure it is a valid and not corrupted cue sheet."), dismissButton: .cancel())
                    }
                SettingsView(config: store.config) {
                    Task {
                        do {
                            try await store.save(config: store.config)
                        } catch {
                            invalidFileAlert = true
                            store.config = UserConfiguration()
                        }
                    }
                }
                .tabItem {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                }
                .task {
                    do {
                        try await store.load()
                    } catch {
                        invalidFileAlert = true
                        store.config = UserConfiguration()
                    }
                }
                .alert(isPresented: $invalidFileAlert) { () -> Alert in
                    Alert(title: Text("Welcome to QHelper!"), message: Text("Adjust these settings to match your desired workflow, drop your cue sheets in the 'Add Files' tab, and hit 'Add all to QLab' to begin!"), dismissButton: .cancel(
                        Text("Got it")
                    ))
                }
            }
            .frame(width: WINDOW_WIDTH - PADDING, height: WINDOW_HEIGHT - PADDING)
            .preferredColorScheme(.dark)
            .padding(.vertical, PADDING)
            .padding(.horizontal, PADDING/2)
        }
        .windowResizability(.contentSize)
    }
}
