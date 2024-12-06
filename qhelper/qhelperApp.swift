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
    @State var isDisplayingAlert: Bool = false
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
                    .frame(width: WINDOW_WIDTH - PADDING, height: WINDOW_HEIGHT - PADDING)
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
                                        let parser = Parser(file_path: newFile.path, file_name: newFile.name)
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
                        fatalError(error.localizedDescription)
                    }
                }
            }
            .frame(width: WINDOW_WIDTH, height: WINDOW_HEIGHT)
            .preferredColorScheme(.dark)
        }
        .windowResizability(.contentSize)
    }
}
