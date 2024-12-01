//
//  Config.swift
//  qhelper
//
//  Created by Arthur Efremenko on 11/30/24.
//

import Foundation

class UserConfiguration: ObservableObject, Codable {
    @Published var workspace: String
    @Published var host: String
    @Published var port: String
    @Published var passcode: String
    @Published var cue_type: CueType
    
    init() {
        self.workspace = DEFAULT_WORKSPACE_NAME
        self.host = DEFAULT_HOST
        self.port = DEFAULT_LISTENING_PORT
        self.passcode = DEFAULT_PASSCODE
        self.cue_type = CueType.MIDI
    }
    
    func set_workspace(_ workspace: String) {
        self.workspace = workspace
    }
    
    func set_host(_ host: String) {
        self.host = host
    }
    
    func set_port(_ port: String) {
        self.port = port
    }
    
    func set_passcode(_ passcode: String) {
        self.passcode = passcode
    }
    
    func set_cue_type(_ cue_type: CueType) {
        self.cue_type = cue_type
    }
    
    enum ConfigKeys: CodingKey {
        case workspace
        case host
        case port
        case passcode
        case cue_type
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: ConfigKeys.self)
        workspace = try values.decode(String.self, forKey: .workspace)
        host = try values.decode(String.self, forKey: .host)
        port = try values.decode(String.self, forKey: .port)
        passcode = try values.decode(String.self, forKey: .passcode)
        cue_type = try values.decode(CueType.self, forKey: .cue_type)
    }
    
    public func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: ConfigKeys.self)
        try values.encode(workspace, forKey: .workspace)
        try values.encode(host, forKey: .host)
        try values.encode(port, forKey: .port)
        try values.encode(passcode, forKey: .passcode)
        try values.encode(cue_type, forKey: .cue_type)
    }
}

@MainActor
class QHelperStore: ObservableObject {
    @Published var config: UserConfiguration = UserConfiguration()
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("qhelper.data")
    }
    
    func load() async throws {
        let task = Task<UserConfiguration, Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return UserConfiguration()
            }
            let dailyScrums = try JSONDecoder().decode(UserConfiguration.self, from: data)
            return dailyScrums
        }
        let config = try await task.value
        self.config = config
    }
    
    func save(config: UserConfiguration) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(config)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
}
