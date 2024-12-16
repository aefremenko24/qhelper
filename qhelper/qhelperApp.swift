//
//  qhelperApp.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/18/24.
//

import SwiftUI

@main
struct qhelperApp: App {
    @State var files: Files = Files()
    @State var invalidFileAlert: Bool = false
    @State var failedConfigLoadAlert: Bool = false
    @State var isDroppingFile: Bool = false
    @StateObject private var store: QHelperStore = QHelperStore()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                MainView(files: files, config: store.config)
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
                            if provider.canLoadObject(ofClass: URL.self) {
                                let _ = provider.loadObject(ofClass: URL.self) { object, error in
                                    if let url = object {
                                        let newFile = File(path: url.path(percentEncoded: false), name: url.lastPathComponent)
                                        if url.pathExtension != "xlsx" {
                                            invalidFileAlert = true
                                            return
                                        }
                                        do {
                                            let parser = Parser(file_path: newFile.path, file_name: newFile.name)
                                            try parser.set_shared_strings()
                                            newFile.cue_tables = try parser.parse_excel_file()
                                            files.add(file: newFile)
                                        } catch {
                                            invalidFileAlert = true
                                        }
                                        
                                    }
                                }
                            } else {
                                return false
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
                            fatalError(error.localizedDescription)
                        }
                    }
                }
                .frame(width: WINDOW_WIDTH - PADDING, height: WINDOW_HEIGHT - PADDING)
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
