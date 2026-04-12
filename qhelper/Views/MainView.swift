//
//  MainView.swift
//  qhelper
//
//  Created by Arthur Efremenko on 12/2/24.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var files: Files
    @ObservedObject var config: UserConfiguration
    @State var isDisplayingAlert: Bool = false
    
    var client: Client
    var server: Server
    var connection: QLAbConnection

    var body: some View {
        if files.files.isEmpty {
            DropView()
        } else {
            FilesView(files: files, config: config, client: client, server: server, connection: connection)
        }
    }
}
