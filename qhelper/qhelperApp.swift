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
    @State var viewSelection: ViewSelection = .DropView
    
    var body: some Scene {
        WindowGroup {
            VStack {
                HStack {
                    Button("Add Files") {
                        viewSelection = .DropView
                    }
                    .background(viewSelection == .DropView ? Color.red : Color.clear)
                    
                    Button("Preview Cues") {
                        viewSelection = .FilesView
                    }
                    .background(viewSelection == .FilesView ? Color.red : Color.clear)
                    
                    Button("Settings") {
                        viewSelection = .SettingsView
                    }
                    .background(viewSelection == .SettingsView ? Color.red : Color.clear)
                }
                .padding()
                if viewSelection == ViewSelection.DropView {
                    DropView(files: files)
                } else if viewSelection == ViewSelection.FilesView {
                    FilesView(files: files, config: store.config)
                } else if viewSelection == ViewSelection.SettingsView {
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
            }
            .frame(width: WINDOW_WIDTH, height: WINDOW_HEIGHT)
            .preferredColorScheme(.dark)
        }
        .windowResizability(.contentSize)
    }
}
