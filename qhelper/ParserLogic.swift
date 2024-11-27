//
//  ParserLogic.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/19/24.
//

import Foundation

class Files: ObservableObject {
    @Published var files: [File] = []
    
    func add(file: File) {
        files.append(file)
    }
    
    func delete(uuid: UUID) {
        self.files = files.filter {$0.id != uuid}
    }
}

class File: Identifiable, ObservableObject {
    init(path: String, name: String) {
        self.path = path
        self.name = name
    }
    
    let path: String
    let name: String
    let id = UUID()
    var is_expanded: Bool = false
    var cue_tables: [CueTable] = []
}
