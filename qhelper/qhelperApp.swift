//
//  qhelperApp.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/18/24.
//

import SwiftUI
import Python

@main
struct qhelperApp: App {
    Py_Initialize()
    
    @State var files: Files = Files()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Add Sheets", systemImage: "plus") {
                    ContentView(files: files)
                }
                .badge(1)

                Tab("Edit", systemImage: "pencil") {
                    FileView(files: files)
                }
                .badge(2)
            }
        }
        .windowResizability(.contentSize)
    }
}
