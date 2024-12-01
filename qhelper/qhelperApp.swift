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
    @StateObject private var store = QHelperStore()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Add Sheets", systemImage: "plus") {
                    DropView(files: files)
                }
                .badge(1)
                
                Tab("Preview", systemImage: "list.bullet.indent") {
                    FilesView(files: files, config: store.config)
                }
                .badge(2)
                
                Tab("Settings", systemImage: "gearshape") {
                    SettingsView(config: store.config) {
                        Task {
                            do {
                                try await store.save(config: store.config)
                            } catch {
                                fatalError(error.localizedDescription)
                            }
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
                .badge(2)
            }
            .frame(width: WINDOW_WIDTH, height: WINDOW_HEIGHT)
            .preferredColorScheme(.dark)
        }
        .windowResizability(.contentSize)
    }
}
